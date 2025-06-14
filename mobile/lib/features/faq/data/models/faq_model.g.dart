// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faq_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserReferenceModel _$UserReferenceModelFromJson(Map<String, dynamic> json) =>
    UserReferenceModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$UserReferenceModelToJson(UserReferenceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
    };

KnowledgeBaseReferenceModel _$KnowledgeBaseReferenceModelFromJson(
        Map<String, dynamic> json) =>
    KnowledgeBaseReferenceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$KnowledgeBaseReferenceModelToJson(
        KnowledgeBaseReferenceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
    };

FaqCategoryModel _$FaqCategoryModelFromJson(Map<String, dynamic> json) =>
    FaqCategoryModel(
      category: json['category'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$FaqCategoryModelToJson(FaqCategoryModel instance) =>
    <String, dynamic>{
      'category': instance.category,
      'count': instance.count,
    };

FaqModel _$FaqModelFromJson(Map<String, dynamic> json) => FaqModel(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      priority: json['priority'] as String,
      status: json['status'] as String,
      isPublic: json['isPublic'] as bool,
      viewCount: (json['viewCount'] as num).toInt(),
      likeCount: (json['likeCount'] as num).toInt(),
      dislikeCount: (json['dislikeCount'] as num).toInt(),
      knowledgeBaseId: json['knowledgeBaseId'] as String?,
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      knowledgeBase: json['knowledgeBase'] == null
          ? null
          : KnowledgeBaseReferenceModel.fromJson(
              json['knowledgeBase'] as Map<String, dynamic>),
      creator: json['creator'] == null
          ? null
          : UserReferenceModel.fromJson(
              json['creator'] as Map<String, dynamic>),
      updater: json['updater'] == null
          ? null
          : UserReferenceModel.fromJson(
              json['updater'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FaqModelToJson(FaqModel instance) => <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'answer': instance.answer,
      'category': instance.category,
      'tags': instance.tags,
      'priority': instance.priority,
      'status': instance.status,
      'isPublic': instance.isPublic,
      'viewCount': instance.viewCount,
      'likeCount': instance.likeCount,
      'dislikeCount': instance.dislikeCount,
      'knowledgeBaseId': instance.knowledgeBaseId,
      'createdBy': instance.createdBy,
      'updatedBy': instance.updatedBy,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'knowledgeBase': instance.knowledgeBase,
      'creator': instance.creator,
      'updater': instance.updater,
    };

FaqCreateRequest _$FaqCreateRequestFromJson(Map<String, dynamic> json) =>
    FaqCreateRequest(
      question: json['question'] as String,
      answer: json['answer'] as String,
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      priority: json['priority'] as String?,
      status: json['status'] as String?,
      isPublic: json['isPublic'] as bool?,
      knowledgeBaseId: json['knowledgeBaseId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$FaqCreateRequestToJson(FaqCreateRequest instance) =>
    <String, dynamic>{
      'question': instance.question,
      'answer': instance.answer,
      'category': instance.category,
      'tags': instance.tags,
      'priority': instance.priority,
      'status': instance.status,
      'isPublic': instance.isPublic,
      'knowledgeBaseId': instance.knowledgeBaseId,
      'metadata': instance.metadata,
    };

FaqBulkDeleteRequest _$FaqBulkDeleteRequestFromJson(
        Map<String, dynamic> json) =>
    FaqBulkDeleteRequest(
      ids: (json['ids'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$FaqBulkDeleteRequestToJson(
        FaqBulkDeleteRequest instance) =>
    <String, dynamic>{
      'ids': instance.ids,
    };

FaqSearchParams _$FaqSearchParamsFromJson(Map<String, dynamic> json) =>
    FaqSearchParams(
      search: json['search'] as String?,
      category: json['category'] as String?,
      status: json['status'] as String?,
      knowledgeBaseId: json['knowledgeBaseId'] as String?,
      isPublic: json['isPublic'] as bool?,
      sortBy: json['sortBy'] as String?,
      sortOrder: json['sortOrder'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      page: (json['page'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FaqSearchParamsToJson(FaqSearchParams instance) =>
    <String, dynamic>{
      'search': instance.search,
      'category': instance.category,
      'status': instance.status,
      'knowledgeBaseId': instance.knowledgeBaseId,
      'isPublic': instance.isPublic,
      'sortBy': instance.sortBy,
      'sortOrder': instance.sortOrder,
      'tags': instance.tags,
      'page': instance.page,
      'limit': instance.limit,
    };

FaqResponse _$FaqResponseFromJson(Map<String, dynamic> json) => FaqResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      faq: json['faq'] == null
          ? null
          : FaqModel.fromJson(json['faq'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FaqResponseToJson(FaqResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'faq': instance.faq,
    };

FaqListResponse _$FaqListResponseFromJson(Map<String, dynamic> json) =>
    FaqListResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : FaqListData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FaqListResponseToJson(FaqListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

FaqListData _$FaqListDataFromJson(Map<String, dynamic> json) => FaqListData(
      faqs: (json['faqs'] as List<dynamic>)
          .map((e) => FaqModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FaqListDataToJson(FaqListData instance) =>
    <String, dynamic>{
      'faqs': instance.faqs,
      'pagination': instance.pagination,
    };

FaqCategoriesResponse _$FaqCategoriesResponseFromJson(
        Map<String, dynamic> json) =>
    FaqCategoriesResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : FaqCategoriesData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FaqCategoriesResponseToJson(
        FaqCategoriesResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

FaqCategoriesData _$FaqCategoriesDataFromJson(Map<String, dynamic> json) =>
    FaqCategoriesData(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => FaqCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FaqCategoriesDataToJson(FaqCategoriesData instance) =>
    <String, dynamic>{
      'categories': instance.categories,
    };

PaginationModel _$PaginationModelFromJson(Map<String, dynamic> json) =>
    PaginationModel(
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      hasNext: json['hasNext'] as bool,
      hasPrev: json['hasPrev'] as bool,
    );

Map<String, dynamic> _$PaginationModelToJson(PaginationModel instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
      'hasNext': instance.hasNext,
      'hasPrev': instance.hasPrev,
    };
