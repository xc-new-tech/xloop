class OnboardingProgress {
  final String userId;
  final List<String> completedSteps;
  final String? currentStepId;
  final bool isCompleted;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime updatedAt;
  final bool canSkip;

  const OnboardingProgress({
    required this.userId,
    required this.completedSteps,
    this.currentStepId,
    required this.isCompleted,
    this.startedAt,
    this.completedAt,
    required this.updatedAt,
    this.canSkip = true,
  });

  OnboardingProgress copyWith({
    String? userId,
    List<String>? completedSteps,
    String? currentStepId,
    bool? isCompleted,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? updatedAt,
    bool? canSkip,
  }) {
    return OnboardingProgress(
      userId: userId ?? this.userId,
      completedSteps: completedSteps ?? this.completedSteps,
      currentStepId: currentStepId ?? this.currentStepId,
      isCompleted: isCompleted ?? this.isCompleted,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      canSkip: canSkip ?? this.canSkip,
    );
  }

  bool isStepCompleted(String stepId) {
    return completedSteps.contains(stepId);
  }

  double get progressPercentage {
    if (completedSteps.isEmpty) return 0.0;
    // 假设总共有5个引导步骤
    const totalSteps = 5;
    return (completedSteps.length / totalSteps).clamp(0.0, 1.0);
  }

  OnboardingProgress markStepCompleted(String stepId) {
    if (completedSteps.contains(stepId)) return this;
    
    final newCompletedSteps = [...completedSteps, stepId];
    return copyWith(
      completedSteps: newCompletedSteps,
      updatedAt: DateTime.now(),
    );
  }

  OnboardingProgress markCompleted() {
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingProgress &&
        other.userId == userId &&
        other.completedSteps.length == completedSteps.length &&
        other.completedSteps.every((step) => completedSteps.contains(step)) &&
        other.currentStepId == currentStepId &&
        other.isCompleted == isCompleted &&
        other.canSkip == canSkip;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        completedSteps.hashCode ^
        currentStepId.hashCode ^
        isCompleted.hashCode ^
        canSkip.hashCode;
  }

  @override
  String toString() {
    return 'OnboardingProgress(userId: $userId, completedSteps: $completedSteps, currentStepId: $currentStepId, isCompleted: $isCompleted, startedAt: $startedAt, completedAt: $completedAt, updatedAt: $updatedAt, canSkip: $canSkip)';
  }
} 