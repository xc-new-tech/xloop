import 'package:flutter/material.dart';
import '../bloc/data_management_state.dart';

/// 备份状态卡片
class BackupStatusCard extends StatelessWidget {
  final BackupStatus status;
  final VoidCallback? onViewDetails;

  const BackupStatusCard({
    super.key,
    required this.status,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.backup,
                  color: _getStatusColor(),
                ),
                const SizedBox(width: 8),
                Text(
                  '备份状态',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (onViewDetails != null)
                  TextButton(
                    onPressed: onViewDetails,
                    child: const Text('详情'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 状态信息
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.status.displayName,
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  status.formattedBackupSize,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            if (status.lastBackupTime != null) ...[
              Text(
                '上次备份: ${_formatDateTime(status.lastBackupTime!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
            ],
            
            if (status.nextBackupTime != null) ...[
              Text(
                '下次备份: ${_formatDateTime(status.nextBackupTime!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
            ],
            
            Text(
              '备份位置: ${status.backupLocation}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Icon(
                  status.isAutoBackupEnabled ? Icons.schedule : Icons.schedule_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  status.isAutoBackupEnabled 
                      ? '自动备份 (${status.backupFrequency.displayName})'
                      : '手动备份',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status.status) {
      case BackupStatusType.completed:
        return Colors.green;
      case BackupStatusType.inProgress:
        return Colors.blue;
      case BackupStatusType.failed:
        return Colors.red;
      case BackupStatusType.scheduled:
        return Colors.orange;
      case BackupStatusType.disabled:
        return Colors.grey;
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