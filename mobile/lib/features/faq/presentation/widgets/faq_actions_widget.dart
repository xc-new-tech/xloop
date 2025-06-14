import 'package:flutter/material.dart';

import '../../domain/entities/faq_entity.dart';

/// FAQ操作按钮组件
class FaqActionsWidget extends StatelessWidget {
  final FaqEntity faq;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FaqActionsWidget({
    super.key,
    required this.faq,
    this.onLike,
    this.onDislike,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '操作',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 点赞/点踩统计
            _buildFeedbackStats(theme),
            const SizedBox(height: 16),

            // 操作按钮
            Row(
              children: [
                // 点赞按钮
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onLike,
                    icon: Icon(
                      Icons.thumb_up_outlined,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    label: Text(
                      '有用 (${faq.likeCount})',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 点踩按钮
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDislike,
                    icon: Icon(
                      Icons.thumb_down_outlined,
                      size: 18,
                      color: colorScheme.outline,
                    ),
                    label: Text(
                      '无用 (${faq.dislikeCount})',
                      style: TextStyle(color: colorScheme.outline),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 管理操作按钮
            Row(
              children: [
                // 编辑按钮
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('编辑'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 删除按钮
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('删除'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackStats(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final totalFeedback = faq.likeCount + faq.dislikeCount;
    final helpfulnessRate = faq.helpfulnessRate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 有用率
        Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              '有用率: ${helpfulnessRate.toStringAsFixed(1)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 浏览统计
        Row(
          children: [
            Icon(
              Icons.visibility_outlined,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              '浏览次数: ${faq.viewCount}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.comment_outlined,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              '反馈次数: $totalFeedback',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),

        // 有用率进度条
        if (totalFeedback > 0) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: helpfulnessRate / 100,
                  backgroundColor: colorScheme.outline.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    helpfulnessRate >= 70 
                        ? Colors.green 
                        : helpfulnessRate >= 40 
                            ? Colors.orange 
                            : Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${faq.likeCount}/${totalFeedback}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
} 