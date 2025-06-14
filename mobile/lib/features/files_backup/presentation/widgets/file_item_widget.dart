import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/file_entity.dart';

/// 文件项组件
class FileItemWidget extends StatelessWidget {
  final FileEntity file;
  final bool? isSelected;
  final VoidCallback? onTap;
  final Function(bool)? onSelectionChanged;
  final String? searchQuery;
  final bool showActions;

  const FileItemWidget({
    super.key,
    required this.file,
    this.isSelected,
    this.onTap,
    this.onSelectionChanged,
    this.searchQuery,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              _buildContent(),
              if (file.chunks.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildChunksInfo(),
              ],
              const SizedBox(height: 8),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (isSelected != null)
          Checkbox(
            value: isSelected!,
            onChanged: (value) => onSelectionChanged?.call(value ?? false),
          ),
        Icon(
          _getFileIcon(),
          color: _getStatusColor(),
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFileName(),
              const SizedBox(height: 2),
              _buildFileInfo(),
            ],
          ),
        ),
        if (showActions) _buildActionMenu(context),
      ],
    );
  }

  Widget _buildFileName() {
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      return _buildHighlightedText(
        file.originalName,
        searchQuery!,
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    
    return Text(
      file.originalName,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFileInfo() {
    return Row(
      children: [
        Text(
          _formatFileSize(file.size),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getCategoryColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _getCategoryName(),
            style: TextStyle(
              fontSize: 10,
              color: _getCategoryColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildContent() {
    if (file.extractedText != null && file.extractedText!.isNotEmpty) {
      return Text(
        file.extractedText!.length > 100 
            ? '${file.extractedText!.substring(0, 100)}...'
            : file.extractedText!,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildChunksInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_stories,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            '已解析 ${file.chunks.length} 个文档片段',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (file.chunks.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              '总计 ${file.chunks.map((c) => c.text.length).reduce((a, b) => a + b)} 字符',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        if (file.tags.isNotEmpty) ...[
          Expanded(child: _buildTags()),
          const SizedBox(width: 8),
        ] else
          const Spacer(),
        Text(
          DateFormat('MM-dd HH:mm').format(file.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: file.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.primary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusBadge() {
    final color = _getStatusColor();
    final text = _getStatusText();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleAction(context, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility),
              SizedBox(width: 8),
              Text('查看详情'),
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
        if (file.status == FileStatus.failed)
          const PopupMenuItem(
            value: 'reparse',
            child: Row(
              children: [
                Icon(Icons.refresh),
                SizedBox(width: 8),
                Text('重新解析'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit),
              SizedBox(width: 8),
              Text('编辑信息'),
            ],
          ),
        ),
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
      child: Icon(
        Icons.more_vert,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query, TextStyle style) {
    if (query.isEmpty) {
      return Text(text, style: style);
    }

    final matches = <TextSpan>[];
    final queryLower = query.toLowerCase();
    final textLower = text.toLowerCase();
    
    int start = 0;
    int index = textLower.indexOf(queryLower);
    
    while (index != -1) {
      // 添加匹配前的文本
      if (index > start) {
        matches.add(TextSpan(
          text: text.substring(start, index),
          style: style,
        ));
      }
      
      // 添加高亮的匹配文本
      matches.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: style.copyWith(
          backgroundColor: AppColors.primary.withOpacity(0.3),
          fontWeight: FontWeight.bold,
        ),
      ));
      
      start = index + query.length;
      index = textLower.indexOf(queryLower, start);
    }
    
    // 添加剩余文本
    if (start < text.length) {
      matches.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }
    
    return RichText(
      text: TextSpan(children: matches),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'view':
        Navigator.pushNamed(
          context,
          '/files/detail',
          arguments: {'fileId': file.id},
        );
        break;
      case 'download':
        // TODO: 实现下载功能
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('下载功能开发中...')),
        );
        break;
      case 'reparse':
        // TODO: 实现重新解析功能
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('重新解析功能开发中...')),
        );
        break;
      case 'edit':
        Navigator.pushNamed(
          context,
          '/files/edit',
          arguments: {'file': file},
        );
        break;
      case 'delete':
        _showDeleteConfirmDialog(context);
        break;
    }
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除文件 "${file.name}" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 触发删除事件
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('删除功能开发中...')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon() {
    switch (file.category) {
      case FileCategory.document:
        final extension = file.name.split('.').last.toLowerCase();
        switch (extension) {
          case 'pdf':
            return Icons.picture_as_pdf;
          case 'doc':
          case 'docx':
            return Icons.description;
          case 'xls':
          case 'xlsx':
            return Icons.table_chart;
          case 'ppt':
          case 'pptx':
            return Icons.slideshow;
          case 'txt':
            return Icons.text_snippet;
          default:
            return Icons.description;
        }
      case FileCategory.image:
        return Icons.image;
      case FileCategory.audio:
        return Icons.audiotrack;
      case FileCategory.video:
        return Icons.videocam;
      case FileCategory.other:
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getStatusColor() {
    switch (file.status) {
      case FileStatus.uploading:
        return AppColors.warning;
      case FileStatus.processing:
        return AppColors.info;
      case FileStatus.processed:
        return AppColors.success;
      case FileStatus.failed:
        return AppColors.error;
    }
  }

  String _getStatusText() {
    switch (file.status) {
      case FileStatus.uploading:
        return '上传中';
      case FileStatus.processing:
        return '处理中';
      case FileStatus.processed:
        return '已处理';
      case FileStatus.failed:
        return '失败';
    }
  }

  Color _getCategoryColor() {
    switch (file.category) {
      case FileCategory.document:
        return AppColors.info;
      case FileCategory.image:
        return AppColors.success;
      case FileCategory.audio:
        return AppColors.warning;
      case FileCategory.video:
        return AppColors.error;
      case FileCategory.other:
      default:
        return AppColors.textSecondary;
    }
  }

  String _getCategoryName() {
    switch (file.category) {
      case FileCategory.document:
        return '文档';
      case FileCategory.image:
        return '图片';
      case FileCategory.audio:
        return '音频';
      case FileCategory.video:
        return '视频';
      case FileCategory.other:
      default:
        return '其他';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
} 