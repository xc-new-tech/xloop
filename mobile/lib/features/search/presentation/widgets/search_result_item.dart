import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../domain/entities/search_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 搜索结果项组件
class SearchResultItem extends StatelessWidget {
  final SearchResult result;
  final String? searchQuery;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  const SearchResultItem({
    super.key,
    required this.result,
    this.searchQuery,
    this.onTap,
    this.onSave,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildContent(),
              if (result.metadata.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildMetadata(),
              ],
              const SizedBox(height: 12),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildTypeIcon(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHighlightedText(
                result.title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildScoreChip(),
                  const SizedBox(width: 8),
                  Text(
                    result.source,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildActionButton(),
      ],
    );
  }

  Widget _buildTypeIcon() {
    IconData iconData;
    Color color;

    switch (result.type) {
      case SearchResultType.document:
        iconData = Icons.description;
        color = Colors.blue;
        break;
      case SearchResultType.faq:
        iconData = Icons.help;
        color = Colors.green;
        break;
      case SearchResultType.conversation:
        iconData = Icons.chat;
        color = Colors.orange;
        break;
      case SearchResultType.knowledgeBase:
        iconData = Icons.library_books;
        color = Colors.purple;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _buildScoreChip() {
    final scorePercentage = (result.score * 100).round();
    final color = _getScoreColor(result.score);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$scorePercentage%',
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
        color: AppColors.textSecondary,
      ),
      onSelected: _handleAction,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'save',
          child: Row(
            children: [
              Icon(Icons.bookmark_add),
              SizedBox(width: 8),
              Text('保存'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share),
              SizedBox(width: 8),
              Text('分享'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'feedback',
          child: Row(
            children: [
              Icon(Icons.feedback),
              SizedBox(width: 8),
              Text('反馈'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHighlightedText(
          result.snippet,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          maxLines: 3,
        ),
        if (result.highlights.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildHighlights(),
        ],
      ],
    );
  }

  Widget _buildHighlights() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '关键片段',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...result.highlights.take(2).map((highlight) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildHighlightedText(
              highlight,
              style: AppTextStyles.bodySmall.copyWith(
                height: 1.3,
              ),
              maxLines: 2,
            ),
          )),
          if (result.highlights.length > 2) ...[
            Text(
              '还有 ${result.highlights.length - 2} 个匹配片段...',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadata() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: result.metadata.entries.take(3).map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Text(
            '${entry.key}: ${entry.value}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          _formatDate(result.lastUpdated),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        if (result.tags.isNotEmpty) ...[
          ...result.tags.take(2).map((tag) => Container(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tag,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontSize: 10,
              ),
            ),
          )),
          if (result.tags.length > 2) ...[
            Container(
              margin: const EdgeInsets.only(left: 4),
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${result.tags.length - 2}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildHighlightedText(
    String text, {
    required TextStyle style,
    int? maxLines,
  }) {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }

    final query = searchQuery!.toLowerCase();
    final lowerText = text.toLowerCase();
    final spans = <TextSpan>[];
    
    int start = 0;
    while (start < text.length) {
      final index = lowerText.indexOf(query, start);
      if (index == -1) {
        // 添加剩余文本
        if (start < text.length) {
          spans.add(TextSpan(
            text: text.substring(start),
            style: style,
          ));
        }
        break;
      }

      // 添加高亮前的文本
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: style,
        ));
      }

      // 添加高亮文本
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: style.copyWith(
          backgroundColor: AppColors.primary.withOpacity(0.2),
          fontWeight: FontWeight.w600,
        ),
      ));

      start = index + query.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return AppColors.success;
    if (score >= 0.6) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.month}/${date.day}';
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

  void _handleAction(String action) {
    switch (action) {
      case 'save':
        onSave?.call();
        break;
      case 'share':
        onShare?.call();
        break;
      case 'feedback':
        // 实现反馈功能
        break;
    }
  }
}

/// 搜索结果网格项组件
class SearchResultGridItem extends StatelessWidget {
  final SearchResult result;
  final String query;
  final VoidCallback? onTap;

  const SearchResultGridItem({
    super.key,
    required this.result,
    required this.query,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTypeIcon(),
                  const Spacer(),
                  if (result.score != null) _buildScoreChip(),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                result.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  result.content,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (result.lastModified != null) ...[
                const SizedBox(height: 8),
                Text(
                  _formatDate(result.lastModified!),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData iconData;
    Color iconColor;

    switch (result.type) {
      case SearchResultType.document:
        iconData = Icons.description;
        iconColor = AppColors.info;
        break;
      case SearchResultType.faq:
        iconData = Icons.quiz;
        iconColor = AppColors.success;
        break;
      case SearchResultType.conversation:
        iconData = Icons.chat;
        iconColor = AppColors.warning;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        iconData,
        size: 16,
        color: iconColor,
      ),
    );
  }

  Widget _buildScoreChip() {
    final scoreText = '${(result.score! * 100).toInt()}%';
    final scoreColor = _getScoreColor(result.score!);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: scoreColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        scoreText,
        style: AppTextStyles.bodySmall.copyWith(
          color: scoreColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return AppColors.success;
    if (score >= 0.6) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

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