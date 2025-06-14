import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 搜索建议数据
class SearchSuggestion {
  final String text;
  final SearchSuggestionType type;
  final String? category;
  final int? frequency;
  final DateTime? lastUsed;

  const SearchSuggestion({
    required this.text,
    required this.type,
    this.category,
    this.frequency,
    this.lastUsed,
  });
}

/// 搜索建议类型
enum SearchSuggestionType {
  history,
  smart,
  popular,
  related,
}

/// 搜索建议组件
class SearchSuggestionWidget extends StatelessWidget {
  final List<SearchSuggestion> suggestions;
  final ValueChanged<String>? onSuggestionSelected;
  final ValueChanged<SearchSuggestion>? onSuggestionRemoved;
  final VoidCallback? onClearHistory;
  final bool showHistory;
  final bool showSmart;
  final bool showPopular;
  final int maxSuggestions;

  const SearchSuggestionWidget({
    super.key,
    required this.suggestions,
    this.onSuggestionSelected,
    this.onSuggestionRemoved,
    this.onClearHistory,
    this.showHistory = true,
    this.showSmart = true,
    this.showPopular = true,
    this.maxSuggestions = 10,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return _buildEmptyState();
    }

    final groupedSuggestions = _groupSuggestions();
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (groupedSuggestions[SearchSuggestionType.smart]?.isNotEmpty == true) ...[
            _buildSectionHeader('智能建议', Icons.lightbulb),
            ...groupedSuggestions[SearchSuggestionType.smart]!
                .take(3)
                .map((suggestion) => _buildSuggestionItem(suggestion)),
          ],
          if (groupedSuggestions[SearchSuggestionType.popular]?.isNotEmpty == true) ...[
            _buildSectionHeader('热门搜索', Icons.trending_up),
            ...groupedSuggestions[SearchSuggestionType.popular]!
                .take(3)
                .map((suggestion) => _buildSuggestionItem(suggestion)),
          ],
          if (groupedSuggestions[SearchSuggestionType.history]?.isNotEmpty == true) ...[
            _buildSectionHeader(
              '搜索历史', 
              Icons.history,
              action: onClearHistory != null ? _buildClearHistoryButton() : null,
            ),
            ...groupedSuggestions[SearchSuggestionType.history]!
                .take(5)
                .map((suggestion) => _buildSuggestionItem(suggestion)),
          ],
          if (groupedSuggestions[SearchSuggestionType.related]?.isNotEmpty == true) ...[
            _buildSectionHeader('相关建议', Icons.link),
            ...groupedSuggestions[SearchSuggestionType.related]!
                .take(3)
                .map((suggestion) => _buildSuggestionItem(suggestion)),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            '开始输入以获取搜索建议',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '支持语义搜索、关键词搜索等多种方式',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Widget? action}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _buildClearHistoryButton() {
    return TextButton(
      onPressed: onClearHistory,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        '清除',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(SearchSuggestion suggestion) {
    return InkWell(
      onTap: () => onSuggestionSelected?.call(suggestion.text),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildSuggestionIcon(suggestion.type),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.text,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (suggestion.category != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      suggestion.category!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (suggestion.frequency != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${suggestion.frequency}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (suggestion.type == SearchSuggestionType.history) ...[
              IconButton(
                onPressed: () => onSuggestionRemoved?.call(suggestion),
                icon: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
            ] else ...[
              const Icon(
                Icons.north_west,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionIcon(SearchSuggestionType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case SearchSuggestionType.history:
        iconData = Icons.history;
        color = AppColors.textSecondary;
        break;
      case SearchSuggestionType.smart:
        iconData = Icons.auto_awesome;
        color = AppColors.primary;
        break;
      case SearchSuggestionType.popular:
        iconData = Icons.trending_up;
        color = AppColors.success;
        break;
      case SearchSuggestionType.related:
        iconData = Icons.link;
        color = AppColors.info;
        break;
    }

    return Icon(
      iconData,
      size: 16,
      color: color,
    );
  }

  Map<SearchSuggestionType, List<SearchSuggestion>> _groupSuggestions() {
    final grouped = <SearchSuggestionType, List<SearchSuggestion>>{};
    
    for (final suggestion in suggestions) {
      grouped.putIfAbsent(suggestion.type, () => []).add(suggestion);
    }

    // 排序每个组的建议
    grouped.forEach((type, suggestions) {
      switch (type) {
        case SearchSuggestionType.history:
          suggestions.sort((a, b) => 
            (b.lastUsed ?? DateTime(0)).compareTo(a.lastUsed ?? DateTime(0))
          );
          break;
        case SearchSuggestionType.popular:
          suggestions.sort((a, b) => 
            (b.frequency ?? 0).compareTo(a.frequency ?? 0)
          );
          break;
        case SearchSuggestionType.smart:
        case SearchSuggestionType.related:
          // 保持原有顺序或按相关性排序
          break;
      }
    });

    return grouped;
  }
}

/// 快速搜索按钮组件
class QuickSearchWidget extends StatelessWidget {
  final List<String> quickSearchItems;
  final ValueChanged<String>? onQuickSearchSelected;

  const QuickSearchWidget({
    super.key,
    required this.quickSearchItems,
    this.onQuickSearchSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (quickSearchItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '快速搜索',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: quickSearchItems.map((item) => 
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(item),
                    onPressed: () => onQuickSearchSelected?.call(item),
                    backgroundColor: AppColors.surface,
                    side: BorderSide(color: AppColors.border),
                    labelStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
} 