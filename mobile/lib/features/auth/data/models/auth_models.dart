import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'auth_models.g.dart';

/// 登录请求模型
@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;
  @JsonKey(name: 'remember_me')
  final bool rememberMe;

  const LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

/// 注册请求模型
@JsonSerializable()
class RegisterRequest {
  final String username;
  final String email;
  final String password;
  @JsonKey(name: 'confirm_password')
  final String confirmPassword;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'agree_to_terms')
  final bool agreeToTerms;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.firstName,
    this.lastName,
    this.agreeToTerms = false,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

/// 认证响应模型
@JsonSerializable()
class AuthResponse {
  final UserModel user;
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @JsonKey(name: 'token_type')
  final String tokenType;
  @JsonKey(name: 'expires_in')
  final int? expiresIn;
  final String? message;
  @JsonKey(name: 'is_first_login')
  final bool? isFirstLogin;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
    this.tokenType = 'Bearer',
    this.expiresIn,
    this.message,
    this.isFirstLogin,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

/// Token刷新请求模型
@JsonSerializable()
class RefreshTokenRequest {
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  const RefreshTokenRequest({required this.refreshToken});

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}

/// Token刷新响应模型
@JsonSerializable()
class RefreshTokenResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @JsonKey(name: 'token_type')
  final String tokenType;
  @JsonKey(name: 'expires_in')
  final int? expiresIn;

  const RefreshTokenResponse({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.tokenType = 'Bearer',
    this.expiresIn,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenResponseToJson(this);
}

/// 密码重置请求模型
@JsonSerializable()
class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({required this.email});

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordRequestToJson(this);
}

/// 重置密码请求模型
@JsonSerializable()
class ResetPasswordRequest {
  final String token;
  @JsonKey(name: 'new_password')
  final String newPassword;
  @JsonKey(name: 'confirm_password')
  final String confirmPassword;

  const ResetPasswordRequest({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}

/// 更改密码请求模型
@JsonSerializable()
class ChangePasswordRequest {
  @JsonKey(name: 'current_password')
  final String currentPassword;
  @JsonKey(name: 'new_password')
  final String newPassword;
  @JsonKey(name: 'confirm_password')
  final String confirmPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);
}

/// 邮箱验证请求模型
@JsonSerializable()
class EmailVerificationRequest {
  final String email;

  const EmailVerificationRequest({required this.email});

  factory EmailVerificationRequest.fromJson(Map<String, dynamic> json) =>
      _$EmailVerificationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EmailVerificationRequestToJson(this);
}

/// 验证邮箱请求模型
@JsonSerializable()
class VerifyEmailRequest {
  final String token;

  const VerifyEmailRequest({required this.token});

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyEmailRequestToJson(this);
}

/// 更新个人资料请求模型
@JsonSerializable()
class UpdateProfileRequest {
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String? username;
  final String? email;

  const UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.username,
    this.email,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}

/// 验证邮箱Token请求模型
@JsonSerializable()
class VerifyEmailTokenRequest {
  final String token;

  const VerifyEmailTokenRequest({required this.token});

  factory VerifyEmailTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyEmailTokenRequestToJson(this);
}

/// 更新用户信息请求模型
@JsonSerializable()
class UpdateUserRequest {
  final String? username;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String? avatar;
  final Map<String, dynamic>? profile;
  final Map<String, dynamic>? preferences;

  const UpdateUserRequest({
    this.username,
    this.firstName,
    this.lastName,
    this.avatar,
    this.profile,
    this.preferences,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateUserRequestToJson(this);
}

/// 登出请求模型
@JsonSerializable()
class LogoutRequest {
  @JsonKey(name: 'clear_all_sessions')
  final bool clearAllSessions;

  const LogoutRequest({this.clearAllSessions = false});

  factory LogoutRequest.fromJson(Map<String, dynamic> json) =>
      _$LogoutRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LogoutRequestToJson(this);
}

/// 删除账户请求模型
@JsonSerializable()
class DeleteAccountRequest {
  final String password;
  final String reason;

  const DeleteAccountRequest({
    required this.password,
    required this.reason,
  });

  factory DeleteAccountRequest.fromJson(Map<String, dynamic> json) =>
      _$DeleteAccountRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteAccountRequestToJson(this);
}

/// 注册响应模型
@JsonSerializable()
class RegisterResponse {
  final String message;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'requires_verification')
  final bool requiresVerification;

  const RegisterResponse({
    required this.message,
    this.userId,
    this.requiresVerification = true,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);
}

/// 基础API响应模型
@JsonSerializable()
class BaseApiResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final String? error;
  @JsonKey(name: 'error_code')
  final String? errorCode;

  const BaseApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
    this.errorCode,
  });

  factory BaseApiResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseApiResponseToJson(this);
}

/// 通用API响应模型
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;
  @JsonKey(name: 'error_code')
  final String? errorCode;
  final Map<String, dynamic>? metadata;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
    this.errorCode,
    this.metadata,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
} 