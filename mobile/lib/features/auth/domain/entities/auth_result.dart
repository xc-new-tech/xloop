import 'package:equatable/equatable.dart';
import 'user.dart';

/// Login operation result
class LoginResult extends Equatable {
  final User user;
  final String accessToken;
  final String refreshToken;
  final bool requiresEmailVerification;

  const LoginResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.requiresEmailVerification = false,
  });

  String get username => user.username;
  String get displayName => user.displayName;

  @override
  List<Object?> get props => [
        user,
        accessToken,
        refreshToken,
        requiresEmailVerification,
      ];
}

/// Registration operation result
class RegisterResult extends Equatable {
  final String message;
  final bool requiresEmailVerification;
  final String? userId;

  const RegisterResult({
    required this.message,
    this.requiresEmailVerification = true,
    this.userId,
  });

  @override
  List<Object?> get props => [
        message,
        requiresEmailVerification,
        userId,
      ];
}

/// Token refresh operation result
class TokenResult extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const TokenResult({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        expiresAt,
      ];
} 