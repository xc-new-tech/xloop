import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_journey.dart';
import '../../domain/entities/user_journey_step.dart';
import 'user_journey_step_model.dart';

part 'user_journey_model.g.dart';

@JsonSerializable()
class UserJourneyModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final UserJourneyStatus status;
  final List<UserJourneyStepModel> steps;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastActiveAt;
  final Map<String, dynamic>? metadata;
  final String? currentStepId;

  const UserJourneyModel({
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
    this.metadata,
    this.currentStepId,
  });

  factory UserJourneyModel.fromJson(Map<String, dynamic> json) =>
      _$UserJourneyModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserJourneyModelToJson(this);

  factory UserJourneyModel.fromEntity(UserJourney entity) {
    return UserJourneyModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      status: entity.status,
      steps: entity.steps.map((step) => UserJourneyStepModel.fromEntity(step)).toList(),
      createdAt: entity.createdAt,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
      lastActiveAt: entity.lastActiveAt,
      metadata: entity.metadata,
      currentStepId: entity.currentStepId,
    );
  }

  UserJourney toEntity() {
    return UserJourney(
      id: id,
      userId: userId,
      title: title,
      description: description,
      status: status,
      steps: steps.map((model) => model.toEntity()).toList(),
      createdAt: createdAt,
      startedAt: startedAt,
      completedAt: completedAt,
      lastActiveAt: lastActiveAt,
      metadata: metadata ?? const {},
      currentStepId: currentStepId,
    );
  }

  UserJourneyModel copyWith({
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
    return UserJourneyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      steps: steps?.map((step) => UserJourneyStepModel.fromEntity(step)).toList() ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      metadata: metadata ?? this.metadata,
      currentStepId: currentStepId ?? this.currentStepId,
    );
  }
} 