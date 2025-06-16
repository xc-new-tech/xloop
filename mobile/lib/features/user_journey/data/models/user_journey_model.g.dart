// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_journey_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserJourneyModel _$UserJourneyModelFromJson(Map<String, dynamic> json) =>
    UserJourneyModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: $enumDecode(_$UserJourneyStatusEnumMap, json['status']),
      steps: (json['steps'] as List<dynamic>)
          .map((e) => UserJourneyStepModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      lastActiveAt: json['lastActiveAt'] == null
          ? null
          : DateTime.parse(json['lastActiveAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      currentStepId: json['currentStepId'] as String?,
    );

Map<String, dynamic> _$UserJourneyModelToJson(UserJourneyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'status': _$UserJourneyStatusEnumMap[instance.status]!,
      'steps': instance.steps,
      'createdAt': instance.createdAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
      'metadata': instance.metadata,
      'currentStepId': instance.currentStepId,
    };

const _$UserJourneyStatusEnumMap = {
  UserJourneyStatus.notStarted: 'notStarted',
  UserJourneyStatus.inProgress: 'inProgress',
  UserJourneyStatus.completed: 'completed',
  UserJourneyStatus.paused: 'paused',
  UserJourneyStatus.failed: 'failed',
};
