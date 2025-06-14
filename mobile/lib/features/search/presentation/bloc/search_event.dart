import 'package:equatable/equatable.dart';

import '../../domain/entities/search_result.dart';

/// 搜索事件基类
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// 执行搜索事件
class SearchPerformed extends SearchEvent {
  final String query;
  final SearchOptions options;

  const SearchPerformed({
    required this.query,
    this.options = const SearchOptions(),
  });

  @override
  List<Object?> get props => [query, options];
}

/// 搜索文档事件
class SearchDocumentsPerformed extends SearchEvent {
  final String query;
  final SearchOptions options;

  const SearchDocumentsPerformed({
    required this.query,
    this.options = const SearchOptions(),
  });

  @override
  List<Object?> get props => [query, options];
}

/// 搜索FAQ事件
class SearchFaqsPerformed extends SearchEvent {
  final String query;
  final SearchOptions options;

  const SearchFaqsPerformed({
    required this.query,
    this.options = const SearchOptions(),
  });

  @override
  List<Object?> get props => [query, options];
}

/// 获取推荐内容事件
class RecommendationsRequested extends SearchEvent {
  final RecommendationOptions options;

  const RecommendationsRequested({
    this.options = const RecommendationOptions(),
  });

  @override
  List<Object?> get props => [options];
}

/// 清除搜索结果事件
class SearchResultsCleared extends SearchEvent {
  const SearchResultsCleared();
}

/// 更新搜索选项事件
class SearchOptionsUpdated extends SearchEvent {
  final SearchOptions options;

  const SearchOptionsUpdated({
    required this.options,
  });

  @override
  List<Object?> get props => [options];
}

/// 搜索历史事件
class SearchHistoryRequested extends SearchEvent {
  const SearchHistoryRequested();
}

/// 添加到搜索历史事件
class SearchHistoryAdded extends SearchEvent {
  final String query;

  const SearchHistoryAdded({
    required this.query,
  });

  @override
  List<Object?> get props => [query];
}

/// 清除搜索历史事件
class SearchHistoryCleared extends SearchEvent {
  const SearchHistoryCleared();
}

/// 删除搜索历史项事件
class SearchHistoryItemRemoved extends SearchEvent {
  final String query;

  const SearchHistoryItemRemoved({
    required this.query,
  });

  @override
  List<Object?> get props => [query];
}

/// 切换搜索类型事件
class SearchTypeChanged extends SearchEvent {
  final SearchType searchType;

  const SearchTypeChanged({
    required this.searchType,
  });

  @override
  List<Object?> get props => [searchType];
}

/// 重试搜索事件
class SearchRetried extends SearchEvent {
  const SearchRetried();
}

/// 加载更多搜索结果事件
class LoadMoreSearchResults extends SearchEvent {
  const LoadMoreSearchResults();
}

/// 刷新搜索结果事件
class SearchResultsRefreshed extends SearchEvent {
  const SearchResultsRefreshed();
}

/// 搜索类型枚举
enum SearchType {
  /// 混合搜索（文档+FAQ）
  hybrid,
  /// 仅文档搜索
  documents,
  /// 仅FAQ搜索
  faqs,
  /// 推荐内容
  recommendations,
} 