import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 缓存管理器
class CacheManager {
  static CacheManager? _instance;
  static CacheManager get instance {
    _instance ??= CacheManager._internal();
    return _instance!;
  }
  
  CacheManager._internal();
  
  SharedPreferences? _prefs;
  
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  /// 设置字符串缓存
  Future<bool> setString(String key, String value) async {
    await init();
    return await _prefs!.setString(key, value);
  }
  
  /// 获取字符串缓存
  String? getString(String key) {
    return _prefs?.getString(key);
  }
  
  /// 设置整数缓存
  Future<bool> setInt(String key, int value) async {
    await init();
    return await _prefs!.setInt(key, value);
  }
  
  /// 获取整数缓存
  int? getInt(String key) {
    return _prefs?.getInt(key);
  }
  
  /// 设置布尔缓存
  Future<bool> setBool(String key, bool value) async {
    await init();
    return await _prefs!.setBool(key, value);
  }
  
  /// 获取布尔缓存
  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }
  
  /// 设置双精度缓存
  Future<bool> setDouble(String key, double value) async {
    await init();
    return await _prefs!.setDouble(key, value);
  }
  
  /// 获取双精度缓存
  double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }
  
  /// 设置字符串列表缓存
  Future<bool> setStringList(String key, List<String> value) async {
    await init();
    return await _prefs!.setStringList(key, value);
  }
  
  /// 获取字符串列表缓存
  List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }
  
  /// 设置JSON对象缓存
  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    await init();
    final jsonString = jsonEncode(value);
    return await _prefs!.setString(key, jsonString);
  }
  
  /// 获取JSON对象缓存
  Map<String, dynamic>? getObject(String key) {
    final jsonString = _prefs?.getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  /// 设置对象列表缓存
  Future<bool> setObjectList(String key, List<Map<String, dynamic>> value) async {
    await init();
    final jsonString = jsonEncode(value);
    return await _prefs!.setString(key, jsonString);
  }
  
  /// 获取对象列表缓存
  List<Map<String, dynamic>>? getObjectList(String key) {
    final jsonString = _prefs?.getString(key);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.cast<Map<String, dynamic>>();
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  /// 删除缓存
  Future<bool> remove(String key) async {
    await init();
    return await _prefs!.remove(key);
  }
  
  /// 清除所有缓存
  Future<bool> clear() async {
    await init();
    return await _prefs!.clear();
  }
  
  /// 检查缓存是否存在
  bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }
  
  /// 获取所有缓存键
  Set<String> getKeys() {
    return _prefs?.getKeys() ?? {};
  }
  
  /// 设置带过期时间的缓存
  Future<bool> setWithExpiry(String key, String value, Duration expiry) async {
    await init();
    final expiryTime = DateTime.now().add(expiry).millisecondsSinceEpoch;
    final cacheData = {
      'value': value,
      'expiry': expiryTime,
    };
    return await setObject('${key}_expiry', cacheData);
  }
  
  /// 获取带过期时间的缓存
  String? getWithExpiry(String key) {
    final cacheData = getObject('${key}_expiry');
    if (cacheData != null) {
      final expiryTime = cacheData['expiry'] as int?;
      if (expiryTime != null && DateTime.now().millisecondsSinceEpoch < expiryTime) {
        return cacheData['value'] as String?;
      } else {
        // 缓存已过期，删除
        remove('${key}_expiry');
        return null;
      }
    }
    return null;
  }
  
  /// 获取缓存大小（估算）
  Future<int> getCacheSize() async {
    await init();
    final keys = _prefs!.getKeys();
    int totalSize = 0;
    
    for (final key in keys) {
      final value = _prefs!.get(key);
      if (value is String) {
        totalSize += value.length * 2; // UTF-16编码
      } else if (value is List<String>) {
        for (final item in value) {
          totalSize += item.length * 2;
        }
      } else {
        totalSize += 8; // 基本类型大小估算
      }
    }
    
    return totalSize;
  }
  
  /// 清理过期缓存
  Future<void> cleanExpiredCache() async {
    await init();
    final keys = _prefs!.getKeys();
    final expiredKeys = <String>[];
    
    for (final key in keys) {
      if (key.endsWith('_expiry')) {
        final cacheData = getObject(key);
        if (cacheData != null) {
          final expiryTime = cacheData['expiry'] as int?;
          if (expiryTime != null && DateTime.now().millisecondsSinceEpoch >= expiryTime) {
            expiredKeys.add(key);
          }
        }
      }
    }
    
    for (final key in expiredKeys) {
      await remove(key);
    }
  }
}

/// 缓存键常量
class CacheKeys {
  static const String userProfile = 'user_profile';
  static const String authToken = 'auth_token';
  static const String knowledgeBases = 'knowledge_bases';
  static const String conversations = 'conversations';
  static const String searchHistory = 'search_history';
  static const String appSettings = 'app_settings';
  static const String fileCache = 'file_cache';
  static const String analytics = 'analytics_data';
  
  // 带过期时间的缓存键
  static const String dailyStats = 'daily_stats';
  static const String systemHealth = 'system_health';
  static const String userActivity = 'user_activity';
} 