import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/conversation.dart';

class ConversationCard extends StatefulWidget {
  final Conversation conversation;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;
  final Function(int)? onRate;
  final Function(String)? onTitleEdit;
  final bool isSelected;
  final Function(bool)? onSelectionChanged;

  const ConversationCard({
    Key? key,
    required this.conversation,
    this.onTap,
    this.onDelete,
    this.onArchive,
    this.onRate,
    this.onTitleEdit,
    this.isSelected = false,
    this.onSelectionChanged,
  }) : super(key: key);

  @override
  State<ConversationCard> createState() => _ConversationCardState();
}

class _ConversationCardState extends State<ConversationCard> {
  bool _isEditingTitle = false;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.conversation.title ?? '未命名对话',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _startEditingTitle() {
    setState(() {
      _isEditingTitle = true;
    });
  }

  void _saveTitle() {
    final newTitle = _titleController.text.trim();
    if (newTitle.isNotEmpty && newTitle != widget.conversation.title) {
      widget.onTitleEdit?.call(newTitle);
    }
    setState(() {
      _isEditingTitle = false;
    });
  }

  void _cancelEditingTitle() {
    _titleController.text = widget.conversation.title ?? '未命名对话';
    setState(() {
      _isEditingTitle = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastMessage = widget.conversation.lastUserMessage ?? 
                       widget.conversation.lastAssistantMessage;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: widget.isSelected ? 4 : 1,
      color: widget.isSelected 
          ? theme.primaryColor.withOpacity(0.1) 
          : theme.colorScheme.surface,
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: () {
          widget.onSelectionChanged?.call(!widget.isSelected);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：标题、状态和选择框
              Row(
                children: [
                  // 选择框
                  if (widget.onSelectionChanged != null)
                    Checkbox(
                      value: widget.isSelected,
                      onChanged: (value) {
                        widget.onSelectionChanged?.call(value ?? false);
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  
                  // 对话类型图标
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(widget.conversation.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(widget.conversation.type),
                      size: 20,
                      color: _getTypeColor(widget.conversation.type),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 标题和状态
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题编辑区域
                        if (_isEditingTitle)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _titleController,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    isDense: true,
                                  ),
                                  autofocus: true,
                                  onSubmitted: (_) => _saveTitle(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: _saveTitle,
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: _cancelEditingTitle,
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.conversation.title ?? '未命名对话',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: _startEditingTitle,
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        
                        const SizedBox(height: 4),
                        
                        // 状态和时间
                        Row(
                          children: [
                            _buildStatusChip(widget.conversation.status, theme),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(widget.conversation.lastMessageAt ?? 
                                         widget.conversation.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 更多操作菜单
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _startEditingTitle();
                          break;
                        case 'archive':
                          widget.onArchive?.call();
                          break;
                        case 'delete':
                          _showDeleteConfirm(context);
                          break;
                        case 'rate':
                          _showRatingDialog(context);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('编辑标题'),
                          ],
                        ),
                      ),
                      if (widget.conversation.status != ConversationStatus.archived)
                        const PopupMenuItem(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(Icons.archive),
                              SizedBox(width: 8),
                              Text('归档'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'rate',
                        child: Row(
                          children: [
                            Icon(Icons.star),
                            SizedBox(width: 8),
                            Text('评分'),
                          ],
                        ),
                      ),
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
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 最后一条消息预览
              if (lastMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    lastMessage.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // 底部统计信息
              Row(
                children: [
                  // 消息数量
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.conversation.messageCount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 评分显示
                  if (widget.conversation.rating != null) ...[
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.conversation.rating}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // 知识库标签
                  if (widget.conversation.knowledgeBaseId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '知识库',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ConversationStatus status, ThemeData theme) {
    Color color;
    String label;
    
    switch (status) {
      case ConversationStatus.active:
        color = Colors.green;
        label = '活跃';
        break;
      case ConversationStatus.ended:
        color = Colors.grey;
        label = '已结束';
        break;
      case ConversationStatus.archived:
        color = Colors.orange;
        label = '已归档';
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
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
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
              widget.onDelete?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    int selectedRating = widget.conversation.rating ?? 5;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('为对话评分'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('请为这次对话体验评分：'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final rating = index + 1;
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        selectedRating = rating;
                      });
                    },
                    icon: Icon(
                      rating <= selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onRate?.call(selectedRating);
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }
} 