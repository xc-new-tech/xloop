/// 应用程序异常基类
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, [this.code]);
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// 服务器异常
class ServerException extends AppException {
  const ServerException({required String message, String? code}) 
      : super(message, code);
  
  @override
  String toString() => 'ServerException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// 认证异常
class AuthException extends AppException {
  const AuthException({required String message, String? code}) 
      : super(message, code);
  
  @override
  String toString() => 'AuthException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// 验证异常
class ValidationException extends AppException {
  const ValidationException({required String message, String? code}) 
      : super(message, code);
  
  @override
  String toString() => 'ValidationException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// 网络异常
class NetworkException extends AppException {
  const NetworkException({required String message, String? code}) 
      : super(message, code);
  
  @override
  String toString() => 'NetworkException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// 缓存异常
class CacheException extends AppException {
  const CacheException({required String message, String? code}) 
      : super(message, code);
  
  @override
  String toString() => 'CacheException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// 文件异常
class FileException extends AppException {
  const FileException({required String message, String? code}) 
      : super(message, code);
  
  @override
  String toString() => 'FileException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// 解析异常
class ParseException extends AppException {
  const ParseException({required String message, String? code}) 
      : super(message, code);
  
  @override
  String toString() => 'ParseException: $message${code != null ? ' (Code: $code)' : ''}';
} 