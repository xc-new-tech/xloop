import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/conversation.dart';

class ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final Function(double)? onRate;

  const ConversationCard({
    Key? key,
    required this.conversation,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onEdit,
    this.onRate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastMessage = conversation.messages.isNotEmpty 
        ? conversation.messages.last 
        : null;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? theme.primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部信息
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 选择指示器
                  if (isSelectionMode)
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Icon(
                        isSelected 
                            ? Icons.check_circle 
                            : Icons.radio_button_unchecked,
                        color: isSelected 
                            ? theme.primaryColor 
                            : Colors.grey,
                      ),
                    ),
                  
                  // 对话类型图标
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(conversation.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(conversation.type),
                      color: _getTypeColor(conversation.type),
                      size: 20,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 对话信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题和状态
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                conversation.title ?? '未命名对话',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(conversation.status, theme),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // 最后一条消息
                        if (lastMessage != null)
                          Text(
                            lastMessage.content,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        
                        const SizedBox(height: 8),
                        
                        // 统计信息
                        Row(
                          children: [
                            Icon(
                              Icons.message_outlined,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${conversation.messageCount}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            
                            if (conversation.rating != null) ...[
                              const SizedBox(width: 16),
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${conversation.rating}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                            
                            const Spacer(),
                            
                            // 时间
                            Text(
                              _formatTime(conversation.lastMessageAt ?? conversation.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 操作菜单
                  if (!isSelectionMode)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            _showDeleteConfirm(context);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('编辑'),
                            dense: true,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('删除', style: TextStyle(color: Colors.red)),
                            dense: true,
                          ),
                        ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
              
              // 标签
              if (conversation.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: conversation.tags.take(3).map((tag) => Chip(
                    label: Text(
                      tag,
                      style: theme.textTheme.bodySmall,
                    ),
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    side: BorderSide.none,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ConversationStatus status, ThemeData theme) {
    Color color;
    String text;
    
    switch (status) {
      case ConversationStatus.active:
        color = Colors.green;
        text = '活跃';
        break;
      case ConversationStatus.ended:
        color = Colors.blue;
        text = '已结束';
        break;
      case ConversationStatus.archived:
        color = Colors.grey;
        text = '已归档';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getTypeIcon(ConversationType type) {
    switch (type) {
      case ConversationType.chat:
        return Icons.chat_bubble_outline;
      case ConversationType.search:
        return Icons.search;
      case ConversationType.qa:
        return Icons.quiz_outlined;
      case ConversationType.support:
        return Icons.support_agent_outlined;
    }
  }

  Color _getTypeColor(ConversationType type) {
    switch (type) {
      case ConversationType.chat:
        return Colors.blue;
      case ConversationType.search:
        return Colors.purple;
      case ConversationType.qa:
        return Colors.green;
      case ConversationType.support:
        return Colors.orange;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return DateFormat('MM/dd').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个对话吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
} 