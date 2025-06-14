import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_event.dart';
import 'search_state.dart';

/// 搜索BLoC的临时实现
class SearchBlocImpl extends Bloc<SearchEvent, SearchState> {
  SearchBlocImpl() : super(const SearchInitial()) {
    on<SearchTextChangedEvent>(_onSearchTextChanged);
    on<SemanticSearchEvent>(_onSemanticSearch);
    on<KeywordSearchEvent>(_onKeywordSearch);
    on<HybridSearchEvent>(_onHybridSearch);
    on<GetSearchSuggestionsEvent>(_onGetSearchSuggestions);
    on<LoadSearchHistoryEvent>(_onLoadSearchHistory);
    on<ClearSearchHistoryEvent>(_onClearSearchHistory);
    on<ClearSearchResultsEvent>(_onClearSearchResults);
  }

  void _onSearchTextChanged(SearchTextChangedEvent event, Emitter<SearchState> emit) {
    // 临时实现
    emit(SearchLoading());
    // 模拟延迟
    Future.delayed(const Duration(milliseconds: 300), () {
      emit(SearchLoaded(
        results: [],
        query: event.query,
        hasMore: false,
        totalCount: 0,
      ));
    });
  }

  void _onSemanticSearch(SemanticSearchEvent event, Emitter<SearchState> emit) {
    emit(SearchLoading());
    // 临时实现 - 返回空结果
    Future.delayed(const Duration(seconds: 1), () {
      emit(SearchLoaded(
        results: [],
        query: event.query,
        hasMore: false,
        totalCount: 0,
      ));
    });
  }

  void _onKeywordSearch(KeywordSearchEvent event, Emitter<SearchState> emit) {
    emit(SearchLoading());
    // 临时实现 - 返回空结果
    Future.delayed(const Duration(seconds: 1), () {
      emit(SearchLoaded(
        results: [],
        query: event.query,
        hasMore: false,
        totalCount: 0,
      ));
    });
  }

  void _onHybridSearch(HybridSearchEvent event, Emitter<SearchState> emit) {
    emit(SearchLoading());
    // 临时实现 - 返回空结果
    Future.delayed(const Duration(seconds: 1), () {
      emit(SearchLoaded(
        results: [],
        query: event.query,
        hasMore: false,
        totalCount: 0,
      ));
    });
  }

  void _onGetSearchSuggestions(GetSearchSuggestionsEvent event, Emitter<SearchState> emit) {
    // 临时实现 - 返回空建议
    emit(SearchSuggestionsLoaded(suggestions: []));
  }

  void _onLoadSearchHistory(LoadSearchHistoryEvent event, Emitter<SearchState> emit) {
    // 临时实现 - 返回空历史
    emit(SearchHistoryLoaded(history: []));
  }

  void _onClearSearchHistory(ClearSearchHistoryEvent event, Emitter<SearchState> emit) {
    // 临时实现
    emit(SearchHistoryLoaded(history: []));
  }

  void _onClearSearchResults(ClearSearchResultsEvent event, Emitter<SearchState> emit) {
    emit(const SearchInitial());
  }
} 