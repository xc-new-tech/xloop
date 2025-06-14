import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// 验证邮箱用例
class VerifyEmailUseCase implements UseCase<void, VerifyEmailParams> {
  final AuthRepository repository;

  VerifyEmailUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(VerifyEmailParams params) async {
    return await repository.verifyEmail(params.token);
  }
}

/// 验证邮箱参数
class VerifyEmailParams {
  final String token;

  const VerifyEmailParams({required this.token});
} 