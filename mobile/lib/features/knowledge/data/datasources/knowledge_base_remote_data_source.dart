import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/knowledge_base_model.dart';

/// 知识库远程数据源接口
abstract class KnowledgeBaseRemoteDataSource {
  Future<List<KnowledgeBaseModel>> getKnowledgeBases({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? tags,
    String? sortBy,
    String? sortOrder,
  });

  Future<List<KnowledgeBaseModel>> getMyKnowledgeBases({
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
    String? sortBy,
    String? sortOrder,
  });

  Future<List<KnowledgeBaseModel>> getPublicKnowledgeBases({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? tags,
    String? sortBy,
    String? sortOrder,
  });

  Future<KnowledgeBaseModel> getKnowledgeBase(String id);
  Future<KnowledgeBaseModel> createKnowledgeBase(Map<String, dynamic> data);
  Future<KnowledgeBaseModel> updateKnowledgeBase(String id, Map<String, dynamic> data);
  Future<void> deleteKnowledgeBase(String id);
  
  // 添加缺失的方法
  Future<KnowledgeBaseModel> updateKnowledgeBaseStatus(String id, String status);
  Future<KnowledgeBaseModel> duplicateKnowledgeBase(String id, String newName, String? description);
  Future<void> shareKnowledgeBase(String id, List<String> userIds, String? message);
  Future<KnowledgeBaseModel> importKnowledgeBase(String filePath, String name, String? description);
  Future<String> exportKnowledgeBase(String id, String format);
  Future<Map<String, dynamic>> getKnowledgeBaseStats({String? userId, DateTime? startDate, DateTime? endDate});
  Future<List<KnowledgeBaseModel>> searchKnowledgeBases({required String query, int page = 1, int limit = 20, String? type, List<String>? tags});
  Future<List<String>> getKnowledgeBaseTags();
  Future<void> deleteKnowledgeBases(List<String> ids);
  Future<List<KnowledgeBaseModel>> batchUpdateStatus(List<String> ids, String status);
}

/// 知识库远程数据源实现
class KnowledgeBaseRemoteDataSourceImpl implements KnowledgeBaseRemoteDataSource {
  final ApiClient _apiClient;

  KnowledgeBaseRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<KnowledgeBaseModel>> getKnowledgeBases({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? tags,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) queryParameters['search'] = search;
      if (tags != null && tags.isNotEmpty) queryParameters['tags'] = tags.join(',');
      if (sortBy != null) queryParameters['sortBy'] = sortBy;
      if (sortOrder != null) queryParameters['sortOrder'] = sortOrder;

      final response = await _apiClient.get(
        ApiEndpoints.knowledgeBases,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final responseData = data['data'] as Map<String, dynamic>;
        final knowledgeBasesData = responseData['knowledgeBases'] as List<dynamic>;
        
        return knowledgeBasesData
            .map((json) => KnowledgeBaseModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? '获取知识库列表失败',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data['message'] ?? '网络请求失败',
          code: e.response?.statusCode?.toString(),
        );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<KnowledgeBaseModel>> getMyKnowledgeBases({
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (type != null) queryParameters['type'] = type;
      if (status != null) queryParameters['status'] = status;
      if (sortBy != null) queryParameters['sortBy'] = sortBy;
      if (sortOrder != null) queryParameters['sortOrder'] = sortOrder;

      final response = await _apiClient.get(
        ApiEndpoints.myKnowledgeBases,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final responseData = data['data'] as Map<String, dynamic>;
        final knowledgeBasesData = responseData['knowledgeBases'] as List<dynamic>;
        
        return knowledgeBasesData
            .map((json) => KnowledgeBaseModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? '获取我的知识库失败',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data['message'] ?? '网络请求失败',
          code: e.response?.statusCode?.toString(),
        );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<KnowledgeBaseModel>> getPublicKnowledgeBases({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? tags,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) queryParameters['search'] = search;
      if (tags != null && tags.isNotEmpty) queryParameters['tags'] = tags.join(',');
      if (sortBy != null) queryParameters['sortBy'] = sortBy;
      if (sortOrder != null) queryParameters['sortOrder'] = sortOrder;

      final response = await _apiClient.get(
        ApiEndpoints.publicKnowledgeBases,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final responseData = data['data'] as Map<String, dynamic>;
        final knowledgeBasesData = responseData['knowledgeBases'] as List<dynamic>;
        
        return knowledgeBasesData
            .map((json) => KnowledgeBaseModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? '获取公开知识库失败',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data['message'] ?? '网络请求失败',
          code: e.response?.statusCode?.toString(),
        );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<KnowledgeBaseModel> getKnowledgeBase(String id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.knowledgeBases}/$id');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return KnowledgeBaseModel.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: response.data['message'] ?? '获取知识库详情失败',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: '知识库不存在');
      }
      throw ServerException(
          message: e.response?.data['message'] ?? '网络请求失败',
          code: e.response?.statusCode?.toString(),
        );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<KnowledgeBaseModel> createKnowledgeBase(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.knowledgeBases,
        data: data,
      );

      if (response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        return KnowledgeBaseModel.fromJson(responseData['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: response.data['message'] ?? '创建知识库失败',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data['message'] ?? '网络请求失败',
          code: e.response?.statusCode?.toString(),
        );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<KnowledgeBaseModel> updateKnowledgeBase(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiEndpoints.knowledgeBases}/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return KnowledgeBaseModel.fromJson(responseData['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: response.data['message'] ?? '更新知识库失败',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: '知识库不存在');
      }
      throw ServerException(
          message: e.response?.data['message'] ?? '网络请求失败',
          code: e.response?.statusCode?.toString(),
        );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteKnowledgeBase(String id) async {
    try {
      final response = await _apiClient.delete('${ApiEndpoints.knowledgeBases}/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: response.data['message'] ?? '删除知识库失败',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: '知识库不存在');
      }
      throw ServerException(
          message: e.response?.data['message'] ?? '网络请求失败',
          code: e.response?.statusCode?.toString(),
        );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<KnowledgeBaseModel> updateKnowledgeBaseStatus(String id, String status) async {
    try {
      final response = await _apiClient.put(
        '${ApiEndpoints.knowledgeBases}/$id/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return KnowledgeBaseModel.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: response.data['message'] ?? '更新知识库状态失败',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? '网络请求失败',
        code: e.response?.statusCode?.toString(),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<KnowledgeBaseModel> duplicateKnowledgeBase(String id, String newName, String? description) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.knowledgeBases}/$id/duplicate',
        data: {
          'name': newName,
          if (description != null) 'description': description,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return KnowledgeBaseModel.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: response.data['message'] ?? '复制知识库失败',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? '网络请求失败',
        code: e.response?.statusCode?.toString(),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> shareKnowledgeBase(String id, List<String> userIds, String? message) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.knowledgeBases}/$id/share',
        data: {
          'userIds': userIds,
          if (message != null) 'message': message,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: response.data['message'] ?? '分享知识库失败',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? '网络请求失败',
        code: e.response?.statusCode?.toString(),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<KnowledgeBaseModel> importKnowledgeBase(String filePath, String name, String? description) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.knowledgeBases}/import',
        data: {
          'filePath': filePath,
          'name': name,
          if (description != null) 'description': description,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return KnowledgeBaseModel.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: response.data['message'] ?? '导入知识库失败',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? '网络请求失败',
        code: e.response?.statusCode?.toString(),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> exportKnowledgeBase(String id, String format) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.knowledgeBases}/$id/export',
        queryParameters: {'format': format},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['downloadUrl'] as String;
      } else {
        throw ServerException(
          message: response.data['message'] ?? '导出知识库失败',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data['message'] ?? '网络请求失败',
          code: e.response?.statusCode?.toString(),
        );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getKnowledgeBaseStats({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (userId != null) queryParameters['userId'] = userId;
      if (startDate != null) queryParameters['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParameters['endDate'] = endDate.toIso8601String();

      final response = await _apiClient.get(
        '${ApiEndpoints.knowledgeBases}/stats',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(
          message: response.data['message'] ?? '获取统计信息失败',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data['message'] ?? '网络请求失败',
          code: e.response?.statusCode?.toString(),
        );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<KnowledgeBaseModel>> searchKnowledgeBases({
    required String query,
    int page = 1,
    int limit = 20,
    String? type,
    List<String>? tags,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'q': query,
        'page': page,
        'limit': limit,
      };

      if (type != null) queryParameters['type'] = type;
      if (tags != null && tags.isNotEmpty) queryParameters['tags'] = tags.join(',');

      final response = await _apiClient.get(
        '${ApiEndpoints.knowledgeBases}/search',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final knowledgeBasesData = data['data'] as List<dynamic>;
        
        return knowledgeBasesData
            .map((json) => KnowledgeBaseModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? '搜索知识库失败',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data['message'] ?? '网络请求失败',
          code: e.response?.statusCode?.toString(),
        );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<String>> getKnowledgeBaseTags() async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.knowledgeBases}/tags');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final tagsData = data['data'] as List<dynamic>;
        return tagsData.cast<String>();
      } else {
        throw ServerException(
          message: response.data['message'] ?? '获取标签失败',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data['message'] ?? '网络请求失败',
          code: e.response?.statusCode?.toString(),
        );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteKnowledgeBases(List<String> ids) async {
    try {
      final response = await _apiClient.delete(
        '${ApiEndpoints.knowledgeBases}/batch',
        data: {'ids': ids},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: response.data['message'] ?? '批量删除知识库失败',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data['message'] ?? '网络请求失败',
          code: e.response?.statusCode?.toString(),
        );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<KnowledgeBaseModel>> batchUpdateStatus(List<String> ids, String status) async {
    try {
      final response = await _apiClient.put(
        '${ApiEndpoints.knowledgeBases}/batch/status',
        data: {
          'ids': ids,
          'status': status,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final knowledgeBasesData = data['data'] as List<dynamic>;
        
        return knowledgeBasesData
            .map((json) => KnowledgeBaseModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? '批量更新状态失败',
          code: response.statusCode?.toString(),
        );
      }
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data['message'] ?? '网络请求失败',
          code: e.response?.statusCode?.toString(),
        );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
} 