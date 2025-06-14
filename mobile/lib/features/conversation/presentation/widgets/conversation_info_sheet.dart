import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/conversation.dart';

class ConversationInfoSheet extends StatefulWidget {
  final Conversation conversation;
  final Function(String?, List<String>, Map<String, dynamic>) onUpdate;
  final Function(double, String?) onRate;
  final VoidCallback onDelete;

  const ConversationInfoSheet({
    Key? key,
    required this.conversation,
    required this.onUpdate,
    required this.onRate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<ConversationInfoSheet> createState() => _ConversationInfoSheetState();
}

class _ConversationInfoSheetState extends State<ConversationInfoSheet> {
  late TextEditingController _titleController;
  late TextEditingController _tagsController;
  late TextEditingController _feedbackController;
  
  double _rating = 0;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.conversation.title);
    _tagsController = TextEditingController(
      text: widget.conversation.tags.join(', '),
    );
    _feedbackController = TextEditingController();
    _rating = widget.conversation.rating?.toDouble() ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    widget.onUpdate(
      _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      tags,
      widget.conversation.settings,
    );

    setState(() {
      _isEditing = false;
    });
  }

  void _submitRating() {
    if (_rating > 0) {
      widget.onRate(
        _rating,
        _feedbackController.text.trim().isEmpty 
            ? null 
            : _feedbackController.text.trim(),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('评分已提交'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showDeleteConfirm() {
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
              Navigator.of(context).pop();
              widget.onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              // 拖拽指示器
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 标题栏
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      '对话信息',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (_isEditing) ...[
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                          });
                        },
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _saveChanges,
                        child: const Text('保存'),
                      ),
                    ] else ...[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: _showDeleteConfirm,
                      ),
                    ],
                  ],
                ),
              ),
              
              const Divider(),
              
              // 内容
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 基本信息
                      _buildSection(
                        '基本信息',
                        [
                          _buildInfoRow(
                            '对话ID',
                            widget.conversation.id,
                          ),
                          _buildInfoRow(
                            '创建时间',
                            DateFormat('yyyy/MM/dd HH:mm').format(
                              widget.conversation.createdAt,
                            ),
                          ),
                          _buildInfoRow(
                            '最后更新',
                            widget.conversation.lastMessageAt != null
                                ? DateFormat('yyyy/MM/dd HH:mm').format(
                                    widget.conversation.lastMessageAt!,
                                  )
                                : '暂无',
                          ),
                          _buildInfoRow(
                            '对话类型',
                            _getTypeLabel(widget.conversation.type),
                          ),
                          _buildInfoRow(
                            '对话状态',
                            _getStatusLabel(widget.conversation.status),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 对话设置
                      _buildSection(
                        '对话设置',
                        [
                          // 标题
                          if (_isEditing)
                            TextField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: '对话标题',
                                border: OutlineInputBorder(),
                              ),
                            )
                          else
                            _buildInfoRow(
                              '标题',
                              widget.conversation.title ?? '未命名对话',
                            ),
                          
                          const SizedBox(height: 16),
                          
                          // 标签
                          if (_isEditing)
                            TextField(
                              controller: _tagsController,
                              decoration: const InputDecoration(
                                labelText: '标签（用逗号分隔）',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            )
                          else
                            _buildTagsRow('标签', widget.conversation.tags),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 统计信息
                      _buildSection(
                        '统计信息',
                        [
                          _buildInfoRow(
                            '消息数量',
                            '${widget.conversation.messageCount}',
                          ),
                          _buildInfoRow(
                            '知识库',
                            widget.conversation.knowledgeBaseId ?? '未关联',
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 评分反馈
                      _buildSection(
                        '评分反馈',
                        [
                          // 当前评分
                          if (widget.conversation.rating != null)
                            _buildInfoRow(
                              '当前评分',
                              '${widget.conversation.rating} 星',
                            ),
                          
                          const SizedBox(height: 16),
                          
                          // 评分组件
                          const Text(
                            '对本次对话评分：',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (index) {
                              final starValue = index + 1;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _rating = starValue.toDouble();
                                  });
                                },
                                child: Icon(
                                  _rating >= starValue
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                              );
                            }),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 反馈文本
                          TextField(
                            controller: _feedbackController,
                            decoration: const InputDecoration(
                              labelText: '反馈意见（可选）',
                              border: OutlineInputBorder(),
                              hintText: '请描述您的使用体验...',
                            ),
                            maxLines: 3,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          ElevatedButton(
                            onPressed: _rating > 0 ? _submitRating : null,
                            child: const Text('提交评分'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsRow(String label, List<String> tags) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: tags.isEmpty
                ? const Text('无标签')
                : Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: tags.map((tag) => Chip(
                      label: Text(tag),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(ConversationType type) {
    switch (type) {
      case ConversationType.chat:
        return '聊天对话';
      case ConversationType.qa:
        return '问答对话';
      case ConversationType.support:
        return '客服对话';
    }
  }

  String _getStatusLabel(ConversationStatus status) {
    switch (status) {
      case ConversationStatus.active:
        return '活跃';
      case ConversationStatus.paused:
        return '暂停';
      case ConversationStatus.completed:
        return '完成';
      case ConversationStatus.archived:
        return '归档';
    }
  }
} 