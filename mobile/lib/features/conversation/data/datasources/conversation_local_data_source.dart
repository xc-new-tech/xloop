import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/conversation_model.dart';

abstract class ConversationLocalDataSource {
  /// 获取缓存的对话列表
  Future<List<ConversationModel>> getCachedConversations();

  /// 缓存对话到本地
  Future<void> cacheConversation(ConversationModel conversation);

  /// 批量缓存对话
  Future<void> cacheConversations(List<ConversationModel> conversations);

  /// 获取特定对话
  Future<ConversationModel?> getCachedConversation(String id);

  /// 删除缓存的对话
  Future<void> deleteCachedConversation(String id);

  /// 清空所有缓存
  Future<void> clearCache();

  /// 获取缓存的对话统计
  Future<Map<String, int>> getCacheStats();
}

class ConversationLocalDataSourceImpl implements ConversationLocalDataSource {
  final SharedPreferences _prefs;

  static const String _conversationsKey = 'cached_conversations';
  static const String _conversationPrefix = 'conversation_';
  static const String _cacheStatsKey = 'conversation_cache_stats';

  ConversationLocalDataSourceImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  @override
  Future<List<ConversationModel>> getCachedConversations() async {
    try {
      final conversationIds = _prefs.getStringList(_conversationsKey) ?? [];
      final conversations = <ConversationModel>[];

      for (final id in conversationIds) {
        final conversation = await getCachedConversation(id);
        if (conversation != null) {
          conversations.add(conversation);
        }
      }

      // 按最后消息时间排序
      conversations.sort((a, b) {
        final aTime = a.lastMessageAt ?? a.createdAt;
        final bTime = b.lastMessageAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });

      return conversations;
    } catch (e) {
      throw CacheException(message: '获取缓存对话列表失败: $e');
    }
  }

  @override
  Future<void> cacheConversation(ConversationModel conversation) async {
    try {
      // 缓存对话数据
      final conversationJson = json.encode(conversation.toJson());
      await _prefs.setString('$_conversationPrefix${conversation.id}', conversationJson);

      // 更新对话ID列表
      final conversationIds = _prefs.getStringList(_conversationsKey) ?? [];
      if (!conversationIds.contains(conversation.id)) {
        conversationIds.add(conversation.id);
        await _prefs.setStringList(_conversationsKey, conversationIds);
      }

      // 更新缓存统计
      await _updateCacheStats();
    } catch (e) {
      throw CacheException(message: '缓存对话失败: $e');
    }
  }

  @override
  Future<void> cacheConversations(List<ConversationModel> conversations) async {
    try {
      final conversationIds = _prefs.getStringList(_conversationsKey) ?? [];

      for (final conversation in conversations) {
        // 缓存对话数据
        final conversationJson = json.encode(conversation.toJson());
        await _prefs.setString('$_conversationPrefix${conversation.id}', conversationJson);

        // 添加到ID列表
        if (!conversationIds.contains(conversation.id)) {
          conversationIds.add(conversation.id);
        }
      }

      // 更新对话ID列表
      await _prefs.setStringList(_conversationsKey, conversationIds);

      // 更新缓存统计
      await _updateCacheStats();
    } catch (e) {
      throw CacheException(message: '批量缓存对话失败: $e');
    }
  }

  @override
  Future<ConversationModel?> getCachedConversation(String id) async {
    try {
      final conversationJson = _prefs.getString('$_conversationPrefix$id');
      if (conversationJson == null) return null;

      final conversationMap = json.decode(conversationJson) as Map<String, dynamic>;
      return ConversationModel.fromJson(conversationMap);
    } catch (e) {
      // 如果解析失败，删除损坏的缓存
      await _prefs.remove('$_conversationPrefix$id');
      return null;
    }
  }

  @override
  Future<void> deleteCachedConversation(String id) async {
    try {
      // 删除对话数据
      await _prefs.remove('$_conversationPrefix$id');

      // 从ID列表中移除
      final conversationIds = _prefs.getStringList(_conversationsKey) ?? [];
      conversationIds.remove(id);
      await _prefs.setStringList(_conversationsKey, conversationIds);

      // 更新缓存统计
      await _updateCacheStats();
    } catch (e) {
      throw CacheException(message: '删除缓存对话失败: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      // 获取所有对话ID
      final conversationIds = _prefs.getStringList(_conversationsKey) ?? [];

      // 删除所有对话数据
      for (final id in conversationIds) {
        await _prefs.remove('$_conversationPrefix$id');
      }

      // 清空ID列表
      await _prefs.remove(_conversationsKey);

      // 清空缓存统计
      await _prefs.remove(_cacheStatsKey);
    } catch (e) {
      throw CacheException(message: '清空对话缓存失败: $e');
    }
  }

  @override
  Future<Map<String, int>> getCacheStats() async {
    try {
      final statsJson = _prefs.getString(_cacheStatsKey);
      if (statsJson == null) {
        return {
          'totalConversations': 0,
          'totalMessages': 0,
          'cacheSize': 0,
          'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        };
      }

      final stats = json.decode(statsJson) as Map<String, dynamic>;
      return stats.cast<String, int>();
    } catch (e) {
      return {
        'totalConversations': 0,
        'totalMessages': 0,
        'cacheSize': 0,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };
    }
  }

  /// 更新缓存统计信息
  Future<void> _updateCacheStats() async {
    try {
      final conversationIds = _prefs.getStringList(_conversationsKey) ?? [];
      int totalMessages = 0;
      int cacheSize = 0;

      for (final id in conversationIds) {
        final conversationJson = _prefs.getString('$_conversationPrefix$id');
        if (conversationJson != null) {
          cacheSize += conversationJson.length;
          try {
            final conversationMap = json.decode(conversationJson) as Map<String, dynamic>;
            final messages = conversationMap['messages'] as List?;
            totalMessages += messages?.length ?? 0;
          } catch (e) {
            // 忽略解析错误
          }
        }
      }

      final stats = {
        'totalConversations': conversationIds.length,
        'totalMessages': totalMessages,
        'cacheSize': cacheSize,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };

      await _prefs.setString(_cacheStatsKey, json.encode(stats));
    } catch (e) {
      // 忽略统计更新错误
    }
  }

  /// 清理过期的缓存数据
  Future<void> cleanExpiredCache({Duration maxAge = const Duration(days: 7)}) async {
    try {
      final conversationIds = _prefs.getStringList(_conversationsKey) ?? [];
      final expiredIds = <String>[];
      final cutoffTime = DateTime.now().subtract(maxAge);

      for (final id in conversationIds) {
        final conversation = await getCachedConversation(id);
        if (conversation != null) {
          final lastActivity = conversation.lastMessageAt ?? conversation.createdAt;
          if (lastActivity.isBefore(cutoffTime)) {
            expiredIds.add(id);
          }
        } else {
          // 如果对话数据无法读取，也标记为过期
          expiredIds.add(id);
        }
      }

      // 删除过期的对话
      for (final id in expiredIds) {
        await deleteCachedConversation(id);
      }
    } catch (e) {
      // 忽略清理错误
    }
  }

  /// 获取缓存大小（字节）
  Future<int> getCacheSize() async {
    try {
      final stats = await getCacheStats();
      return stats['cacheSize'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// 检查缓存是否需要清理
  Future<bool> needsCleanup({int maxSizeBytes = 10 * 1024 * 1024}) async {
    try {
      final cacheSize = await getCacheSize();
      return cacheSize > maxSizeBytes;
    } catch (e) {
      return false;
    }
  }
} 