import '../../domain/entities/onboarding_progress.dart';

class OnboardingProgressModel extends OnboardingProgress {
  const OnboardingProgressModel({
    required super.userId,
    required super.completedSteps,
    super.currentStepId,
    required super.isCompleted,
    super.startedAt,
    super.completedAt,
    required super.updatedAt,
    super.canSkip,
  });

  factory OnboardingProgressModel.fromJson(Map<String, dynamic> json) {
    return OnboardingProgressModel(
      userId: json['userId'] as String,
      completedSteps: List<String>.from(json['completedSteps'] as List),
      currentStepId: json['currentStepId'] as String?,
      isCompleted: json['isCompleted'] as bool,
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      canSkip: json['canSkip'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'completedSteps': completedSteps,
      'currentStepId': currentStepId,
      'isCompleted': isCompleted,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'canSkip': canSkip,
    };
  }

  factory OnboardingProgressModel.fromEntity(OnboardingProgress progress) {
    return OnboardingProgressModel(
      userId: progress.userId,
      completedSteps: progress.completedSteps,
      currentStepId: progress.currentStepId,
      isCompleted: progress.isCompleted,
      startedAt: progress.startedAt,
      completedAt: progress.completedAt,
      updatedAt: progress.updatedAt,
      canSkip: progress.canSkip,
    );
  }
} 