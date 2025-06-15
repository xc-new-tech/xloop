import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/search_result.dart';
import 'search_event.dart';

/// 搜索状态基类
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// 搜索初始状态
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// 搜索加载中状态
class SearchLoading extends SearchState {
  const SearchLoading();
}

/// 搜索结果加载完成状态
class SearchResultsLoaded extends SearchState {
  final List<SearchResult> results;
  final String query;
  final int totalCount;
  final bool hasMore;
  final String searchMode;
  final Map<String, dynamic>? filters;

  const SearchResultsLoaded({
    required this.results,
    required this.query,
    required this.totalCount,
    this.hasMore = false,
    this.searchMode = 'semantic',
    this.filters,
  });

  @override
  List<Object?> get props => [results, query, totalCount, hasMore, searchMode, filters];

  SearchResultsLoaded copyWith({
    List<SearchResult>? results,
    String? query,
    int? totalCount,
    bool? hasMore,
    String? searchMode,
    Map<String, dynamic>? filters,
  }) {
    return SearchResultsLoaded(
      results: results ?? this.results,
      query: query ?? this.query,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      searchMode: searchMode ?? this.searchMode,
      filters: filters ?? this.filters,
    );
  }
}

/// 搜索建议加载完成状态
class SearchSuggestionsLoaded extends SearchState {
  final List<String> suggestions;

  const SearchSuggestionsLoaded({required this.suggestions});

  @override
  List<Object?> get props => [suggestions];
}

/// 搜索历史加载完成状态
class SearchHistoryLoaded extends SearchState {
  final List<String> history;

  const SearchHistoryLoaded({required this.history});

  @override
  List<Object?> get props => [history];
}

/// 搜索错误状态
class SearchError extends SearchState {
  final String message;
  final String? errorCode;

  const SearchError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// 搜索成功状态
class SearchSuccess extends SearchState {
  final String query;
  final SearchType searchType;
  final HybridSearchResults? hybridResults;
  final List<DocumentSearchResult>? documentResults;
  final List<FaqSearchResult>? faqResults;
  final SearchOptions options;
  final bool hasReachedMax;
  final bool isRefreshing;

  const SearchSuccess({
    required this.query,
    required this.searchType,
    this.hybridResults,
    this.documentResults,
    this.faqResults,
    required this.options,
    this.hasReachedMax = false,
    this.isRefreshing = false,
  });

  /// 检查是否有结果
  bool get hasResults {
    switch (searchType) {
      case SearchType.hybrid:
      case SearchType.recommendations:
        return hybridResults != null &&
            (hybridResults!.documents.isNotEmpty || hybridResults!.faqs.isNotEmpty);
      case SearchType.documents:
        return documentResults != null && documentResults!.isNotEmpty;
      case SearchType.faqs:
        return faqResults != null && faqResults!.isNotEmpty;
    }
  }

  /// 获取结果总数
  int get totalResults {
    switch (searchType) {
      case SearchType.hybrid:
      case SearchType.recommendations:
        return (hybridResults?.documents.length ?? 0) + 
               (hybridResults?.faqs.length ?? 0);
      case SearchType.documents:
        return documentResults?.length ?? 0;
      case SearchType.faqs:
        return faqResults?.length ?? 0;
    }
  }

  @override
  List<Object?> get props => [
        query,
        searchType,
        hybridResults,
        documentResults,
        faqResults,
        options,
        hasReachedMax,
        isRefreshing,
      ];

  SearchSuccess copyWith({
    String? query,
    SearchType? searchType,
    HybridSearchResults? hybridResults,
    List<DocumentSearchResult>? documentResults,
    List<FaqSearchResult>? faqResults,
    SearchOptions? options,
    bool? hasReachedMax,
    bool? isRefreshing,
  }) {
    return SearchSuccess(
      query: query ?? this.query,
      searchType: searchType ?? this.searchType,
      hybridResults: hybridResults ?? this.hybridResults,
      documentResults: documentResults ?? this.documentResults,
      faqResults: faqResults ?? this.faqResults,
      options: options ?? this.options,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// 搜索失败状态
class SearchFailure extends SearchState {
  final Failure failure;
  final String? lastQuery;
  final SearchType? lastSearchType;

  const SearchFailure({
    required this.failure,
    this.lastQuery,
    this.lastSearchType,
  });

  @override
  List<Object?> get props => [failure, lastQuery, lastSearchType];
}

/// 搜索选项更新状态
class SearchOptionsUpdatedState extends SearchState {
  final SearchOptions options;

  const SearchOptionsUpdatedState({
    required this.options,
  });

  @override
  List<Object?> get props => [options];
}

/// 推荐内容状态
class RecommendationsLoaded extends SearchState {
  final HybridSearchResults recommendations;
  final RecommendationOptions options;

  const RecommendationsLoaded({
    required this.recommendations,
    required this.options,
  });

  bool get hasRecommendations {
    return recommendations.documents.isNotEmpty || recommendations.faqs.isNotEmpty;
  }

  @override
  List<Object?> get props => [recommendations, options];
}

/// 推荐内容加载失败状态
class RecommendationsFailure extends SearchState {
  final Failure failure;

  const RecommendationsFailure({
    required this.failure,
  });

  @override
  List<Object?> get props => [failure];
}

/// 语义搜索完成状态
class SemanticSearchCompleted extends SearchState {
  final List<SearchResult> results;
  final String query;
  final Map<String, dynamic>? semanticContext;

  const SemanticSearchCompleted({
    required this.results,
    required this.query,
    this.semanticContext,
  });

  @override
  List<Object?> get props => [results, query, semanticContext];
}

/// 相似度搜索完成状态
class SimilaritySearchCompleted extends SearchState {
  final List<SearchResult> results;
  final String referenceText;
  final double threshold;

  const SimilaritySearchCompleted({
    required this.results,
    required this.referenceText,
    required this.threshold,
  });

  @override
  List<Object?> get props => [results, referenceText, threshold];
}

/// 多模态搜索完成状态
class MultimodalSearchCompleted extends SearchState {
  final List<SearchResult> results;
  final Map<String, dynamic> query;

  const MultimodalSearchCompleted({
    required this.results,
    required this.query,
  });

  @override
  List<Object?> get props => [results, query];
}

/// 搜索导出完成状态
class SearchExportCompleted extends SearchState {
  final String filePath;
  final String format;
  final int count;

  const SearchExportCompleted({
    required this.filePath,
    required this.format,
    required this.count,
  });

  @override
  List<Object?> get props => [filePath, format, count];
} 