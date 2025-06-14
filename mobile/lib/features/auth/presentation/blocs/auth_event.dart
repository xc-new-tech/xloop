import 'package:equatable/equatable.dart';

/// 认证事件基类
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// 应用启动事件 - 检查用户登录状态
class AuthAppStarted extends AuthEvent {
  const AuthAppStarted();

  @override
  String toString() => 'AuthAppStarted';
}

/// 登录事件
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const AuthLoginRequested({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];

  @override
  String toString() {
    return 'AuthLoginRequested('
        'email: $email, '
        'rememberMe: $rememberMe'
        ')';
  }
}

/// 注册事件
class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final String? firstName;
  final String? lastName;
  final bool agreeToTerms;

  const AuthRegisterRequested({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.firstName,
    this.lastName,
    this.agreeToTerms = false,
  });

  @override
  List<Object?> get props => [
        username,
        email,
        password,
        confirmPassword,
        firstName,
        lastName,
        agreeToTerms,
      ];

  @override
  String toString() {
    return 'AuthRegisterRequested('
        'username: $username, '
        'email: $email, '
        'firstName: $firstName, '
        'lastName: $lastName, '
        'agreeToTerms: $agreeToTerms'
        ')';
  }
}

/// 登出事件
class AuthLogoutRequested extends AuthEvent {
  final bool clearAllSessions;

  const AuthLogoutRequested({this.clearAllSessions = false});

  @override
  List<Object?> get props => [clearAllSessions];

  @override
  String toString() {
    return 'AuthLogoutRequested(clearAllSessions: $clearAllSessions)';
  }
}

/// Token刷新事件
class AuthTokenRefreshRequested extends AuthEvent {
  final String refreshToken;
  final bool isBackground;

  const AuthTokenRefreshRequested({
    required this.refreshToken,
    this.isBackground = false,
  });

  @override
  List<Object?> get props => [refreshToken, isBackground];

  @override
  String toString() {
    return 'AuthTokenRefreshRequested(isBackground: $isBackground)';
  }
}

/// 邮箱验证事件
class AuthEmailVerificationRequested extends AuthEvent {
  final String email;

  const AuthEmailVerificationRequested({required this.email});

  @override
  List<Object?> get props => [email];

  @override
  String toString() {
    return 'AuthEmailVerificationRequested(email: $email)';
  }
}

/// 验证邮箱token事件
class AuthVerifyEmailToken extends AuthEvent {
  final String token;

  const AuthVerifyEmailToken({required this.token});

  @override
  List<Object?> get props => [token];

  @override
  String toString() {
    return 'AuthVerifyEmailToken(token: $token)';
  }
}

/// 密码重置请求事件
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];

  @override
  String toString() {
    return 'AuthPasswordResetRequested(email: $email)';
  }
}

/// 重置密码事件
class AuthResetPassword extends AuthEvent {
  final String token;
  final String newPassword;
  final String confirmPassword;

  const AuthResetPassword({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [token, newPassword, confirmPassword];

  @override
  String toString() {
    return 'AuthResetPassword(token: $token)';
  }
}

/// 更改密码事件
class AuthChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const AuthChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmPassword];

  @override
  String toString() {
    return 'AuthChangePasswordRequested()';
  }
}

/// 更新用户信息事件
class AuthUpdateUserRequested extends AuthEvent {
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  final Map<String, dynamic>? profile;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? userData;

  const AuthUpdateUserRequested({
    this.username,
    this.firstName,
    this.lastName,
    this.avatar,
    this.profile,
    this.preferences,
    this.userData,
  });

  @override
  List<Object?> get props => [
        username,
        firstName,
        lastName,
        avatar,
        profile,
        preferences,
        userData,
      ];

  @override
  String toString() {
    return 'AuthUpdateUserRequested('
        'username: $username, '
        'firstName: $firstName, '
        'lastName: $lastName'
        ')';
  }
}

/// 删除账户事件
class AuthDeleteAccountRequested extends AuthEvent {
  final String password;
  final String reason;

  const AuthDeleteAccountRequested({
    required this.password,
    required this.reason,
  });

  @override
  List<Object?> get props => [password, reason];

  @override
  String toString() {
    return 'AuthDeleteAccountRequested(reason: $reason)';
  }
}

/// 清除错误状态事件
class AuthClearError extends AuthEvent {
  const AuthClearError();

  @override
  String toString() => 'AuthClearError';
}

/// 检查认证状态事件
class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();

  @override
  String toString() => 'AuthCheckStatus';
}

/// 检查认证状态事件（别名）
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();

  @override
  String toString() => 'AuthCheckRequested';
}

/// 社交登录事件
class AuthSocialLoginRequested extends AuthEvent {
  final String provider; // google, apple, github等
  final String accessToken;
  final Map<String, dynamic>? additionalData;

  const AuthSocialLoginRequested({
    required this.provider,
    required this.accessToken,
    this.additionalData,
  });

  @override
  List<Object?> get props => [provider, accessToken, additionalData];

  @override
  String toString() {
    return 'AuthSocialLoginRequested(provider: $provider)';
  }
} 