import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 简单缓存服务
class SimpleCache {
  static final Map<String, dynamic> _cache = {};
  
  static Future<void> set(String key, dynamic value) async {
    _cache[key] = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cache_$key', jsonEncode(value));
    } catch (e) {
      print('Cache error: $e');
    }
  }
  
  static T? get<T>(String key) {
    return _cache[key] as T?;
  }
  
  static void clear() {
    _cache.clear();
  }
} 