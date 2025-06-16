import '../entities/user_journey_step.dart';
import '../repositories/user_journey_repository.dart';

/// 更新步骤参数
class UpdateStepParams {
  final String journeyId;
  final String stepId;
  final UserJourneyStepStatus? status;
  final double? progress;
  final Map<String, dynamic>? metadata;
  final String? errorMessage;

  const UpdateStepParams({
    required this.journeyId,
    required this.stepId,
    this.status,
    this.progress,
    this.metadata,
    this.errorMessage,
  });
}

/// 更新步骤用例
class UpdateStepUseCase {
  final UserJourneyRepository repository;

  UpdateStepUseCase(this.repository);

  Future<UserJourneyStep> call(UpdateStepParams params) async {
    switch (params.status) {
      case UserJourneyStepStatus.inProgress:
        return await repository.startStep(params.journeyId, params.stepId);
      case UserJourneyStepStatus.completed:
        return await repository.completeStep(
          params.journeyId,
          params.stepId,
          metadata: params.metadata,
        );
      case UserJourneyStepStatus.skipped:
        return await repository.skipStep(
          params.journeyId,
          params.stepId,
          reason: params.errorMessage,
        );
      case UserJourneyStepStatus.failed:
        return await repository.failStep(
          params.journeyId,
          params.stepId,
          params.errorMessage ?? 'Unknown error',
        );
      default:
        // 对于其他状态，使用通用更新方法
        throw UnimplementedError('Status ${params.status} not implemented');
    }
  }
} 