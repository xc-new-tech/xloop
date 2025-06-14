import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

/// 刷新Token用例
class RefreshTokenUsecase implements UseCaseNoParams<TokenResult> {
  final AuthRepository repository;

  RefreshTokenUsecase(this.repository);

  @override
  Future<Either<Failure, TokenResult>> call() async {
    return await repository.refreshToken();
  }
} 