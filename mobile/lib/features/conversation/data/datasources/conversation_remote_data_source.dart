import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
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
      final body = {
        if (knowledgeBaseId != null) 'knowledgeBaseId': knowledgeBaseId,
        if (title != null) 'title': title,
        'type': type.value,
        'settings': settings,
        'tags': tags,
      };

      final response = await _apiClient.post(
        ApiEndpoints.conversations,
        body: body,
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(apiResponse.error ?? '创建对话失败');
      }

      return ConversationModel.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('创建对话时发生未知错误: $e');
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
      final queryParameters = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
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
        throw ServerException(apiResponse.error ?? '获取对话列表失败');
      }

      return PaginatedResponseModel<ConversationModel>.fromJson(
        apiResponse.data!,
        (json) => ConversationModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('获取对话列表时发生未知错误: $e');
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
        throw ServerException(apiResponse.error ?? '获取对话详情失败');
      }

      return ConversationModel.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('获取对话详情时发生未知错误: $e');
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
        body: request.toJson(),
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(apiResponse.error ?? '发送消息失败');
      }

      return SendMessageResponseModel.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('发送消息时发生未知错误: $e');
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
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (tags != null) body['tags'] = tags;
      if (settings != null) body['settings'] = settings;
      if (status != null) body['status'] = status.value;

      final response = await _apiClient.put(
        '${ApiEndpoints.conversations}/$id',
        body: body,
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(apiResponse.error ?? '更新对话失败');
      }

      return ConversationModel.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('更新对话时发生未知错误: $e');
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
        throw ServerException(apiResponse.error ?? '删除对话失败');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('删除对话时发生未知错误: $e');
    }
  }

  @override
  Future<int> bulkDeleteConversations(List<String> ids) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.conversations}/bulk-delete',
        body: {'ids': ids},
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(apiResponse.error ?? '批量删除对话失败');
      }

      return apiResponse.data!['deletedCount'] as int? ?? 0;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('批量删除对话时发生未知错误: $e');
    }
  }

  @override
  Future<void> rateConversation({
    required String id,
    required int rating,
    String? feedback,
  }) async {
    try {
      final body = {
        'rating': rating,
        if (feedback != null) 'feedback': feedback,
      };

      final response = await _apiClient.post(
        '${ApiEndpoints.conversations}/$id/rate',
        body: body,
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>?>.fromJson(
        response,
        (json) => json as Map<String, dynamic>?,
      );

      if (!apiResponse.success) {
        throw ServerException(apiResponse.error ?? '对话评分失败');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('对话评分时发生未知错误: $e');
    }
  }

  @override
  Future<ConversationStatsModel> getConversationStats({
    DateTime? startDate,
    DateTime? endDate,
    String? knowledgeBaseId,
  }) async {
    try {
      final queryParameters = <String, String>{
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (knowledgeBaseId != null) 'knowledgeBaseId': knowledgeBaseId,
      };

      final response = await _apiClient.get(
        '${ApiEndpoints.conversations}/stats',
        queryParameters: queryParameters,
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(apiResponse.error ?? '获取对话统计失败');
      }

      return ConversationStatsModel.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('获取对话统计时发生未知错误: $e');
    }
  }

  /// 处理Dio异常
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('请求超时，请检查网络连接');
      case DioExceptionType.badResponse:
        return _handleStatusCode(e.response?.statusCode ?? 0, e.response?.data);
      case DioExceptionType.cancel:
        return NetworkException('请求已取消');
      case DioExceptionType.unknown:
        if (e.error.toString().contains('SocketException')) {
          return NetworkException('网络连接失败，请检查网络设置');
        }
        return NetworkException('网络请求失败: ${e.message}');
      default:
        return NetworkException('未知网络错误');
    }
  }

  /// 处理HTTP状态码
  Exception _handleStatusCode(int statusCode, dynamic responseData) {
    final message = _extractErrorMessage(responseData);
    
    switch (statusCode) {
      case 400:
        return ValidationException(message ?? '请求参数错误');
      case 401:
        return AuthException(message ?? '身份验证失败');
      case 403:
        return AuthException(message ?? '访问被拒绝');
      case 404:
        return NotFoundException(message ?? '请求的资源不存在');
      case 429:
        return RateLimitException(message ?? '请求过于频繁，请稍后再试');
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(message ?? '服务器内部错误');
      default:
        return ServerException(message ?? '未知服务器错误');
    }
  }

  /// 提取错误消息
  String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['error']?.toString() ?? 
             responseData['message']?.toString();
    }
    return responseData?.toString();
  }
} 