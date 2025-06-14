import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/conversation_repository.dart';

class GetConversationUseCase implements UseCase<Conversation, GetConversationParams> {
  final ConversationRepository _repository;

  GetConversationUseCase(this._repository);

  @override
  Future<Either<Failure, Conversation>> call(GetConversationParams params) async {
    return await _repository.getConversationById(params.id);
  }
}

class GetConversationParams {
  final String id;

  const GetConversationParams({required this.id});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetConversationParams && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'GetConversationParams(id: $id)';
} 