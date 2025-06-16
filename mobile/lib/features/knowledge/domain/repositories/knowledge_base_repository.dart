import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/knowledge_base.dart';

/// 知识库仓库接口
abstract class KnowledgeBaseRepository {
  /// 获取知识库列表
  Future<Either<Failure, List<KnowledgeBase>>> getKnowledgeBases({
    int page = 1,
    int limit = 20,
    KnowledgeBaseStatus? status,
    KnowledgeBaseType? type,
    String? search,
    List<String>? tags,
  });

  /// 获取单个知识库详情
  Future<Either<Failure, KnowledgeBase>> getKnowledgeBase(String id);

  /// 创建知识库
  Future<Either<Failure, KnowledgeBase>> createKnowledgeBase({
    required String name,
    String? description,
    String? coverImage,
    required KnowledgeBaseType type,
    required KnowledgeBaseContentType contentType, // 新增内容类型参数
    Map<String, dynamic>? settings,
    bool isPublic = false,
    List<String>? tags,
  });

  /// 更新知识库
  Future<Either<Failure, KnowledgeBase>> updateKnowledgeBase({
    required String id,
    String? name,
    String? description,
    String? coverImage,
    KnowledgeBaseType? type,
    Map<String, dynamic>? settings,
    bool? isPublic,
    List<String>? tags,
  });

  /// 删除知识库
  Future<Either<Failure, void>> deleteKnowledgeBase(String id);

  /// 更新知识库状态
  Future<Either<Failure, KnowledgeBase>> updateKnowledgeBaseStatus({
    required String id,
    required KnowledgeBaseStatus status,
  });

  /// 复制知识库
  Future<Either<Failure, KnowledgeBase>> duplicateKnowledgeBase({
    required String id,
    String? newName,
  });

  /// 获取我的知识库列表
  Future<Either<Failure, List<KnowledgeBase>>> getMyKnowledgeBases({
    int page = 1,
    int limit = 20,
    KnowledgeBaseStatus? status,
    KnowledgeBaseType? type,
  });

  /// 获取公开知识库列表
  Future<Either<Failure, List<KnowledgeBase>>> getPublicKnowledgeBases({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? tags,
  });

  /// 分享知识库
  Future<Either<Failure, void>> shareKnowledgeBase({
    required String id,
    required List<String> userIds,
    String? message,
  });

  /// 导入知识库
  Future<Either<Failure, KnowledgeBase>> importKnowledgeBase({
    required String filePath,
    String? name,
    String? description,
    required KnowledgeBaseType type,
  });

  /// 导出知识库
  Future<Either<Failure, String>> exportKnowledgeBase({
    required String id,
    required String format,
  });

  /// 获取知识库统计信息
  Future<Either<Failure, Map<String, dynamic>>> getKnowledgeBaseStats({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 搜索知识库
  Future<Either<Failure, List<KnowledgeBase>>> searchKnowledgeBases({
    required String query,
    int page = 1,
    int limit = 20,
    KnowledgeBaseType? type,
    List<String>? tags,
  });

  /// 获取知识库标签列表
  Future<Either<Failure, List<String>>> getKnowledgeBaseTags();

  /// 批量删除知识库
  Future<Either<Failure, void>> batchDeleteKnowledgeBases(List<String> ids);

  /// 批量更新知识库状态
  Future<Either<Failure, List<KnowledgeBase>>> batchUpdateStatus({
    required List<String> ids,
    required KnowledgeBaseStatus status,
  });
} 