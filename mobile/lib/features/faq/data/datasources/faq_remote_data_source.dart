import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/faq_model.dart';

abstract class FaqRemoteDataSource {
  /// 获取FAQ列表
  Future<FaqListResponse> getFaqs({
    String? search,
    String? category,
    String? status,
    String? knowledgeBaseId,
    bool? isPublic,
    String? sortBy,
    String? sortOrder,
    List<String>? tags,
    int page = 1,
    int limit = 20,
  });

  /// 搜索FAQ
  Future<FaqListResponse> searchFaqs(FaqSearchParams params);

  /// 获取FAQ详情
  Future<FaqResponse> getFaqById(String id);

  /// 创建FAQ
  Future<FaqResponse> createFaq(FaqCreateRequest request);

  /// 更新FAQ
  Future<FaqResponse> updateFaq(String id, FaqCreateRequest request);

  /// 删除FAQ
  Future<void> deleteFaq(String id);

  /// 批量删除FAQ
  Future<void> bulkDeleteFaqs(List<String> ids);

  /// 获取FAQ分类
  Future<FaqCategoriesResponse> getCategories();

  /// 获取热门FAQ
  Future<FaqListResponse> getPopularFaqs({
    int limit = 10,
  });

  /// 点赞FAQ
  Future<FaqResponse> likeFaq(String id);

  /// 点踩FAQ
  Future<FaqResponse> dislikeFaq(String id);

  /// 切换FAQ状态
  Future<FaqResponse> toggleFaqStatus(String id);
}

class FaqRemoteDataSourceImpl implements FaqRemoteDataSource {
  final ApiClient _apiClient;

  FaqRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<FaqListResponse> getFaqs({
    String? search,
    String? category,
    String? status,
    String? knowledgeBaseId,
    bool? isPublic,
    String? sortBy,
    String? sortOrder,
    List<String>? tags,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (knowledgeBaseId != null && knowledgeBaseId.isNotEmpty) {
        queryParams['knowledgeBaseId'] = knowledgeBaseId;
      }
      if (isPublic != null) queryParams['isPublic'] = isPublic.toString();
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
      if (sortOrder != null && sortOrder.isNotEmpty) queryParams['sortOrder'] = sortOrder;
      if (tags != null && tags.isNotEmpty) {
        for (int i = 0; i < tags.length; i++) {
          queryParams['tags[$i]'] = tags[i];
        }
      }
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      final response = await _apiClient.get(
        ApiEndpoints.faqs,
        queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())),
      );

      return FaqListResponse.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: '获取FAQ列表失败: ${e.toString()}');
    }
  }

  @override
  Future<FaqListResponse> searchFaqs(FaqSearchParams params) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.faqSearch,
        queryParameters: params.toQueryParams().map((key, value) => MapEntry(key, value.toString())),
      );

      return FaqListResponse.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: '搜索FAQ失败: ${e.toString()}');
    }
  }

  @override
  Future<FaqResponse> getFaqById(String id) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.faqDetail(id),
      );

      return FaqResponse.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: '获取FAQ详情失败: ${e.toString()}');
    }
  }

  @override
  Future<FaqResponse> createFaq(FaqCreateRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.faqs,
        data: request.toJson(),
      );

      return FaqResponse.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: '创建FAQ失败: ${e.toString()}');
    }
  }

  @override
  Future<FaqResponse> updateFaq(String id, FaqCreateRequest request) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.faqDetail(id),
        data: request.toJson(),
      );

      return FaqResponse.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: '更新FAQ失败: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteFaq(String id) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.faqDetail(id),
      );
    } catch (e) {
      throw ServerException(message: '删除FAQ失败: ${e.toString()}');
    }
  }

  @override
  Future<void> bulkDeleteFaqs(List<String> ids) async {
    try {
      final request = FaqBulkDeleteRequest(ids: ids);
      await _apiClient.post(
        ApiEndpoints.faqBulkDelete,
        data: request.toJson(),
      );
    } catch (e) {
      throw ServerException(message: '批量删除FAQ失败: ${e.toString()}');
    }
  }

  @override
  Future<FaqCategoriesResponse> getCategories() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.faqCategories,
      );

      return FaqCategoriesResponse.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: '获取FAQ分类失败: ${e.toString()}');
    }
  }

  @override
  Future<FaqListResponse> getPopularFaqs({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.faqPopular,
        queryParameters: {'limit': limit.toString()},
      );

      return FaqListResponse.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: '获取热门FAQ失败: ${e.toString()}');
    }
  }

  @override
  Future<FaqResponse> likeFaq(String id) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.faqLike(id),
      );

      return FaqResponse.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: '点赞FAQ失败: ${e.toString()}');
    }
  }

  @override
  Future<FaqResponse> dislikeFaq(String id) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.faqDislike(id),
      );

      return FaqResponse.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: '点踩FAQ失败: ${e.toString()}');
    }
  }

  @override
  Future<FaqResponse> toggleFaqStatus(String id) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.faqToggleStatus(id),
      );

      return FaqResponse.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: '切换FAQ状态失败: ${e.toString()}');
    }
  }
} 