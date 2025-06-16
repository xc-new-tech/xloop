import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/error/exceptions.dart';
import '../models/knowledge_base_model.dart';
import 'knowledge_base_remote_datasource.dart';

/// 知识库远程数据源实现
class KnowledgeBaseRemoteDataSourceImpl implements KnowledgeBaseRemoteDataSource {
  final Dio _dio;
  final Logger _logger;

  KnowledgeBaseRemoteDataSourceImpl({
    required Dio dio,
    required Logger logger,
  }) : _dio = dio, _logger = logger;

  @override
  Future<KnowledgeBaseListResponse> getKnowledgeBases({
    int page = 1,
    int limit = 20,
    String? status,
    String? type,
    String? search,
    List<String>? tags,
  }) async {
    try {
      _logger.d('获取知识库列表 - page: $page, limit: $limit');

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (tags != null && tags.isNotEmpty) queryParams['tags'] = tags.join(',');

      final response = await _dio.get(
        '/api/knowledge-bases',
        queryParameters: queryParams,
      );

      _logger.d('获取知识库列表成功');
      return KnowledgeBaseListResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('获取知识库列表失败', error: e);
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('获取知识库列表未知错误', error: e);
      throw ServerException('获取知识库列表失败: ${e.toString()}');
    }
  }

  @override
  Future<KnowledgeBaseModel> getKnowledgeBase(String id) async {
    try {
      _logger.d('获取知识库详情 - id: $id');

      final response = await _dio.get('/api/knowledge-bases/$id');

      _logger.d('获取知识库详情成功');
      return KnowledgeBaseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      _logger.e('获取知识库详情失败', error: e);
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('获取知识库详情未知错误', error: e);
      throw ServerException('获取知识库详情失败: ${e.toString()}');
    }
  }

  @override
  Future<KnowledgeBaseModel> createKnowledgeBase(CreateKnowledgeBaseRequest request) async {
    try {
      _logger.d('创建知识库 - name: ${request.name}');

      final response = await _dio.post(
        '/api/knowledge-bases',
        data: request.toJson(),
      );

      _logger.d('创建知识库成功');
      return KnowledgeBaseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      _logger.e('创建知识库失败', error: e);
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('创建知识库未知错误', error: e);
      throw ServerException('创建知识库失败: ${e.toString()}');
    }
  }

  @override
  Future<KnowledgeBaseModel> updateKnowledgeBase(String id, UpdateKnowledgeBaseRequest request) async {
    try {
      _logger.d('更新知识库 - id: $id');

      final response = await _dio.put(
        '/api/knowledge-bases/$id',
        data: request.toJson(),
      );

      _logger.d('更新知识库成功');
      return KnowledgeBaseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      _logger.e('更新知识库失败', error: e);
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('更新知识库未知错误', error: e);
      throw ServerException('更新知识库失败: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteKnowledgeBase(String id) async {
    try {
      _logger.d('删除知识库 - id: $id');

      await _dio.delete('/api/knowledge-bases/$id');

      _logger.d('删除知识库成功');
    } on DioException catch (e) {
      _logger.e('删除知识库失败', error: e);
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('删除知识库未知错误', error: e);
      throw ServerException('删除知识库失败: ${e.toString()}');
    }
  }

  @override
  Future<KnowledgeBaseModel> updateKnowledgeBaseStatus(String id, String status) async {
    try {
      _logger.d('更新知识库状态 - id: $id, status: $status');

      final response = await _dio.patch(
        '/api/knowledge-bases/$id/status',
        data: {'status': status},
      );

      _logger.d('更新知识库状态成功');
      return KnowledgeBaseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      _logger.e('更新知识库状态失败', error: e);
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('更新知识库状态未知错误', error: e);
      throw ServerException('更新知识库状态失败: ${e.toString()}');
    }
  }

  @override
  Future<KnowledgeBaseModel> duplicateKnowledgeBase(String id, String name, String? description) async {
    try {
      _logger.d('复制知识库 - id: $id, name: $name');

      final response = await _dio.post(
        '/api/knowledge-bases/$id/duplicate',
        data: {
          'name': name,
          if (description != null) 'description': description,
        },
      );

      _logger.d('复制知识库成功');
      return KnowledgeBaseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      _logger.e('复制知识库失败', error: e);
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('复制知识库未知错误', error: e);
      throw ServerException('复制知识库失败: ${e.toString()}');
    }
  }

  @override
  Future<KnowledgeBaseListResponse> getMyKnowledgeBases({
    int page = 1,
    int limit = 20,
    String? status,
    String? type,
  }) async {
    try {
      _logger.d('获取我的知识库列表 - page: $page, limit: $limit');

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;

      final response = await _dio.get(
        '/api/knowledge-bases/my',
        queryParameters: queryParams,
      );

      _logger.d('获取我的知识库列表成功');
      return KnowledgeBaseListResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('获取我的知识库列表失败', error: e);
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('获取我的知识库列表未知错误', error: e);
      throw ServerException('获取我的知识库列表失败: ${e.toString()}');
    }
  }

  @override
  Future<KnowledgeBaseListResponse> getPublicKnowledgeBases({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? tags,
  }) async {
    try {
      _logger.d('获取公开知识库列表 - page: $page, limit: $limit');

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (tags != null && tags.isNotEmpty) queryParams['tags'] = tags.join(',');

      final response = await _dio.get(
        '/api/v1/knowledge-bases/public',
        queryParameters: queryParams,
      );

      _logger.d('获取公开知识库列表成功');
      return KnowledgeBaseListResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('获取公开知识库列表失败', error: e);
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('获取公开知识库列表未知错误', error: e);
      throw ServerException('获取公开知识库列表失败: ${e.toString()}');
    }
  }

  @override
  Future<void> shareKnowledgeBase(String id, List<String> userIds, String? message) async {
    try {
      _logger.d('分享知识库 - id: $id, userIds: $userIds');

      await _dio.post(
        '/api/v1/knowledge-bases/$id/share',
        data: {
          'user_ids': userIds,
          if (message != null) 'message': message,
        },
      );

      _logger.d('分享知识库成功');
    } on DioException catch (e) {
      _logger.e('分享知识库失败', error: e);
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('分享知识库未知错误', error: e);
      throw ServerException('分享知识库失败: ${e.toString()}');
    }
  }

  @override
  Future<KnowledgeBaseModel> importKnowledgeBase({
    required String filePath,
    String? name,
    String? description,
    required String type,
  }) async {
    try {
      _logger.d('导入知识库 - filePath: $filePath');

      final response = await _dio.post(
        '/api/v1/knowledge-bases/import',
        data: {
          'file_path': filePath,
          'type': type,
          if (name != null) 'name': name,
          if (description != null) 'description': description,
        },
      );

      _logger.d('导入知识库成功');
      return KnowledgeBaseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      _logger.e('导入知识库失败', error: e);
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('导入知识库未知错误', error: e);
      throw ServerException('导入知识库失败: ${e.toString()}');
    }
  }

  @override
  Future<String> exportKnowledgeBase(String id, String format) async {
    try {
      _logger.d('导出知识库 - id: $id, format: $format');

      final response = await _dio.post(
        '/api/v1/knowledge-bases/$id/export',
        data: {'format': format},
      );

      _logger.d('导出知识库成功');
      return response.data['data']['download_url'] as String;
    } on DioException catch (e) {
      _logger.e('导出知识库失败', error: e);
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('导出知识库未知错误', error: e);
      throw ServerException('导出知识库失败: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getKnowledgeBaseStats({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _logger.d('获取知识库统计信息 - userId: $userId');

      final response = await _dio.get('/api/v1/knowledge-bases/stats');

      _logger.d('获取知识库统计信息成功');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      _logger.e('获取知识库统计信息失败', error: e);
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('获取知识库统计信息未知错误', error: e);
      throw ServerException('获取知识库统计信息失败: ${e.toString()}');
    }
  }

  @override
  Future<KnowledgeBaseListResponse> searchKnowledgeBases({
    required String query,
    int page = 1,
    int limit = 20,
    String? type,
    List<String>? tags,
  }) async {
    try {
      _logger.d('搜索知识库 - query: $query, page: $page, limit: $limit');

      final queryParams = <String, dynamic>{
        'q': query,
        'page': page,
        'limit': limit,
      };

      if (type != null) queryParams['type'] = type;
      if (tags != null && tags.isNotEmpty) queryParams['tags'] = tags.join(',');

      final response = await _dio.get(
        '/api/v1/knowledge-bases/search',
        queryParameters: queryParams,
      );

      _logger.d('搜索知识库成功');
      return KnowledgeBaseListResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('搜索知识库失败', error: e);
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('搜索知识库未知错误', error: e);
      throw ServerException('搜索知识库失败: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getKnowledgeBaseTags() async {
    try {
      _logger.d('获取知识库标签列表');

      final response = await _dio.get('/api/v1/knowledge-bases/tags');

      _logger.d('获取知识库标签列表成功');
      return List<String>.from(response.data['data']);
    } on DioException catch (e) {
      _logger.e('获取知识库标签列表失败', error: e);
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('获取知识库标签列表未知错误', error: e);
      throw ServerException('获取知识库标签列表失败: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteKnowledgeBases(List<String> ids) async {
    try {
      _logger.d('批量删除知识库 - ids: $ids');

      await _dio.delete(
        '/api/v1/knowledge-bases/batch',
        data: {'ids': ids},
      );

      _logger.d('批量删除知识库成功');
    } on DioException catch (e) {
      _logger.e('批量删除知识库失败', error: e);
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('批量删除知识库未知错误', error: e);
      throw ServerException('批量删除知识库失败: ${e.toString()}');
    }
  }

  @override
  Future<List<KnowledgeBaseModel>> batchUpdateStatus(List<String> ids, String status) async {
    try {
      _logger.d('批量更新知识库状态 - ids: $ids, status: $status');

      final response = await _dio.patch(
        '/api/v1/knowledge-bases/batch/status',
        data: {
          'ids': ids,
          'status': status,
        },
      );

      _logger.d('批量更新知识库状态成功');
      final dataList = response.data['data'] as List;
      return dataList.map((item) => KnowledgeBaseModel.fromJson(item)).toList();
    } on DioException catch (e) {
      _logger.e('批量更新知识库状态失败', error: e);
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('批量更新知识库状态未知错误', error: e);
      throw ServerException('批量更新知识库状态失败: ${e.toString()}');
    }
  }

  /// 处理Dio异常
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('网络连接超时');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? '服务器错误';
        
        if (statusCode == 401) {
          return AuthException('认证失败，请重新登录');
        } else if (statusCode == 403) {
          return AuthException('权限不足');
        } else if (statusCode == 404) {
          return NotFoundException('资源不存在');
        } else if (statusCode == 422) {
          return ValidationException(message);
        } else {
          return ServerException('服务器错误: $message', statusCode);
        }
      case DioExceptionType.cancel:
        return NetworkException('请求已取消');
      case DioExceptionType.connectionError:
        return NetworkException('网络连接失败');
      case DioExceptionType.unknown:
      default:
        return ServerException('未知错误: ${e.message}');
    }
  }
} 