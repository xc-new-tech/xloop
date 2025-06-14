import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_event.dart';
import 'search_state.dart';

/// 搜索BLoC的临时实现
class SearchBlocImpl extends Bloc<SearchEvent, SearchState> {
  SearchBlocImpl() : super(const SearchInitial()) {
    on<SearchPerformed>(_onSearchPerformed);
    on<SearchDocumentsPerformed>(_onSearchDocuments);
    on<SearchFaqsPerformed>(_onSearchFaqs);
    on<RecommendationsRequested>(_onRecommendationsRequested);
    on<SearchHistoryRequested>(_onLoadSearchHistory);
    on<SearchHistoryCleared>(_onClearSearchHistory);
    on<SearchResultsCleared>(_onClearSearchResults);
  }

  void _onSearchPerformed(SearchPerformed event, Emitter<SearchState> emit) {
    // 临时实现
    emit(SearchLoading());
    // 模拟延迟
    Future.delayed(const Duration(milliseconds: 300), () {
      emit(SearchResultsLoaded(
        results: [],
        query: event.query,
        hasMore: false,
        totalCount: 0,
      ));
    });
  }

  void _onSearchDocuments(SearchDocumentsPerformed event, Emitter<SearchState> emit) {
    emit(SearchLoading());
    // 临时实现 - 返回空结果
    Future.delayed(const Duration(seconds: 1), () {
      emit(SearchResultsLoaded(
        results: [],
        query: event.query,
        hasMore: false,
        totalCount: 0,
      ));
    });
  }

  void _onSearchFaqs(SearchFaqsPerformed event, Emitter<SearchState> emit) {
    emit(SearchLoading());
    // 临时实现 - 返回空结果
    Future.delayed(const Duration(seconds: 1), () {
      emit(SearchResultsLoaded(
        results: [],
        query: event.query,
        hasMore: false,
        totalCount: 0,
      ));
    });
  }

  void _onRecommendationsRequested(RecommendationsRequested event, Emitter<SearchState> emit) {
    emit(SearchLoading());
    // 临时实现 - 返回空结果
    Future.delayed(const Duration(seconds: 1), () {
      emit(SearchResultsLoaded(
        results: [],
        query: '',
        hasMore: false,
        totalCount: 0,
      ));
    });
  }

  void _onLoadSearchHistory(SearchHistoryRequested event, Emitter<SearchState> emit) {
    // 临时实现 - 返回空历史
    emit(SearchHistoryLoaded(history: []));
  }

  void _onClearSearchHistory(SearchHistoryCleared event, Emitter<SearchState> emit) {
    // 临时实现
    emit(SearchHistoryLoaded(history: []));
  }

  void _onClearSearchResults(SearchResultsCleared event, Emitter<SearchState> emit) {
    emit(const SearchInitial());
  }
} 