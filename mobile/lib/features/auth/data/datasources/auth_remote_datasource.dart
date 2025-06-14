import '../models/auth_models.dart';
import '../models/user_model.dart';

/// 认证远程数据源抽象接口
abstract class AuthRemoteDataSource {
  /// 用户登录
  Future<AuthResponse> login(LoginRequest request);

  /// 用户注册
  Future<ApiResponse<String>> register(RegisterRequest request);

  /// 登出
  Future<ApiResponse<String>> logout(LogoutRequest request);

  /// 刷新Token
  Future<RefreshTokenResponse> refreshToken(RefreshTokenRequest request);

  /// 忘记密码
  Future<ApiResponse<String>> forgotPassword(ForgotPasswordRequest request);

  /// 重置密码
  Future<ApiResponse<String>> resetPassword(ResetPasswordRequest request);

  /// 更改密码
  Future<ApiResponse<String>> changePassword(ChangePasswordRequest request);

  /// 发送邮箱验证
  Future<ApiResponse<String>> sendEmailVerification(EmailVerificationRequest request);

  /// 验证邮箱Token
  Future<ApiResponse<String>> verifyEmailToken(VerifyEmailTokenRequest request);

  /// 获取当前用户信息
  Future<UserModel> getCurrentUser();

  /// 更新用户信息
  Future<UserModel> updateUser(UpdateUserRequest request);

  /// 删除账户
  Future<ApiResponse<String>> deleteAccount(DeleteAccountRequest request);

  /// 验证Token有效性
  Future<ApiResponse<String>> validateToken();

  /// 重新发送验证邮件
  Future<ApiResponse<String>> resendVerificationEmail();

  /// 验证邮件
  Future<ApiResponse<String>> verifyEmail(VerifyEmailRequest request);

  /// 更新个人资料
  Future<UserModel> updateProfile(UpdateProfileRequest request);
} 