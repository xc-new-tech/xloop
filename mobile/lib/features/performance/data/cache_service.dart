import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// 缓存服务
/// 
/// 提供统一的缓存管理功能，包括内存缓存、持久化缓存和缓存优化
class CacheService {
  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();
  
  CacheService._();

  // 内存缓存
  final Map<String, CacheEntry> _memoryCache = {};
  
  // 缓存配置
  static const int _maxMemoryCacheSize = 50 * 1024 * 1024; // 50MB
  static const int _maxCacheEntries = 1000;
  static const Duration _defaultExpiration = Duration(hours: 24);
  
  // 缓存统计
  int _hits = 0;
  int _misses = 0;
  int get hits => _hits;
  int get misses => _misses;
  double get hitRate => (_hits + _misses == 0) ? 0.0 : _hits / (_hits + _misses);

  /// 获取缓存项
  Future<T?> get<T>(String key) async {
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      _hits++;
      return memoryEntry.value as T?;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('cache_$key');
      
      if (jsonStr != null) {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        final expiration = DateTime.parse(data['expiration'] as String);
        
        if (expiration.isAfter(DateTime.now())) {
          _hits++;
          return data['value'] as T?;
        }
      }
    } catch (e) {
      if (kDebugMode) print('Cache read error: $e');
    }

    _misses++;
    return null;
  }

  /// 设置缓存项
  Future<void> set<T>(String key, T value, {Duration? expiration}) async {
    final exp = expiration ?? _defaultExpiration;
    final expirationTime = DateTime.now().add(exp);

    _memoryCache[key] = CacheEntry(
      value: value,
      expiration: expirationTime,
      created: DateTime.now(),
      lastAccessed: DateTime.now(),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'value': value,
        'expiration': expirationTime.toIso8601String(),
      };
      
      await prefs.setString('cache_$key', jsonEncode(cacheData));
    } catch (e) {
      if (kDebugMode) print('Cache write error: $e');
    }
  }

  /// 删除缓存项
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
  }

  /// 清空所有缓存
  Future<void> clear() async {
    _memoryCache.clear();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('cache_')).toList();
      
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      if (kDebugMode) print('Cache clear error: $e');
    }
    
    _hits = 0;
    _misses = 0;
  }

  /// 清理过期缓存
  Future<void> clearExpired() async {
    // 清理内存缓存
    final expiredKeys = <String>[];
    for (final entry in _memoryCache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _memoryCache.remove(key);
    }

    // 清理持久化缓存
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKeys = prefs.getKeys().where((key) => key.startsWith('cache_')).toList();
      
      for (final cacheKey in cacheKeys) {
        final jsonStr = prefs.getString(cacheKey);
        if (jsonStr != null) {
          try {
            final data = jsonDecode(jsonStr) as Map<String, dynamic>;
            final expiration = DateTime.parse(data['expiration'] as String);
            
            if (expiration.isBefore(DateTime.now())) {
              await prefs.remove(cacheKey);
            }
          } catch (e) {
            // 数据格式错误，删除
            await prefs.remove(cacheKey);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing expired persistent cache: $e');
      }
    }
  }

  /// 优化缓存
  Future<void> optimize() async {
    await clearExpired();
    
    // 如果内存缓存过大，清理最少使用的项
    if (_getMemoryCacheSize() > _maxMemoryCacheSize || _memoryCache.length > _maxCacheEntries) {
      _evictLeastRecentlyUsed();
    }
  }

  /// 获取缓存统计信息
  CacheStats getStats() {
    final memorySize = _getMemoryCacheSize();
    final itemCount = _memoryCache.length;
    
    return CacheStats(
      totalHits: _hits,
      totalMisses: _misses,
      hitRate: hitRate,
      memoryCacheSize: memorySize,
      memoryCacheItems: itemCount,
      maxMemorySize: _maxMemoryCacheSize,
    );
  }

  /// 获取所有缓存键
  Future<List<String>> getCacheKeys() async {
    final memoryKeys = _memoryCache.keys.toSet();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final persistentKeys = prefs.getKeys()
          .where((key) => key.startsWith('cache_'))
          .map((key) => key.substring(6)) // 移除 'cache_' 前缀
          .toSet();
      
      return [...memoryKeys, ...persistentKeys].toList();
    } catch (e) {
      return memoryKeys.toList();
    }
  }

  /// 获取缓存项详情
  Future<CacheItemInfo?> getCacheItemInfo(String key) async {
    // 检查内存缓存
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null) {
      return CacheItemInfo(
        key: key,
        size: _calculateSize(memoryEntry.value),
        created: memoryEntry.created,
        lastAccessed: memoryEntry.lastAccessed,
        expiration: memoryEntry.expiration,
        isInMemory: true,
        isPersistent: false,
        hitCount: memoryEntry.hitCount,
      );
    }

    // 检查持久化缓存
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('cache_$key');
      
      if (jsonStr != null) {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        return CacheItemInfo(
          key: key,
          size: utf8.encode(jsonStr).length,
          created: DateTime.parse(data['created'] as String),
          lastAccessed: DateTime.now(), // 持久化缓存无法跟踪访问时间
          expiration: DateTime.parse(data['expiration'] as String),
          isInMemory: false,
          isPersistent: true,
          hitCount: 0, // 持久化缓存无法跟踪命中次数
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cache item info for $key: $e');
      }
    }

    return null;
  }

  // 私有方法

  void _setMemoryCache(String key, dynamic value, DateTime expiration) {
    _memoryCache[key] = CacheEntry(
      value: value,
      expiration: expiration,
      created: DateTime.now(),
      lastAccessed: DateTime.now(),
    );

    // 检查缓存限制
    if (_getMemoryCacheSize() > _maxMemoryCacheSize || _memoryCache.length > _maxCacheEntries) {
      _evictLeastRecentlyUsed();
    }
  }

  void _updateAccessTime(String key) {
    final entry = _memoryCache[key];
    if (entry != null) {
      entry.lastAccessed = DateTime.now();
      entry.hitCount++;
    }
  }

  Future<void> _removePersistentCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cache_$key');
    } catch (e) {
      if (kDebugMode) {
        print('Error removing persistent cache for key $key: $e');
      }
    }
  }

  int _getMemoryCacheSize() {
    int totalSize = 0;
    for (final entry in _memoryCache.values) {
      totalSize += _calculateSize(entry.value);
    }
    return totalSize;
  }

  int _calculateSize(dynamic value) {
    if (value is String) {
      return utf8.encode(value).length;
    } else if (value is Uint8List) {
      return value.length;
    } else if (value is List) {
      return value.length * 4; // 估算
    } else if (value is Map) {
      return value.length * 8; // 估算
    } else {
      return 64; // 默认估算
    }
  }

  void _evictLeastRecentlyUsed() {
    if (_memoryCache.isEmpty) return;

    // 按最后访问时间排序，移除最旧的项
    final sortedEntries = _memoryCache.entries.toList()
      ..sort((a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed));

    final itemsToRemove = (_memoryCache.length * 0.2).ceil(); // 移除20%的项
    for (int i = 0; i < itemsToRemove && i < sortedEntries.length; i++) {
      _memoryCache.remove(sortedEntries[i].key);
    }
  }

  void _resetStats() {
    _hits = 0;
    _misses = 0;
  }
}

/// 缓存条目
class CacheEntry {
  final dynamic value;
  final DateTime expiration;
  final DateTime created;
  DateTime lastAccessed;
  int hitCount;

  CacheEntry({
    required this.value,
    required this.expiration,
    required this.created,
    required this.lastAccessed,
    this.hitCount = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiration);
}

/// 缓存统计信息
class CacheStats {
  final int totalHits;
  final int totalMisses;
  final double hitRate;
  final int memoryCacheSize;
  final int memoryCacheItems;
  final int maxMemorySize;

  CacheStats({
    required this.totalHits,
    required this.totalMisses,
    required this.hitRate,
    required this.memoryCacheSize,
    required this.memoryCacheItems,
    required this.maxMemorySize,
  });

  double get memoryUsagePercentage => 
      maxMemorySize > 0 ? (memoryCacheSize / maxMemorySize) * 100 : 0.0;
}

/// 缓存项信息
class CacheItemInfo {
  final String key;
  final int size;
  final DateTime created;
  final DateTime lastAccessed;
  final DateTime expiration;
  final bool isInMemory;
  final bool isPersistent;
  final int hitCount;

  CacheItemInfo({
    required this.key,
    required this.size,
    required this.created,
    required this.lastAccessed,
    required this.expiration,
    required this.isInMemory,
    required this.isPersistent,
    required this.hitCount,
  });

  bool get isExpired => DateTime.now().isAfter(expiration);
  
  Duration get age => DateTime.now().difference(created);
  
  Duration get timeSinceAccess => DateTime.now().difference(lastAccessed);
} 