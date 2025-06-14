import 'package:flutter/material.dart';

class ConversationSortDialog extends StatefulWidget {
  final Function(String sortBy, String sortOrder) onSort;

  const ConversationSortDialog({
    Key? key,
    required this.onSort,
  }) : super(key: key);

  @override
  State<ConversationSortDialog> createState() => _ConversationSortDialogState();
}

class _ConversationSortDialogState extends State<ConversationSortDialog> {
  String _sortBy = 'lastMessageAt';
  String _sortOrder = 'DESC';

  final Map<String, String> _sortOptions = {
    'lastMessageAt': '最后消息时间',
    'createdAt': '创建时间',
    'title': '标题',
    'messageCount': '消息数量',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: const Text('排序对话'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 排序字段
          Text(
            '排序字段',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ..._sortOptions.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _sortBy,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortBy = value;
                  });
                }
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            );
          }),
          
          const SizedBox(height: 16),
          
          // 排序顺序
          Text(
            '排序顺序',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          RadioListTile<String>(
            title: const Text('降序（新到旧）'),
            value: 'DESC',
            groupValue: _sortOrder,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _sortOrder = value;
                });
              }
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<String>(
            title: const Text('升序（旧到新）'),
            value: 'ASC',
            groupValue: _sortOrder,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _sortOrder = value;
                });
              }
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSort(_sortBy, _sortOrder);
            Navigator.of(context).pop();
          },
          child: const Text('应用'),
        ),
      ],
    );
  }
} 