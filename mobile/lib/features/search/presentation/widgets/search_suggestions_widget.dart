import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// 搜索建议组件
class SearchSuggestionsWidget extends StatelessWidget {
  final List<String> suggestions;
  final List<String> searchHistory;
  final ValueChanged<String> onSuggestionSelected;
  final ValueChanged<String> onHistorySelected;
  final VoidCallback? onClearHistory;

  const SearchSuggestionsWidget({
    super.key,
    required this.suggestions,
    required this.searchHistory,
    required this.onSuggestionSelected,
    required this.onHistorySelected,
    this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    final hasSuggestions = suggestions.isNotEmpty;
    final hasHistory = searchHistory.isNotEmpty;

    if (!hasSuggestions && !hasHistory) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
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
          // 搜索建议
          if (hasSuggestions) ...[
            _buildSectionHeader(
              context,
              '搜索建议',
              Icons.lightbulb_outline,
            ),
            ...suggestions.take(5).map((suggestion) => _buildSuggestionItem(
              context,
              suggestion,
              Icons.search,
              () => onSuggestionSelected(suggestion),
            )),
          ],

          // 分隔线
          if (hasSuggestions && hasHistory)
            const Divider(height: 1),

          // 搜索历史
          if (hasHistory) ...[
            _buildSectionHeader(
              context,
              '最近搜索',
              Icons.history,
              onClearHistory != null
                  ? IconButton(
                      onPressed: onClearHistory,
                      icon: const Icon(Icons.clear_all),
                      iconSize: 20,
                      tooltip: '清除历史',
                    )
                  : null,
            ),
            ...searchHistory.take(8).map((query) => _buildSuggestionItem(
              context,
              query,
              Icons.history,
              () => onHistorySelected(query),
              trailing: IconButton(
                onPressed: () {
                  // 这里可以添加删除单个历史记录的逻辑
                },
                icon: const Icon(Icons.close),
                iconSize: 16,
                tooltip: '删除',
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon, [
    Widget? trailing,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
} 