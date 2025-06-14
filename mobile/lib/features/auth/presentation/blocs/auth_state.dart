import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// 认证状态枚举
enum AuthStatus {
  initial,      // 初始状态
  loading,      // 加载中
  authenticated,// 已认证
  unauthenticated, // 未认证
  error,        // 错误状态
}

/// 认证状态基类
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// 加载状态
class AuthLoading extends AuthState {
  final String? message;

  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// 已认证状态
class AuthAuthenticated extends AuthState {
  final User user;
  final String accessToken;
  final String refreshToken;
  final DateTime? tokenExpiresAt;

  const AuthAuthenticated({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.tokenExpiresAt,
  });

  /// 检查token是否即将过期（提前5分钟刷新）
  bool get isTokenExpiringSoon {
    if (tokenExpiresAt == null) return false;
    final now = DateTime.now();
    final expiryTime = tokenExpiresAt!;
    final fiveMinutesBeforeExpiry = expiryTime.subtract(const Duration(minutes: 5));
    return now.isAfter(fiveMinutesBeforeExpiry);
  }

  /// 检查token是否已过期
  bool get isTokenExpired {
    if (tokenExpiresAt == null) return false;
    return DateTime.now().isAfter(tokenExpiresAt!);
  }

  /// 复制并更新认证状态
  AuthAuthenticated copyWith({
    User? user,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
  }) {
    return AuthAuthenticated(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
    );
  }

  @override
  List<Object?> get props => [user, accessToken, refreshToken, tokenExpiresAt];

  @override
  String toString() {
    return 'AuthAuthenticated('
        'user: ${user.toString()}, '
        'hasAccessToken: ${accessToken.isNotEmpty}, '
        'hasRefreshToken: ${refreshToken.isNotEmpty}, '
        'tokenExpiresAt: $tokenExpiresAt'
        ')';
  }
}

/// 未认证状态
class AuthUnauthenticated extends AuthState {
  final String? message;

  const AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return 'AuthUnauthenticated(message: $message)';
  }
}

/// 错误状态
class AuthError extends AuthState {
  final String message;
  final String? errorCode;
  final dynamic error;
  final StackTrace? stackTrace;

  const AuthError({
    required this.message,
    this.errorCode,
    this.error,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, errorCode, error];

  @override
  String toString() {
    return 'AuthError('
        'message: $message, '
        'errorCode: $errorCode, '
        'error: $error'
        ')';
  }
}

/// 登录加载状态
class AuthLoginLoading extends AuthLoading {
  const AuthLoginLoading({super.message});

  @override
  String toString() {
    return 'AuthLoginLoading(message: $message)';
  }
}

/// 登录成功状态
class AuthLoginSuccess extends AuthAuthenticated {
  final bool isFirstLogin;
  final String? welcomeMessage;

  const AuthLoginSuccess({
    required super.user,
    required super.accessToken,
    required super.refreshToken,
    super.tokenExpiresAt,
    this.isFirstLogin = false,
    this.welcomeMessage,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        isFirstLogin,
        welcomeMessage,
      ];

  @override
  String toString() {
    return 'AuthLoginSuccess('
        'user: ${user.toString()}, '
        'isFirstLogin: $isFirstLogin, '
        'welcomeMessage: $welcomeMessage'
        ')';
  }
}

/// 登录失败状态
class AuthLoginFailure extends AuthError {
  final String? email;
  final int? statusCode;

  const AuthLoginFailure({
    required super.message,
    super.errorCode,
    super.error,
    super.stackTrace,
    this.email,
    this.statusCode,
  });

  @override
  List<Object?> get props => [...super.props, email, statusCode];

  @override
  String toString() {
    return 'AuthLoginFailure('
        'message: $message, '
        'email: $email, '
        'statusCode: $statusCode'
        ')';
  }
}

/// 注册成功状态
class AuthRegisterSuccess extends AuthState {
  final String message;
  final String? email;
  final bool requiresEmailVerification;

  const AuthRegisterSuccess({
    required this.message,
    this.email,
    this.requiresEmailVerification = true,
  });

  @override
  List<Object?> get props => [message, email, requiresEmailVerification];

  @override
  String toString() {
    return 'AuthRegisterSuccess('
        'message: $message, '
        'email: $email, '
        'requiresEmailVerification: $requiresEmailVerification'
        ')';
  }
}

/// 邮箱验证状态
class AuthEmailVerificationSent extends AuthState {
  final String email;
  final String message;

  const AuthEmailVerificationSent({
    required this.email,
    required this.message,
  });

  @override
  List<Object?> get props => [email, message];

  @override
  String toString() {
    return 'AuthEmailVerificationSent(email: $email, message: $message)';
  }
}

/// 密码重置状态
class AuthPasswordResetSent extends AuthState {
  final String email;
  final String message;

  const AuthPasswordResetSent({
    required this.email,
    required this.message,
  });

  @override
  List<Object?> get props => [email, message];

  @override
  String toString() {
    return 'AuthPasswordResetSent(email: $email, message: $message)';
  }
}

/// 登出状态
class AuthLoggedOut extends AuthState {
  final String? message;

  const AuthLoggedOut({this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return 'AuthLoggedOut(message: $message)';
  }
}

/// 登出成功状态
class AuthLogoutSuccess extends AuthState {
  final String message;
  final bool redirectToLogin;

  const AuthLogoutSuccess({
    required this.message,
    this.redirectToLogin = true,
  });

  @override
  List<Object?> get props => [message, redirectToLogin];

  @override
  String toString() {
    return 'AuthLogoutSuccess(message: $message, redirectToLogin: $redirectToLogin)';
  }
}

/// 邮箱验证成功状态
class AuthEmailVerificationSuccess extends AuthState {
  final String message;
  final bool redirectToLogin;

  const AuthEmailVerificationSuccess({
    required this.message,
    this.redirectToLogin = true,
  });

  @override
  List<Object?> get props => [message, redirectToLogin];

  @override
  String toString() {
    return 'AuthEmailVerificationSuccess(message: $message, redirectToLogin: $redirectToLogin)';
  }
}

/// 密码重置邮件发送状态
class AuthPasswordResetEmailSent extends AuthState {
  final String email;
  final String message;

  const AuthPasswordResetEmailSent({
    required this.email,
    required this.message,
  });

  @override
  List<Object?> get props => [email, message];

  @override
  String toString() {
    return 'AuthPasswordResetEmailSent(email: $email, message: $message)';
  }
}

/// 密码重置成功状态
class AuthPasswordResetSuccess extends AuthState {
  final String message;
  final bool redirectToLogin;

  const AuthPasswordResetSuccess({
    required this.message,
    this.redirectToLogin = true,
  });

  @override
  List<Object?> get props => [message, redirectToLogin];

  @override
  String toString() {
    return 'AuthPasswordResetSuccess(message: $message, redirectToLogin: $redirectToLogin)';
  }
}

/// 密码更改成功状态
class AuthPasswordChangeSuccess extends AuthState {
  final String message;
  final bool requiresReLogin;

  const AuthPasswordChangeSuccess({
    required this.message,
    this.requiresReLogin = false,
  });

  @override
  List<Object?> get props => [message, requiresReLogin];

  @override
  String toString() {
    return 'AuthPasswordChangeSuccess(message: $message, requiresReLogin: $requiresReLogin)';
  }
}

/// 用户信息更新成功状态
class AuthUserUpdateSuccess extends AuthState {
  final User user;
  final String message;

  const AuthUserUpdateSuccess({
    required this.user,
    required this.message,
  });

  @override
  List<Object?> get props => [user, message];

  @override
  String toString() {
    return 'AuthUserUpdateSuccess(user: ${user.toString()}, message: $message)';
  }
}

/// 账户删除成功状态
class AuthAccountDeleteSuccess extends AuthState {
  final String message;
  final bool redirectToWelcome;

  const AuthAccountDeleteSuccess({
    required this.message,
    this.redirectToWelcome = true,
  });

  @override
  List<Object?> get props => [message, redirectToWelcome];

  @override
  String toString() {
    return 'AuthAccountDeleteSuccess(message: $message, redirectToWelcome: $redirectToWelcome)';
  }
}

/// 邮箱验证完成状态
class AuthEmailVerified extends AuthState {
  final String message;

  const AuthEmailVerified({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return 'AuthEmailVerified(message: $message)';
  }
}

/// 账户删除状态
class AuthAccountDeleted extends AuthState {
  final String message;

  const AuthAccountDeleted({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return 'AuthAccountDeleted(message: $message)';
  }
} 