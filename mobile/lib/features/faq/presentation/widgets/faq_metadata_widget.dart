import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/faq_entity.dart';

/// FAQ元数据组件
class FaqMetadataWidget extends StatelessWidget {
  final FaqEntity faq;

  const FaqMetadataWidget({
    super.key,
    required this.faq,
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
              '详细信息',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 创建信息
            _buildInfoRow(
              context,
              icon: Icons.person_add_outlined,
              label: '创建者',
              value: faq.creator?.username ?? '未知',
              subtitle: _formatDateTime(faq.createdAt),
            ),
            const SizedBox(height: 12),

            // 更新信息
            if (faq.updater != null) ...[
              _buildInfoRow(
                context,
                icon: Icons.person_outlined,
                label: '更新者',
                value: faq.updater!.username,
                subtitle: _formatDateTime(faq.updatedAt),
              ),
              const SizedBox(height: 12),
            ],

            // 知识库信息
            if (faq.knowledgeBase != null) ...[
              _buildInfoRow(
                context,
                icon: Icons.folder_outlined,
                label: '所属知识库',
                value: faq.knowledgeBase!.name,
                subtitle: faq.knowledgeBase!.description,
              ),
              const SizedBox(height: 12),
            ],

            // FAQ ID
            _buildInfoRow(
              context,
              icon: Icons.fingerprint_outlined,
              label: 'FAQ ID',
              value: faq.id,
            ),
            const SizedBox(height: 12),

            // 统计信息
            _buildStatsSection(context),

            // 状态标识
            if (faq.isNew || faq.isPopular || faq.isRecentlyUpdated) ...[
              const SizedBox(height: 16),
              _buildBadgesSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '统计数据',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.visibility_outlined,
                  label: '浏览',
                  value: faq.viewCount.toString(),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.thumb_up_outlined,
                  label: '点赞',
                  value: faq.likeCount.toString(),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.thumb_down_outlined,
                  label: '点踩',
                  value: faq.dislikeCount.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '标识',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (faq.isNew)
              _buildBadge(
                context,
                label: '新发布',
                color: Colors.green,
                icon: Icons.new_releases_outlined,
              ),
            if (faq.isPopular)
              _buildBadge(
                context,
                label: '热门',
                color: Colors.orange,
                icon: Icons.trending_up_outlined,
              ),
            if (faq.isRecentlyUpdated)
              _buildBadge(
                context,
                label: '最近更新',
                color: Colors.blue,
                icon: Icons.update_outlined,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return '刚刚';
        }
        return '${difference.inMinutes}分钟前';
      }
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return DateFormat('yyyy年MM月dd日 HH:mm').format(dateTime);
    }
  }
} 