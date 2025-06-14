import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
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
        final knowledgeBasesData = data['data'] as List<dynamic>;
        
        return knowledgeBasesData
            .map((json) => KnowledgeBaseModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? '获取知识库列表失败',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? '网络请求失败',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(e.toString());
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
        final knowledgeBasesData = data['data'] as List<dynamic>;
        
        return knowledgeBasesData
            .map((json) => KnowledgeBaseModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? '获取我的知识库失败',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? '网络请求失败',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(e.toString());
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
        final knowledgeBasesData = data['data'] as List<dynamic>;
        
        return knowledgeBasesData
            .map((json) => KnowledgeBaseModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? '获取公开知识库失败',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? '网络请求失败',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(e.toString());
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
          response.data['message'] ?? '获取知识库详情失败',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException('知识库不存在');
      }
      throw ServerException(
        e.response?.data['message'] ?? '网络请求失败',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(e.toString());
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
          response.data['message'] ?? '创建知识库失败',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? '网络请求失败',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(e.toString());
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
          response.data['message'] ?? '更新知识库失败',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException('知识库不存在');
      }
      throw ServerException(
        e.response?.data['message'] ?? '网络请求失败',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteKnowledgeBase(String id) async {
    try {
      final response = await _apiClient.delete('${ApiEndpoints.knowledgeBases}/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          response.data['message'] ?? '删除知识库失败',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException('知识库不存在');
      }
      throw ServerException(
        e.response?.data['message'] ?? '网络请求失败',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
} 