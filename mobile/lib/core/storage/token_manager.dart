import 'token_storage.dart';

/// 令牌管理器 - TokenStorage的包装器
class TokenManager {
  final TokenStorage _tokenStorage;

  TokenManager(this._tokenStorage);

  /// 保存令牌
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// 获取访问令牌
  Future<String?> getAccessToken() async {
    return await _tokenStorage.getAccessToken();
  }

  /// 获取刷新令牌
  Future<String?> getRefreshToken() async {
    return await _tokenStorage.getRefreshToken();
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    return await _tokenStorage.isLoggedIn();
  }

  /// 清除所有令牌
  Future<void> clearTokens() async {
    await _tokenStorage.clearTokens();
  }

  /// 检查令牌是否过期
  Future<bool> isTokenExpired() async {
    return await _tokenStorage.isTokenExpired();
  }

  /// 保存用户凭据（记住我功能）
  Future<void> saveUserCredentials({
    required String email,
    required String password,
  }) async {
    await _tokenStorage.saveUserCredentials(
      email: email,
      password: password,
    );
  }

  /// 获取用户凭据
  Future<Map<String, String>?> getUserCredentials() async {
    return await _tokenStorage.getUserCredentials();
  }

  /// 清除用户凭据
  Future<void> clearUserCredentials() async {
    await _tokenStorage.clearUserCredentials();
  }

  /// 清除所有数据
  Future<void> clearAll() async {
    await _tokenStorage.clearAll();
  }
} 