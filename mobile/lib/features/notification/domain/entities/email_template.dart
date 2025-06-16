import 'package:equatable/equatable.dart';

/// 邮件模板类型枚举
enum EmailTemplateType {
  accountCreation,
  passwordReset,
  emailVerification,
  welcome,
  notification,
}

/// 邮件模板实体
class EmailTemplate extends Equatable {
  final String id;
  final String name;
  final EmailTemplateType type;
  final String subject;
  final String htmlContent;
  final String textContent;
  final Map<String, String> variables;
  final String language;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmailTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.subject,
    required this.htmlContent,
    required this.textContent,
    required this.variables,
    this.language = 'zh-CN',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        subject,
        htmlContent,
        textContent,
        variables,
        language,
        isActive,
        createdAt,
        updatedAt,
      ];

  EmailTemplate copyWith({
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
    return EmailTemplate(
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

  @override
  String toString() {
    return 'EmailTemplate('
        'id: $id, '
        'name: $name, '
        'type: $type, '
        'subject: $subject, '
        'language: $language, '
        'isActive: $isActive'
        ')';
  }
} 