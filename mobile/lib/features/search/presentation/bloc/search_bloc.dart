import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/search_result.dart';
import '../../domain/usecases/search_use_cases.dart';
import 'search_event.dart';
import 'search_state.dart';

/// 搜索BLoC
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchUseCase _searchUseCase;
  final SearchDocumentsUseCase _searchDocumentsUseCase;
  final SearchFaqsUseCase _searchFaqsUseCase;
  final GetRecommendationsUseCase _getRecommendationsUseCase;
  final SharedPreferences _sharedPreferences;

  // 搜索历史缓存键
  static const String _searchHistoryKey = 'search_history';

  // 当前搜索状态缓存
  String? _lastQuery;
  SearchType _currentSearchType = SearchType.hybrid;
  SearchOptions _currentOptions = const SearchOptions();
  final List<String> _searchHistory = [];

  SearchBloc({
    required SearchUseCase searchUseCase,
    required SearchDocumentsUseCase searchDocumentsUseCase,
    required SearchFaqsUseCase searchFaqsUseCase,
    required GetRecommendationsUseCase getRecommendationsUseCase,
    required SharedPreferences sharedPreferences,
  })  : _searchUseCase = searchUseCase,
        _searchDocumentsUseCase = searchDocumentsUseCase,
        _searchFaqsUseCase = searchFaqsUseCase,
        _getRecommendationsUseCase = getRecommendationsUseCase,
        _sharedPreferences = sharedPreferences,
        super(const SearchInitial()) {
    // 注册事件处理器
    on<SearchPerformed>(_onSearchPerformed);
    on<SearchDocumentsPerformed>(_onSearchDocumentsPerformed);
    on<SearchFaqsPerformed>(_onSearchFaqsPerformed);
    on<RecommendationsRequested>(_onRecommendationsRequested);
    on<SearchResultsCleared>(_onSearchResultsCleared);
    on<SearchOptionsUpdated>(_onSearchOptionsUpdated);
    on<SearchHistoryRequested>(_onSearchHistoryRequested);
    on<SearchHistoryAdded>(_onSearchHistoryAdded);
    on<SearchHistoryCleared>(_onSearchHistoryCleared);
    on<SearchHistoryItemRemoved>(_onSearchHistoryItemRemoved);
    on<SearchTypeChanged>(_onSearchTypeChanged);
    on<SearchRetried>(_onSearchRetried);
    on<LoadMoreSearchResults>(_onLoadMoreSearchResults);
    on<SearchResultsRefreshed>(_onSearchResultsRefreshed);

    // 初始化时加载搜索历史
    _loadSearchHistory();
  }

  /// 处理混合搜索事件
  Future<void> _onSearchPerformed(
    SearchPerformed event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(const SearchLoading());

    _lastQuery = event.query;
    _currentSearchType = SearchType.hybrid;
    _currentOptions = event.options;

    final result = await _searchUseCase(SearchParams(
      query: event.query,
      options: event.options,
    ));

    result.fold(
      (failure) => emit(SearchFailure(
        failure: failure,
        lastQuery: event.query,
        lastSearchType: SearchType.hybrid,
      )),
      (results) {
        emit(SearchSuccess(
          query: event.query,
          searchType: SearchType.hybrid,
          hybridResults: results,
          options: event.options,
        ));
        _addToSearchHistory(event.query);
      },
    );
  }

  /// 处理文档搜索事件
  Future<void> _onSearchDocumentsPerformed(
    SearchDocumentsPerformed event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(const SearchLoading());

    _lastQuery = event.query;
    _currentSearchType = SearchType.documents;
    _currentOptions = event.options;

    final result = await _searchDocumentsUseCase(SearchParams(
      query: event.query,
      options: event.options,
    ));

    result.fold(
      (failure) => emit(SearchFailure(
        failure: failure,
        lastQuery: event.query,
        lastSearchType: SearchType.documents,
      )),
      (results) {
        emit(SearchSuccess(
          query: event.query,
          searchType: SearchType.documents,
          documentResults: results,
          options: event.options,
        ));
        _addToSearchHistory(event.query);
      },
    );
  }

  /// 处理FAQ搜索事件
  Future<void> _onSearchFaqsPerformed(
    SearchFaqsPerformed event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(const SearchLoading());

    _lastQuery = event.query;
    _currentSearchType = SearchType.faqs;
    _currentOptions = event.options;

    final result = await _searchFaqsUseCase(SearchParams(
      query: event.query,
      options: event.options,
    ));

    result.fold(
      (failure) => emit(SearchFailure(
        failure: failure,
        lastQuery: event.query,
        lastSearchType: SearchType.faqs,
      )),
      (results) {
        emit(SearchSuccess(
          query: event.query,
          searchType: SearchType.faqs,
          faqResults: results,
          options: event.options,
        ));
        _addToSearchHistory(event.query);
      },
    );
  }

  /// 处理推荐内容请求事件
  Future<void> _onRecommendationsRequested(
    RecommendationsRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());

    _currentSearchType = SearchType.recommendations;

    final result = await _getRecommendationsUseCase(RecommendationParams(
      options: event.options,
    ));

    result.fold(
      (failure) => emit(RecommendationsFailure(failure: failure)),
      (recommendations) => emit(RecommendationsLoaded(
        recommendations: recommendations,
        options: event.options,
      )),
    );
  }

  /// 处理清除搜索结果事件
  void _onSearchResultsCleared(
    SearchResultsCleared event,
    Emitter<SearchState> emit,
  ) {
    _lastQuery = null;
    emit(const SearchInitial());
  }

  /// 处理搜索选项更新事件
  void _onSearchOptionsUpdated(
    SearchOptionsUpdated event,
    Emitter<SearchState> emit,
  ) {
    _currentOptions = event.options;
    emit(SearchOptionsUpdatedState(options: event.options));
  }

  /// 处理搜索历史请求事件
  void _onSearchHistoryRequested(
    SearchHistoryRequested event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchHistoryLoaded(history: List.from(_searchHistory)));
  }

  /// 处理添加搜索历史事件
  void _onSearchHistoryAdded(
    SearchHistoryAdded event,
    Emitter<SearchState> emit,
  ) {
    _addToSearchHistory(event.query);
    emit(SearchHistoryLoaded(history: List.from(_searchHistory)));
  }

  /// 处理清除搜索历史事件
  void _onSearchHistoryCleared(
    SearchHistoryCleared event,
    Emitter<SearchState> emit,
  ) {
    _searchHistory.clear();
    _saveSearchHistory();
    emit(const SearchHistoryLoaded(history: []));
  }

  /// 处理删除搜索历史项事件
  void _onSearchHistoryItemRemoved(
    SearchHistoryItemRemoved event,
    Emitter<SearchState> emit,
  ) {
    _searchHistory.remove(event.query);
    _saveSearchHistory();
    emit(SearchHistoryLoaded(history: List.from(_searchHistory)));
  }

  /// 处理搜索类型切换事件
  void _onSearchTypeChanged(
    SearchTypeChanged event,
    Emitter<SearchState> emit,
  ) {
    _currentSearchType = event.searchType;
    
    // 如果有上次搜索的查询，则执行相应类型的搜索
    if (_lastQuery != null && _lastQuery!.isNotEmpty) {
      switch (event.searchType) {
        case SearchType.hybrid:
          add(SearchPerformed(query: _lastQuery!, options: _currentOptions));
          break;
        case SearchType.documents:
          add(SearchDocumentsPerformed(query: _lastQuery!, options: _currentOptions));
          break;
        case SearchType.faqs:
          add(SearchFaqsPerformed(query: _lastQuery!, options: _currentOptions));
          break;
        case SearchType.recommendations:
          add(const RecommendationsRequested());
          break;
      }
    }
  }

  /// 处理重试搜索事件
  void _onSearchRetried(
    SearchRetried event,
    Emitter<SearchState> emit,
  ) {
    if (_lastQuery != null && _lastQuery!.isNotEmpty) {
      switch (_currentSearchType) {
        case SearchType.hybrid:
          add(SearchPerformed(query: _lastQuery!, options: _currentOptions));
          break;
        case SearchType.documents:
          add(SearchDocumentsPerformed(query: _lastQuery!, options: _currentOptions));
          break;
        case SearchType.faqs:
          add(SearchFaqsPerformed(query: _lastQuery!, options: _currentOptions));
          break;
        case SearchType.recommendations:
          add(const RecommendationsRequested());
          break;
      }
    }
  }

  /// 处理加载更多结果事件
  Future<void> _onLoadMoreSearchResults(
    LoadMoreSearchResults event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchSuccess || 
        currentState.hasReachedMax || 
        _lastQuery == null) {
      return;
    }

    emit(currentState.copyWith(isRefreshing: false));
    
    // 计算新的偏移量
    final currentOffset = _currentOptions.offset ?? 0;
    final limit = _currentOptions.limit ?? 20;
    final newOptions = _currentOptions.copyWith(
      offset: currentOffset + limit,
    );

    switch (_currentSearchType) {
      case SearchType.hybrid:
        final result = await _searchUseCase(SearchParams(
          query: _lastQuery!,
          options: newOptions,
        ));
        
        result.fold(
          (failure) => emit(SearchFailure(
            failure: failure,
            lastQuery: _lastQuery,
            lastSearchType: _currentSearchType,
          )),
          (newResults) {
            final hasReachedMax = newResults.documents.isEmpty && newResults.faqs.isEmpty;
            
            // 合并结果
            final updatedHybridResults = HybridSearchResults(
              query: currentState.hybridResults!.query,
              documents: [
                ...currentState.hybridResults!.documents,
                ...newResults.documents,
              ],
              faqs: [
                ...currentState.hybridResults!.faqs,
                ...newResults.faqs,
              ],
              total: (currentState.hybridResults!.documents.length + newResults.documents.length) +
                     (currentState.hybridResults!.faqs.length + newResults.faqs.length),
              timestamp: DateTime.now(),
              totalDocuments: newResults.totalDocuments,
              totalFaqs: newResults.totalFaqs,
            );
            
            emit(currentState.copyWith(
              hybridResults: updatedHybridResults,
              hasReachedMax: hasReachedMax,
            ));
          },
        );
        break;
        
      case SearchType.documents:
        final result = await _searchDocumentsUseCase(SearchParams(
          query: _lastQuery!,
          options: newOptions,
        ));
        
        result.fold(
          (failure) => emit(SearchFailure(
            failure: failure,
            lastQuery: _lastQuery,
            lastSearchType: _currentSearchType,
          )),
          (newResults) {
            final hasReachedMax = newResults.isEmpty;
            
            emit(currentState.copyWith(
              documentResults: [
                ...currentState.documentResults!,
                ...newResults,
              ],
              hasReachedMax: hasReachedMax,
            ));
          },
        );
        break;
        
      case SearchType.faqs:
        final result = await _searchFaqsUseCase(SearchParams(
          query: _lastQuery!,
          options: newOptions,
        ));
        
        result.fold(
          (failure) => emit(SearchFailure(
            failure: failure,
            lastQuery: _lastQuery,
            lastSearchType: _currentSearchType,
          )),
          (newResults) {
            final hasReachedMax = newResults.isEmpty;
            
            emit(currentState.copyWith(
              faqResults: [
                ...currentState.faqResults!,
                ...newResults,
              ],
              hasReachedMax: hasReachedMax,
            ));
          },
        );
        break;
        
      case SearchType.recommendations:
        // 推荐内容不支持分页
        break;
    }
  }

  /// 处理刷新搜索结果事件
  void _onSearchResultsRefreshed(
    SearchResultsRefreshed event,
    Emitter<SearchState> emit,
  ) {
    if (_lastQuery != null && _lastQuery!.isNotEmpty) {
      // 重置选项的偏移量
      final refreshOptions = _currentOptions.copyWith(offset: 0);
      _currentOptions = refreshOptions;
      
      switch (_currentSearchType) {
        case SearchType.hybrid:
          add(SearchPerformed(query: _lastQuery!, options: refreshOptions));
          break;
        case SearchType.documents:
          add(SearchDocumentsPerformed(query: _lastQuery!, options: refreshOptions));
          break;
        case SearchType.faqs:
          add(SearchFaqsPerformed(query: _lastQuery!, options: refreshOptions));
          break;
        case SearchType.recommendations:
          add(const RecommendationsRequested());
          break;
      }
    }
  }

  /// 添加到搜索历史
  void _addToSearchHistory(String query) {
    if (query.trim().isEmpty) return;
    
    // 移除已存在的相同查询
    _searchHistory.remove(query);
    
    // 添加到列表开头
    _searchHistory.insert(0, query);
    
    // 限制历史记录数量（最多保存20条）
    if (_searchHistory.length > 20) {
      _searchHistory.removeRange(20, _searchHistory.length);
    }
    
    _saveSearchHistory();
  }

  /// 加载搜索历史
  void _loadSearchHistory() {
    final history = _sharedPreferences.getStringList(_searchHistoryKey) ?? [];
    _searchHistory.clear();
    _searchHistory.addAll(history);
  }

  /// 保存搜索历史
  void _saveSearchHistory() {
    _sharedPreferences.setStringList(_searchHistoryKey, _searchHistory);
  }

  /// 获取当前搜索查询
  String? get currentQuery => _lastQuery;

  /// 获取当前搜索类型
  SearchType get currentSearchType => _currentSearchType;

  /// 获取当前搜索选项
  SearchOptions get currentOptions => _currentOptions;

  /// 获取搜索历史
  List<String> get searchHistory => List.unmodifiable(_searchHistory);
} 