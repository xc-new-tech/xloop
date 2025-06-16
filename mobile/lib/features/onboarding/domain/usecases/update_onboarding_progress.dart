import '../entities/onboarding_progress.dart';
import '../repositories/onboarding_repository.dart';

class UpdateOnboardingProgress {
  final OnboardingRepository repository;

  UpdateOnboardingProgress(this.repository);

  Future<void> call(OnboardingProgress progress) async {
    await repository.updateOnboardingProgress(progress);
  }
} 