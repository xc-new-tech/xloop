import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/email_template.dart';
import '../repositories/email_notification_repository.dart';

/// 获取邮件模板用例参数
class GetEmailTemplatesParams extends Equatable {
  final EmailTemplateType? type;
  final String? language;

  const GetEmailTemplatesParams({
    this.type,
    this.language,
  });

  @override
  List<Object?> get props => [type, language];
}

/// 获取邮件模板用例
class GetEmailTemplatesUseCase
    implements UseCase<List<EmailTemplate>, GetEmailTemplatesParams> {
  final EmailNotificationRepository repository;

  GetEmailTemplatesUseCase(this.repository);

  @override
  Future<Either<Failure, List<EmailTemplate>>> call(
    GetEmailTemplatesParams params,
  ) async {
    return await repository.getEmailTemplates(
      type: params.type,
      language: params.language,
    );
  }
} 