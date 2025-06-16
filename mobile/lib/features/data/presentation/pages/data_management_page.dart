import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 数据管理页面
/// 
/// 提供数据导入导出、备份管理、操作日志等功能
class DataManagementPage extends StatefulWidget {
  const DataManagementPage({super.key});

  @override
  State<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends State<DataManagementPage> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '数据管理',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          // 添加到新的数据导入导出页面的快捷入口
          IconButton(
            icon: const Icon(Icons.import_export),
            tooltip: '高级导入导出',
            onPressed: () => context.go('/data-import-export'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '导入导出'),
            Tab(text: '备份管理'),
            Tab(text: '操作日志'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ImportExportTab(),
          _BackupManagementTab(),
          _OperationLogsTab(),
        ],
      ),
    );
  }
}

/// 导入导出标签页
class _ImportExportTab extends StatelessWidget {
  const _ImportExportTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 添加高级导入导出功能的卡片
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: () => context.go('/data-import-export'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.import_export,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '高级导入导出',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '功能完整的数据导入导出工具，支持多种格式、任务管理、进度跟踪和备份恢复',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildFeatureChip('CSV/Excel'),
                            const SizedBox(width: 8),
                            _buildFeatureChip('任务管理'),
                            const SizedBox(width: 8),
                            _buildFeatureChip('备份恢复'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        _buildSection(
          context,
          title: '数据导入',
          icon: Icons.upload_file,
          iconColor: AppColors.success,
          children: [
            _buildActionCard(
              context,
              icon: Icons.library_books,
              title: '导入知识库',
              subtitle: '从JSON、CSV或Excel文件导入知识库数据',
              onTap: () => _showImportDialog(context, '知识库'),
            ),
            _buildActionCard(
              context,
              icon: Icons.quiz,
              title: '导入FAQ',
              subtitle: '批量导入FAQ问答对',
              onTap: () => _showImportDialog(context, 'FAQ'),
            ),
            _buildActionCard(
              context,
              icon: Icons.people,
              title: '导入用户数据',
              subtitle: '导入用户配置和偏好设置',
              onTap: () => _showImportDialog(context, '用户数据'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          context,
          title: '数据导出',
          icon: Icons.download,
          iconColor: AppColors.primary,
          children: [
            _buildActionCard(
              context,
              icon: Icons.archive,
              title: '导出所有数据',
              subtitle: '完整的系统数据备份导出',
              onTap: () => _showExportDialog(context, '所有数据'),
            ),
            _buildActionCard(
              context,
              icon: Icons.folder_copy,
              title: '导出知识库',
              subtitle: '按知识库导出相关数据',
              onTap: () => _showExportDialog(context, '知识库'),
            ),
            _buildActionCard(
              context,
              icon: Icons.history,
              title: '导出操作日志',
              subtitle: '导出系统操作和审计日志',
              onTap: () => _showExportDialog(context, '操作日志'),
            ),
          ],
        ),
      ],
    );
  }

  void _showImportDialog(BuildContext context, String dataType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('导入$dataType'),
        content: const Text('请选择要导入的文件'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('正在导入$dataType...')),
              );
            },
            child: const Text('选择文件'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, String dataType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('导出$dataType'),
        content: const Text('确定要导出数据吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('正在导出$dataType...')),
              );
            },
            child: const Text('开始导出'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// 备份管理标签页
class _BackupManagementTab extends StatelessWidget {
  const _BackupManagementTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSection(
          context,
          title: '自动备份',
          icon: Icons.schedule,
          iconColor: AppColors.primary,
          children: [
            Card(
              elevation: 0,
              color: AppColors.surface,
              child: SwitchListTile(
                title: const Text('启用自动备份'),
                subtitle: const Text('每日自动创建数据备份'),
                value: true,
                onChanged: (value) {},
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          context,
          title: '手动备份',
          icon: Icons.backup,
          iconColor: AppColors.warning,
          children: [
            _buildActionCard(
              context,
              icon: Icons.save,
              title: '立即创建备份',
              subtitle: '创建当前系统状态的完整备份',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('正在创建备份...')),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          context,
          title: '备份历史',
          icon: Icons.history,
          iconColor: AppColors.onSurfaceVariant,
          children: List.generate(5, (index) {
            final date = DateTime.now().subtract(Duration(days: index));
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              elevation: 0,
              color: AppColors.surface,
              child: ListTile(
                leading: Icon(Icons.archive, color: AppColors.primary),
                title: Text('备份 ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'),
                subtitle: Text('${(15.6 + index * 2.3).toStringAsFixed(1)} MB'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _showRestoreDialog(context, date),
                      icon: const Icon(Icons.restore),
                      color: AppColors.success,
                      tooltip: '恢复备份',
                    ),
                    IconButton(
                      onPressed: () => _showDeleteDialog(context, date),
                      icon: const Icon(Icons.delete),
                      color: AppColors.error,
                      tooltip: '删除备份',
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showRestoreDialog(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认恢复'),
        content: Text('确定要恢复到 ${date.toString().split(' ')[0]} 的备份吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('正在恢复备份...')),
              );
            },
            child: const Text('确认恢复'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 ${date.toString().split(' ')[0]} 的备份吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('备份已删除')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 操作日志标签页
class _OperationLogsTab extends StatelessWidget {
  const _OperationLogsTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 搜索栏
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(
                color: AppColors.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索日志...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, 
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_list),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
        // 日志列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: 20,
            itemBuilder: (context, index) {
              final timestamp = DateTime.now().subtract(
                Duration(hours: index, minutes: index * 15),
              );
              return _buildLogTile(context, index, timestamp);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLogTile(BuildContext context, int index, DateTime timestamp) {
    final actions = ['创建知识库', '上传文件', '编辑FAQ', '删除数据', '用户登录'];
    final details = [
      '创建了新的知识库 "技术文档"',
      '上传文件 "API接口文档.pdf"',
      '编辑FAQ "如何重置密码？"',
      '删除了过期的文档数据',
      '用户成功登录系统',
    ];
    final colors = [AppColors.primary, AppColors.success, AppColors.warning, AppColors.error, AppColors.tertiary];
    final icons = [Icons.add, Icons.upload, Icons.edit, Icons.delete, Icons.login];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: AppColors.surface,
      child: ListTile(
        leading: Icon(
          icons[index % icons.length], 
          color: colors[index % colors.length],
          size: 20,
        ),
        title: Row(
          children: [
            Text(
              actions[index % actions.length],
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(details[index % details.length]),
            const SizedBox(height: 2),
            Text(
              '操作者: 用户${index + 1}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

// Helper Functions

Widget _buildSection(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Color iconColor,
  required List<Widget> children,
}) {
  return Card(
    elevation: 0,
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    ),
  );
}

Widget _buildActionCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 4),
    elevation: 0,
    color: AppColors.background,
    child: ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: Text(subtitle, style: AppTextStyles.bodyMedium),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
} 