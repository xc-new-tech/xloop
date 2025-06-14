import 'package:equatable/equatable.dart';

/// 基础失败类
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
    required super.message,
    super.statusCode,
  });
}

/// 网络连接失败
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = '网络连接失败，请检查网络设置',
    super.statusCode,
  });
}

/// 认证失败
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.statusCode,
  });
}

/// 验证失败
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;
  
  const ValidationFailure({
    required super.message,
    super.statusCode,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, statusCode, fieldErrors];
}

/// 缓存失败
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = '本地数据访问失败',
    super.statusCode,
  });
}

/// 权限失败
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = '权限不足',
    super.statusCode = 403,
  });
}

/// 未找到资源失败
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = '请求的资源不存在',
    super.statusCode = 404,
  });
}

/// 频率限制失败
class RateLimitFailure extends Failure {
  const RateLimitFailure({
    super.message = '请求过于频繁，请稍后再试',
    super.statusCode = 429,
  });
}

/// 未知失败
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = '未知错误，请重试',
    super.statusCode,
  });
} 