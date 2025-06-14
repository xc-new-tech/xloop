import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger_utils.dart';

/// 应用偏好设置管理器
class AppPreferences {
  final SharedPreferences _sharedPreferences;
  
  // 统计计数器
  int _getCount = 0;

  AppPreferences({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  // ===============================
  // 常量定义
  // ===============================
  
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyIsFirstLaunch = 'is_first_launch';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyLastLoginEmail = 'last_login_email';
  static const String _keyNotificationEnabled = 'notification_enabled';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyAutoLockTimeout = 'auto_lock_timeout';
  static const String _keyApiBaseUrl = 'api_base_url';
  static const String _keyDebugMode = 'debug_mode';

  // ===============================
  // 主题设置
  // ===============================
  
  /// 获取主题模式 (0: 系统, 1: 浅色, 2: 深色)
  int getThemeMode() {
    _getCount++;
    return _sharedPreferences.getInt(_keyThemeMode) ?? 0;
  }

  /// 设置主题模式
  Future<bool> setThemeMode(int themeMode) {
    return _sharedPreferences.setInt(_keyThemeMode, themeMode);
  }

  // ===============================
  // 语言设置
  // ===============================
  
  /// 获取应用语言 (zh: 中文, en: 英文)
  String getLanguage() {
    return _sharedPreferences.getString(_keyLanguage) ?? 'zh';
  }

  /// 设置应用语言
  Future<bool> setLanguage(String language) {
    return _sharedPreferences.setString(_keyLanguage, language);
  }

  // ===============================
  // 首次启动
  // ===============================
  
  /// 是否首次启动
  bool isFirstLaunch() {
    return _sharedPreferences.getBool(_keyIsFirstLaunch) ?? true;
  }

  /// 设置首次启动标志
  Future<bool> setFirstLaunchCompleted() {
    return _sharedPreferences.setBool(_keyIsFirstLaunch, false);
  }

  // ===============================
  // 登录相关
  // ===============================
  
  /// 获取记住我状态
  bool getRememberMe() {
    return _sharedPreferences.getBool(_keyRememberMe) ?? false;
  }

  /// 设置记住我状态
  Future<bool> setRememberMe(bool remember) {
    return _sharedPreferences.setBool(_keyRememberMe, remember);
  }

  /// 获取上次登录的邮箱
  String? getLastLoginEmail() {
    return _sharedPreferences.getString(_keyLastLoginEmail);
  }

  /// 设置上次登录的邮箱
  Future<bool> setLastLoginEmail(String email) {
    return _sharedPreferences.setString(_keyLastLoginEmail, email);
  }

  /// 清除上次登录的邮箱
  Future<bool> clearLastLoginEmail() {
    return _sharedPreferences.remove(_keyLastLoginEmail);
  }

  // ===============================
  // 通知设置
  // ===============================
  
  /// 获取通知开启状态
  bool isNotificationEnabled() {
    return _sharedPreferences.getBool(_keyNotificationEnabled) ?? true;
  }

  /// 设置通知开启状态
  Future<bool> setNotificationEnabled(bool enabled) {
    return _sharedPreferences.setBool(_keyNotificationEnabled, enabled);
  }

  // ===============================
  // 安全设置
  // ===============================
  
  /// 获取生物识别开启状态
  bool isBiometricEnabled() {
    return _sharedPreferences.getBool(_keyBiometricEnabled) ?? false;
  }

  /// 设置生物识别开启状态
  Future<bool> setBiometricEnabled(bool enabled) {
    return _sharedPreferences.setBool(_keyBiometricEnabled, enabled);
  }

  /// 获取自动锁定超时时间（分钟）
  int getAutoLockTimeout() {
    return _sharedPreferences.getInt(_keyAutoLockTimeout) ?? 15;
  }

  /// 设置自动锁定超时时间
  Future<bool> setAutoLockTimeout(int minutes) {
    return _sharedPreferences.setInt(_keyAutoLockTimeout, minutes);
  }

  // ===============================
  // 开发设置
  // ===============================
  
  /// 获取API基础URL（用于开发环境切换）
  String? getApiBaseUrl() {
    return _sharedPreferences.getString(_keyApiBaseUrl);
  }

  /// 设置API基础URL
  Future<bool> setApiBaseUrl(String baseUrl) {
    return _sharedPreferences.setString(_keyApiBaseUrl, baseUrl);
  }

  /// 清除API基础URL
  Future<bool> clearApiBaseUrl() {
    return _sharedPreferences.remove(_keyApiBaseUrl);
  }

  /// 获取调试模式状态
  bool isDebugMode() {
    return _sharedPreferences.getBool(_keyDebugMode) ?? false;
  }

  /// 设置调试模式状态
  Future<bool> setDebugMode(bool enabled) {
    return _sharedPreferences.setBool(_keyDebugMode, enabled);
  }

  // ===============================
  // 清理方法
  // ===============================
  
  /// 清除所有偏好设置（保留语言和主题）
  Future<void> clearUserPreferences() async {
    final currentLanguage = getLanguage();
    final currentThemeMode = getThemeMode();
    
    await _sharedPreferences.clear();
    
    // 恢复基础设置
    await setLanguage(currentLanguage);
    await setThemeMode(currentThemeMode);
  }

  /// 清除所有偏好设置
  Future<void> clearAllPreferences() async {
    await _sharedPreferences.clear();
  }

  // ===============================
  // 调试方法
  // ===============================
  
  /// 获取所有偏好设置键值对（用于调试）
  Map<String, dynamic> getAllPreferences() {
    final keys = _sharedPreferences.getKeys();
    final Map<String, dynamic> preferences = {};
    
    for (final key in keys) {
      final value = _sharedPreferences.get(key);
      preferences[key] = value;
    }
    
    return preferences;
  }

  /// 打印所有偏好设置（用于调试）
  void printAllPreferences() {
    final preferences = getAllPreferences();
    LoggerUtils.i('=== App Preferences ===');
    preferences.forEach((key, value) {
      LoggerUtils.i('$key: $value');
    });
    LoggerUtils.i('=======================');
  }

  /// 打印统计信息
  void printStats() {
    LoggerUtils.i('=== AppPreferences 统计信息 ===');
    try {
      LoggerUtils.i('设置读取次数: $_getCount');
    } catch (e) {
      LoggerUtils.w('获取统计信息失败: $e');
    }
    LoggerUtils.i('=== 统计信息结束 ===');
  }
} 