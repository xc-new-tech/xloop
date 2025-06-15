import 'package:flutter/material.dart';
import '../bloc/data_management_state.dart';

/// 同步状态卡片
class SyncStatusCard extends StatelessWidget {
  final SyncStatus status;
  final VoidCallback? onViewDetails;

  const SyncStatusCard({
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
                  Icons.sync,
                  color: _getStatusColor(),
                ),
                const SizedBox(width: 8),
                Text(
                  '同步状态',
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
            
            const SizedBox(height: 12),
            
            if (status.pendingChanges > 0) ...[
              Row(
                children: [
                  Icon(
                    Icons.pending_actions,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${status.pendingChanges}个待同步更改',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            if (status.lastSyncTime != null) ...[
              Text(
                '上次同步: ${_formatDateTime(status.lastSyncTime!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
            ],
            
            if (status.nextSyncTime != null) ...[
              Text(
                '下次同步: ${_formatDateTime(status.nextSyncTime!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
            ],
            
            Row(
              children: [
                Icon(
                  status.isAutoSyncEnabled ? Icons.sync : Icons.sync_disabled,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  status.isAutoSyncEnabled 
                      ? '自动同步 (${status.syncFrequency.displayName})'
                      : '手动同步',
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
      case SyncStatusType.synced:
        return Colors.green;
      case SyncStatusType.syncing:
        return Colors.blue;
      case SyncStatusType.pending:
        return Colors.orange;
      case SyncStatusType.failed:
        return Colors.red;
      case SyncStatusType.offline:
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