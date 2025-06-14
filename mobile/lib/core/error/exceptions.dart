/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, [super.statusCode]);
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException(super.message, [super.statusCode]);
}

/// Validation related exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, [super.statusCode]);
}

/// Server related exceptions
class ServerException extends AppException {
  const ServerException(super.message, [super.statusCode]);
}

/// Cache related exceptions
class CacheException extends AppException {
  const CacheException(super.message, [super.statusCode]);
}

/// Storage related exceptions
class StorageException extends AppException {
  const StorageException(super.message, [super.statusCode]);
}

/// Parse related exceptions
class ParseException extends AppException {
  const ParseException(super.message, [super.statusCode]);
}

/// Timeout related exceptions
class TimeoutException extends AppException {
  const TimeoutException(super.message, [super.statusCode]);
}

/// Permission related exceptions
class PermissionException extends AppException {
  const PermissionException(super.message, [super.statusCode]);
}

/// Not found related exceptions
class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.statusCode]);
}

/// Bad request related exceptions
class BadRequestException extends AppException {
  const BadRequestException(super.message, [super.statusCode]);
}

/// Unauthorized related exceptions
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, [super.statusCode]);
}

/// Forbidden related exceptions
class ForbiddenException extends AppException {
  const ForbiddenException(super.message, [super.statusCode]);
}

/// Operation cancelled related exceptions
class OperationCancelledException extends AppException {
  const OperationCancelledException(super.message, [super.statusCode]);
}

/// Client error related exceptions
class ClientException extends AppException {
  const ClientException(super.message, [super.statusCode]);
}

/// Rate limit related exceptions
class RateLimitException extends AppException {
  const RateLimitException(super.message, [super.statusCode]);
} 