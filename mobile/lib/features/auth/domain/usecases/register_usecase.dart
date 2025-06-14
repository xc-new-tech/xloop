import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

/// 注册用例
class RegisterUsecase implements UseCase<RegisterResult, RegisterParams> {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  @override
  Future<Either<Failure, RegisterResult>> call(RegisterParams params) {
    return repository.register(
      username: params.username,
      email: params.email,
      password: params.password,
      firstName: params.firstName,
      lastName: params.lastName,
    );
  }
}

/// 注册参数
class RegisterParams {
  final String username;
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;

  const RegisterParams({
    required this.username,
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
  });
} 