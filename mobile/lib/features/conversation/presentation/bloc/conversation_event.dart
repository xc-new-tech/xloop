import 'package:equatable/equatable.dart';
import '../../domain/entities/conversation.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

/// 获取对话列表事件
class GetConversationsEvent extends ConversationEvent {
  final int page;
  final int limit;
  final ConversationType? type;
  final ConversationStatus? status;
  final String? knowledgeBaseId;
  final String? search;
  final String sortBy;
  final String sortOrder;
  final bool refresh;

  const GetConversationsEvent({
    this.page = 1,
    this.limit = 20,
    this.type,
    this.status,
    this.knowledgeBaseId,
    this.search,
    this.sortBy = 'lastMessageAt',
    this.sortOrder = 'DESC',
    this.refresh = false,
  });

  @override
  List<Object?> get props => [
        page,
        limit,
        type,
        status,
        knowledgeBaseId,
        search,
        sortBy,
        sortOrder,
        refresh,
      ];
}

/// 加载更多对话事件
class LoadMoreConversationsEvent extends ConversationEvent {
  const LoadMoreConversationsEvent();
}

/// 获取单个对话事件
class GetConversationEvent extends ConversationEvent {
  final String id;

  const GetConversationEvent({required this.id});

  @override
  List<Object> get props => [id];
}

/// 创建新对话事件
class CreateConversationEvent extends ConversationEvent {
  final String? knowledgeBaseId;
  final String? title;
  final ConversationType type;
  final Map<String, dynamic> settings;
  final List<String> tags;

  const CreateConversationEvent({
    this.knowledgeBaseId,
    this.title,
    this.type = ConversationType.chat,
    this.settings = const {},
    this.tags = const [],
  });

  @override
  List<Object?> get props => [knowledgeBaseId, title, type, settings, tags];
}

/// 发送消息事件
class SendMessageEvent extends ConversationEvent {
  final String conversationId;
  final String content;
  final String contentType;
  final Map<String, dynamic> metadata;

  const SendMessageEvent({
    required this.conversationId,
    required this.content,
    this.contentType = 'text',
    this.metadata = const {},
  });

  @override
  List<Object> get props => [conversationId, content, contentType, metadata];
}

/// 更新对话事件
class UpdateConversationEvent extends ConversationEvent {
  final String id;
  final String? title;
  final List<String>? tags;
  final Map<String, dynamic>? settings;
  final ConversationStatus? status;

  const UpdateConversationEvent({
    required this.id,
    this.title,
    this.tags,
    this.settings,
    this.status,
  });

  @override
  List<Object?> get props => [id, title, tags, settings, status];
}

/// 删除对话事件
class DeleteConversationEvent extends ConversationEvent {
  final String id;

  const DeleteConversationEvent({required this.id});

  @override
  List<Object> get props => [id];
}

/// 批量删除对话事件
class BulkDeleteConversationsEvent extends ConversationEvent {
  final List<String> ids;

  const BulkDeleteConversationsEvent({required this.ids});

  @override
  List<Object> get props => [ids];
}

/// 对话评分事件
class RateConversationEvent extends ConversationEvent {
  final String id;
  final int rating;
  final String? feedback;

  const RateConversationEvent({
    required this.id,
    required this.rating,
    this.feedback,
  });

  @override
  List<Object?> get props => [id, rating, feedback];
}

/// 获取对话统计事件
class GetConversationStatsEvent extends ConversationEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? knowledgeBaseId;

  const GetConversationStatsEvent({
    this.startDate,
    this.endDate,
    this.knowledgeBaseId,
  });

  @override
  List<Object?> get props => [startDate, endDate, knowledgeBaseId];
}

/// 搜索对话事件
class SearchConversationsEvent extends ConversationEvent {
  final String query;
  final ConversationType? type;
  final ConversationStatus? status;
  final String? knowledgeBaseId;

  const SearchConversationsEvent({
    required this.query,
    this.type,
    this.status,
    this.knowledgeBaseId,
  });

  @override
  List<Object?> get props => [query, type, status, knowledgeBaseId];
}

/// 清除搜索事件
class ClearSearchEvent extends ConversationEvent {
  const ClearSearchEvent();
}

/// 筛选对话事件
class FilterConversationsEvent extends ConversationEvent {
  final ConversationType? type;
  final ConversationStatus? status;
  final String? knowledgeBaseId;

  const FilterConversationsEvent({
    this.type,
    this.status,
    this.knowledgeBaseId,
  });

  @override
  List<Object?> get props => [type, status, knowledgeBaseId];
}

/// 清除筛选事件
class ClearFiltersEvent extends ConversationEvent {
  const ClearFiltersEvent();
}

/// 排序对话事件
class SortConversationsEvent extends ConversationEvent {
  final String sortBy;
  final String sortOrder;

  const SortConversationsEvent({
    required this.sortBy,
    required this.sortOrder,
  });

  @override
  List<Object> get props => [sortBy, sortOrder];
}

/// 选择对话事件（用于批量操作）
class SelectConversationEvent extends ConversationEvent {
  final String id;
  final bool selected;

  const SelectConversationEvent({
    required this.id,
    required this.selected,
  });

  @override
  List<Object> get props => [id, selected];
}

/// 全选/取消全选对话事件
class SelectAllConversationsEvent extends ConversationEvent {
  final bool selectAll;

  const SelectAllConversationsEvent({required this.selectAll});

  @override
  List<Object> get props => [selectAll];
}

/// 清除选择事件
class ClearSelectionEvent extends ConversationEvent {
  const ClearSelectionEvent();
}

/// 重置状态事件
class ResetConversationStateEvent extends ConversationEvent {
  const ResetConversationStateEvent();
}

/// 缓存操作事件
class GetCachedConversationsEvent extends ConversationEvent {
  const GetCachedConversationsEvent();
}

class ClearConversationCacheEvent extends ConversationEvent {
  const ClearConversationCacheEvent();
} 