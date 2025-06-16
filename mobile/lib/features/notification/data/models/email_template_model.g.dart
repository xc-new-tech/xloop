// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_template_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmailTemplateModel _$EmailTemplateModelFromJson(Map<String, dynamic> json) =>
    EmailTemplateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$EmailTemplateTypeEnumMap, json['type']),
      subject: json['subject'] as String,
      htmlContent: json['htmlContent'] as String,
      textContent: json['textContent'] as String,
      variables: Map<String, String>.from(json['variables'] as Map),
      language: json['language'] as String? ?? 'zh-CN',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$EmailTemplateModelToJson(EmailTemplateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$EmailTemplateTypeEnumMap[instance.type]!,
      'subject': instance.subject,
      'htmlContent': instance.htmlContent,
      'textContent': instance.textContent,
      'variables': instance.variables,
      'language': instance.language,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$EmailTemplateTypeEnumMap = {
  EmailTemplateType.accountCreation: 'accountCreation',
  EmailTemplateType.passwordReset: 'passwordReset',
  EmailTemplateType.emailVerification: 'emailVerification',
  EmailTemplateType.welcome: 'welcome',
  EmailTemplateType.notification: 'notification',
};
