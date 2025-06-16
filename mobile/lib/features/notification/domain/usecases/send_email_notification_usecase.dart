import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/email_notification.dart';
import '../repositories/email_notification_repository.dart';

/// 发送邮件通知用例参数
class SendEmailNotificationParams extends Equatable {
  final String to;
  final String? cc;
  final String? bcc;
  final String templateId;
  final Map<String, dynamic> variables;
  final EmailPriority priority;
  final DateTime? scheduledAt;

  const SendEmailNotificationParams({
    required this.to,
    this.cc,
    this.bcc,
    required this.templateId,
    required this.variables,
    this.priority = EmailPriority.normal,
    this.scheduledAt,
  });

  @override
  List<Object?> get props => [
        to,
        cc,
        bcc,
        templateId,
        variables,
        priority,
        scheduledAt,
      ];
}

/// 发送邮件通知用例
class SendEmailNotificationUseCase
    implements UseCase<EmailNotification, SendEmailNotificationParams> {
  final EmailNotificationRepository repository;

  SendEmailNotificationUseCase(this.repository);

  @override
  Future<Either<Failure, EmailNotification>> call(
    SendEmailNotificationParams params,
  ) async {
    return await repository.sendEmailNotification(
      to: params.to,
      cc: params.cc,
      bcc: params.bcc,
      templateId: params.templateId,
      variables: params.variables,
      priority: params.priority,
      scheduledAt: params.scheduledAt,
    );
  }
} 