import 'package:flutter/material.dart';

import '../../domain/entities/conversation.dart';

class ConversationFilterDialog extends StatefulWidget {
  final Function(ConversationType?, ConversationStatus?, String?) onApplyFilter;
  final VoidCallback onClearFilter;

  const ConversationFilterDialog({
    Key? key,
    required this.onApplyFilter,
    required this.onClearFilter,
  }) : super(key: key);

  @override
  State<ConversationFilterDialog> createState() => _ConversationFilterDialogState();
}

class _ConversationFilterDialogState extends State<ConversationFilterDialog> {
  ConversationType? _selectedType;
  ConversationStatus? _selectedStatus;
  String? _selectedKnowledgeBaseId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: const Text('筛选对话'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 对话类型
            Text(
              '对话类型',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ConversationType.values.map((type) {
                final isSelected = _selectedType == type;
                return FilterChip(
                  label: Text(_getTypeLabel(type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? type : null;
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // 对话状态
            Text(
              '对话状态',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ConversationStatus.values.map((status) {
                final isSelected = _selectedStatus == status;
                return FilterChip(
                  label: Text(_getStatusLabel(status)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? status : null;
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // 知识库选择（这里简化处理，实际可能需要从API获取知识库列表）
            Text(
              '知识库',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedKnowledgeBaseId,
              decoration: const InputDecoration(
                hintText: '选择知识库',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('全部知识库'),
                ),
                // 这里应该从实际的知识库列表中生成
                ...['kb1', 'kb2', 'kb3'].map((id) => DropdownMenuItem(
                  value: id,
                  child: Text('知识库 $id'),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedKnowledgeBaseId = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onClearFilter();
            Navigator.of(context).pop();
          },
          child: const Text('清除筛选'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApplyFilter(
              _selectedType,
              _selectedStatus,
              _selectedKnowledgeBaseId,
            );
            Navigator.of(context).pop();
          },
          child: const Text('应用'),
        ),
      ],
    );
  }

  String _getTypeLabel(ConversationType type) {
    switch (type) {
      case ConversationType.chat:
        return '聊天对话';
      case ConversationType.search:
        return '搜索对话';
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
      case ConversationStatus.ended:
        return '已结束';
      case ConversationStatus.archived:
        return '已归档';
    }
  }
} 