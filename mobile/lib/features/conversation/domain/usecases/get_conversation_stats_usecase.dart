import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/conversation_repository.dart';

class GetConversationStatsUseCase implements UseCase<ConversationStats, GetConversationStatsParams> {
  final ConversationRepository _repository;

  GetConversationStatsUseCase(this._repository);

  @override
  Future<Either<Failure, ConversationStats>> call(GetConversationStatsParams params) async {
    return await _repository.getConversationStats(
      startDate: params.startDate,
      endDate: params.endDate,
      knowledgeBaseId: params.knowledgeBaseId,
    );
  }
}

class GetConversationStatsParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? knowledgeBaseId;

  const GetConversationStatsParams({
    this.startDate,
    this.endDate,
    this.knowledgeBaseId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetConversationStatsParams &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.knowledgeBaseId == knowledgeBaseId;
  }

  @override
  int get hashCode {
    return startDate.hashCode ^ endDate.hashCode ^ knowledgeBaseId.hashCode;
  }

  @override
  String toString() {
    return 'GetConversationStatsParams(startDate: $startDate, endDate: $endDate, knowledgeBaseId: $knowledgeBaseId)';
  }
} 