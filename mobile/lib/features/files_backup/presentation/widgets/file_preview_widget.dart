import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/file_bloc.dart';
import '../../domain/entities/file_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/file_constants.dart';

/// 文件预览组件
class FilePreviewWidget extends StatelessWidget {
  final List<FileEntity> files;
  final VoidCallback? onRefresh;
  final ValueChanged<FileEntity>? onFileSelected;
  final bool showActions;

  const FilePreviewWidget({
    super.key,
    required this.files,
    this.onRefresh,
    this.onFileSelected,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: files.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final file = files[index];
        return _buildFileItem(context, file);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无文件',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击上传按钮添加文件',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(BuildContext context, FileEntity file) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onFileSelected?.call(file),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildFileIcon(file),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFileInfo(file),
              ),
              if (showActions) ...[
                const SizedBox(width: 16),
                _buildFileActions(context, file),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileIcon(FileEntity file) {
    final fileType = FileConstants.getFileType(file.extension);
    final iconData = _getFileTypeIcon(fileType);
    final color = _getFileTypeColor(fileType);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildFileInfo(FileEntity file) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          file.originalName,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          _formatFileSize(file.size),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildStatusChip(file.status),
            const SizedBox(width: 8),
            Text(
              _formatDate(file.createdAt),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        if (file.description?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(
            file.description!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildStatusChip(FileStatus status) {
    final statusInfo = _getStatusInfo(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (statusInfo.icon != null) ...[
            Icon(
              statusInfo.icon,
              size: 12,
              color: statusInfo.color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            statusInfo.text,
            style: AppTextStyles.bodySmall.copyWith(
              color: statusInfo.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileActions(BuildContext context, FileEntity file) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (action) => _handleFileAction(context, file, action),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'preview',
          child: Row(
            children: [
              Icon(Icons.visibility),
              SizedBox(width: 8),
              Text('预览'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'download',
          child: Row(
            children: [
              Icon(Icons.download),
              SizedBox(width: 8),
              Text('下载'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share),
              SizedBox(width: 8),
              Text('分享'),
            ],
          ),
        ),
        if (file.status == FileStatus.failed) ...[
          const PopupMenuItem(
            value: 'retry',
            child: Row(
              children: [
                Icon(Icons.refresh),
                SizedBox(width: 8),
                Text('重试'),
              ],
            ),
          ),
        ],
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('删除', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _handleFileAction(BuildContext context, FileEntity file, String action) {
    switch (action) {
      case 'preview':
        _previewFile(context, file);
        break;
      case 'download':
        _downloadFile(context, file);
        break;
      case 'share':
        _shareFile(context, file);
        break;
      case 'retry':
        _retryUpload(context, file);
        break;
      case 'delete':
        _deleteFile(context, file);
        break;
    }
  }

  void _previewFile(BuildContext context, FileEntity file) {
    // 实现文件预览
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('预览文件: ${file.originalName}')),
    );
  }

  void _downloadFile(BuildContext context, FileEntity file) {
    // 实现文件下载
    context.read<FileBloc>().add(DownloadFileEvent(fileId: file.id));
  }

  void _shareFile(BuildContext context, FileEntity file) {
    // 实现文件分享
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('分享文件: ${file.originalName}')),
    );
  }

  void _retryUpload(BuildContext context, FileEntity file) {
    // 重试上传
    context.read<FileBloc>().add(RetryUploadEvent(fileId: file.id));
  }

  void _deleteFile(BuildContext context, FileEntity file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除文件'),
        content: Text('确定要删除文件 "${file.originalName}" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<FileBloc>().add(DeleteFileEvent(fileId: file.id));
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  IconData _getFileTypeIcon(FileType type) {
    switch (type) {
      case FileType.document:
        return Icons.description;
      case FileType.image:
        return Icons.image;
      case FileType.audio:
        return Icons.audiotrack;
      case FileType.video:
        return Icons.videocam;
      case FileType.archive:
        return Icons.archive;
      case FileType.other:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileTypeColor(FileType type) {
    switch (type) {
      case FileType.document:
        return Colors.blue;
      case FileType.image:
        return Colors.green;
      case FileType.audio:
        return Colors.orange;
      case FileType.video:
        return Colors.red;
      case FileType.archive:
        return Colors.purple;
      case FileType.other:
        return AppColors.textSecondary;
    }
  }

  ({String text, Color color, IconData? icon}) _getStatusInfo(FileStatus status) {
    switch (status) {
      case FileStatus.pending:
        return (
          text: '等待中',
          color: AppColors.warning,
          icon: Icons.schedule,
        );
      case FileStatus.uploading:
        return (
          text: '上传中',
          color: AppColors.info,
          icon: Icons.cloud_upload,
        );
      case FileStatus.processing:
        return (
          text: '处理中',
          color: AppColors.info,
          icon: Icons.sync,
        );
      case FileStatus.completed:
        return (
          text: '已完成',
          color: AppColors.success,
          icon: Icons.check_circle,
        );
      case FileStatus.failed:
        return (
          text: '失败',
          color: AppColors.error,
          icon: Icons.error,
        );
      case FileStatus.deleted:
        return (
          text: '已删除',
          color: AppColors.textSecondary,
          icon: Icons.delete,
        );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
} 