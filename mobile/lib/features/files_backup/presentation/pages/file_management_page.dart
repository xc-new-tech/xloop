import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../bloc/file_event.dart';
import '../bloc/file_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/base_page.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../bloc/file_bloc.dart';
import '../widgets/file_upload_widget.dart';
import '../widgets/file_list_widget.dart';
import '../widgets/file_preview_widget.dart';
import '../../domain/entities/file_entity.dart' as entity;
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/file_constants.dart';
import '../../../../features/shared/presentation/widgets/custom_app_bar.dart';
import '../../../../features/shared/presentation/widgets/loading_widget.dart';
import '../../../../features/shared/presentation/widgets/error_widget.dart';

/// 文件管理页面
class FileManagementPage extends StatefulWidget {
  final String? knowledgeBaseId;

  const FileManagementPage({
    super.key,
    this.knowledgeBaseId,
  });

  @override
  State<FileManagementPage> createState() => _FileManagementPageState();
}

class _FileManagementPageState extends State<FileManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  FileType? _selectedFileType;
  entity.FileStatus? _selectedFileStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFiles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadFiles() {
    context.read<FileBloc>().add(GetFilesEvent(
      knowledgeBaseId: widget.knowledgeBaseId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllFilesTab(),
                _buildUploadTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('文件管理'),
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(
            icon: Icon(Icons.folder),
            text: '所有文件',
          ),
          Tab(
            icon: Icon(Icons.cloud_upload),
            text: '上传文件',
          ),
          Tab(
            icon: Icon(Icons.settings),
            text: '设置',
          ),
        ],
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // 搜索框
          TextField(
            decoration: InputDecoration(
              hintText: '搜索文件...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _applyFilters();
            },
          ),
          const SizedBox(height: 12),
          // 筛选器
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  label: '文件类型',
                  value: _selectedFileType?.name ?? '全部',
                  onTap: _showFileTypeFilter,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterChip(
                  label: '状态',
                  value: _selectedFileStatus != null 
                      ? _getStatusText(_selectedFileStatus!)
                      : '全部',
                  onTap: _showFileStatusFilter,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear_all),
                tooltip: '清除筛选',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllFilesTab() {
    return BlocBuilder<FileBloc, FileState>(
      builder: (context, state) {
        if (state is FileLoading) {
          return const LoadingWidget(message: '加载文件列表中...');
        }

        if (state is FileError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: _loadFiles,
          );
        }

        if (state is FileListLoaded) {
          final filteredFiles = _filterFiles(state.files);
          
          return Column(
            children: [
              _buildFileStats(filteredFiles),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadFiles(),
                  child: FilePreviewWidget(
                    files: filteredFiles,
                    onRefresh: _loadFiles,
                    onFileSelected: _showFileDetails,
                  ),
                ),
              ),
            ],
          );
        }

        return const Center(
          child: Text('暂无数据'),
        );
      },
    );
  }

  Widget _buildFileStats(List<entity.FileEntity> files) {
    final totalSize = files.fold<int>(0, (sum, file) => sum + (file.size ?? 0));
    final completedFiles = files.where((f) => f.status == entity.FileStatus.processed).length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              label: '总文件数',
              value: '${files.length}',
              icon: Icons.folder,
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              label: '已完成',
              value: '$completedFiles',
              icon: Icons.check_circle,
              color: AppColors.success,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              label: '总大小',
              value: _formatFileSize(totalSize),
              icon: Icons.storage,
              color: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '上传新文件',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '支持多种文件格式，包括文档、图片、音频等',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FileUploadWidget(
              knowledgeBaseId: widget.knowledgeBaseId,
              onUploadComplete: () {
                _loadFiles();
                _tabController.animateTo(0); // 切换到文件列表
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '文件设置',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          _buildSettingItem(
            title: '自动处理上传文件',
            subtitle: '上传后自动进行内容提取和索引',
            value: true,
            onChanged: (value) {
              // 实现设置更新
            },
          ),
          _buildSettingItem(
            title: '压缩大文件',
            subtitle: '自动压缩超过指定大小的文件',
            value: false,
            onChanged: (value) {
              // 实现设置更新
            },
          ),
          _buildSettingItem(
            title: '保留原始文件',
            subtitle: '处理后保留原始文件副本',
            value: true,
            onChanged: (value) {
              // 实现设置更新
            },
          ),
          const SizedBox(height: 24),
          _buildActionButton(
            title: '清理临时文件',
            subtitle: '删除处理过程中产生的临时文件',
            icon: Icons.cleaning_services,
            onTap: _cleanupTempFiles,
          ),
          _buildActionButton(
            title: '重新索引所有文件',
            subtitle: '重新处理和索引所有文件内容',
            icon: Icons.refresh,
            onTap: _reindexFiles,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        _tabController.animateTo(1); // 切换到上传标签页
      },
      label: const Text('上传文件'),
      icon: const Icon(Icons.cloud_upload),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    );
  }

  void _showFileTypeFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择文件类型',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildFilterOption('全部', null, _selectedFileType),
              ...FileType.values.map((type) => 
                _buildFilterOption(_getFileTypeText(type), type, _selectedFileType)
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFileStatusFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择文件状态',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatusFilterOption('全部', null, _selectedFileStatus),
              ...entity.FileStatus.values.map((status) => 
                _buildStatusFilterOption(_getStatusText(status), status, _selectedFileStatus)
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String text, FileType? type, FileType? selectedType) {
    final isSelected = type == selectedType;
    
    return ListTile(
      title: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isSelected ? AppColors.primary : null,
          fontWeight: isSelected ? FontWeight.w600 : null,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        setState(() {
          _selectedFileType = type;
        });
        Navigator.of(context).pop();
        _applyFilters();
      },
    );
  }

  Widget _buildStatusFilterOption(String text, entity.FileStatus? status, entity.FileStatus? selectedStatus) {
    final isSelected = status == selectedStatus;
    
    return ListTile(
      title: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isSelected ? AppColors.primary : null,
          fontWeight: isSelected ? FontWeight.w600 : null,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        setState(() {
          _selectedFileStatus = status;
        });
        Navigator.of(context).pop();
        _applyFilters();
      },
    );
  }

  void _applyFilters() {
    // 触发重新过滤文件
    setState(() {});
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedFileType = null;
      _selectedFileStatus = null;
    });
  }

  List<entity.FileEntity> _filterFiles(List<entity.FileEntity> files) {
    return files.where((file) {
      // 搜索过滤
      if (_searchQuery.isNotEmpty && 
          !file.originalName.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      // 文件类型过滤
      if (_selectedFileType != null && 
          FileConstants.getFileType(file.extension) != _selectedFileType) {
        return false;
      }

      // 状态过滤
      if (_selectedFileStatus != null && file.status != _selectedFileStatus) {
        return false;
      }

      return true;
    }).toList();
  }

  void _showFileDetails(entity.FileEntity file) {
    // 显示文件详情或预览
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                file.originalName,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Text('文件详情功能待实现'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _cleanupTempFiles() {
    // 实现清理临时文件
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('清理临时文件功能待实现')),
    );
  }

  void _reindexFiles() {
    // 实现重新索引文件
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('重新索引文件功能待实现')),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  String _getFileTypeText(FileType type) {
    switch (type) {
      case FileType.document:
        return '文档';
      case FileType.image:
        return '图片';
      case FileType.audio:
        return '音频';
      case FileType.video:
        return '视频';
      case FileType.archive:
        return '压缩包';
      case FileType.other:
        return '其他';
    }
  }

  String _getStatusText(entity.FileStatus status) {
    switch (status) {
      case entity.FileStatus.uploading:
        return '上传中';
      case entity.FileStatus.processing:
        return '处理中';
      case entity.FileStatus.processed:
        return '已完成';
      case entity.FileStatus.failed:
        return '失败';
    }
  }
} 