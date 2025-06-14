import 'package:equatable/equatable.dart';
import '../../domain/entities/conversation.dart';

abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class ConversationInitial extends ConversationState {
  const ConversationInitial();
}

/// 加载状态
class ConversationLoading extends ConversationState {
  const ConversationLoading();
}

/// 对话列表加载成功状态
class ConversationsLoaded extends ConversationState {
  final List<Conversation> conversations;
  final bool hasReachedMax;
  final int currentPage;
  final String? searchQuery;
  final ConversationType? filterType;
  final ConversationStatus? filterStatus;
  final String? filterKnowledgeBaseId;
  final String sortBy;
  final String sortOrder;
  final Set<String> selectedIds;
  final bool isSelectionMode;

  const ConversationsLoaded({
    required this.conversations,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.searchQuery,
    this.filterType,
    this.filterStatus,
    this.filterKnowledgeBaseId,
    this.sortBy = 'lastMessageAt',
    this.sortOrder = 'DESC',
    this.selectedIds = const {},
    this.isSelectionMode = false,
  });

  ConversationsLoaded copyWith({
    List<Conversation>? conversations,
    bool? hasReachedMax,
    int? currentPage,
    String? searchQuery,
    ConversationType? filterType,
    ConversationStatus? filterStatus,
    String? filterKnowledgeBaseId,
    String? sortBy,
    String? sortOrder,
    Set<String>? selectedIds,
    bool? isSelectionMode,
  }) {
    return ConversationsLoaded(
      conversations: conversations ?? this.conversations,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: filterType ?? this.filterType,
      filterStatus: filterStatus ?? this.filterStatus,
      filterKnowledgeBaseId: filterKnowledgeBaseId ?? this.filterKnowledgeBaseId,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      selectedIds: selectedIds ?? this.selectedIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  @override
  List<Object?> get props => [
        conversations,
        hasReachedMax,
        currentPage,
        searchQuery,
        filterType,
        filterStatus,
        filterKnowledgeBaseId,
        sortBy,
        sortOrder,
        selectedIds,
        isSelectionMode,
      ];

  /// 获取筛选后的对话列表
  List<Conversation> get filteredConversations {
    var filtered = conversations.where((conversation) {
      // 应用搜索过滤
      if (searchQuery != null && searchQuery!.isNotEmpty) {
        final query = searchQuery!.toLowerCase();
        final titleMatch = conversation.title?.toLowerCase().contains(query) ?? false;
        final messageMatch = conversation.messages.any(
          (message) => message.content.toLowerCase().contains(query),
        );
        if (!titleMatch && !messageMatch) return false;
      }

      // 应用类型过滤
      if (filterType != null && conversation.type != filterType) {
        return false;
      }

      // 应用状态过滤
      if (filterStatus != null && conversation.status != filterStatus) {
        return false;
      }

      // 应用知识库过滤
      if (filterKnowledgeBaseId != null && 
          conversation.knowledgeBaseId != filterKnowledgeBaseId) {
        return false;
      }

      return true;
    }).toList();

    // 应用排序
    filtered.sort((a, b) {
      switch (sortBy) {
        case 'createdAt':
          final aTime = a.createdAt;
          final bTime = b.createdAt;
          return sortOrder == 'DESC' 
              ? bTime.compareTo(aTime) 
              : aTime.compareTo(bTime);
        case 'title':
          final aTitle = a.title ?? '';
          final bTitle = b.title ?? '';
          return sortOrder == 'DESC' 
              ? bTitle.compareTo(aTitle) 
              : aTitle.compareTo(bTitle);
        case 'messageCount':
          return sortOrder == 'DESC' 
              ? b.messageCount.compareTo(a.messageCount) 
              : a.messageCount.compareTo(b.messageCount);
        case 'lastMessageAt':
        default:
          final aTime = a.lastMessageAt ?? a.createdAt;
          final bTime = b.lastMessageAt ?? b.createdAt;
          return sortOrder == 'DESC' 
              ? bTime.compareTo(aTime) 
              : aTime.compareTo(bTime);
      }
    });

    return filtered;
  }

  /// 是否有激活的筛选条件
  bool get hasActiveFilters {
    return searchQuery != null && searchQuery!.isNotEmpty ||
           filterType != null ||
           filterStatus != null ||
           filterKnowledgeBaseId != null;
  }

  /// 选中的对话数量
  int get selectedCount => selectedIds.length;

  /// 是否全选
  bool get isAllSelected => 
      conversations.isNotEmpty && selectedIds.length == conversations.length;
}

/// 单个对话加载成功状态
class ConversationDetailLoaded extends ConversationState {
  final Conversation conversation;

  const ConversationDetailLoaded({required this.conversation});

  @override
  List<Object> get props => [conversation];
}

/// 对话创建成功状态
class ConversationCreated extends ConversationState {
  final Conversation conversation;

  const ConversationCreated({required this.conversation});

  @override
  List<Object> get props => [conversation];
}

/// 消息发送中状态
class MessageSending extends ConversationState {
  final String conversationId;
  final String messageContent;

  const MessageSending({
    required this.conversationId,
    required this.messageContent,
  });

  @override
  List<Object> get props => [conversationId, messageContent];
}

/// 消息发送成功状态
class MessageSent extends ConversationState {
  final SendMessageResponse response;

  const MessageSent({required this.response});

  @override
  List<Object> get props => [response];
}

/// 对话更新成功状态
class ConversationUpdated extends ConversationState {
  final Conversation conversation;

  const ConversationUpdated({required this.conversation});

  @override
  List<Object> get props => [conversation];
}

/// 对话删除成功状态
class ConversationDeleted extends ConversationState {
  final String deletedId;

  const ConversationDeleted({required this.deletedId});

  @override
  List<Object> get props => [deletedId];
}

/// 批量删除成功状态
class ConversationsBulkDeleted extends ConversationState {
  final int deletedCount;
  final List<String> deletedIds;

  const ConversationsBulkDeleted({
    required this.deletedCount,
    required this.deletedIds,
  });

  @override
  List<Object> get props => [deletedCount, deletedIds];
}

/// 评分成功状态
class ConversationRated extends ConversationState {
  final String conversationId;
  final int rating;
  final String? feedback;

  const ConversationRated({
    required this.conversationId,
    required this.rating,
    this.feedback,
  });

  @override
  List<Object?> get props => [conversationId, rating, feedback];
}

/// 统计数据加载成功状态
class ConversationStatsLoaded extends ConversationState {
  final ConversationStats stats;

  const ConversationStatsLoaded({required this.stats});

  @override
  List<Object> get props => [stats];
}

/// 缓存对话加载成功状态
class CachedConversationsLoaded extends ConversationState {
  final List<Conversation> conversations;

  const CachedConversationsLoaded({required this.conversations});

  @override
  List<Object> get props => [conversations];
}

/// 加载更多状态
class ConversationLoadingMore extends ConversationState {
  final List<Conversation> currentConversations;

  const ConversationLoadingMore({required this.currentConversations});

  @override
  List<Object> get props => [currentConversations];
}

/// 操作成功状态（通用）
class ConversationOperationSuccess extends ConversationState {
  final String message;

  const ConversationOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

/// 错误状态
class ConversationError extends ConversationState {
  final String message;
  final String? errorCode;

  const ConversationError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// 网络错误状态
class ConversationNetworkError extends ConversationError {
  const ConversationNetworkError({
    String message = '网络连接失败，请检查网络设置',
    String? errorCode,
  }) : super(message: message, errorCode: errorCode);
}

/// 服务器错误状态
class ConversationServerError extends ConversationError {
  const ConversationServerError({
    String message = '服务器错误，请稍后重试',
    String? errorCode,
  }) : super(message: message, errorCode: errorCode);
}

/// 验证错误状态
class ConversationValidationError extends ConversationError {
  const ConversationValidationError({
    required String message,
    String? errorCode,
  }) : super(message: message, errorCode: errorCode);
}

/// 权限错误状态
class ConversationPermissionError extends ConversationError {
  const ConversationPermissionError({
    String message = '权限不足，无法执行此操作',
    String? errorCode,
  }) : super(message: message, errorCode: errorCode);
}

/// 未找到错误状态
class ConversationNotFoundError extends ConversationError {
  const ConversationNotFoundError({
    String message = '对话不存在或已被删除',
    String? errorCode,
  }) : super(message: message, errorCode: errorCode);
} 