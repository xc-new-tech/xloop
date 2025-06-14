import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/conversation.dart';
import '../models/conversation_model.dart';

abstract class ConversationRemoteDataSource {
  /// 创建新对话
  Future<ConversationModel> createConversation({
    String? knowledgeBaseId,
    String? title,
    ConversationType type = ConversationType.chat,
    Map<String, dynamic> settings = const {},
    List<String> tags = const [],
  });

  /// 获取对话列表
  Future<PaginatedResponseModel<ConversationModel>> getConversations({
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
  Future<ConversationModel> getConversationById(String id);

  /// 发送消息
  Future<SendMessageResponseModel> sendMessage({
    required String conversationId,
    required SendMessageRequestModel request,
  });

  /// 更新对话
  Future<ConversationModel> updateConversation({
    required String id,
    String? title,
    List<String>? tags,
    Map<String, dynamic>? settings,
    ConversationStatus? status,
  });

  /// 删除对话
  Future<void> deleteConversation(String id);

  /// 批量删除对话
  Future<int> bulkDeleteConversations(List<String> ids);

  /// 对话评分
  Future<void> rateConversation({
    required String id,
    required int rating,
    String? feedback,
  });

  /// 获取对话统计信息
  Future<ConversationStatsModel> getConversationStats({
    DateTime? startDate,
    DateTime? endDate,
    String? knowledgeBaseId,
  });
}

class ConversationRemoteDataSourceImpl implements ConversationRemoteDataSource {
  final ApiClient _apiClient;

  ConversationRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<ConversationModel> createConversation({
    String? knowledgeBaseId,
    String? title,
    ConversationType type = ConversationType.chat,
    Map<String, dynamic> settings = const {},
    List<String> tags = const [],
  }) async {
    try {
      final data = {
        if (knowledgeBaseId != null) 'knowledgeBaseId': knowledgeBaseId,
        if (title != null) 'title': title,
        'type': type.value,
        'settings': settings,
        'tags': tags,
      };

      final response = await _apiClient.post(
        ApiEndpoints.conversations,
        data: data,
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(message: apiResponse.error ?? '创建对话失败');
      }

      return ConversationModel.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(message: '创建对话时发生未知错误: $e');
    }
  }

  @override
  Future<PaginatedResponseModel<ConversationModel>> getConversations({
    int page = 1,
    int limit = 20,
    ConversationType? type,
    ConversationStatus? status,
    String? knowledgeBaseId,
    String? search,
    String sortBy = 'lastMessageAt',
    String sortOrder = 'DESC',
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        if (type != null) 'type': type.value,
        if (status != null) 'status': status.value,
        if (knowledgeBaseId != null) 'knowledgeBaseId': knowledgeBaseId,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _apiClient.get(
        ApiEndpoints.conversations,
        queryParameters: queryParameters,
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(message: apiResponse.error ?? '获取对话列表失败');
      }

      return PaginatedResponseModel<ConversationModel>.fromJson(
        apiResponse.data!,
        (json) => ConversationModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(message: '获取对话列表时发生未知错误: $e');
    }
  }

  @override
  Future<ConversationModel> getConversationById(String id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.conversations}/$id');

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(message: apiResponse.error ?? '获取对话详情失败');
      }

      return ConversationModel.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(message: '获取对话详情时发生未知错误: $e');
    }
  }

  @override
  Future<SendMessageResponseModel> sendMessage({
    required String conversationId,
    required SendMessageRequestModel request,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.conversations}/$conversationId/messages',
        data: request.toJson(),
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(message: apiResponse.error ?? '发送消息失败');
      }

      return SendMessageResponseModel.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(message: '发送消息时发生未知错误: $e');
    }
  }

  @override
  Future<ConversationModel> updateConversation({
    required String id,
    String? title,
    List<String>? tags,
    Map<String, dynamic>? settings,
    ConversationStatus? status,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (tags != null) data['tags'] = tags;
      if (settings != null) data['settings'] = settings;
      if (status != null) data['status'] = status.value;

      final response = await _apiClient.put(
        '${ApiEndpoints.conversations}/$id',
        data: data,
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(message: apiResponse.error ?? '更新对话失败');
      }

      return ConversationModel.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(message: '更新对话时发生未知错误: $e');
    }
  }

  @override
  Future<void> deleteConversation(String id) async {
    try {
      final response = await _apiClient.delete('${ApiEndpoints.conversations}/$id');

      final apiResponse = ApiResponseModel<Map<String, dynamic>?>.fromJson(
        response,
        (json) => json as Map<String, dynamic>?,
      );

      if (!apiResponse.success) {
        throw ServerException(message: apiResponse.error ?? '删除对话失败');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(message: '删除对话时发生未知错误: $e');
    }
  }

  @override
  Future<int> bulkDeleteConversations(List<String> ids) async {
    try {
      final response = await _apiClient.delete(
        '${ApiEndpoints.conversations}/bulk',
        data: {'ids': ids},
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(message: apiResponse.error ?? '批量删除对话失败');
      }

      return apiResponse.data!['deletedCount'] as int;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(message: '批量删除对话时发生未知错误: $e');
    }
  }

  @override
  Future<void> rateConversation({
    required String id,
    required int rating,
    String? feedback,
  }) async {
    try {
      final data = {
        'rating': rating,
        if (feedback != null) 'feedback': feedback,
      };

      final response = await _apiClient.post(
        '${ApiEndpoints.conversations}/$id/rating',
        data: data,
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>?>.fromJson(
        response,
        (json) => json as Map<String, dynamic>?,
      );

      if (!apiResponse.success) {
        throw ServerException(message: apiResponse.error ?? '对话评分失败');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(message: '对话评分时发生未知错误: $e');
    }
  }

  @override
  Future<ConversationStatsModel> getConversationStats({
    DateTime? startDate,
    DateTime? endDate,
    String? knowledgeBaseId,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (startDate != null) {
        queryParameters['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParameters['endDate'] = endDate.toIso8601String();
      }
      if (knowledgeBaseId != null) {
        queryParameters['knowledgeBaseId'] = knowledgeBaseId;
      }

      final response = await _apiClient.get(
        '${ApiEndpoints.conversations}/stats',
        queryParameters: queryParameters,
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(message: apiResponse.error ?? '获取对话统计失败');
      }

      return ConversationStatsModel.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(message: '获取对话统计时发生未知错误: $e');
    }
  }

  /// 处理Dio异常
  AppException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(message: '网络连接超时，请检查网络设置');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = _extractErrorMessage(e.response?.data);
        
        switch (statusCode) {
          case 400:
            return ValidationException(message: message ?? '请求参数无效');
          case 401:
            return AuthenticationException(message: message ?? '身份验证失败');
          case 403:
            return AuthorizationException(message: message ?? '权限不足');
          case 404:
            return NotFoundException(message: message ?? '对话不存在');
          case 429:
            return RateLimitException(message: message ?? '请求过于频繁');
          case 500:
          case 502:
          case 503:
          case 504:
            return ServerException(message: message ?? '服务器内部错误');
          default:
            return ServerException(message: message ?? '服务器响应异常');
        }
      case DioExceptionType.cancel:
        return NetworkException(message: '请求已取消');
      case DioExceptionType.badCertificate:
        return NetworkException(message: 'SSL证书验证失败');
      case DioExceptionType.connectionError:
        return NetworkException(message: '网络连接失败，请检查网络设置');
      case DioExceptionType.unknown:
      default:
        return NetworkException(message: '网络请求失败: ${e.message}');
    }
  }

  /// 从响应中提取错误消息
  String? _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return null;
    
    try {
      if (responseData is Map<String, dynamic>) {
        return responseData['message'] as String? ?? 
               responseData['error'] as String?;
      } else if (responseData is String) {
        return responseData;
      }
    } catch (e) {
      // 忽略解析错误
    }
    
    return null;
  }
} 