import 'package:equatable/equatable.dart';
import '../../domain/entities/user_journey.dart';

abstract class UserJourneyState extends Equatable {
  const UserJourneyState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class UserJourneyInitial extends UserJourneyState {}

/// 加载中状态
class UserJourneyLoading extends UserJourneyState {}

/// 已加载状态
class UserJourneyLoaded extends UserJourneyState {
  final UserJourney? currentJourney;
  final List<UserJourney> journeyHistory;
  final Map<String, dynamic>? journeyStats;
  final Map<String, dynamic>? savedProgress;

  const UserJourneyLoaded({
    this.currentJourney,
    this.journeyHistory = const [],
    this.journeyStats,
    this.savedProgress,
  });

  UserJourneyLoaded copyWith({
    UserJourney? currentJourney,
    List<UserJourney>? journeyHistory,
    Map<String, dynamic>? journeyStats,
    Map<String, dynamic>? savedProgress,
  }) {
    return UserJourneyLoaded(
      currentJourney: currentJourney ?? this.currentJourney,
      journeyHistory: journeyHistory ?? this.journeyHistory,
      journeyStats: journeyStats ?? this.journeyStats,
      savedProgress: savedProgress ?? this.savedProgress,
    );
  }

  @override
  List<Object?> get props => [currentJourney, journeyHistory, journeyStats, savedProgress];
}

/// 旅程更新状态
class UserJourneyUpdated extends UserJourneyState {
  final UserJourney journey;
  final String message;

  const UserJourneyUpdated({
    required this.journey,
    required this.message,
  });

  @override
  List<Object?> get props => [journey, message];
}

/// 步骤更新状态
class UserJourneyStepUpdated extends UserJourneyState {
  final UserJourney journey;
  final String stepId;
  final String message;

  const UserJourneyStepUpdated({
    required this.journey,
    required this.stepId,
    required this.message,
  });

  @override
  List<Object?> get props => [journey, stepId, message];
}

/// 进度保存状态
class UserJourneyProgressSaved extends UserJourneyState {
  final String journeyId;
  final String message;

  const UserJourneyProgressSaved({
    required this.journeyId,
    required this.message,
  });

  @override
  List<Object?> get props => [journeyId, message];
}

/// 进度恢复状态
class UserJourneyProgressRestored extends UserJourneyState {
  final String journeyId;
  final Map<String, dynamic> progressData;
  final String message;

  const UserJourneyProgressRestored({
    required this.journeyId,
    required this.progressData,
    required this.message,
  });

  @override
  List<Object?> get props => [journeyId, progressData, message];
}

/// 旅程删除状态
class UserJourneyDeleted extends UserJourneyState {
  final String journeyId;
  final String message;

  const UserJourneyDeleted({
    required this.journeyId,
    required this.message,
  });

  @override
  List<Object?> get props => [journeyId, message];
}

/// 错误状态
class UserJourneyError extends UserJourneyState {
  final String message;
  final String? errorCode;

  const UserJourneyError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// 操作成功状态
class UserJourneyOperationSuccess extends UserJourneyState {
  final String message;
  final String operation;
  final Map<String, dynamic>? data;

  const UserJourneyOperationSuccess({
    required this.message,
    required this.operation,
    this.data,
  });

  @override
  List<Object?> get props => [message, operation, data];
} 