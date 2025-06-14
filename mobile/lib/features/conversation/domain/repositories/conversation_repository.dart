import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';

abstract class ConversationRepository {
  /// 创建新对话
  Future<Either<Failure, Conversation>> createConversation({
    String? knowledgeBaseId,
    String? title,
    ConversationType type = ConversationType.chat,
    Map<String, dynamic> settings = const {},
    List<String> tags = const [],
  });

  /// 获取对话列表
  Future<Either<Failure, List<Conversation>>> getConversations({
    int page = 1,
    int limit = 20,
    ConversationType? type,
    ConversationStatus? status,
    String? knowledgeBaseId,
    String? search,
    String sortBy = 'lastMessageAt',
    String sortOrder = 'DESC',
  });

  /// 获取对话详情
  Future<Either<Failure, Conversation>> getConversationById(String id);

  /// 发送消息
  Future<Either<Failure, SendMessageResponse>> sendMessage({
    required String conversationId,
    required SendMessageRequest request,
  });

  /// 更新对话
  Future<Either<Failure, Conversation>> updateConversation({
    required String id,
    String? title,
    List<String>? tags,
    Map<String, dynamic>? settings,
    ConversationStatus? status,
  });

  /// 删除对话
  Future<Either<Failure, void>> deleteConversation(String id);

  /// 批量删除对话
  Future<Either<Failure, int>> bulkDeleteConversations(List<String> ids);

  /// 对话评分
  Future<Either<Failure, void>> rateConversation({
    required String id,
    required int rating,
    String? feedback,
  });

  /// 获取对话统计信息
  Future<Either<Failure, ConversationStats>> getConversationStats({
    DateTime? startDate,
    DateTime? endDate,
    String? knowledgeBaseId,
  });

  /// 获取本地缓存的对话列表
  Future<Either<Failure, List<Conversation>>> getCachedConversations();

  /// 缓存对话到本地
  Future<Either<Failure, void>> cacheConversation(Conversation conversation);

  /// 删除本地缓存的对话
  Future<Either<Failure, void>> deleteCachedConversation(String id);

  /// 清空本地缓存
  Future<Either<Failure, void>> clearCache();
} 