import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/email_notification.dart';

part 'email_notification_model.g.dart';

/// 邮件通知数据模型
@JsonSerializable()
class EmailNotificationModel extends EmailNotification {
  const EmailNotificationModel({
    required super.id,
    required super.to,
    super.cc,
    super.bcc,
    required super.subject,
    required super.htmlContent,
    required super.textContent,
    super.status,
    super.priority,
    required super.templateId,
    super.variables,
    super.retryCount,
    super.maxRetries,
    super.errorMessage,
    super.scheduledAt,
    super.sentAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory EmailNotificationModel.fromJson(Map<String, dynamic> json) =>
      _$EmailNotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmailNotificationModelToJson(this);

  factory EmailNotificationModel.fromEntity(EmailNotification notification) {
    return EmailNotificationModel(
      id: notification.id,
      to: notification.to,
      cc: notification.cc,
      bcc: notification.bcc,
      subject: notification.subject,
      htmlContent: notification.htmlContent,
      textContent: notification.textContent,
      status: notification.status,
      priority: notification.priority,
      templateId: notification.templateId,
      variables: notification.variables,
      retryCount: notification.retryCount,
      maxRetries: notification.maxRetries,
      errorMessage: notification.errorMessage,
      scheduledAt: notification.scheduledAt,
      sentAt: notification.sentAt,
      createdAt: notification.createdAt,
      updatedAt: notification.updatedAt,
    );
  }

  EmailNotification toEntity() {
    return EmailNotification(
      id: id,
      to: to,
      cc: cc,
      bcc: bcc,
      subject: subject,
      htmlContent: htmlContent,
      textContent: textContent,
      status: status,
      priority: priority,
      templateId: templateId,
      variables: variables,
      retryCount: retryCount,
      maxRetries: maxRetries,
      errorMessage: errorMessage,
      scheduledAt: scheduledAt,
      sentAt: sentAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  EmailNotificationModel copyWith({
    String? id,
    String? to,
    String? cc,
    String? bcc,
    String? subject,
    String? htmlContent,
    String? textContent,
    EmailStatus? status,
    EmailPriority? priority,
    String? templateId,
    Map<String, dynamic>? variables,
    int? retryCount,
    int? maxRetries,
    String? errorMessage,
    DateTime? scheduledAt,
    DateTime? sentAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmailNotificationModel(
      id: id ?? this.id,
      to: to ?? this.to,
      cc: cc ?? this.cc,
      bcc: bcc ?? this.bcc,
      subject: subject ?? this.subject,
      htmlContent: htmlContent ?? this.htmlContent,
      textContent: textContent ?? this.textContent,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      templateId: templateId ?? this.templateId,
      variables: variables ?? this.variables,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      errorMessage: errorMessage ?? this.errorMessage,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 