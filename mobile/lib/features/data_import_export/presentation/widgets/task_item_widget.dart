import 'package:flutter/material.dart';
import '../../../../shared/widgets/adaptive_layout.dart';
import '../../domain/entities/import_export_entity.dart';
import 'task_progress_widget.dart';

class TaskItemWidget extends StatelessWidget {
  final ImportExportTask task;
  final Function(ImportExportTask, String) onAction;

  const TaskItemWidget({
    super.key,
    required this.task,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 任务头部信息
          Row(
            children: [
              _buildStatusIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildDataTypeChip(),
                        const SizedBox(width: 8),
                        _buildFormatChip(),
                      ],
                    ),
                  ],
                ),
              ),
              _buildActionButton(context),
            ],
          ),

          // 进度条（仅在进行中时显示）
          if (task.status == ImportExportStatus.inProgress) ...[
            const SizedBox(height: 12),
            TaskProgressWidget(
              progress: task.progress,
              totalItems: task.totalItems,
              processedItems: task.processedItems,
            ),
          ],

          // 错误信息（仅在失败时显示）
          if (task.status == ImportExportStatus.failed && task.errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: Colors.red[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 任务底部信息
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                _formatDateTime(task.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              if (task.completedAt != null) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '完成于 ${_formatDateTime(task.completedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green[600],
                  ),
                ),
              ],
              const Spacer(),
              if (task.status == ImportExportStatus.completed && task.filePath != null)
                TextButton.icon(
                  onPressed: () => onAction(task, 'share'),
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('分享'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (task.status) {
      case ImportExportStatus.pending:
        icon = Icons.schedule;
        color = Colors.orange;
        break;
      case ImportExportStatus.inProgress:
        icon = Icons.play_circle_outline;
        color = Colors.blue;
        break;
      case ImportExportStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case ImportExportStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
      case ImportExportStatus.cancelled:
        icon = Icons.cancel;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 20,
        color: color,
      ),
    );
  }

  Widget _buildDataTypeChip() {
    String label;
    IconData icon;

    switch (task.dataType) {
      case DataType.faq:
        label = 'FAQ';
        icon = Icons.quiz;
        break;
      case DataType.knowledgeBase:
        label = '知识库';
        icon = Icons.library_books;
        break;
      case DataType.documents:
        label = '文档';
        icon = Icons.description;
        break;
      case DataType.conversations:
        label = '对话';
        icon = Icons.chat;
        break;
      case DataType.userSettings:
        label = '设置';
        icon = Icons.settings;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatChip() {
    String label;
    MaterialColor color;

    switch (task.format) {
      case ExportFormat.csv:
        label = 'CSV';
        color = Colors.green;
        break;
      case ExportFormat.excel:
        label = 'Excel';
        color = Colors.teal;
        break;
      case ExportFormat.json:
        label = 'JSON';
        color = Colors.purple;
        break;
      case ExportFormat.pdf:
        label = 'PDF';
        color = Colors.red;
        break;
      case ExportFormat.zip:
        label = 'ZIP';
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    switch (task.status) {
      case ImportExportStatus.pending:
        return PopupMenuButton<String>(
          onSelected: (action) => onAction(task, action),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'start',
              child: Row(
                children: [
                  Icon(Icons.play_arrow, size: 16),
                  SizedBox(width: 8),
                  Text('开始'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('删除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          child: const Icon(Icons.more_vert),
        );

      case ImportExportStatus.inProgress:
        return PopupMenuButton<String>(
          onSelected: (action) => onAction(task, action),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(Icons.stop, size: 16, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('取消', style: TextStyle(color: Colors.orange)),
                ],
              ),
            ),
          ],
          child: const Icon(Icons.more_vert),
        );

      case ImportExportStatus.completed:
        return PopupMenuButton<String>(
          onSelected: (action) => onAction(task, action),
          itemBuilder: (context) => [
            if (task.filePath != null)
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, size: 16),
                    SizedBox(width: 8),
                    Text('分享'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('删除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          child: const Icon(Icons.more_vert),
        );

      case ImportExportStatus.failed:
      case ImportExportStatus.cancelled:
        return PopupMenuButton<String>(
          onSelected: (action) => onAction(task, action),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('删除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          child: const Icon(Icons.more_vert),
        );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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