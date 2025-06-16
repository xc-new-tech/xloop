import 'package:equatable/equatable.dart';
import '../../domain/entities/user_journey_step.dart';

abstract class UserJourneyEvent extends Equatable {
  const UserJourneyEvent();

  @override
  List<Object?> get props => [];
}

/// 加载当前旅程
class LoadCurrentJourneyEvent extends UserJourneyEvent {
  final String userId;

  const LoadCurrentJourneyEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// 创建新旅程
class CreateJourneyEvent extends UserJourneyEvent {
  final String userId;
  final String journeyType;

  const CreateJourneyEvent({
    required this.userId,
    required this.journeyType,
  });

  @override
  List<Object?> get props => [userId, journeyType];
}

/// 开始旅程
class StartJourneyEvent extends UserJourneyEvent {
  final String journeyId;

  const StartJourneyEvent(this.journeyId);

  @override
  List<Object?> get props => [journeyId];
}

/// 开始步骤
class StartStepEvent extends UserJourneyEvent {
  final String journeyId;
  final String stepId;

  const StartStepEvent({
    required this.journeyId,
    required this.stepId,
  });

  @override
  List<Object?> get props => [journeyId, stepId];
}

/// 完成步骤
class CompleteStepEvent extends UserJourneyEvent {
  final String journeyId;
  final String stepId;
  final Map<String, dynamic>? metadata;

  const CompleteStepEvent({
    required this.journeyId,
    required this.stepId,
    this.metadata,
  });

  @override
  List<Object?> get props => [journeyId, stepId, metadata];
}

/// 跳过步骤
class SkipStepEvent extends UserJourneyEvent {
  final String journeyId;
  final String stepId;
  final String? reason;

  const SkipStepEvent({
    required this.journeyId,
    required this.stepId,
    this.reason,
  });

  @override
  List<Object?> get props => [journeyId, stepId, reason];
}

/// 步骤失败
class FailStepEvent extends UserJourneyEvent {
  final String journeyId;
  final String stepId;
  final String errorMessage;

  const FailStepEvent({
    required this.journeyId,
    required this.stepId,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [journeyId, stepId, errorMessage];
}

/// 更新步骤进度
class UpdateStepProgressEvent extends UserJourneyEvent {
  final String journeyId;
  final String stepId;
  final double progress;

  const UpdateStepProgressEvent({
    required this.journeyId,
    required this.stepId,
    required this.progress,
  });

  @override
  List<Object?> get props => [journeyId, stepId, progress];
}

/// 暂停旅程
class PauseJourneyEvent extends UserJourneyEvent {
  final String journeyId;

  const PauseJourneyEvent(this.journeyId);

  @override
  List<Object?> get props => [journeyId];
}

/// 恢复旅程
class ResumeJourneyEvent extends UserJourneyEvent {
  final String journeyId;

  const ResumeJourneyEvent(this.journeyId);

  @override
  List<Object?> get props => [journeyId];
}

/// 完成旅程
class CompleteJourneyEvent extends UserJourneyEvent {
  final String journeyId;

  const CompleteJourneyEvent(this.journeyId);

  @override
  List<Object?> get props => [journeyId];
}

/// 保存进度
class SaveProgressEvent extends UserJourneyEvent {
  final String journeyId;
  final Map<String, dynamic> progressData;

  const SaveProgressEvent({
    required this.journeyId,
    required this.progressData,
  });

  @override
  List<Object?> get props => [journeyId, progressData];
}

/// 恢复进度
class RestoreProgressEvent extends UserJourneyEvent {
  final String journeyId;

  const RestoreProgressEvent(this.journeyId);

  @override
  List<Object?> get props => [journeyId];
}

/// 加载旅程历史
class LoadJourneyHistoryEvent extends UserJourneyEvent {
  final String userId;

  const LoadJourneyHistoryEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// 删除旅程
class DeleteJourneyEvent extends UserJourneyEvent {
  final String journeyId;

  const DeleteJourneyEvent(this.journeyId);

  @override
  List<Object?> get props => [journeyId];
}

/// 获取旅程统计
class LoadJourneyStatsEvent extends UserJourneyEvent {
  final String userId;

  const LoadJourneyStatsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
} 