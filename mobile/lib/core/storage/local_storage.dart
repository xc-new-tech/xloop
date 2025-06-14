import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储工具类
/// 封装SharedPreferences，提供类型安全的存储接口
class LocalStorage {
  static SharedPreferences? _prefs;
  static LocalStorage? _instance;

  LocalStorage._();

  /// 获取单例实例
  static LocalStorage get instance {
    _instance ??= LocalStorage._();
    return _instance!;
  }

  /// 初始化存储
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    developer.log('LocalStorage initialized', name: 'LocalStorage');
  }

  /// 确保SharedPreferences已初始化
  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw Exception('LocalStorage未初始化，请先调用LocalStorage.init()');
    }
    return _prefs!;
  }

  // ========== 字符串存储 ==========

  /// 存储字符串
  Future<bool> setString(String key, String value) async {
    try {
      final result = await _preferences.setString(key, value);
      developer.log('存储字符串: $key = $value', name: 'LocalStorage');
      return result;
    } catch (e) {
      developer.log('存储字符串失败: $key, 错误: $e', name: 'LocalStorage');
      return false;
    }
  }

  /// 获取字符串
  String? getString(String key, {String? defaultValue}) {
    try {
      final value = _preferences.getString(key) ?? defaultValue;
      developer.log('获取字符串: $key = $value', name: 'LocalStorage');
      return value;
    } catch (e) {
      developer.log('获取字符串失败: $key, 错误: $e', name: 'LocalStorage');
      return defaultValue;
    }
  }

  // ========== 整数存储 ==========

  /// 存储整数
  Future<bool> setInt(String key, int value) async {
    try {
      final result = await _preferences.setInt(key, value);
      developer.log('存储整数: $key = $value', name: 'LocalStorage');
      return result;
    } catch (e) {
      developer.log('存储整数失败: $key, 错误: $e', name: 'LocalStorage');
      return false;
    }
  }

  /// 获取整数
  int? getInt(String key, {int? defaultValue}) {
    try {
      final value = _preferences.getInt(key) ?? defaultValue;
      developer.log('获取整数: $key = $value', name: 'LocalStorage');
      return value;
    } catch (e) {
      developer.log('获取整数失败: $key, 错误: $e', name: 'LocalStorage');
      return defaultValue;
    }
  }

  // ========== 布尔值存储 ==========

  /// 存储布尔值
  Future<bool> setBool(String key, bool value) async {
    try {
      final result = await _preferences.setBool(key, value);
      developer.log('存储布尔值: $key = $value', name: 'LocalStorage');
      return result;
    } catch (e) {
      developer.log('存储布尔值失败: $key, 错误: $e', name: 'LocalStorage');
      return false;
    }
  }

  /// 获取布尔值
  bool? getBool(String key, {bool? defaultValue}) {
    try {
      final value = _preferences.getBool(key) ?? defaultValue;
      developer.log('获取布尔值: $key = $value', name: 'LocalStorage');
      return value;
    } catch (e) {
      developer.log('获取布尔值失败: $key, 错误: $e', name: 'LocalStorage');
      return defaultValue;
    }
  }

  // ========== 浮点数存储 ==========

  /// 存储浮点数
  Future<bool> setDouble(String key, double value) async {
    try {
      final result = await _preferences.setDouble(key, value);
      developer.log('存储浮点数: $key = $value', name: 'LocalStorage');
      return result;
    } catch (e) {
      developer.log('存储浮点数失败: $key, 错误: $e', name: 'LocalStorage');
      return false;
    }
  }

  /// 获取浮点数
  double? getDouble(String key, {double? defaultValue}) {
    try {
      final value = _preferences.getDouble(key) ?? defaultValue;
      developer.log('获取浮点数: $key = $value', name: 'LocalStorage');
      return value;
    } catch (e) {
      developer.log('获取浮点数失败: $key, 错误: $e', name: 'LocalStorage');
      return defaultValue;
    }
  }

  // ========== 字符串列表存储 ==========

  /// 存储字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      final result = await _preferences.setStringList(key, value);
      developer.log('存储字符串列表: $key = $value', name: 'LocalStorage');
      return result;
    } catch (e) {
      developer.log('存储字符串列表失败: $key, 错误: $e', name: 'LocalStorage');
      return false;
    }
  }

  /// 获取字符串列表
  List<String>? getStringList(String key, {List<String>? defaultValue}) {
    try {
      final value = _preferences.getStringList(key) ?? defaultValue;
      developer.log('获取字符串列表: $key = $value', name: 'LocalStorage');
      return value;
    } catch (e) {
      developer.log('获取字符串列表失败: $key, 错误: $e', name: 'LocalStorage');
      return defaultValue;
    }
  }

  // ========== JSON对象存储 ==========

  /// 存储JSON对象
  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      final result = await setString(key, jsonString);
      developer.log('存储JSON对象: $key', name: 'LocalStorage');
      return result;
    } catch (e) {
      developer.log('存储JSON对象失败: $key, 错误: $e', name: 'LocalStorage');
      return false;
    }
  }

  /// 获取JSON对象
  Map<String, dynamic>? getObject(String key, {Map<String, dynamic>? defaultValue}) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return defaultValue;
      
      final value = jsonDecode(jsonString) as Map<String, dynamic>;
      developer.log('获取JSON对象: $key', name: 'LocalStorage');
      return value;
    } catch (e) {
      developer.log('获取JSON对象失败: $key, 错误: $e', name: 'LocalStorage');
      return defaultValue;
    }
  }

  /// 存储JSON数组
  Future<bool> setObjectList(String key, List<Map<String, dynamic>> value) async {
    try {
      final jsonString = jsonEncode(value);
      final result = await setString(key, jsonString);
      developer.log('存储JSON数组: $key', name: 'LocalStorage');
      return result;
    } catch (e) {
      developer.log('存储JSON数组失败: $key, 错误: $e', name: 'LocalStorage');
      return false;
    }
  }

  /// 获取JSON数组
  List<Map<String, dynamic>>? getObjectList(String key, {List<Map<String, dynamic>>? defaultValue}) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return defaultValue;
      
      final jsonList = jsonDecode(jsonString) as List;
      final value = jsonList.cast<Map<String, dynamic>>();
      developer.log('获取JSON数组: $key', name: 'LocalStorage');
      return value;
    } catch (e) {
      developer.log('获取JSON数组失败: $key, 错误: $e', name: 'LocalStorage');
      return defaultValue;
    }
  }

  // ========== 通用操作 ==========

  /// 检查键是否存在
  bool containsKey(String key) {
    try {
      final exists = _preferences.containsKey(key);
      developer.log('检查键存在: $key = $exists', name: 'LocalStorage');
      return exists;
    } catch (e) {
      developer.log('检查键存在失败: $key, 错误: $e', name: 'LocalStorage');
      return false;
    }
  }

  /// 删除指定键
  Future<bool> remove(String key) async {
    try {
      final result = await _preferences.remove(key);
      developer.log('删除键: $key', name: 'LocalStorage');
      return result;
    } catch (e) {
      developer.log('删除键失败: $key, 错误: $e', name: 'LocalStorage');
      return false;
    }
  }

  /// 清空所有数据
  Future<bool> clear() async {
    try {
      final result = await _preferences.clear();
      developer.log('清空所有数据', name: 'LocalStorage');
      return result;
    } catch (e) {
      developer.log('清空所有数据失败, 错误: $e', name: 'LocalStorage');
      return false;
    }
  }

  /// 获取所有键
  Set<String> getKeys() {
    try {
      final keys = _preferences.getKeys();
      developer.log('获取所有键: ${keys.length}个', name: 'LocalStorage');
      return keys;
    } catch (e) {
      developer.log('获取所有键失败, 错误: $e', name: 'LocalStorage');
      return <String>{};
    }
  }

  /// 批量删除键（支持前缀匹配）
  Future<int> removeWithPrefix(String prefix) async {
    try {
      final keys = getKeys().where((key) => key.startsWith(prefix)).toList();
      int removedCount = 0;
      
      for (final key in keys) {
        if (await remove(key)) {
          removedCount++;
        }
      }
      
      developer.log('批量删除键: $prefix*, 删除了${removedCount}个', name: 'LocalStorage');
      return removedCount;
    } catch (e) {
      developer.log('批量删除键失败: $prefix*, 错误: $e', name: 'LocalStorage');
      return 0;
    }
  }

  /// 获取存储大小（估算）
  int getStorageSize() {
    try {
      int totalSize = 0;
      final keys = getKeys();
      
      for (final key in keys) {
        final value = _preferences.get(key);
        if (value != null) {
          totalSize += key.length;
          if (value is String) {
            totalSize += value.length;
          } else {
            totalSize += value.toString().length;
          }
        }
      }
      
      developer.log('存储大小: ${totalSize}字符', name: 'LocalStorage');
      return totalSize;
    } catch (e) {
      developer.log('获取存储大小失败, 错误: $e', name: 'LocalStorage');
      return 0;
    }
  }

  /// 导出所有数据
  Map<String, dynamic> exportAll() {
    try {
      final keys = getKeys();
      final data = <String, dynamic>{};
      
      for (final key in keys) {
        data[key] = _preferences.get(key);
      }
      
      developer.log('导出所有数据: ${keys.length}项', name: 'LocalStorage');
      return data;
    } catch (e) {
      developer.log('导出所有数据失败, 错误: $e', name: 'LocalStorage');
      return <String, dynamic>{};
    }
  }

  /// 导入数据
  Future<int> importData(Map<String, dynamic> data) async {
    try {
      int importedCount = 0;
      
      for (final entry in data.entries) {
        try {
          final key = entry.key;
          final value = entry.value;
          
          bool success = false;
          if (value is String) {
            success = await setString(key, value);
          } else if (value is int) {
            success = await setInt(key, value);
          } else if (value is bool) {
            success = await setBool(key, value);
          } else if (value is double) {
            success = await setDouble(key, value);
          } else if (value is List<String>) {
            success = await setStringList(key, value);
          } else {
            // 尝试作为JSON存储
            success = await setString(key, jsonEncode(value));
          }
          
          if (success) {
            importedCount++;
          }
        } catch (e) {
          developer.log('导入数据项失败: ${entry.key}, 错误: $e', name: 'LocalStorage');
        }
      }
      
      developer.log('导入数据完成: ${importedCount}/${data.length}项', name: 'LocalStorage');
      return importedCount;
    } catch (e) {
      developer.log('导入数据失败, 错误: $e', name: 'LocalStorage');
      return 0;
    }
  }
}

/// 存储键常量
class StorageKeys {
  // 用户相关
  static const String userToken = 'user_token';
  static const String refreshToken = 'refresh_token';
  static const String userProfile = 'user_profile';
  static const String userPreferences = 'user_preferences';
  
  // 应用设置
  static const String appTheme = 'app_theme';
  static const String appLanguage = 'app_language';
  static const String firstLaunch = 'first_launch';
  static const String appVersion = 'app_version';
  
  // 功能设置
  static const String enableNotifications = 'enable_notifications';
  static const String enableAnalytics = 'enable_analytics';
  static const String cacheEnabled = 'cache_enabled';
  
  // 缓存相关
  static const String cachePrefix = 'cache_';
  static const String searchHistory = 'search_history';
  static const String recentConversations = 'recent_conversations';
  
  // 临时数据
  static const String tempPrefix = 'temp_';
  static const String draftPrefix = 'draft_';
} 