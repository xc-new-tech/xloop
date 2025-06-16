import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_journey_step.dart';

part 'user_journey_step_model.g.dart';

@JsonSerializable()
class UserJourneyStepModel extends UserJourneyStep {
  const UserJourneyStepModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.status,
    required super.order,
    super.dependencies,
    super.metadata,
    super.startedAt,
    super.completedAt,
    super.errorMessage,
    super.progress,
  });

  factory UserJourneyStepModel.fromJson(Map<String, dynamic> json) =>
      _$UserJourneyStepModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserJourneyStepModelToJson(this);

  factory UserJourneyStepModel.fromEntity(UserJourneyStep entity) {
    return UserJourneyStepModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      type: entity.type,
      status: entity.status,
      order: entity.order,
      dependencies: entity.dependencies,
      metadata: entity.metadata,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
      errorMessage: entity.errorMessage,
      progress: entity.progress,
    );
  }

  UserJourneyStep toEntity() {
    return UserJourneyStep(
      id: id,
      title: title,
      description: description,
      type: type,
      status: status,
      order: order,
      dependencies: dependencies,
      metadata: metadata,
      startedAt: startedAt,
      completedAt: completedAt,
      errorMessage: errorMessage,
      progress: progress,
    );
  }

  @override
  UserJourneyStepModel copyWith({
    String? id,
    String? title,
    String? description,
    UserJourneyStepType? type,
    UserJourneyStepStatus? status,
    int? order,
    List<String>? dependencies,
    Map<String, dynamic>? metadata,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    double? progress,
  }) {
    return UserJourneyStepModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      order: order ?? this.order,
      dependencies: dependencies ?? this.dependencies,
      metadata: metadata ?? this.metadata,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }
} 