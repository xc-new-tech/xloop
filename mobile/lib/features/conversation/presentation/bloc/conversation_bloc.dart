import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/usecases/create_conversation_usecase.dart';
import '../../domain/usecases/delete_conversation_usecase.dart';
import '../../domain/usecases/get_conversation_usecase.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/get_conversation_stats_usecase.dart';
import '../../domain/usecases/rate_conversation_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/update_conversation_usecase.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final CreateConversationUseCase _createConversationUseCase;
  final GetConversationsUseCase _getConversationsUseCase;
  final GetConversationUseCase _getConversationUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final UpdateConversationUseCase _updateConversationUseCase;
  final DeleteConversationUseCase _deleteConversationUseCase;
  final BulkDeleteConversationsUseCase _bulkDeleteConversationsUseCase;
  final RateConversationUseCase _rateConversationUseCase;
  final GetConversationStatsUseCase _getConversationStatsUseCase;

  ConversationBloc({
    required CreateConversationUseCase createConversationUseCase,
    required GetConversationsUseCase getConversationsUseCase,
    required GetConversationUseCase getConversationUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required UpdateConversationUseCase updateConversationUseCase,
    required DeleteConversationUseCase deleteConversationUseCase,
    required BulkDeleteConversationsUseCase bulkDeleteConversationsUseCase,
    required RateConversationUseCase rateConversationUseCase,
    required GetConversationStatsUseCase getConversationStatsUseCase,
  })  : _createConversationUseCase = createConversationUseCase,
        _getConversationsUseCase = getConversationsUseCase,
        _getConversationUseCase = getConversationUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _updateConversationUseCase = updateConversationUseCase,
        _deleteConversationUseCase = deleteConversationUseCase,
        _bulkDeleteConversationsUseCase = bulkDeleteConversationsUseCase,
        _rateConversationUseCase = rateConversationUseCase,
        _getConversationStatsUseCase = getConversationStatsUseCase,
        super(const ConversationInitial()) {
    on<GetConversationsEvent>(_onGetConversations);
    on<LoadMoreConversationsEvent>(_onLoadMoreConversations);
    on<GetConversationEvent>(_onGetConversation);
    on<CreateConversationEvent>(_onCreateConversation);
    on<SendMessageEvent>(_onSendMessage);
    on<UpdateConversationEvent>(_onUpdateConversation);
    on<DeleteConversationEvent>(_onDeleteConversation);
    on<BulkDeleteConversationsEvent>(_onBulkDeleteConversations);
    on<RateConversationEvent>(_onRateConversation);
    on<GetConversationStatsEvent>(_onGetConversationStats);
    on<SearchConversationsEvent>(_onSearchConversations);
    on<ClearSearchEvent>(_onClearSearch);
    on<FilterConversationsEvent>(_onFilterConversations);
    on<ClearFiltersEvent>(_onClearFilters);
    on<SortConversationsEvent>(_onSortConversations);
    on<SelectConversationEvent>(_onSelectConversation);
    on<SelectAllConversationsEvent>(_onSelectAllConversations);
    on<ClearSelectionEvent>(_onClearSelection);
    on<ResetConversationStateEvent>(_onResetState);
  }

  /// 获取对话列表
  Future<void> _onGetConversations(
    GetConversationsEvent event,
    Emitter<ConversationState> emit,
  ) async {
    if (event.refresh || state is! ConversationsLoaded) {
      emit(const ConversationLoading());
    }

    final params = GetConversationsParams(
      page: event.page,
      limit: event.limit,
      type: event.type,
      status: event.status,
      knowledgeBaseId: event.knowledgeBaseId,
      search: event.search,
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
    );

    final result = await _getConversationsUseCase(params);

    result.fold(
      (failure) => emit(_mapFailureToErrorState(failure)),
      (conversations) {
        final currentState = state;
        if (currentState is ConversationsLoaded && !event.refresh) {
          // 合并现有对话和新对话
          final updatedConversations = List<Conversation>.from(currentState.conversations)
            ..addAll(conversations);
          
          emit(currentState.copyWith(
            conversations: updatedConversations,
            hasReachedMax: conversations.length < event.limit,
            currentPage: event.page,
          ));
        } else {
          // 新的对话列表
          emit(ConversationsLoaded(
            conversations: conversations,
            hasReachedMax: conversations.length < event.limit,
            currentPage: event.page,
            searchQuery: event.search,
            filterType: event.type,
            filterStatus: event.status,
            filterKnowledgeBaseId: event.knowledgeBaseId,
            sortBy: event.sortBy,
            sortOrder: event.sortOrder,
          ));
        }
      },
    );
  }

  /// 加载更多对话
  Future<void> _onLoadMoreConversations(
    LoadMoreConversationsEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final currentState = state;
    if (currentState is ConversationsLoaded && !currentState.hasReachedMax) {
      emit(ConversationLoadingMore(currentConversations: currentState.conversations));
      
      add(GetConversationsEvent(
        page: currentState.currentPage + 1,
        type: currentState.filterType,
        status: currentState.filterStatus,
        knowledgeBaseId: currentState.filterKnowledgeBaseId,
        search: currentState.searchQuery,
        sortBy: currentState.sortBy,
        sortOrder: currentState.sortOrder,
      ));
    }
  }

  /// 获取单个对话
  Future<void> _onGetConversation(
    GetConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(const ConversationLoading());

    final result = await _getConversationUseCase(GetConversationParams(id: event.id));

    result.fold(
      (failure) => emit(_mapFailureToErrorState(failure)),
      (conversation) => emit(ConversationDetailLoaded(conversation: conversation)),
    );
  }

  /// 创建新对话
  Future<void> _onCreateConversation(
    CreateConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(const ConversationLoading());

    final params = CreateConversationParams(
      knowledgeBaseId: event.knowledgeBaseId,
      title: event.title,
      type: event.type,
      settings: event.settings,
      tags: event.tags,
    );

    final result = await _createConversationUseCase(params);

    result.fold(
      (failure) => emit(_mapFailureToErrorState(failure)),
      (conversation) {
        emit(ConversationCreated(conversation: conversation));
        
        // 刷新对话列表
        add(const GetConversationsEvent(refresh: true));
      },
    );
  }

  /// 发送消息
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(MessageSending(
      conversationId: event.conversationId,
      messageContent: event.content,
    ));

    final request = SendMessageRequest(
      content: event.content,
      contentType: event.contentType,
      metadata: event.metadata,
    );

    final params = SendMessageParams(
      conversationId: event.conversationId,
      request: request,
    );

    final result = await _sendMessageUseCase(params);

    result.fold(
      (failure) => emit(_mapFailureToErrorState(failure)),
      (response) {
        emit(MessageSent(response: response));
        
        // 如果当前在对话详情页面，刷新对话
        if (state is ConversationDetailLoaded) {
          add(GetConversationEvent(id: event.conversationId));
        }
        
        // 刷新对话列表以更新最后消息时间
        add(const GetConversationsEvent(refresh: true));
      },
    );
  }

  /// 更新对话
  Future<void> _onUpdateConversation(
    UpdateConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final params = UpdateConversationParams(
      id: event.id,
      title: event.title,
      tags: event.tags,
      settings: event.settings,
      status: event.status,
    );

    final result = await _updateConversationUseCase(params);

    result.fold(
      (failure) => emit(_mapFailureToErrorState(failure)),
      (conversation) {
        emit(ConversationUpdated(conversation: conversation));
        
        // 刷新对话列表
        add(const GetConversationsEvent(refresh: true));
      },
    );
  }

  /// 删除对话
  Future<void> _onDeleteConversation(
    DeleteConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final params = DeleteConversationParams(id: event.id);
    final result = await _deleteConversationUseCase(params);

    result.fold(
      (failure) => emit(_mapFailureToErrorState(failure)),
      (_) {
        emit(ConversationDeleted(deletedId: event.id));
        
        // 从当前列表中移除已删除的对话
        final currentState = state;
        if (currentState is ConversationsLoaded) {
          final updatedConversations = currentState.conversations
              .where((c) => c.id != event.id)
              .toList();
          
          emit(currentState.copyWith(conversations: updatedConversations));
        }
      },
    );
  }

  /// 批量删除对话
  Future<void> _onBulkDeleteConversations(
    BulkDeleteConversationsEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final params = BulkDeleteConversationsParams(ids: event.ids);
    final result = await _bulkDeleteConversationsUseCase(params);

    result.fold(
      (failure) => emit(_mapFailureToErrorState(failure)),
      (deletedCount) {
        emit(ConversationsBulkDeleted(
          deletedCount: deletedCount,
          deletedIds: event.ids,
        ));
        
        // 从当前列表中移除已删除的对话
        final currentState = state;
        if (currentState is ConversationsLoaded) {
          final updatedConversations = currentState.conversations
              .where((c) => !event.ids.contains(c.id))
              .toList();
          
          emit(currentState.copyWith(
            conversations: updatedConversations,
            selectedIds: {},
            isSelectionMode: false,
          ));
        }
      },
    );
  }

  /// 对话评分
  Future<void> _onRateConversation(
    RateConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final params = RateConversationParams(
      id: event.id,
      rating: event.rating,
      feedback: event.feedback,
    );

    final result = await _rateConversationUseCase(params);

    result.fold(
      (failure) => emit(_mapFailureToErrorState(failure)),
      (_) {
        emit(ConversationRated(
          conversationId: event.id,
          rating: event.rating,
          feedback: event.feedback,
        ));
        
        // 刷新对话详情或列表
        add(GetConversationEvent(id: event.id));
      },
    );
  }

  /// 获取对话统计
  Future<void> _onGetConversationStats(
    GetConversationStatsEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(const ConversationLoading());

    final params = GetConversationStatsParams(
      startDate: event.startDate,
      endDate: event.endDate,
      knowledgeBaseId: event.knowledgeBaseId,
    );

    final result = await _getConversationStatsUseCase(params);

    result.fold(
      (failure) => emit(_mapFailureToErrorState(failure)),
      (stats) => emit(ConversationStatsLoaded(stats: stats)),
    );
  }

  /// 搜索对话
  Future<void> _onSearchConversations(
    SearchConversationsEvent event,
    Emitter<ConversationState> emit,
  ) async {
    add(GetConversationsEvent(
      page: 1,
      search: event.query,
      type: event.type,
      status: event.status,
      knowledgeBaseId: event.knowledgeBaseId,
      refresh: true,
    ));
  }

  /// 清除搜索
  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final currentState = state;
    if (currentState is ConversationsLoaded) {
      add(GetConversationsEvent(
        page: 1,
        type: currentState.filterType,
        status: currentState.filterStatus,
        knowledgeBaseId: currentState.filterKnowledgeBaseId,
        sortBy: currentState.sortBy,
        sortOrder: currentState.sortOrder,
        refresh: true,
      ));
    }
  }

  /// 筛选对话
  Future<void> _onFilterConversations(
    FilterConversationsEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final currentState = state;
    String? searchQuery;
    if (currentState is ConversationsLoaded) {
      searchQuery = currentState.searchQuery;
    }

    add(GetConversationsEvent(
      page: 1,
      search: searchQuery,
      type: event.type,
      status: event.status,
      knowledgeBaseId: event.knowledgeBaseId,
      refresh: true,
    ));
  }

  /// 清除筛选
  Future<void> _onClearFilters(
    ClearFiltersEvent event,
    Emitter<ConversationState> emit,
  ) async {
    add(const GetConversationsEvent(page: 1, refresh: true));
  }

  /// 排序对话
  Future<void> _onSortConversations(
    SortConversationsEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final currentState = state;
    if (currentState is ConversationsLoaded) {
      add(GetConversationsEvent(
        page: 1,
        search: currentState.searchQuery,
        type: currentState.filterType,
        status: currentState.filterStatus,
        knowledgeBaseId: currentState.filterKnowledgeBaseId,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
        refresh: true,
      ));
    }
  }

  /// 选择对话
  Future<void> _onSelectConversation(
    SelectConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final currentState = state;
    if (currentState is ConversationsLoaded) {
      final selectedIds = Set<String>.from(currentState.selectedIds);
      
      if (event.selected) {
        selectedIds.add(event.id);
      } else {
        selectedIds.remove(event.id);
      }

      emit(currentState.copyWith(
        selectedIds: selectedIds,
        isSelectionMode: selectedIds.isNotEmpty,
      ));
    }
  }

  /// 全选/取消全选对话
  Future<void> _onSelectAllConversations(
    SelectAllConversationsEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final currentState = state;
    if (currentState is ConversationsLoaded) {
      final selectedIds = event.selectAll
          ? currentState.conversations.map((c) => c.id).toSet()
          : <String>{};

      emit(currentState.copyWith(
        selectedIds: selectedIds,
        isSelectionMode: selectedIds.isNotEmpty,
      ));
    }
  }

  /// 清除选择
  Future<void> _onClearSelection(
    ClearSelectionEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final currentState = state;
    if (currentState is ConversationsLoaded) {
      emit(currentState.copyWith(
        selectedIds: {},
        isSelectionMode: false,
      ));
    }
  }

  /// 重置状态
  Future<void> _onResetState(
    ResetConversationStateEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(const ConversationInitial());
  }

  /// 将失败映射为错误状态
  ConversationState _mapFailureToErrorState(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return ConversationNetworkError(
          message: failure.message,
          errorCode: 'NETWORK_ERROR',
        );
      case ServerFailure:
        return ConversationServerError(
          message: failure.message,
          errorCode: 'SERVER_ERROR',
        );
      case ValidationFailure:
        return ConversationValidationError(
          message: failure.message,
          errorCode: 'VALIDATION_ERROR',
        );
      case AuthenticationFailure:
      case AuthorizationFailure:
        return ConversationPermissionError(
          message: failure.message,
          errorCode: 'PERMISSION_ERROR',
        );
      case NotFoundFailure:
        return ConversationNotFoundError(
          message: failure.message,
          errorCode: 'NOT_FOUND',
        );
      default:
        return ConversationError(
          message: failure.message,
          errorCode: 'UNKNOWN_ERROR',
        );
    }
  }
} 