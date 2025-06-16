import '../../domain/entities/onboarding_progress.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDatasource localDatasource;

  OnboardingRepositoryImpl({
    required this.localDatasource,
  });

  @override
  Future<OnboardingProgress> getOnboardingProgress(String userId) async {
    try {
      return await localDatasource.getOnboardingProgress(userId);
    } catch (e) {
      // 如果没有找到进度，返回默认的新进度
      return OnboardingProgress(
        userId: userId,
        completedSteps: [],
        isCompleted: false,
        updatedAt: DateTime.now(),
        startedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> updateOnboardingProgress(OnboardingProgress progress) async {
    await localDatasource.saveOnboardingProgress(progress);
  }

  @override
  Future<bool> isOnboardingCompleted(String userId) async {
    try {
      final progress = await localDatasource.getOnboardingProgress(userId);
      return progress.isCompleted;
    } catch (e) {
      return false;
    }
  }
} 