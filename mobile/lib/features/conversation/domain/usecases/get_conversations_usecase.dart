import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/conversation_repository.dart';

class GetConversationsUseCase implements UseCase<List<Conversation>, GetConversationsParams> {
  final ConversationRepository _repository;

  GetConversationsUseCase(this._repository);

  @override
  Future<Either<Failure, List<Conversation>>> call(GetConversationsParams params) async {
    return await _repository.getConversations(
      page: params.page,
      limit: params.limit,
      type: params.type,
      status: params.status,
      knowledgeBaseId: params.knowledgeBaseId,
      search: params.search,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
    );
  }
}

class GetConversationsParams {
  final int page;
  final int limit;
  final ConversationType? type;
  final ConversationStatus? status;
  final String? knowledgeBaseId;
  final String? search;
  final String sortBy;
  final String sortOrder;

  const GetConversationsParams({
    this.page = 1,
    this.limit = 20,
    this.type,
    this.status,
    this.knowledgeBaseId,
    this.search,
    this.sortBy = 'lastMessageAt',
    this.sortOrder = 'DESC',
  });

  GetConversationsParams copyWith({
    int? page,
    int? limit,
    ConversationType? type,
    ConversationStatus? status,
    String? knowledgeBaseId,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) {
    return GetConversationsParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      type: type ?? this.type,
      status: status ?? this.status,
      knowledgeBaseId: knowledgeBaseId ?? this.knowledgeBaseId,
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetConversationsParams &&
        other.page == page &&
        other.limit == limit &&
        other.type == type &&
        other.status == status &&
        other.knowledgeBaseId == knowledgeBaseId &&
        other.search == search &&
        other.sortBy == sortBy &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode {
    return page.hashCode ^
        limit.hashCode ^
        type.hashCode ^
        status.hashCode ^
        knowledgeBaseId.hashCode ^
        search.hashCode ^
        sortBy.hashCode ^
        sortOrder.hashCode;
  }

  @override
  String toString() {
    return 'GetConversationsParams(page: $page, limit: $limit, type: $type, status: $status, knowledgeBaseId: $knowledgeBaseId, search: $search, sortBy: $sortBy, sortOrder: $sortOrder)';
  }
} 