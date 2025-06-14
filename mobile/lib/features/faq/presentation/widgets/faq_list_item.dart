import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/faq_entity.dart';

/// FAQ列表项组件
class FaqListItem extends StatelessWidget {
  final FaqEntity faq;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onToggleSelection;

  const FaqListItem({
    super.key,
    required this.faq,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onTap,
    this.onLongPress,
    this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: isSelectionMode ? onToggleSelection : onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头部：状态、优先级、选择框
                Row(
                  children: [
                    // 状态标签
                    _buildStatusChip(context),
                    const SizedBox(width: 8),
                    
                    // 优先级标签
                    _buildPriorityChip(context),
                    
                    const Spacer(),
                    
                    // 选择框（选择模式时显示）
                    if (isSelectionMode)
                      Checkbox(
                        value: isSelected,
                        onChanged: (_) => onToggleSelection?.call(),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // 问题标题
                Text(
                  faq.question,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // 答案预览
                if (faq.answer.isNotEmpty)
                  Text(
                    faq.answer,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                const SizedBox(height: 12),
                
                // 分类和标签
                _buildCategoryAndTags(context),
                
                const SizedBox(height: 12),
                
                // 底部信息：统计数据、时间等
                _buildBottomInfo(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    IconData chipIcon;
    
    switch (faq.status) {
      case FaqStatus.published:
        chipColor = Colors.green;
        chipIcon = Icons.check_circle;
        break;
      case FaqStatus.draft:
        chipColor = Colors.orange;
        chipIcon = Icons.edit;
        break;
      case FaqStatus.archived:
        chipColor = Colors.grey;
        chipIcon = Icons.archive;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chipIcon, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            faq.status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(BuildContext context) {
    Color chipColor;
    IconData chipIcon;
    
    switch (faq.priority) {
      case FaqPriority.high:
        chipColor = Colors.red;
        chipIcon = Icons.priority_high;
        break;
      case FaqPriority.medium:
        chipColor = Colors.blue;
        chipIcon = Icons.remove;
        break;
      case FaqPriority.low:
        chipColor = Colors.grey;
        chipIcon = Icons.expand_more;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chipIcon, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            faq.priority.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAndTags(BuildContext context) {
    return Row(
      children: [
        // 分类
        if (faq.category.isNotEmpty) ...[
          Icon(
            Icons.folder_outlined,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            faq.category,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
        ],
        
        // 标签
        if (faq.tags.isNotEmpty) ...[
          Expanded(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: faq.tags.take(3).map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                  ),
                ),
              )).toList(),
            ),
          ),
          if (faq.tags.length > 3)
            Text(
              '+${faq.tags.length - 3}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildBottomInfo(BuildContext context) {
    return Row(
      children: [
        // 浏览次数
        Icon(
          Icons.visibility_outlined,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          '${faq.viewCount}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // 点赞数
        Icon(
          Icons.thumb_up_outlined,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          '${faq.likeCount}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // 有用率
        if (faq.likeCount > 0 || faq.dislikeCount > 0) ...[
          Icon(
            Icons.trending_up_outlined,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            '${((faq.likeCount / (faq.likeCount + faq.dislikeCount)) * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
        ],
        
        const Spacer(),
        
        // 更新时间
        Text(
          DateFormat('MM/dd HH:mm').format(faq.updatedAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        
        // 可见性图标
        const SizedBox(width: 8),
        Icon(
          faq.isPublic ? Icons.public : Icons.lock_outline,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
} 