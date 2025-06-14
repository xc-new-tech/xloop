import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/conversation_repository.dart';

class RateConversationUseCase implements UseCase<void, RateConversationParams> {
  final ConversationRepository _repository;

  RateConversationUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(RateConversationParams params) async {
    return await _repository.rateConversation(
      id: params.id,
      rating: params.rating,
      feedback: params.feedback,
    );
  }
}

class RateConversationParams {
  final String id;
  final int rating;
  final String? feedback;

  const RateConversationParams({
    required this.id,
    required this.rating,
    this.feedback,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RateConversationParams &&
        other.id == id &&
        other.rating == rating &&
        other.feedback == feedback;
  }

  @override
  int get hashCode => id.hashCode ^ rating.hashCode ^ feedback.hashCode;

  @override
  String toString() {
    return 'RateConversationParams(id: $id, rating: $rating, feedback: $feedback)';
  }
} 