import '../models/knowledge_base_model.dart';

/// 知识库远程数据源接口
abstract class KnowledgeBaseRemoteDataSource {
  /// 获取知识库列表
  Future<KnowledgeBaseListResponse> getKnowledgeBases({
    int page = 1,
    int limit = 20,
    String? status,
    String? type,
    String? search,
    List<String>? tags,
  });

  /// 获取单个知识库详情
  Future<KnowledgeBaseModel> getKnowledgeBase(String id);

  /// 创建知识库
  Future<KnowledgeBaseModel> createKnowledgeBase(CreateKnowledgeBaseRequest request);

  /// 更新知识库
  Future<KnowledgeBaseModel> updateKnowledgeBase(String id, UpdateKnowledgeBaseRequest request);

  /// 删除知识库
  Future<void> deleteKnowledgeBase(String id);

  /// 更新知识库状态
  Future<KnowledgeBaseModel> updateKnowledgeBaseStatus(String id, String status);

  /// 复制知识库
  Future<KnowledgeBaseModel> duplicateKnowledgeBase(String id, String newName, String? newDescription);

  /// 获取我的知识库列表
  Future<KnowledgeBaseListResponse> getMyKnowledgeBases({
    int page = 1,
    int limit = 20,
    String? status,
    String? type,
  });

  /// 获取公开知识库列表
  Future<KnowledgeBaseListResponse> getPublicKnowledgeBases({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? tags,
  });

  /// 分享知识库
  Future<void> shareKnowledgeBase(String id, List<String> userIds, String? message);

  /// 导入知识库
  Future<KnowledgeBaseModel> importKnowledgeBase({
    required String filePath,
    String? name,
    String? description,
    required String type,
  });

  /// 导出知识库
  Future<String> exportKnowledgeBase(String id, String format);

  /// 获取知识库统计信息
  Future<Map<String, dynamic>> getKnowledgeBaseStats({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 搜索知识库
  Future<KnowledgeBaseListResponse> searchKnowledgeBases({
    required String query,
    int page = 1,
    int limit = 20,
    String? type,
    List<String>? tags,
  });

  /// 获取知识库标签列表
  Future<List<String>> getKnowledgeBaseTags();

  /// 批量删除知识库
  Future<void> deleteKnowledgeBases(List<String> ids);

  /// 批量更新知识库状态
  Future<List<KnowledgeBaseModel>> batchUpdateStatus(List<String> ids, String status);
} 