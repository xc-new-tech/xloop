import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/search_models.dart';

/// 搜索远程数据源接口
abstract class SearchRemoteDataSource {
  /// 执行语义搜索
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
  Future<BatchVectorizeResultModel> batchVectorize(BatchVectorizeRequest request);

  /// 获取搜索统计信息
  Future<SearchStatsModel> getSearchStats();

  /// 清理缓存
  Future<void> clearCache([String? pattern]);

  /// 检查健康状态
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
        ApiEndpoints.search,
        queryParameters: params,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return HybridSearchResultsModel.fromApiJson(response.data, query);
      } else {
        throw ServerException(
          response.data['message'] ?? '搜索失败',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, '搜索请求失败');
    } catch (e) {
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

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> documentsData = response.data['data'] ?? [];
        return documentsData
            .map((doc) => DocumentSearchResultModel.fromApiJson(doc))
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? '文档搜索失败',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, '文档搜索请求失败');
    } catch (e) {
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

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> faqsData = response.data['data'] ?? [];
        return faqsData
            .map((faq) => FaqSearchResultModel.fromApiJson(faq))
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'FAQ搜索失败',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'FAQ搜索请求失败');
    } catch (e) {
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

      if (response.statusCode == 200 && response.data['success'] == true) {
        return HybridSearchResultsModel.fromApiJson(
          response.data,
          'recommendations',
        );
      } else {
        throw ServerException(
          response.data['message'] ?? '推荐内容获取失败',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, '推荐内容请求失败');
    } catch (e) {
      throw ServerException('推荐内容获取过程中发生未知错误: $e');
    }
  }

  @override
  Future<void> vectorizeDocument(VectorizeDocumentRequest request) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.search}/vectorize/document',
        data: request.toJson(),
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ServerException(
          response.data['message'] ?? '文档向量化失败',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, '文档向量化请求失败');
    } catch (e) {
      throw ServerException('文档向量化过程中发生未知错误: $e');
    }
  }

  @override
  Future<void> vectorizeFaq(VectorizeFaqRequest request) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.search}/vectorize/faq',
        data: request.toJson(),
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ServerException(
          response.data['message'] ?? 'FAQ向量化失败',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, 'FAQ向量化请求失败');
    } catch (e) {
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
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return BatchVectorizeResultModel.fromApiJson(response.data);
      } else {
        throw ServerException(
          response.data['message'] ?? '批量向量化失败',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, '批量向量化请求失败');
    } catch (e) {
      throw ServerException('批量向量化过程中发生未知错误: $e');
    }
  }

  @override
  Future<SearchStatsModel> getSearchStats() async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.search}/stats',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SearchStatsModel.fromApiJson(response.data);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取搜索统计失败',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, '搜索统计请求失败');
    } catch (e) {
      throw ServerException('获取搜索统计过程中发生未知错误: $e');
    }
  }

  @override
  Future<void> clearCache([String? pattern]) async {
    try {
      final request = ClearCacheRequest(pattern: pattern);
      
      final response = await _apiClient.post(
        '${ApiEndpoints.search}/cache/clear',
        data: request.toJson(),
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ServerException(
          response.data['message'] ?? '清理缓存失败',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, '清理缓存请求失败');
    } catch (e) {
      throw ServerException('清理缓存过程中发生未知错误: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.search}/health',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException(
          '健康检查失败',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e, '健康检查请求失败');
    } catch (e) {
      throw ServerException('健康检查过程中发生未知错误: $e');
    }
  }

  /// 处理Dio异常
  ServerException _handleDioException(DioException e, String defaultMessage) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerException(
          '网络请求超时，请检查网络连接',
          408,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 500;
        final message = e.response?.data?['message'] ?? defaultMessage;
        return ServerException(
          message,
          statusCode,
        );
      case DioExceptionType.cancel:
        return ServerException(
          '请求已取消',
          499,
        );
      case DioExceptionType.connectionError:
        return ServerException(
          '网络连接错误，请检查网络设置',
          503,
        );
      case DioExceptionType.badCertificate:
        return ServerException(
          'SSL证书验证失败',
          495,
        );
      case DioExceptionType.unknown:
      default:
        return ServerException(
          '$defaultMessage: ${e.message}',
          500,
        );
    }
  }
} 