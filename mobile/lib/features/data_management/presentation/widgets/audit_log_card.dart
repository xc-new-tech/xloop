import 'package:flutter/material.dart';
import '../bloc/data_management_state.dart';

/// 审计日志卡片
class AuditLogCard extends StatelessWidget {
  final List<AuditLog> logs;
  final VoidCallback? onViewAll;

  const AuditLogCard({
    super.key,
    required this.logs,
    this.onViewAll,
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
                const Icon(Icons.history, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '操作日志',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('查看全部'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (logs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '暂无操作记录',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...logs.take(5).map((log) => _buildLogItem(context, log)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(BuildContext context, AuditLog log) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getActionColor(log.action),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      log.userName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateTime(log.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action.toUpperCase()) {
      case 'CREATE_KNOWLEDGE_BASE':
      case 'UPLOAD_DOCUMENT':
        return Colors.green;
      case 'DELETE_CONVERSATION':
      case 'DELETE_DOCUMENT':
        return Colors.red;
      case 'UPDATE_KNOWLEDGE_BASE':
      case 'EDIT_DOCUMENT':
        return Colors.blue;
      case 'BACKUP_DATA':
      case 'SYNC_DATA':
        return Colors.orange;
      default:
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