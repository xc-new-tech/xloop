import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/email_template.dart';

part 'email_template_model.g.dart';

/// 邮件模板数据模型
@JsonSerializable()
class EmailTemplateModel extends EmailTemplate {
  const EmailTemplateModel({
    required super.id,
    required super.name,
    required super.type,
    required super.subject,
    required super.htmlContent,
    required super.textContent,
    required super.variables,
    super.language,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory EmailTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$EmailTemplateModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmailTemplateModelToJson(this);

  factory EmailTemplateModel.fromEntity(EmailTemplate template) {
    return EmailTemplateModel(
      id: template.id,
      name: template.name,
      type: template.type,
      subject: template.subject,
      htmlContent: template.htmlContent,
      textContent: template.textContent,
      variables: template.variables,
      language: template.language,
      isActive: template.isActive,
      createdAt: template.createdAt,
      updatedAt: template.updatedAt,
    );
  }

  EmailTemplate toEntity() {
    return EmailTemplate(
      id: id,
      name: name,
      type: type,
      subject: subject,
      htmlContent: htmlContent,
      textContent: textContent,
      variables: variables,
      language: language,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  EmailTemplateModel copyWith({
    String? id,
    String? name,
    EmailTemplateType? type,
    String? subject,
    String? htmlContent,
    String? textContent,
    Map<String, String>? variables,
    String? language,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmailTemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      htmlContent: htmlContent ?? this.htmlContent,
      textContent: textContent ?? this.textContent,
      variables: variables ?? this.variables,
      language: language ?? this.language,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 