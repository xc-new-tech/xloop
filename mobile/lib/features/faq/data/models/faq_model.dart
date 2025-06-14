import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/faq_entity.dart';

part 'faq_model.g.dart';

@JsonSerializable()
class UserReferenceModel {
  final String id;
  final String username;
  final String email;

  const UserReferenceModel({
    required this.id,
    required this.username,
    required this.email,
  });

  factory UserReferenceModel.fromJson(Map<String, dynamic> json) => 
      _$UserReferenceModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserReferenceModelToJson(this);

  UserReference toEntity() {
    return UserReference(
      id: id,
      username: username,
      email: email,
    );
  }

  factory UserReferenceModel.fromEntity(UserReference entity) {
    return UserReferenceModel(
      id: entity.id,
      username: entity.username,
      email: entity.email,
    );
  }
}

@JsonSerializable()
class KnowledgeBaseReferenceModel {
  final String id;
  final String name;
  final String? description;

  const KnowledgeBaseReferenceModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory KnowledgeBaseReferenceModel.fromJson(Map<String, dynamic> json) => 
      _$KnowledgeBaseReferenceModelFromJson(json);

  Map<String, dynamic> toJson() => _$KnowledgeBaseReferenceModelToJson(this);

  KnowledgeBaseReference toEntity() {
    return KnowledgeBaseReference(
      id: id,
      name: name,
      description: description,
    );
  }

  factory KnowledgeBaseReferenceModel.fromEntity(KnowledgeBaseReference entity) {
    return KnowledgeBaseReferenceModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
    );
  }
}

@JsonSerializable()
class FaqCategoryModel {
  final String category;
  final int count;

  const FaqCategoryModel({
    required this.category,
    required this.count,
  });

  factory FaqCategoryModel.fromJson(Map<String, dynamic> json) => 
      _$FaqCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$FaqCategoryModelToJson(this);

  FaqCategory toEntity() {
    return FaqCategory(
      category: category,
      count: count,
    );
  }

  factory FaqCategoryModel.fromEntity(FaqCategory entity) {
    return FaqCategoryModel(
      category: entity.category,
      count: entity.count,
    );
  }
}

@JsonSerializable()
class FaqModel {
  final String id;
  final String question;
  final String answer;
  final String category;
  final List<String> tags;
  final String priority;
  final String status;
  @JsonKey(name: 'isPublic')
  final bool isPublic;
  @JsonKey(name: 'viewCount')
  final int viewCount;
  @JsonKey(name: 'likeCount')
  final int likeCount;
  @JsonKey(name: 'dislikeCount')
  final int dislikeCount;
  @JsonKey(name: 'knowledgeBaseId')
  final String? knowledgeBaseId;
  @JsonKey(name: 'createdBy')
  final String createdBy;
  @JsonKey(name: 'updatedBy')
  final String? updatedBy;
  final Map<String, dynamic> metadata;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;
  @JsonKey(name: 'deletedAt')
  final DateTime? deletedAt;
  
  // 关联对象
  @JsonKey(name: 'knowledgeBase')
  final KnowledgeBaseReferenceModel? knowledgeBase;
  final UserReferenceModel? creator;
  final UserReferenceModel? updater;

  const FaqModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.tags,
    required this.priority,
    required this.status,
    required this.isPublic,
    required this.viewCount,
    required this.likeCount,
    required this.dislikeCount,
    this.knowledgeBaseId,
    required this.createdBy,
    this.updatedBy,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.knowledgeBase,
    this.creator,
    this.updater,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) => _$FaqModelFromJson(json);

  Map<String, dynamic> toJson() => _$FaqModelToJson(this);

  FaqEntity toEntity() {
    return FaqEntity(
      id: id,
      question: question,
      answer: answer,
      category: category,
      tags: tags,
      priority: FaqPriority.fromString(priority),
      status: FaqStatus.fromString(status),
      isPublic: isPublic,
      viewCount: viewCount,
      likeCount: likeCount,
      dislikeCount: dislikeCount,
      knowledgeBaseId: knowledgeBaseId,
      createdBy: createdBy,
      updatedBy: updatedBy,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      knowledgeBase: knowledgeBase?.toEntity(),
      creator: creator?.toEntity(),
      updater: updater?.toEntity(),
    );
  }

  factory FaqModel.fromEntity(FaqEntity entity) {
    return FaqModel(
      id: entity.id,
      question: entity.question,
      answer: entity.answer,
      category: entity.category,
      tags: entity.tags,
      priority: entity.priority.value,
      status: entity.status.value,
      isPublic: entity.isPublic,
      viewCount: entity.viewCount,
      likeCount: entity.likeCount,
      dislikeCount: entity.dislikeCount,
      knowledgeBaseId: entity.knowledgeBaseId,
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
      knowledgeBase: entity.knowledgeBase != null 
          ? KnowledgeBaseReferenceModel.fromEntity(entity.knowledgeBase!)
          : null,
      creator: entity.creator != null 
          ? UserReferenceModel.fromEntity(entity.creator!)
          : null,
      updater: entity.updater != null 
          ? UserReferenceModel.fromEntity(entity.updater!)
          : null,
    );
  }
}

/// FAQ创建/更新请求模型
@JsonSerializable()
class FaqCreateRequest {
  final String question;
  final String answer;
  final String? category;
  final List<String>? tags;
  final String? priority;
  final String? status;
  @JsonKey(name: 'isPublic')
  final bool? isPublic;
  @JsonKey(name: 'knowledgeBaseId')
  final String? knowledgeBaseId;
  final Map<String, dynamic>? metadata;

  const FaqCreateRequest({
    required this.question,
    required this.answer,
    this.category,
    this.tags,
    this.priority,
    this.status,
    this.isPublic,
    this.knowledgeBaseId,
    this.metadata,
  });

  factory FaqCreateRequest.fromJson(Map<String, dynamic> json) => 
      _$FaqCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FaqCreateRequestToJson(this);

  factory FaqCreateRequest.fromEntity(FaqEntity entity) {
    return FaqCreateRequest(
      question: entity.question,
      answer: entity.answer,
      category: entity.category,
      tags: entity.tags,
      priority: entity.priority.value,
      status: entity.status.value,
      isPublic: entity.isPublic,
      knowledgeBaseId: entity.knowledgeBaseId,
      metadata: entity.metadata,
    );
  }
}

/// FAQ批量删除请求模型
@JsonSerializable()
class FaqBulkDeleteRequest {
  final List<String> ids;

  const FaqBulkDeleteRequest({
    required this.ids,
  });

  factory FaqBulkDeleteRequest.fromJson(Map<String, dynamic> json) => 
      _$FaqBulkDeleteRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FaqBulkDeleteRequestToJson(this);
}

/// FAQ搜索参数模型
@JsonSerializable()
class FaqSearchParams {
  final String? search;
  final String? category;
  final String? status;
  @JsonKey(name: 'knowledgeBaseId')
  final String? knowledgeBaseId;
  @JsonKey(name: 'isPublic')
  final bool? isPublic;
  @JsonKey(name: 'sortBy')
  final String? sortBy;
  @JsonKey(name: 'sortOrder')
  final String? sortOrder;
  final List<String>? tags;
  final int? page;
  final int? limit;

  const FaqSearchParams({
    this.search,
    this.category,
    this.status,
    this.knowledgeBaseId,
    this.isPublic,
    this.sortBy,
    this.sortOrder,
    this.tags,
    this.page,
    this.limit,
  });

  factory FaqSearchParams.fromJson(Map<String, dynamic> json) => 
      _$FaqSearchParamsFromJson(json);

  Map<String, dynamic> toJson() => _$FaqSearchParamsToJson(this);

  /// 从筛选条件和排序配置创建搜索参数
  factory FaqSearchParams.fromFilter({
    required FaqFilter filter,
    required FaqSort sort,
    int page = 1,
    int limit = 20,
  }) {
    return FaqSearchParams(
      search: filter.search,
      category: filter.category,
      status: filter.status?.value,
      knowledgeBaseId: filter.knowledgeBaseId,
      isPublic: filter.isPublic,
      sortBy: sort.sortBy.value,
      sortOrder: sort.sortOrder.value,
      tags: filter.tags.isEmpty ? null : filter.tags,
      page: page,
      limit: limit,
    );
  }

  /// 转换为查询参数Map
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (category != null && category!.isNotEmpty) params['category'] = category;
    if (status != null && status!.isNotEmpty) params['status'] = status;
    if (knowledgeBaseId != null && knowledgeBaseId!.isNotEmpty) {
      params['knowledgeBaseId'] = knowledgeBaseId;
    }
    if (isPublic != null) params['isPublic'] = isPublic.toString();
    if (sortBy != null && sortBy!.isNotEmpty) params['sortBy'] = sortBy;
    if (sortOrder != null && sortOrder!.isNotEmpty) params['sortOrder'] = sortOrder;
    if (tags != null && tags!.isNotEmpty) {
      for (int i = 0; i < tags!.length; i++) {
        params['tags[$i]'] = tags![i];
      }
    }
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();

    return params;
  }
}

/// API响应模型
@JsonSerializable()
class FaqResponse {
  final bool success;
  final String? message;
  final FaqModel? faq;

  const FaqResponse({
    required this.success,
    this.message,
    this.faq,
  });

  factory FaqResponse.fromJson(Map<String, dynamic> json) => 
      _$FaqResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FaqResponseToJson(this);
}

@JsonSerializable()
class FaqListResponse {
  final bool success;
  final String? message;
  @JsonKey(name: 'data')
  final FaqListData? data;

  const FaqListResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory FaqListResponse.fromJson(Map<String, dynamic> json) => 
      _$FaqListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FaqListResponseToJson(this);
}

@JsonSerializable()
class FaqListData {
  final List<FaqModel> faqs;
  final PaginationModel pagination;

  const FaqListData({
    required this.faqs,
    required this.pagination,
  });

  factory FaqListData.fromJson(Map<String, dynamic> json) => 
      _$FaqListDataFromJson(json);

  Map<String, dynamic> toJson() => _$FaqListDataToJson(this);
}

@JsonSerializable()
class FaqCategoriesResponse {
  final bool success;
  final String? message;
  @JsonKey(name: 'data')
  final FaqCategoriesData? data;

  const FaqCategoriesResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory FaqCategoriesResponse.fromJson(Map<String, dynamic> json) => 
      _$FaqCategoriesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FaqCategoriesResponseToJson(this);
}

@JsonSerializable()
class FaqCategoriesData {
  final List<FaqCategoryModel> categories;

  const FaqCategoriesData({
    required this.categories,
  });

  factory FaqCategoriesData.fromJson(Map<String, dynamic> json) => 
      _$FaqCategoriesDataFromJson(json);

  Map<String, dynamic> toJson() => _$FaqCategoriesDataToJson(this);
}

/// 分页模型
@JsonSerializable()
class PaginationModel {
  final int total;
  final int page;
  final int limit;
  @JsonKey(name: 'totalPages')
  final int totalPages;
  @JsonKey(name: 'hasNext')
  final bool hasNext;
  @JsonKey(name: 'hasPrev')
  final bool hasPrev;

  const PaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) => 
      _$PaginationModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationModelToJson(this);
} 