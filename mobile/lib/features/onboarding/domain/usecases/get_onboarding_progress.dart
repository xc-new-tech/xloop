import '../entities/onboarding_progress.dart';
import '../repositories/onboarding_repository.dart';

class GetOnboardingProgress {
  final OnboardingRepository repository;

  GetOnboardingProgress(this.repository);

  Future<OnboardingProgress> call(String userId) async {
    return await repository.getOnboardingProgress(userId);
  }
} 