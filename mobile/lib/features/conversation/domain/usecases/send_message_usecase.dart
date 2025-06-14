import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/conversation_repository.dart';

class SendMessageUseCase implements UseCase<SendMessageResponse, SendMessageParams> {
  final ConversationRepository _repository;

  SendMessageUseCase(this._repository);

  @override
  Future<Either<Failure, SendMessageResponse>> call(SendMessageParams params) async {
    return await _repository.sendMessage(
      conversationId: params.conversationId,
      request: params.request,
    );
  }
}

class SendMessageParams {
  final String conversationId;
  final SendMessageRequest request;

  const SendMessageParams({
    required this.conversationId,
    required this.request,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SendMessageParams &&
        other.conversationId == conversationId &&
        other.request == request;
  }

  @override
  int get hashCode => conversationId.hashCode ^ request.hashCode;

  @override
  String toString() {
    return 'SendMessageParams(conversationId: $conversationId, request: $request)';
  }
} 