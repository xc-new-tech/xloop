import '../entities/user_journey.dart';
import '../repositories/user_journey_repository.dart';

/// 获取当前旅程用例
class GetCurrentJourneyUseCase {
  final UserJourneyRepository repository;

  GetCurrentJourneyUseCase(this.repository);

  Future<UserJourney?> call(String userId) async {
    return await repository.getCurrentJourney(userId);
  }
} 