import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/faq_repository.dart';
import '../../domain/usecases/get_faqs_usecase.dart';
import '../../domain/usecases/create_faq_usecase.dart';
import '../../domain/usecases/delete_faq_usecase.dart';
import 'faq_event.dart';
import 'faq_state.dart';

class FaqBloc extends Bloc<FaqEvent, FaqState> {
  final FaqRepository faqRepository;
  final GetFaqsUseCase getFaqsUseCase;
  final CreateFaqUseCase createFaqUseCase;
  final DeleteFaqUseCase deleteFaqUseCase;

  FaqBloc({
    required this.faqRepository,
    required this.getFaqsUseCase,
    required this.createFaqUseCase,
    required this.deleteFaqUseCase,
  }) : super(const FaqState()) {
    on<GetFaqsEvent>(_onGetFaqs);
    on<SearchFaqsEvent>(_onSearchFaqs);
    on<GetFaqByIdEvent>(_onGetFaqById);
    on<CreateFaqEvent>(_onCreateFaq);
    on<UpdateFaqEvent>(_onUpdateFaq);
    on<DeleteFaqEvent>(_onDeleteFaq);
    on<BulkDeleteFaqsEvent>(_onBulkDeleteFaqs);
    on<GetCategoriesEvent>(_onGetCategories);
    on<GetPopularFaqsEvent>(_onGetPopularFaqs);
    on<LikeFaqEvent>(_onLikeFaq);
    on<DislikeFaqEvent>(_onDislikeFaq);
    on<ToggleFaqStatusEvent>(_onToggleFaqStatus);
    on<SetFilterEvent>(_onSetFilter);
    on<SetSortEvent>(_onSetSort);
    on<ClearSearchEvent>(_onClearSearch);
    on<ResetFaqStateEvent>(_onResetFaqState);
    on<SelectFaqEvent>(_onSelectFaq);
    on<UnselectFaqEvent>(_onUnselectFaq);
    on<SelectAllFaqsEvent>(_onSelectAllFaqs);
    on<UnselectAllFaqsEvent>(_onUnselectAllFaqs);
    on<ToggleSelectionModeEvent>(_onToggleSelectionMode);
    on<EnterSelectionModeEvent>(_onEnterSelectionMode);
    on<ExitSelectionModeEvent>(_onExitSelectionMode);
    on<LoadMoreFaqsEvent>(_onLoadMoreFaqs);
    on<RefreshFaqsEvent>(_onRefreshFaqs);
  }

  /// 获取FAQ列表
  Future<void> _onGetFaqs(GetFaqsEvent event, Emitter<FaqState> emit) async {
    if (event.isRefresh) {
      emit(state.copyWith(status: FaqBlocStatus.refreshing));
    } else if (event.page == 1) {
      emit(state.copyWith(status: FaqBlocStatus.loading));
    } else {
      emit(state.copyWith(status: FaqBlocStatus.loadingMore));
    }

    final params = GetFaqsParams(
      search: event.search,
      category: event.category,
      status: event.status,
      knowledgeBaseId: event.knowledgeBaseId,
      isPublic: event.isPublic,
      sort: event.sort,
      tags: event.tags,
      page: event.page,
      limit: event.limit,
    );

    final result = await getFaqsUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: FaqBlocStatus.error,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (faqs) {
        final updatedFaqs = event.page == 1 ? faqs : state.faqs + faqs;
        final hasReachedMax = faqs.length < event.limit;
        
        emit(state.copyWith(
          status: FaqBlocStatus.success,
          faqs: updatedFaqs,
          hasReachedMax: hasReachedMax,
          currentPage: event.page,
          clearError: true,
        ));
      },
    );
  }

  /// 搜索FAQ
  Future<void> _onSearchFaqs(SearchFaqsEvent event, Emitter<FaqState> emit) async {
    if (event.isRefresh) {
      emit(state.copyWith(status: FaqBlocStatus.refreshing));
    } else if (event.page == 1) {
      emit(state.copyWith(status: FaqBlocStatus.loading));
    } else {
      emit(state.copyWith(status: FaqBlocStatus.loadingMore));
    }

    final result = await faqRepository.searchFaqs(
      filter: event.filter,
      sort: event.sort,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: FaqBlocStatus.error,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (faqs) {
        final updatedFaqs = event.page == 1 ? faqs : state.faqs + faqs;
        final hasReachedMax = faqs.length < event.limit;
        
        emit(state.copyWith(
          status: FaqBlocStatus.success,
          faqs: updatedFaqs,
          filter: event.filter,
          sort: event.sort,
          hasReachedMax: hasReachedMax,
          currentPage: event.page,
          clearError: true,
        ));
      },
    );
  }

  /// 获取FAQ详情
  Future<void> _onGetFaqById(GetFaqByIdEvent event, Emitter<FaqState> emit) async {
    emit(state.copyWith(status: FaqBlocStatus.loading));

    final result = await faqRepository.getFaqById(event.id);

    result.fold(
      (failure) => emit(state.copyWith(
        status: FaqBlocStatus.error,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (faq) => emit(state.copyWith(
        status: FaqBlocStatus.success,
        selectedFaq: faq,
        clearError: true,
      )),
    );
  }

  /// 创建FAQ
  Future<void> _onCreateFaq(CreateFaqEvent event, Emitter<FaqState> emit) async {
    emit(state.copyWith(status: FaqBlocStatus.loading));

    final result = await createFaqUseCase(event.faq);

    result.fold(
      (failure) => emit(state.copyWith(
        status: FaqBlocStatus.error,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (faq) {
        final updatedFaqs = [faq, ...state.faqs];
        emit(state.copyWith(
          status: FaqBlocStatus.success,
          faqs: updatedFaqs,
          selectedFaq: faq,
          clearError: true,
        ));
      },
    );
  }

  /// 更新FAQ
  Future<void> _onUpdateFaq(UpdateFaqEvent event, Emitter<FaqState> emit) async {
    emit(state.copyWith(status: FaqBlocStatus.loading));

    final result = await faqRepository.updateFaq(event.faq);

    result.fold(
      (failure) => emit(state.copyWith(
        status: FaqBlocStatus.error,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (updatedFaq) {
        final updatedFaqs = state.faqs.map((faq) {
          return faq.id == updatedFaq.id ? updatedFaq : faq;
        }).toList();

        emit(state.copyWith(
          status: FaqBlocStatus.success,
          faqs: updatedFaqs,
          selectedFaq: state.selectedFaq?.id == updatedFaq.id ? updatedFaq : state.selectedFaq,
          clearError: true,
        ));
      },
    );
  }

  /// 删除FAQ
  Future<void> _onDeleteFaq(DeleteFaqEvent event, Emitter<FaqState> emit) async {
    emit(state.copyWith(status: FaqBlocStatus.loading));

    final result = await deleteFaqUseCase(event.id);

    result.fold(
      (failure) => emit(state.copyWith(
        status: FaqBlocStatus.error,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (_) {
        final updatedFaqs = state.faqs.where((faq) => faq.id != event.id).toList();
        final updatedSelectedIds = Set<String>.from(state.selectedIds)
          ..remove(event.id);

        emit(state.copyWith(
          status: FaqBlocStatus.success,
          faqs: updatedFaqs,
          selectedIds: updatedSelectedIds,
          clearSelectedFaq: state.selectedFaq?.id == event.id,
          clearError: true,
        ));
      },
    );
  }

  /// 批量删除FAQ
  Future<void> _onBulkDeleteFaqs(BulkDeleteFaqsEvent event, Emitter<FaqState> emit) async {
    emit(state.copyWith(status: FaqBlocStatus.loading));

    final result = await faqRepository.bulkDeleteFaqs(event.ids);

    result.fold(
      (failure) => emit(state.copyWith(
        status: FaqBlocStatus.error,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (_) {
        final updatedFaqs = state.faqs.where((faq) => !event.ids.contains(faq.id)).toList();
        final updatedSelectedIds = Set<String>.from(state.selectedIds)
          ..removeAll(event.ids);

        emit(state.copyWith(
          status: FaqBlocStatus.success,
          faqs: updatedFaqs,
          selectedIds: updatedSelectedIds,
          clearSelectedFaq: event.ids.contains(state.selectedFaq?.id),
          clearError: true,
        ));
      },
    );
  }

  /// 获取FAQ分类
  Future<void> _onGetCategories(GetCategoriesEvent event, Emitter<FaqState> emit) async {
    final result = await faqRepository.getCategories();

    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: _mapFailureToMessage(failure),
      )),
      (categories) => emit(state.copyWith(
        categories: categories,
        clearError: true,
      )),
    );
  }

  /// 获取热门FAQ
  Future<void> _onGetPopularFaqs(GetPopularFaqsEvent event, Emitter<FaqState> emit) async {
    final result = await faqRepository.getPopularFaqs(limit: event.limit);

    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: _mapFailureToMessage(failure),
      )),
      (popularFaqs) => emit(state.copyWith(
        popularFaqs: popularFaqs,
        clearError: true,
      )),
    );
  }

  /// 点赞FAQ
  Future<void> _onLikeFaq(LikeFaqEvent event, Emitter<FaqState> emit) async {
    final result = await faqRepository.likeFaq(event.id);

    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: _mapFailureToMessage(failure),
      )),
      (updatedFaq) {
        final updatedFaqs = state.faqs.map((faq) {
          return faq.id == updatedFaq.id ? updatedFaq : faq;
        }).toList();

        emit(state.copyWith(
          faqs: updatedFaqs,
          selectedFaq: state.selectedFaq?.id == updatedFaq.id ? updatedFaq : state.selectedFaq,
          clearError: true,
        ));
      },
    );
  }

  /// 点踩FAQ
  Future<void> _onDislikeFaq(DislikeFaqEvent event, Emitter<FaqState> emit) async {
    final result = await faqRepository.dislikeFaq(event.id);

    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: _mapFailureToMessage(failure),
      )),
      (updatedFaq) {
        final updatedFaqs = state.faqs.map((faq) {
          return faq.id == updatedFaq.id ? updatedFaq : faq;
        }).toList();

        emit(state.copyWith(
          faqs: updatedFaqs,
          selectedFaq: state.selectedFaq?.id == updatedFaq.id ? updatedFaq : state.selectedFaq,
          clearError: true,
        ));
      },
    );
  }

  /// 切换FAQ状态
  Future<void> _onToggleFaqStatus(ToggleFaqStatusEvent event, Emitter<FaqState> emit) async {
    final result = await faqRepository.toggleFaqStatus(event.id);

    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: _mapFailureToMessage(failure),
      )),
      (updatedFaq) {
        final updatedFaqs = state.faqs.map((faq) {
          return faq.id == updatedFaq.id ? updatedFaq : faq;
        }).toList();

        emit(state.copyWith(
          faqs: updatedFaqs,
          selectedFaq: state.selectedFaq?.id == updatedFaq.id ? updatedFaq : state.selectedFaq,
          clearError: true,
        ));
      },
    );
  }

  /// 设置筛选器
  void _onSetFilter(SetFilterEvent event, Emitter<FaqState> emit) {
    emit(state.copyWith(
      filter: event.filter,
      currentPage: 1,
      hasReachedMax: false,
    ));
  }

  /// 设置排序
  void _onSetSort(SetSortEvent event, Emitter<FaqState> emit) {
    emit(state.copyWith(
      sort: event.sort,
      currentPage: 1,
      hasReachedMax: false,
    ));
  }

  /// 清除搜索
  void _onClearSearch(ClearSearchEvent event, Emitter<FaqState> emit) {
    final clearedFilter = state.filter.copyWith(clearSearch: true);
    emit(state.copyWith(
      filter: clearedFilter,
      currentPage: 1,
      hasReachedMax: false,
    ));
  }

  /// 重置状态
  void _onResetFaqState(ResetFaqStateEvent event, Emitter<FaqState> emit) {
    emit(const FaqState());
  }

  /// 选择FAQ
  void _onSelectFaq(SelectFaqEvent event, Emitter<FaqState> emit) {
    final updatedSelectedIds = Set<String>.from(state.selectedIds)
      ..add(event.id);
    emit(state.copyWith(selectedIds: updatedSelectedIds));
  }

  /// 取消选择FAQ
  void _onUnselectFaq(UnselectFaqEvent event, Emitter<FaqState> emit) {
    final updatedSelectedIds = Set<String>.from(state.selectedIds)
      ..remove(event.id);
    emit(state.copyWith(selectedIds: updatedSelectedIds));
  }

  /// 全选FAQ
  void _onSelectAllFaqs(SelectAllFaqsEvent event, Emitter<FaqState> emit) {
    final allIds = state.faqs.map((faq) => faq.id).toSet();
    emit(state.copyWith(selectedIds: allIds));
  }

  /// 取消全选FAQ
  void _onUnselectAllFaqs(UnselectAllFaqsEvent event, Emitter<FaqState> emit) {
    emit(state.copyWith(selectedIds: const <String>{}));
  }

  /// 切换选择模式
  void _onToggleSelectionMode(ToggleSelectionModeEvent event, Emitter<FaqState> emit) {
    emit(state.copyWith(
      isSelectionMode: !state.isSelectionMode,
      selectedIds: const <String>{},
    ));
  }

  /// 进入选择模式
  void _onEnterSelectionMode(EnterSelectionModeEvent event, Emitter<FaqState> emit) {
    emit(state.copyWith(
      isSelectionMode: true,
      selectedIds: const <String>{},
    ));
  }

  /// 退出选择模式
  void _onExitSelectionMode(ExitSelectionModeEvent event, Emitter<FaqState> emit) {
    emit(state.copyWith(
      isSelectionMode: false,
      selectedIds: const <String>{},
    ));
  }

  /// 加载更多FAQ
  void _onLoadMoreFaqs(LoadMoreFaqsEvent event, Emitter<FaqState> emit) {
    if (!state.hasReachedMax && !state.isLoading && !state.isLoadingMore) {
      add(GetFaqsEvent(
        search: state.filter.search,
        category: state.filter.category,
        status: state.filter.status,
        knowledgeBaseId: state.filter.knowledgeBaseId,
        isPublic: state.filter.isPublic,
        sort: state.sort,
        tags: state.filter.tags,
        page: state.currentPage + 1,
        limit: 20,
      ));
    }
  }

  /// 刷新FAQ列表
  void _onRefreshFaqs(RefreshFaqsEvent event, Emitter<FaqState> emit) {
    add(GetFaqsEvent(
      search: state.filter.search,
      category: state.filter.category,
      status: state.filter.status,
      knowledgeBaseId: state.filter.knowledgeBaseId,
      isPublic: state.filter.isPublic,
      sort: state.sort,
      tags: state.filter.tags,
      page: 1,
      limit: 20,
      isRefresh: true,
    ));
  }

  /// 映射失败信息到用户友好的消息
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case NetworkFailure:
        return '网络连接失败，请检查网络设置';
      case CacheFailure:
        return '本地数据访问失败';
      default:
        return '未知错误，请稍后重试';
    }
  }
} 