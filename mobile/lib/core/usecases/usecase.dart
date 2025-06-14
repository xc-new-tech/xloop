import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// 用例基类 - 定义所有用例的通用接口
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// 无参数用例基类
abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}

/// 空参数类 - 用于不需要参数的用例
class NoParams {
  const NoParams();
} 