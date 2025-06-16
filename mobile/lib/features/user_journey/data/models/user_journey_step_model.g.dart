// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_journey_step_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserJourneyStepModel _$UserJourneyStepModelFromJson(
        Map<String, dynamic> json) =>
    UserJourneyStepModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$UserJourneyStepTypeEnumMap, json['type']),
      status: $enumDecode(_$UserJourneyStepStatusEnumMap, json['status']),
      order: (json['order'] as num).toInt(),
      dependencies: (json['dependencies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      errorMessage: json['errorMessage'] as String?,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$UserJourneyStepModelToJson(
        UserJourneyStepModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$UserJourneyStepTypeEnumMap[instance.type]!,
      'status': _$UserJourneyStepStatusEnumMap[instance.status]!,
      'order': instance.order,
      'dependencies': instance.dependencies,
      'metadata': instance.metadata,
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'errorMessage': instance.errorMessage,
      'progress': instance.progress,
    };

const _$UserJourneyStepTypeEnumMap = {
  UserJourneyStepType.login: 'login',
  UserJourneyStepType.welcome: 'welcome',
  UserJourneyStepType.knowledgeBaseCreation: 'knowledgeBaseCreation',
  UserJourneyStepType.documentUpload: 'documentUpload',
  UserJourneyStepType.knowledgeTest: 'knowledgeTest',
  UserJourneyStepType.optimization: 'optimization',
  UserJourneyStepType.completion: 'completion',
};

const _$UserJourneyStepStatusEnumMap = {
  UserJourneyStepStatus.notStarted: 'notStarted',
  UserJourneyStepStatus.inProgress: 'inProgress',
  UserJourneyStepStatus.completed: 'completed',
  UserJourneyStepStatus.skipped: 'skipped',
  UserJourneyStepStatus.failed: 'failed',
};
