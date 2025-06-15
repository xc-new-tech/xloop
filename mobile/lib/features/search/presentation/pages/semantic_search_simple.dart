import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/search_result.dart';

/// 简化的语义搜索页面
/// 
/// 提供智能搜索、关键词搜索、混合搜索等功能
class SemanticSearchSimplePage extends StatefulWidget {
  final String? initialQuery;
  final String? knowledgeBaseId;

  const SemanticSearchSimplePage({
    super.key,
    this.initialQuery,
    this.knowledgeBaseId,
  });

  @override
  State<SemanticSearchSimplePage> createState() => _SemanticSearchSimplePageState();
}

class _SemanticSearchSimplePageState extends State<SemanticSearchSimplePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  SearchMode _currentMode = SearchMode.semantic;
  bool _isLoading = false;
  List<SearchResult> _results = [];
  List<String> _searchHistory = [];
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
    
    _loadSearchHistory();
    _loadMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadMockData() {
    // 模拟搜索历史
    _searchHistory = [
      'Flutter开发最佳实践',
      'API接口设计',
      '数据库优化',
      '用户认证流程',
      '性能监控方案',
    ];
    
    // 模拟搜索建议
    _suggestions = [
      'Flutter Widget生命周期',
      'RESTful API设计规范',
      'MySQL索引优化',
      'JWT认证机制',
      'Redis缓存策略',
    ];
  }

  void _loadSearchHistory() {
    // TODO: 从本地存储加载搜索历史
  }

  void _saveSearchHistory(String query) {
    if (query.trim().isNotEmpty && !_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.take(10).toList();
        }
      });
      // TODO: 保存到本地存储
    }
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    _saveSearchHistory(query);
    
    // 模拟API调用延迟
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _results = _generateMockResults(query);
        });
      }
    });
  }

  List<SearchResult> _generateMockResults(String query) {
    // 根据搜索模式生成不同的模拟结果
    return List.generate(8, (index) {
      final type = _getMockType(index);
      final score = 0.95 - (index * 0.1);
      final id = 'result_$index';
      final title = _getMockTitle(query, index);
      final content = _getMockContent(query, index);
      final createdAt = DateTime.now().subtract(Duration(days: index));
      
      if (type == SearchResultType.document) {
        return DocumentSearchResult(
          id: id,
          title: title,
          content: content,
          score: score,
          knowledgeBaseId: widget.knowledgeBaseId ?? 'default_kb',
          knowledgeBaseName: '默认知识库',
          fileName: '$title.pdf',
          filePath: '/documents/$title.pdf',
          fileType: 'pdf',
          fileSize: 1024 * (index + 1),
          category: '技术文档',
          tags: ['技术', 'guide', query.toLowerCase()],
          description: content,
          createdAt: createdAt,
          updatedAt: createdAt,
        );
      } else {
        return FaqSearchResult(
          id: id,
          title: title,
          content: content,
          score: score,
          question: title,
          answer: content,
          knowledgeBaseId: widget.knowledgeBaseId,
          knowledgeBaseName: '默认知识库',
          category: 'FAQ',
          tags: ['faq', query.toLowerCase()],
          likes: index * 5,
          dislikes: index,
          views: index * 20,
          status: 'active',
          createdAt: createdAt,
          updatedAt: createdAt,
        );
      }
    });
  }

  String _getMockTitle(String query, int index) {
    final titles = [
      '${query}完整指南 - 第${index + 1}部分',
      '深入理解$query的核心概念',
      '$query实战案例分析',
      '$query常见问题解答',
      '$query进阶技巧分享',
      '$query性能优化策略',
      '$query安全最佳实践',
      '$query开发规范文档',
    ];
    return titles[index % titles.length];
  }

  String _getMockContent(String query, int index) {
    return '这是关于$query的详细说明内容。本文档提供了全面的技术细节和实践建议，'
        '包括核心概念、实现方法、注意事项等。适合不同级别的开发者学习参考。'
        '内容包含${index + 1}个核心要点和${index + 3}个实践示例...';
  }

  SearchResultType _getMockType(int index) {
    final types = [
      SearchResultType.document,
      SearchResultType.faq,
      SearchResultType.document,
      SearchResultType.faq,
    ];
    return types[index % types.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '智能搜索',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '语义搜索'),
            Tab(text: '关键词搜索'),
            Tab(text: '混合搜索'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          onTap: (index) {
            setState(() {
              _currentMode = SearchMode.values[index];
            });
          },
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSearchContent(),
                _buildSearchContent(),
                _buildSearchContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // 搜索输入框
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: _getHintText(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _results.clear();
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.outline),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onSubmitted: _performSearch,
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          
          // 搜索按钮和筛选器
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading 
                      ? null 
                      : () => _performSearch(_searchController.text),
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: Text(_isLoading ? '搜索中...' : '开始搜索'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _showFilterDialog(),
                icon: const Icon(Icons.tune),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceVariant,
                  foregroundColor: AppColors.onSurfaceVariant,
                ),
                tooltip: '搜索筛选',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getHintText() {
    switch (_currentMode) {
      case SearchMode.semantic:
        return '用自然语言描述你要查找的内容...';
      case SearchMode.keyword:
        return '输入关键词进行精确搜索...';
      case SearchMode.hybrid:
        return '结合语义和关键词进行智能搜索...';
    }
  }

  Widget _buildSearchContent() {
    if (_results.isEmpty && !_isLoading) {
      return _buildEmptyState();
    }
    
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    return _buildResultsList();
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 搜索提示
          _buildSearchTips(),
          const SizedBox(height: 24),
          
          // 搜索历史
          if (_searchHistory.isNotEmpty) ...[
            _buildSearchHistory(),
            const SizedBox(height: 24),
          ],
          
          // 搜索建议
          _buildSearchSuggestions(),
        ],
      ),
    );
  }

  Widget _buildSearchTips() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  '搜索技巧',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_getSearchTips().map((tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.circle,
                    size: 6,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            ))),
          ],
        ),
      ),
    );
  }

  List<String> _getSearchTips() {
    switch (_currentMode) {
      case SearchMode.semantic:
        return [
          '用完整的句子描述问题，如"如何实现用户认证功能"',
          '可以用自然语言表达需求，系统会理解语义含义',
          '支持模糊匹配，即使用词不准确也能找到相关内容',
        ];
      case SearchMode.keyword:
        return [
          '使用具体的技术术语和关键词',
          '多个关键词用空格分隔，如"Flutter BLoC 状态管理"',
          '支持使用引号进行精确匹配，如"用户认证"',
        ];
      case SearchMode.hybrid:
        return [
          '结合自然语言和关键词获得最佳搜索效果',
          '系统会同时进行语义分析和关键词匹配',
          '适合复杂查询，能够找到更全面的相关内容',
        ];
    }
  }

  Widget _buildSearchHistory() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  '搜索历史',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchHistory.clear();
                    });
                  },
                  child: const Text('清空'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchHistory.map((query) => InkWell(
                onTap: () {
                  _searchController.text = query;
                  _performSearch(query);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    query,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: AppColors.secondary, size: 24),
                const SizedBox(width: 12),
                Text(
                  '热门搜索',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_suggestions.map((suggestion) => ListTile(
              dense: true,
              leading: Icon(
                Icons.trending_up,
                size: 16,
                color: AppColors.secondary,
              ),
              title: Text(
                suggestion,
                style: AppTextStyles.bodyMedium,
              ),
              onTap: () {
                _searchController.text = suggestion;
                _performSearch(suggestion);
              },
              contentPadding: EdgeInsets.zero,
            ))),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            '正在搜索...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _results.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildResultsHeader();
        }
        
        final result = _results[index - 1];
        return _buildResultItem(result);
      },
    );
  }

  Widget _buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Text(
            '找到 ${_results.length} 个相关结果',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _showSortDialog(),
            icon: const Icon(Icons.sort),
            tooltip: '排序',
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(SearchResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () => _openResult(result),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题和类型
              Row(
                children: [
                  Icon(
                    _getTypeIcon(result.type),
                    size: 16,
                    color: _getTypeColor(result.type),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.title,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(result.type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(result.score * 100).toInt()}%',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _getTypeColor(result.type),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // 内容预览
              Text(
                result.content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // 来源和时间
              Row(
                children: [
                  Icon(
                    Icons.source,
                    size: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getResultSource(result),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(result.createdAt ?? DateTime.now()),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getResultSource(SearchResult result) {
    if (result is DocumentSearchResult) {
      return result.knowledgeBaseName ?? '技术文档库';
    } else if (result is FaqSearchResult) {
      return result.knowledgeBaseName ?? 'FAQ知识库';
    }
    return '知识库';
  }

  IconData _getTypeIcon(SearchResultType type) {
    switch (type) {
      case SearchResultType.document:
        return Icons.description;
      case SearchResultType.faq:
        return Icons.quiz;
      case SearchResultType.mixed:
        return Icons.library_books;
    }
  }

  Color _getTypeColor(SearchResultType type) {
    switch (type) {
      case SearchResultType.document:
        return AppColors.primary;
      case SearchResultType.faq:
        return AppColors.secondary;
      case SearchResultType.mixed:
        return AppColors.tertiary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '昨天';
    } else if (difference < 7) {
      return '$difference天前';
    } else {
      return '${date.month}月${date.day}日';
    }
  }

  void _openResult(SearchResult result) {
    // TODO: 根据结果类型导航到相应页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('打开: ${result.title}')),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索筛选'),
        content: const Text('筛选选项开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('结果排序'),
        content: const Text('排序选项开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

// 数据模型

enum SearchMode {
  semantic,  // 语义搜索
  keyword,   // 关键词搜索
  hybrid,    // 混合搜索
}