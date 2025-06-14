import 'package:equatable/equatable.dart';

/// 失败基类
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

/// 服务器失败
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

/// 网络失败
class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

/// 认证失败
class AuthFailure extends Failure {
  const AuthFailure({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

/// 验证失败
class ValidationFailure extends Failure {
  const ValidationFailure({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

/// 缓存失败
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

/// 权限失败
class PermissionFailure extends Failure {
  const PermissionFailure({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

/// 未知失败
class UnknownFailure extends Failure {
  const UnknownFailure({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

/// 未找到失败
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required String message,
    int? statusCode = 404,
  }) : super(message: message, statusCode: statusCode);
}

/// 身份验证失败
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = '身份验证失败，请重新登录',
    super.statusCode = 401,
  });
}

/// 授权失败
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    super.message = '权限不足，无法访问此资源',
    super.statusCode = 403,
  });
} 