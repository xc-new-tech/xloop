import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/widgets/adaptive_layout.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/import_export_entity.dart';
import '../bloc/import_export_bloc.dart';
import '../widgets/task_list_widget.dart';
import '../widgets/import_export_fab.dart';
import '../widgets/task_progress_widget.dart';

class DataImportExportPage extends StatefulWidget {
  const DataImportExportPage({super.key});

  @override
  State<DataImportExportPage> createState() => _DataImportExportPageState();
}

class _DataImportExportPageState extends State<DataImportExportPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // 加载任务列表
    context.read<ImportExportBloc>().add(LoadTasksEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: const Text('数据导入导出'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ImportExportBloc>().add(LoadTasksEvent());
            },
          ),
        ],
      ),
      body: BlocListener<ImportExportBloc, ImportExportState>(
        listener: (context, state) {
          if (state is ImportExportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is TaskCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('任务创建成功'),
                backgroundColor: Colors.green,
              ),
            );
            // 重新加载任务列表
            context.read<ImportExportBloc>().add(LoadTasksEvent());
          }
        },
        child: Column(
          children: [
            // Tab Bar
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '任务列表'),
                  Tab(text: '导出'),
                  Tab(text: '导入'),
                  Tab(text: '备份'),
                ],
              ),
            ),
            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTaskListTab(),
                  _buildExportTab(),
                  _buildImportTab(),
                  _buildBackupTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ImportExportFab(
        onExport: () => _tabController.animateTo(1),
        onImport: () => _tabController.animateTo(2),
        onBackup: () => _tabController.animateTo(3),
      ),
    );
  }

  Widget _buildTaskListTab() {
    return const TaskListWidget();
  }

  Widget _buildExportTab() {
    return Padding(
      padding: ResponsiveUtils.getAdaptivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择要导出的数据类型',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: GridView.count(
              crossAxisCount: ResponsiveUtils.isTablet(context) ? 3 : 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              children: [
                _buildDataTypeCard(
                  context,
                  'FAQ',
                  Icons.quiz,
                  DataType.faq,
                ),
                _buildDataTypeCard(
                  context,
                  '知识库',
                  Icons.library_books,
                  DataType.knowledgeBase,
                ),
                _buildDataTypeCard(
                  context,
                  '文档',
                  Icons.description,
                  DataType.documents,
                ),
                _buildDataTypeCard(
                  context,
                  '对话',
                  Icons.chat,
                  DataType.conversations,
                ),
                _buildDataTypeCard(
                  context,
                  '用户设置',
                  Icons.settings,
                  DataType.userSettings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportTab() {
    return Padding(
      padding: ResponsiveUtils.getAdaptivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择要导入的文件',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16.h),
          // 文件选择区域
          Container(
            width: double.infinity,
            height: 200.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: 16.h),
                Text(
                  '点击或拖拽文件到此处',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 8.h),
                Text(
                  '支持 CSV, Excel, JSON 格式',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupTab() {
    return Padding(
      padding: ResponsiveUtils.getAdaptivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '备份与恢复',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _createBackup,
                  icon: const Icon(Icons.backup),
                  label: const Text('创建备份'),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _restoreBackup,
                  icon: const Icon(Icons.restore),
                  label: const Text('恢复备份'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTypeCard(
    BuildContext context,
    String title,
    IconData icon,
    DataType dataType,
  ) {
    return Card(
      child: InkWell(
        onTap: () => _showExportDialog(context, dataType),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, DataType dataType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择导出格式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ExportFormat.values.map((format) {
            return ListTile(
              title: Text(format.name.toUpperCase()),
              onTap: () {
                Navigator.of(context).pop();
                _createExportTask(dataType, format);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _createExportTask(DataType dataType, ExportFormat format) {
    context.read<ImportExportBloc>().add(
      CreateExportTaskEvent(
        name: '${dataType.name}_export_${DateTime.now().millisecondsSinceEpoch}',
        dataType: dataType,
        format: format,
      ),
    );
  }

  void _createBackup() {
    context.read<ImportExportBloc>().add(
      CreateBackupEvent(
        name: 'backup_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
  }

  void _restoreBackup() {
    // TODO: 实现文件选择和恢复逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('恢复功能开发中')),
    );
  }
} 