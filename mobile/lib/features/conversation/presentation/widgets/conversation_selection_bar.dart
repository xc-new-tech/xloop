import 'package:flutter/material.dart';

class ConversationSelectionBar extends StatelessWidget {
  final int selectedCount;
  final bool isAllSelected;
  final Function(bool) onSelectAll;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const ConversationSelectionBar({
    Key? key,
    required this.selectedCount,
    required this.isAllSelected,
    required this.onSelectAll,
    required this.onDelete,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          
          // 全选按钮
          InkWell(
            onTap: () => onSelectAll(!isAllSelected),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isAllSelected 
                        ? Icons.check_box 
                        : Icons.check_box_outline_blank,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '全选',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 选中数量
          Text(
            '已选择 $selectedCount 项',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const Spacer(),
          
          // 操作按钮
          if (selectedCount > 0) ...[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              color: Colors.red,
              tooltip: '删除选中',
            ),
            const SizedBox(width: 8),
          ],
          
          // 取消按钮
          TextButton(
            onPressed: onCancel,
            child: const Text('取消'),
          ),
          
          const SizedBox(width: 16),
        ],
      ),
    );
  }
} 