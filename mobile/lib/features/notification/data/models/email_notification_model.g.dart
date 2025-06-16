// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmailNotificationModel _$EmailNotificationModelFromJson(
        Map<String, dynamic> json) =>
    EmailNotificationModel(
      id: json['id'] as String,
      to: json['to'] as String,
      cc: json['cc'] as String?,
      bcc: json['bcc'] as String?,
      subject: json['subject'] as String,
      htmlContent: json['htmlContent'] as String,
      textContent: json['textContent'] as String,
      status: $enumDecodeNullable(_$EmailStatusEnumMap, json['status']) ??
          EmailStatus.pending,
      priority: $enumDecodeNullable(_$EmailPriorityEnumMap, json['priority']) ??
          EmailPriority.normal,
      templateId: json['templateId'] as String,
      variables: json['variables'] as Map<String, dynamic>? ?? const {},
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      maxRetries: (json['maxRetries'] as num?)?.toInt() ?? 3,
      errorMessage: json['errorMessage'] as String?,
      scheduledAt: json['scheduledAt'] == null
          ? null
          : DateTime.parse(json['scheduledAt'] as String),
      sentAt: json['sentAt'] == null
          ? null
          : DateTime.parse(json['sentAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$EmailNotificationModelToJson(
        EmailNotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'to': instance.to,
      'cc': instance.cc,
      'bcc': instance.bcc,
      'subject': instance.subject,
      'htmlContent': instance.htmlContent,
      'textContent': instance.textContent,
      'status': _$EmailStatusEnumMap[instance.status]!,
      'priority': _$EmailPriorityEnumMap[instance.priority]!,
      'templateId': instance.templateId,
      'variables': instance.variables,
      'retryCount': instance.retryCount,
      'maxRetries': instance.maxRetries,
      'errorMessage': instance.errorMessage,
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
      'sentAt': instance.sentAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$EmailStatusEnumMap = {
  EmailStatus.pending: 'pending',
  EmailStatus.sending: 'sending',
  EmailStatus.sent: 'sent',
  EmailStatus.failed: 'failed',
  EmailStatus.retrying: 'retrying',
};

const _$EmailPriorityEnumMap = {
  EmailPriority.low: 'low',
  EmailPriority.normal: 'normal',
  EmailPriority.high: 'high',
  EmailPriority.urgent: 'urgent',
};
