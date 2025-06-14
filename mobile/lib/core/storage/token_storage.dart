import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../config/security_config.dart';

/// 令牌安全存储服务
class TokenStorage {
  static TokenStorage? _instance;
  late FlutterSecureStorage _secureStorage;
  late SharedPreferences _prefs;

  TokenStorage._internal();

  /// 构造函数用于依赖注入
  TokenStorage(SharedPreferences prefs) {
    _prefs = prefs;
    final securityOptions = SecurityConfig.getSecureStorageOptions();
    
    _secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: securityOptions['encryptedSharedPreferences'] == 'true',
        keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      ),
      iOptions: IOSOptions(
        accessibility: SecurityConfig.requireAuthentication 
            ? KeychainAccessibility.first_unlock_this_device
            : KeychainAccessibility.unlocked_this_device,
        synchronizable: false,
        accountName: SecurityConfig.keyAlias,
      ),
    );
  }

  static Future<TokenStorage> getInstance() async {
    if (_instance == null) {
      _instance = TokenStorage._internal();
      await _instance!._init();
    }
    return _instance!;
  }

  /// 初始化存储
  Future<void> _init() async {
    final securityOptions = SecurityConfig.getSecureStorageOptions();
    
    _secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: securityOptions['encryptedSharedPreferences'] == 'true',
        keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      ),
      iOptions: IOSOptions(
        accessibility: SecurityConfig.requireAuthentication 
            ? KeychainAccessibility.first_unlock_this_device
            : KeychainAccessibility.unlocked_this_device,
        synchronizable: false,
        accountName: SecurityConfig.keyAlias,
      ),
    );
    _prefs = await SharedPreferences.getInstance();
  }

  /// 保存令牌
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        _secureStorage.write(
          key: StorageConstants.accessToken,
          value: accessToken,
        ),
        _secureStorage.write(
          key: StorageConstants.refreshToken,
          value: refreshToken,
        ),
      ]);
    } catch (e) {
      throw TokenStorageException('保存令牌失败: $e');
    }
  }

  /// 获取访问令牌
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: StorageConstants.accessToken);
    } catch (e) {
      throw TokenStorageException('获取访问令牌失败: $e');
    }
  }

  /// 获取刷新令牌
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: StorageConstants.refreshToken);
    } catch (e) {
      throw TokenStorageException('获取刷新令牌失败: $e');
    }
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await getAccessToken();
      return accessToken != null && accessToken.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 检查是否有令牌（同步方法用于AuthRepository）
  bool hasTokens() {
    // 简化版本，实际应该检查存储中是否有令牌
    // 但由于这是同步方法，我们需要使用SharedPreferences
    try {
      // 从SharedPreferences获取一个标志位表示是否有令牌
      return _prefs.getBool('has_tokens') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 保存访问令牌（用于AuthRepository）
  Future<void> saveAccessToken(String accessToken) async {
    try {
      await _secureStorage.write(
        key: StorageConstants.accessToken,
        value: accessToken,
      );
      // 设置标志位
      await _prefs.setBool('has_tokens', true);
    } catch (e) {
      throw TokenStorageException('保存访问令牌失败: $e');
    }
  }

  /// 清除所有令牌
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: StorageConstants.accessToken),
        _secureStorage.delete(key: StorageConstants.refreshToken),
      ]);
    } catch (e) {
      throw TokenStorageException('清除令牌失败: $e');
    }
  }

  /// 保存用户凭据（记住我功能）
  Future<void> saveUserCredentials({
    required String email,
    required String password,
  }) async {
    try {
      await _secureStorage.write(
        key: StorageConstants.userCredentials,
        value: '$email:$password',
      );
    } catch (e) {
      throw TokenStorageException('保存用户凭据失败: $e');
    }
  }

  /// 获取用户凭据
  Future<Map<String, String>?> getUserCredentials() async {
    try {
      final credentials = await _secureStorage.read(
        key: StorageConstants.userCredentials,
      );
      if (credentials != null && credentials.contains(':')) {
        final parts = credentials.split(':');
        if (parts.length == 2) {
          return {
            'email': parts[0],
            'password': parts[1],
          };
        }
      }
      return null;
    } catch (e) {
      throw TokenStorageException('获取用户凭据失败: $e');
    }
  }

  /// 清除用户凭据
  Future<void> clearUserCredentials() async {
    try {
      await _secureStorage.delete(key: StorageConstants.userCredentials);
    } catch (e) {
      throw TokenStorageException('清除用户凭据失败: $e');
    }
  }

  /// 保存用户偏好设置
  Future<void> saveUserPreference(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (e) {
      throw TokenStorageException('保存用户偏好失败: $e');
    }
  }

  /// 获取用户偏好设置
  String? getUserPreference(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      throw TokenStorageException('获取用户偏好失败: $e');
    }
  }

  /// 保存布尔类型偏好
  Future<void> setBoolPreference(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
    } catch (e) {
      throw TokenStorageException('保存布尔偏好失败: $e');
    }
  }

  /// 获取布尔类型偏好
  bool? getBoolPreference(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      throw TokenStorageException('获取布尔偏好失败: $e');
    }
  }

  /// 清除所有数据
  Future<void> clearAll() async {
    try {
      await Future.wait([
        _secureStorage.deleteAll(),
        _prefs.clear(),
      ]);
    } catch (e) {
      throw TokenStorageException('清除所有数据失败: $e');
    }
  }

  /// 检查令牌是否过期（基本检查）
  Future<bool> isTokenExpired() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) return true;

      // 这里可以添加JWT解析逻辑来检查过期时间
      // 目前简单返回false，实际应用中需要解析JWT的exp字段
      return false;
    } catch (e) {
      return true;
    }
  }

  /// 保存用户数据
  Future<void> saveUserData(String userData) async {
    try {
      await _secureStorage.write(
        key: StorageConstants.userData,
        value: userData,
      );
    } catch (e) {
      throw TokenStorageException('保存用户数据失败: $e');
    }
  }

  /// 获取用户数据
  Future<String?> getUserData() async {
    try {
      return await _secureStorage.read(key: StorageConstants.userData);
    } catch (e) {
      throw TokenStorageException('获取用户数据失败: $e');
    }
  }

  /// 获取缓存的用户信息（用于AuthRepository）
  Future<String?> getCachedUser() async {
    try {
      return await _secureStorage.read(key: StorageConstants.userData);
    } catch (e) {
      throw TokenStorageException('获取缓存用户失败: $e');
    }
  }

  /// 设置缓存的用户信息（用于AuthRepository）
  Future<void> setCachedUser(String userJson) async {
    try {
      await _secureStorage.write(
        key: StorageConstants.userData,
        value: userJson,
      );
    } catch (e) {
      throw TokenStorageException('设置缓存用户失败: $e');
    }
  }

  /// 保存刷新令牌（用于AuthRepository）
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _secureStorage.write(
        key: StorageConstants.refreshToken,
        value: refreshToken,
      );
    } catch (e) {
      throw TokenStorageException('保存刷新令牌失败: $e');
    }
  }

  /// 保存令牌过期时间（用于AuthRepository）
  Future<void> saveTokenExpiry(DateTime expiry) async {
    try {
      await _secureStorage.write(
        key: 'token_expiry',
        value: expiry.toIso8601String(),
      );
    } catch (e) {
      throw TokenStorageException('保存令牌过期时间失败: $e');
    }
  }

  /// 清除用户数据
  Future<void> clearUserData() async {
    try {
      await _secureStorage.delete(key: StorageConstants.userData);
    } catch (e) {
      throw TokenStorageException('清除用户数据失败: $e');
    }
  }

  /// 获取存储统计信息（调试用）
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final hasAccessToken = await getAccessToken() != null;
      final hasRefreshToken = await getRefreshToken() != null;
      final hasCredentials = await getUserCredentials() != null;
      final hasUserData = await getUserData() != null;
      
      return {
        'hasAccessToken': hasAccessToken,
        'hasRefreshToken': hasRefreshToken,
        'hasCredentials': hasCredentials,
        'hasUserData': hasUserData,
        'isLoggedIn': await isLoggedIn(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
}

/// 令牌存储异常类
class TokenStorageException implements Exception {
  final String message;
  
  const TokenStorageException(this.message);
  
  @override
  String toString() => 'TokenStorageException: $message';
} 