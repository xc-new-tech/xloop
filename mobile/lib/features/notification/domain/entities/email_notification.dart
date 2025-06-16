import 'package:equatable/equatable.dart';

/// 邮件发送状态枚举
enum EmailStatus {
  pending,
  sending,
  sent,
  failed,
  retrying,
}

/// 邮件优先级枚举
enum EmailPriority {
  low,
  normal,
  high,
  urgent,
}

/// 邮件通知实体
class EmailNotification extends Equatable {
  final String id;
  final String to;
  final String? cc;
  final String? bcc;
  final String subject;
  final String htmlContent;
  final String textContent;
  final EmailStatus status;
  final EmailPriority priority;
  final String templateId;
  final Map<String, dynamic> variables;
  final int retryCount;
  final int maxRetries;
  final String? errorMessage;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmailNotification({
    required this.id,
    required this.to,
    this.cc,
    this.bcc,
    required this.subject,
    required this.htmlContent,
    required this.textContent,
    this.status = EmailStatus.pending,
    this.priority = EmailPriority.normal,
    required this.templateId,
    this.variables = const {},
    this.retryCount = 0,
    this.maxRetries = 3,
    this.errorMessage,
    this.scheduledAt,
    this.sentAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        to,
        cc,
        bcc,
        subject,
        htmlContent,
        textContent,
        status,
        priority,
        templateId,
        variables,
        retryCount,
        maxRetries,
        errorMessage,
        scheduledAt,
        sentAt,
        createdAt,
        updatedAt,
      ];

  EmailNotification copyWith({
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
    return EmailNotification(
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

  /// 是否可以重试
  bool get canRetry => retryCount < maxRetries && status == EmailStatus.failed;

  /// 是否已发送
  bool get isSent => status == EmailStatus.sent;

  /// 是否失败
  bool get isFailed => status == EmailStatus.failed && !canRetry;

  @override
  String toString() {
    return 'EmailNotification('
        'id: $id, '
        'to: $to, '
        'subject: $subject, '
        'status: $status, '
        'priority: $priority, '
        'retryCount: $retryCount'
        ')';
  }
} 