import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/search_result.dart';

/// 搜索存储库接口
/// 定义所有搜索相关的业务操作
abstract class SearchRepository {
  /// 执行语义搜索
  /// 
  /// [query] 搜索查询字符串
  /// [options] 搜索选项配置
  /// 
  /// 返回搜索结果或失败信息
  Future<Either<Failure, HybridSearchResults>> search(
    String query,
    SearchOptions options,
  );

  /// 搜索文档
  /// 
  /// [query] 搜索查询字符串
  /// [options] 搜索选项配置
  /// 
  /// 返回文档搜索结果列表或失败信息
  Future<Either<Failure, List<DocumentSearchResult>>> searchDocuments(
    String query,
    SearchOptions options,
  );

  /// 搜索FAQ
  /// 
  /// [query] 搜索查询字符串
  /// [options] 搜索选项配置
  /// 
  /// 返回FAQ搜索结果列表或失败信息
  Future<Either<Failure, List<FaqSearchResult>>> searchFaqs(
    String query,
    SearchOptions options,
  );

  /// 获取推荐内容
  /// 
  /// [options] 推荐选项配置
  /// 
  /// 返回推荐结果或失败信息
  Future<Either<Failure, HybridSearchResults>> getRecommendations(
    RecommendationOptions options,
  );

  /// 向量化文档内容
  /// 
  /// [documentId] 文档ID
  /// [content] 文档内容
  /// [metadata] 文档元数据
  /// 
  /// 返回成功状态或失败信息
  Future<Either<Failure, Unit>> vectorizeDocument(
    String documentId,
    String content, [
    Map<String, dynamic>? metadata,
  ]);

  /// 向量化FAQ内容
  /// 
  /// [faqId] FAQ ID
  /// [question] FAQ问题
  /// [answer] FAQ答案
  /// [metadata] FAQ元数据
  /// 
  /// 返回成功状态或失败信息
  Future<Either<Failure, Unit>> vectorizeFaq(
    String faqId,
    String question,
    String answer, [
    Map<String, dynamic>? metadata,
  ]);

  /// 批量向量化内容
  /// 
  /// [type] 内容类型 ('document' 或 'faq')
  /// [items] 要向量化的项目列表
  /// 
  /// 返回批量处理结果或失败信息
  Future<Either<Failure, BatchVectorizeResult>> batchVectorize(
    String type,
    List<Map<String, dynamic>> items,
  );

  /// 获取搜索统计信息
  /// 
  /// 返回搜索统计数据或失败信息
  Future<Either<Failure, SearchStats>> getSearchStats();

  /// 清理搜索缓存
  /// 
  /// [pattern] 缓存清理模式，默认为所有embedding缓存
  /// 
  /// 返回成功状态或失败信息
  Future<Either<Failure, Unit>> clearCache([String? pattern]);

  /// 检查搜索服务健康状态
  /// 
  /// 返回健康状态信息或失败信息
  Future<Either<Failure, Map<String, dynamic>>> checkHealth();
} 