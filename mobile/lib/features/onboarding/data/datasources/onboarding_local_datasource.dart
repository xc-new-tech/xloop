import '../../domain/entities/onboarding_progress.dart';

abstract class OnboardingLocalDatasource {
  Future<OnboardingProgress> getOnboardingProgress(String userId);
  Future<void> saveOnboardingProgress(OnboardingProgress progress);
  Future<void> clearOnboardingProgress(String userId);
} 