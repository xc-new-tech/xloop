import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/email_notification.dart';
import '../entities/email_template.dart';

/// 邮件通知仓库接口
abstract class EmailNotificationRepository {
  /// 发送邮件通知
  Future<Either<Failure, EmailNotification>> sendEmailNotification({
    required String to,
    String? cc,
    String? bcc,
    required String templateId,
    required Map<String, dynamic> variables,
    EmailPriority priority = EmailPriority.normal,
    DateTime? scheduledAt,
  });

  /// 获取邮件模板
  Future<Either<Failure, EmailTemplate>> getEmailTemplate(String templateId);

  /// 获取所有邮件模板
  Future<Either<Failure, List<EmailTemplate>>> getEmailTemplates({
    EmailTemplateType? type,
    String? language,
  });

  /// 创建邮件模板
  Future<Either<Failure, EmailTemplate>> createEmailTemplate(EmailTemplate template);

  /// 更新邮件模板
  Future<Either<Failure, EmailTemplate>> updateEmailTemplate(EmailTemplate template);

  /// 删除邮件模板
  Future<Either<Failure, void>> deleteEmailTemplate(String templateId);

  /// 获取邮件通知历史
  Future<Either<Failure, List<EmailNotification>>> getEmailNotifications({
    String? to,
    EmailStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  });

  /// 获取邮件通知详情
  Future<Either<Failure, EmailNotification>> getEmailNotification(String notificationId);

  /// 重试发送邮件
  Future<Either<Failure, EmailNotification>> retryEmailNotification(String notificationId);

  /// 取消邮件发送
  Future<Either<Failure, void>> cancelEmailNotification(String notificationId);

  /// 预览邮件内容
  Future<Either<Failure, String>> previewEmailContent({
    required String templateId,
    required Map<String, dynamic> variables,
  });

  /// 验证邮件模板
  Future<Either<Failure, bool>> validateEmailTemplate(EmailTemplate template);

  /// 获取邮件发送统计
  Future<Either<Failure, Map<String, dynamic>>> getEmailStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });
} 