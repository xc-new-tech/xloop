import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/search_state.dart';

/// 搜索结果卡片组件
class SearchResultCard extends StatelessWidget {
  final SearchResult result;
  final String? searchQuery;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;

  const SearchResultCard({
    super.key,
    required this.result,
    this.searchQuery,
    this.onTap,
    this.onBookmark,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题和类型
              Row(
                children: [
                  _buildTypeIcon(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 相关度评分
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getScoreColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(result.score * 100).toInt()}%',
                      style: TextStyle(
                        color: _getScoreColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 内容摘要
              Text(
                result.summary ?? result.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // 底部信息栏
              Row(
                children: [
                  // 时间信息
                  if (result.updatedAt != null) ...[
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(result.updatedAt!),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // 操作按钮
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onBookmark != null)
                        IconButton(
                          icon: const Icon(Icons.bookmark_border),
                          iconSize: 20,
                          onPressed: onBookmark,
                          tooltip: '收藏',
                        ),
                      if (onShare != null)
                        IconButton(
                          icon: const Icon(Icons.share),
                          iconSize: 20,
                          onPressed: onShare,
                          tooltip: '分享',
                        ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        iconSize: 16,
                        onPressed: onTap,
                        tooltip: '查看详情',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData iconData;
    Color iconColor;
    
    switch (result.type.toLowerCase()) {
      case 'document':
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case 'faq':
        iconData = Icons.quiz;
        iconColor = Colors.green;
        break;
      case 'knowledge_base':
        iconData = Icons.library_books;
        iconColor = Colors.orange;
        break;
      case 'conversation':
        iconData = Icons.chat;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.article;
        iconColor = AppColors.textSecondary;
    }
    
    return Icon(
      iconData,
      size: 20,
      color: iconColor,
    );
  }

  Color _getScoreColor() {
    if (result.score >= 0.8) {
      return Colors.green;
    } else if (result.score >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 30) {
      return '${date.month}月${date.day}日';
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
} 