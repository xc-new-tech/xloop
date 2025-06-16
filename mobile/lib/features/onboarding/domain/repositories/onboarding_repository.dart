import '../entities/onboarding_progress.dart';

abstract class OnboardingRepository {
  Future<OnboardingProgress> getOnboardingProgress(String userId);
  Future<void> updateOnboardingProgress(OnboardingProgress progress);
  Future<bool> isOnboardingCompleted(String userId);
} 