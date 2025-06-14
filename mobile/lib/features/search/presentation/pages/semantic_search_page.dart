import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/search_result_card.dart';
import '../widgets/search_filter_widget.dart';
import '../widgets/search_suggestions_widget.dart';
import '../../domain/entities/search_result.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../features/shared/presentation/widgets/custom_app_bar.dart';
import '../../../../features/shared/presentation/widgets/error_widget.dart';

/// 语义搜索页面
class SemanticSearchPage extends StatefulWidget {
  final String? initialQuery;
  final String? knowledgeBaseId;

  const SemanticSearchPage({
    super.key,
    this.initialQuery,
    this.knowledgeBaseId,
  });

  @override
  State<SemanticSearchPage> createState() => _SemanticSearchPageState();
}

class _SemanticSearchPageState extends State<SemanticSearchPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  String _currentQuery = '';
  SearchMode _searchMode = SearchMode.semantic;
  bool _showFilters = false;
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController(text: widget.initialQuery);
    _currentQuery = widget.initialQuery ?? '';
    
    // 加载搜索历史
    _loadSearchHistory();
    
    // 如果有初始查询，执行搜索
    if (widget.initialQuery?.isNotEmpty == true) {
      _performSearch();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadSearchHistory() {
    context.read<SearchBloc>().add(const LoadSearchHistoryEvent());
  }

  void _performSearch() {
    if (_currentQuery.trim().isEmpty) return;

    context.read<SearchBloc>().add(_getSearchEvent());
    _addToSearchHistory(_currentQuery);
    _searchFocusNode.unfocus();
  }

  SearchEvent _getSearchEvent() {
    switch (_searchMode) {
      case SearchMode.semantic:
        return SemanticSearchEvent(
          query: _currentQuery,
          knowledgeBaseId: widget.knowledgeBaseId,
        );
      case SearchMode.keyword:
        return KeywordSearchEvent(
          query: _currentQuery,
          knowledgeBaseId: widget.knowledgeBaseId,
        );
      case SearchMode.hybrid:
        return HybridSearchEvent(
          query: _currentQuery,
          knowledgeBaseId: widget.knowledgeBaseId,
        );
    }
  }

  void _addToSearchHistory(String query) {
    if (!_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.take(10).toList();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchSection(),
          if (_showFilters) _buildFilterSection(),
          _buildTabBar(),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar.withBackButton(
      title: '智能搜索',
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _showFilters = !_showFilters;
            });
          },
          icon: Icon(
            _showFilters ? Icons.filter_list_off : Icons.filter_list,
          ),
          tooltip: '筛选器',
        ),
        PopupMenuButton<SearchMode>(
          onSelected: (mode) {
            setState(() {
              _searchMode = mode;
            });
            if (_currentQuery.isNotEmpty) {
              _performSearch();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: SearchMode.semantic,
              child: ListTile(
                leading: Icon(
                  Icons.psychology,
                  color: _searchMode == SearchMode.semantic ? AppColors.primary : null,
                ),
                title: Text(
                  '语义搜索',
                  style: TextStyle(
                    color: _searchMode == SearchMode.semantic ? AppColors.primary : null,
                    fontWeight: _searchMode == SearchMode.semantic ? FontWeight.w600 : null,
                  ),
                ),
                subtitle: const Text('基于语义理解的智能搜索'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: SearchMode.keyword,
              child: ListTile(
                leading: Icon(
                  Icons.search,
                  color: _searchMode == SearchMode.keyword ? AppColors.primary : null,
                ),
                title: Text(
                  '关键词搜索',
                  style: TextStyle(
                    color: _searchMode == SearchMode.keyword ? AppColors.primary : null,
                    fontWeight: _searchMode == SearchMode.keyword ? FontWeight.w600 : null,
                  ),
                ),
                subtitle: const Text('基于关键词匹配的精确搜索'),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: SearchMode.hybrid,
              child: ListTile(
                leading: Icon(
                  Icons.auto_awesome,
                  color: _searchMode == SearchMode.hybrid ? AppColors.primary : null,
                ),
                title: Text(
                  '混合搜索',
                  style: TextStyle(
                    color: _searchMode == SearchMode.hybrid ? AppColors.primary : null,
                    fontWeight: _searchMode == SearchMode.hybrid ? FontWeight.w600 : null,
                  ),
                ),
                subtitle: const Text('结合语义和关键词的综合搜索'),
                dense: true,
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getSearchModeIcon()),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索模式指示器
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getSearchModeIcon(),
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  _getSearchModeText(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 搜索框
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: _getSearchHint(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _currentQuery = '';
                        });
                        context.read<SearchBloc>().add(const ClearSearchResultsEvent());
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  IconButton(
                    onPressed: _currentQuery.trim().isNotEmpty ? _performSearch : null,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _currentQuery = value;
              });
              // 获取搜索建议
              if (value.trim().isNotEmpty) {
                context.read<SearchBloc>().add(GetSearchSuggestionsEvent(value.trim()));
              }
            },
            onSubmitted: (value) {
              setState(() {
                _currentQuery = value;
              });
              _performSearch();
            },
            textInputAction: TextInputAction.search,
          ),
          // 搜索建议
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is SearchSuggestionsLoaded && 
                  state.suggestions.isNotEmpty && 
                  _searchFocusNode.hasFocus) {
                return Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: SearchSuggestionWidget(
                    suggestions: state.suggestions,
                    onSuggestionSelected: (suggestion) {
                      _searchController.text = suggestion;
                      setState(() {
                        _currentQuery = suggestion;
                      });
                      _performSearch();
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // 搜索历史
          if (_searchHistory.isNotEmpty && _searchFocusNode.hasFocus) ...[
            const SizedBox(height: 12),
            Text(
              '最近搜索',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchHistory.take(5).map((query) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = query;
                    setState(() {
                      _currentQuery = query;
                    });
                    _performSearch();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          query,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return SearchFilterWidget(
      onFiltersChanged: (filters) {
        // 应用筛选器并重新搜索
        if (_currentQuery.isNotEmpty) {
          _performSearch();
        }
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(
            icon: Icon(Icons.select_all),
            text: '全部',
          ),
          Tab(
            icon: Icon(Icons.description),
            text: '文档',
          ),
          Tab(
            icon: Icon(Icons.quiz),
            text: 'FAQ',
          ),
        ],
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchInitial) {
          return _buildEmptyState();
        }

        if (state is SearchLoading) {
          return const LoadingWidget(message: '搜索中...');
        }

        if (state is SearchError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: _performSearch,
          );
        }

        if (state is SearchLoaded) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildResultsList(state.results, 'all'),
              _buildResultsList(
                state.results.where((r) => r.type == SearchResultType.document).toList(),
                'documents',
              ),
              _buildResultsList(
                state.results.where((r) => r.type == SearchResultType.faq).toList(),
                'faqs',
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getSearchModeIcon(),
            size: 64,
            color: AppColors.iconSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            '开始您的智能搜索',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getSearchModeDescription(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildQuickSearchSuggestions(),
        ],
      ),
    );
  }

  Widget _buildQuickSearchSuggestions() {
    final suggestions = [
      '如何使用平台？',
      '数据导入流程',
      '常见问题',
      '功能介绍',
    ];

    return Column(
      children: [
        Text(
          '试试这些搜索：',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((suggestion) {
            return GestureDetector(
              onTap: () {
                _searchController.text = suggestion;
                setState(() {
                  _currentQuery = suggestion;
                });
                _performSearch();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  suggestion,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResultsList(List<SearchResult> results, String category) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.iconSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              '未找到相关结果',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '尝试调整搜索关键词或搜索模式',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final result = results[index];
        return SearchResultItem(
          result: result,
          query: _currentQuery,
          onTap: () => _openResult(result),
        );
      },
    );
  }

  void _openResult(SearchResult result) {
    // 实现打开搜索结果的逻辑
    switch (result.type) {
      case SearchResultType.document:
        // 打开文档详情页
        break;
      case SearchResultType.faq:
        // 打开FAQ详情页
        break;
      case SearchResultType.conversation:
        // 打开对话记录
        break;
    }
  }

  IconData _getSearchModeIcon() {
    switch (_searchMode) {
      case SearchMode.semantic:
        return Icons.psychology;
      case SearchMode.keyword:
        return Icons.search;
      case SearchMode.hybrid:
        return Icons.auto_awesome;
    }
  }

  String _getSearchModeText() {
    switch (_searchMode) {
      case SearchMode.semantic:
        return '语义搜索';
      case SearchMode.keyword:
        return '关键词搜索';
      case SearchMode.hybrid:
        return '混合搜索';
    }
  }

  String _getSearchModeDescription() {
    switch (_searchMode) {
      case SearchMode.semantic:
        return '通过理解语义含义，找到最相关的内容\n即使用词不同，也能找到相关结果';
      case SearchMode.keyword:
        return '通过精确匹配关键词，找到包含特定词汇的内容\n适合查找具体信息';
      case SearchMode.hybrid:
        return '结合语义理解和关键词匹配\n提供最全面和准确的搜索结果';
    }
  }

  String _getSearchHint() {
    switch (_searchMode) {
      case SearchMode.semantic:
        return '描述您要查找的内容...';
      case SearchMode.keyword:
        return '输入关键词...';
      case SearchMode.hybrid:
        return '输入查询内容...';
    }
  }
}

/// 搜索模式枚举
enum SearchMode {
  semantic,
  keyword,
  hybrid,
} 