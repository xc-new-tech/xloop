import 'user_journey_step.dart';

/// 用户旅程状态
enum UserJourneyStatus {
  notStarted,
  inProgress,
  completed,
  paused,
  failed,
}

/// 用户旅程实体
class UserJourney {
  final String id;
  final String userId;
  final String title;
  final String description;
  final UserJourneyStatus status;
  final List<UserJourneyStep> steps;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastActiveAt;
  final Map<String, dynamic> metadata;
  final String? currentStepId;

  const UserJourney({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.steps,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.lastActiveAt,
    this.metadata = const {},
    this.currentStepId,
  });

  UserJourney copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    UserJourneyStatus? status,
    List<UserJourneyStep>? steps,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastActiveAt,
    Map<String, dynamic>? metadata,
    String? currentStepId,
  }) {
    return UserJourney(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      steps: steps ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      metadata: metadata ?? this.metadata,
      currentStepId: currentStepId ?? this.currentStepId,
    );
  }

  /// 获取当前步骤
  UserJourneyStep? get currentStep {
    if (currentStepId == null) return null;
    try {
      return steps.firstWhere((step) => step.id == currentStepId);
    } catch (e) {
      return null;
    }
  }

  /// 获取下一个可执行的步骤
  UserJourneyStep? get nextAvailableStep {
    final sortedSteps = List<UserJourneyStep>.from(steps)
      ..sort((a, b) => a.order.compareTo(b.order));

    for (final step in sortedSteps) {
      if (step.status == UserJourneyStepStatus.notStarted && step.canStart(steps)) {
        return step;
      }
    }
    return null;
  }

  /// 获取已完成的步骤数量
  int get completedStepsCount {
    return steps.where((step) => step.isCompleted).length;
  }

  /// 获取总步骤数量
  int get totalStepsCount => steps.length;

  /// 获取整体进度 (0.0 - 1.0)
  double get overallProgress {
    if (steps.isEmpty) return 0.0;
    
    final totalProgress = steps.fold<double>(
      0.0,
      (sum, step) => sum + step.progress,
    );
    
    return totalProgress / steps.length;
  }

  /// 获取完成百分比
  double get completionPercentage {
    if (steps.isEmpty) return 0.0;
    return completedStepsCount / totalStepsCount;
  }

  /// 是否已完成
  bool get isCompleted => status == UserJourneyStatus.completed;

  /// 是否进行中
  bool get isInProgress => status == UserJourneyStatus.inProgress;

  /// 是否失败
  bool get isFailed => status == UserJourneyStatus.failed;

  /// 是否暂停
  bool get isPaused => status == UserJourneyStatus.paused;

  /// 获取状态显示文本
  String get statusText {
    switch (status) {
      case UserJourneyStatus.notStarted:
        return '未开始';
      case UserJourneyStatus.inProgress:
        return '进行中';
      case UserJourneyStatus.completed:
        return '已完成';
      case UserJourneyStatus.paused:
        return '已暂停';
      case UserJourneyStatus.failed:
        return '失败';
    }
  }

  /// 获取指定ID的步骤
  UserJourneyStep? getStepById(String stepId) {
    try {
      return steps.firstWhere((step) => step.id == stepId);
    } catch (e) {
      return null;
    }
  }

  /// 更新步骤
  UserJourney updateStep(UserJourneyStep updatedStep) {
    final updatedSteps = steps.map((step) {
      return step.id == updatedStep.id ? updatedStep : step;
    }).toList();

    return copyWith(
      steps: updatedSteps,
      lastActiveAt: DateTime.now(),
    );
  }

  /// 开始旅程
  UserJourney start() {
    final firstStep = nextAvailableStep;
    return copyWith(
      status: UserJourneyStatus.inProgress,
      startedAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
      currentStepId: firstStep?.id,
    );
  }

  /// 完成旅程
  UserJourney complete() {
    return copyWith(
      status: UserJourneyStatus.completed,
      completedAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
  }

  /// 暂停旅程
  UserJourney pause() {
    return copyWith(
      status: UserJourneyStatus.paused,
      lastActiveAt: DateTime.now(),
    );
  }

  /// 恢复旅程
  UserJourney resume() {
    return copyWith(
      status: UserJourneyStatus.inProgress,
      lastActiveAt: DateTime.now(),
    );
  }

  /// 失败
  UserJourney fail() {
    return copyWith(
      status: UserJourneyStatus.failed,
      lastActiveAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserJourney &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserJourney{id: $id, title: $title, status: $status, progress: ${(overallProgress * 100).toStringAsFixed(1)}%}';
  }
} 