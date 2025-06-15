import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/search_models.dart';

/// 搜索远程数据源接口
abstract class SearchRemoteDataSource {
  /// 执行混合搜索
  Future<HybridSearchResultsModel> search(
    String query,
    Map<String, String> queryParams,
  );

  /// 搜索文档
  Future<List<DocumentSearchResultModel>> searchDocuments(
    String query,
    Map<String, String> queryParams,
  );

  /// 搜索FAQ
  Future<List<FaqSearchResultModel>> searchFaqs(
    String query,
    Map<String, String> queryParams,
  );

  /// 获取推荐内容
  Future<HybridSearchResultsModel> getRecommendations(
    Map<String, String> queryParams,
  );

  /// 向量化文档
  Future<void> vectorizeDocument(VectorizeDocumentRequest request);

  /// 向量化FAQ
  Future<void> vectorizeFaq(VectorizeFaqRequest request);

  /// 批量向量化
  Future<BatchVectorizeResultModel> batchVectorize(
    BatchVectorizeRequest request,
  );

  /// 获取搜索统计
  Future<SearchStatsModel> getSearchStats();

  /// 清理缓存
  Future<void> clearCache([String? pattern]);

  /// 健康检查
  Future<Map<String, dynamic>> checkHealth();
}

/// 搜索远程数据源实现
class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final ApiClient _apiClient;

  const SearchRemoteDataSourceImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<HybridSearchResultsModel> search(
    String query,
    Map<String, String> queryParams,
  ) async {
    try {
      final params = {...queryParams, 'q': query};
      
      final response = await _apiClient.get(
        '${ApiEndpoints.search}/hybrid',
        queryParameters: params,
      );

      if (response['success'] == true) {
        return HybridSearchResultsModel.fromApiJson(response, query);
      } else {
        throw ServerException(
          response['message'] ?? '搜索失败',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('搜索过程中发生未知错误: $e');
    }
  }

  @override
  Future<List<DocumentSearchResultModel>> searchDocuments(
    String query,
    Map<String, String> queryParams,
  ) async {
    try {
      final params = {...queryParams, 'q': query};
      
      final response = await _apiClient.get(
        '${ApiEndpoints.search}/documents',
        queryParameters: params,
      );

      if (response['success'] == true) {
        final List<dynamic> documentsData = response['data'] ?? [];
        return documentsData
            .map((doc) => DocumentSearchResultModel.fromApiJson(doc))
            .toList();
      } else {
        throw ServerException(
          response['message'] ?? '文档搜索失败',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('文档搜索过程中发生未知错误: $e');
    }
  }

  @override
  Future<List<FaqSearchResultModel>> searchFaqs(
    String query,
    Map<String, String> queryParams,
  ) async {
    try {
      final params = {...queryParams, 'q': query};
      
      final response = await _apiClient.get(
        '${ApiEndpoints.search}/faqs',
        queryParameters: params,
      );

      if (response['success'] == true) {
        final List<dynamic> faqsData = response['data'] ?? [];
        return faqsData
            .map((faq) => FaqSearchResultModel.fromApiJson(faq))
            .toList();
      } else {
        throw ServerException(
          response['message'] ?? 'FAQ搜索失败',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('FAQ搜索过程中发生未知错误: $e');
    }
  }

  @override
  Future<HybridSearchResultsModel> getRecommendations(
    Map<String, String> queryParams,
  ) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.search}/recommendations',
        queryParameters: queryParams,
      );

      if (response['success'] == true) {
        return HybridSearchResultsModel.fromApiJson(
          response,
          'recommendations',
        );
      } else {
        throw ServerException(
          response['message'] ?? '推荐内容获取失败',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('推荐内容获取过程中发生未知错误: $e');
    }
  }

  @override
  Future<void> vectorizeDocument(VectorizeDocumentRequest request) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.search}/vectorize/document',
        body: request.toJson(),
      );

      if (response['success'] != true) {
        throw ServerException(
          response['message'] ?? '文档向量化失败',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('文档向量化过程中发生未知错误: $e');
    }
  }

  @override
  Future<void> vectorizeFaq(VectorizeFaqRequest request) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.search}/vectorize/faq',
        body: request.toJson(),
      );

      if (response['success'] != true) {
        throw ServerException(
          response['message'] ?? 'FAQ向量化失败',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('FAQ向量化过程中发生未知错误: $e');
    }
  }

  @override
  Future<BatchVectorizeResultModel> batchVectorize(
    BatchVectorizeRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.search}/vectorize/batch',
        body: request.toJson(),
      );

      if (response['success'] == true) {
        return BatchVectorizeResultModel.fromApiJson(response);
      } else {
        throw ServerException(
          response['message'] ?? '批量向量化失败',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('批量向量化过程中发生未知错误: $e');
    }
  }

  @override
  Future<SearchStatsModel> getSearchStats() async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.search}/stats',
      );

      if (response['success'] == true) {
        return SearchStatsModel.fromApiJson(response);
      } else {
        throw ServerException(
          response['message'] ?? '获取搜索统计失败',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('获取搜索统计过程中发生未知错误: $e');
    }
  }

  @override
  Future<void> clearCache([String? pattern]) async {
    try {
      final Map<String, dynamic> body = {};
      if (pattern != null) {
        body['pattern'] = pattern;
      }

      final response = await _apiClient.post(
        '${ApiEndpoints.search}/cache/clear',
        body: body,
      );

      if (response['success'] != true) {
        throw ServerException(
          response['message'] ?? '清理缓存失败',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('清理缓存过程中发生未知错误: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.search}/health',
      );

      if (response['success'] == true) {
        return response['data'] ?? response;
      } else {
        throw ServerException(
          response['message'] ?? '健康检查失败',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('健康检查过程中发生未知错误: $e');
    }
  }
} 