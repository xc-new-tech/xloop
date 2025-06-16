import '../entities/onboarding_progress.dart';
import '../repositories/onboarding_repository.dart';

class CompleteOnboarding {
  final OnboardingRepository repository;

  CompleteOnboarding(this.repository);

  Future<OnboardingProgress> call(OnboardingProgress progress) async {
    final completedProgress = progress.markCompleted();
    await repository.updateOnboardingProgress(completedProgress);
    return completedProgress;
  }
} 