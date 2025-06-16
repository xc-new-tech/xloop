import '../repositories/onboarding_repository.dart';

class CheckFirstTimeUser {
  final OnboardingRepository repository;

  CheckFirstTimeUser(this.repository);

  Future<bool> call(String userId) async {
    return !(await repository.isOnboardingCompleted(userId));
  }
} 