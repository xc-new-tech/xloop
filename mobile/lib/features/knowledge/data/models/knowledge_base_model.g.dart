// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'knowledge_base_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KnowledgeBaseModel _$KnowledgeBaseModelFromJson(Map<String, dynamic> json) =>
    KnowledgeBaseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['ownerId'] as String?,
      type: $enumDecode(_$KnowledgeBaseTypeEnumMap, json['type']),
      contentType:
          $enumDecode(_$KnowledgeBaseContentTypeEnumMap, json['contentType']),
      status: $enumDecode(_$KnowledgeBaseStatusEnumMap, json['status']),
      settings: json['settings'] as Map<String, dynamic>?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      indexingEnabled: json['indexingEnabled'] as bool,
      searchEnabled: json['searchEnabled'] as bool,
      aiEnabled: json['aiEnabled'] as bool,
      vectorStoreId: json['vectorStoreId'] as String?,
      documentCount: (json['documentCount'] as num).toInt(),
      totalSize: (json['totalSize'] as num).toInt(),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );

Map<String, dynamic> _$KnowledgeBaseModelToJson(KnowledgeBaseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'ownerId': instance.ownerId,
      'type': _$KnowledgeBaseTypeEnumMap[instance.type]!,
      'contentType': _$KnowledgeBaseContentTypeEnumMap[instance.contentType]!,
      'status': _$KnowledgeBaseStatusEnumMap[instance.status]!,
      'settings': instance.settings,
      'tags': instance.tags,
      'indexingEnabled': instance.indexingEnabled,
      'searchEnabled': instance.searchEnabled,
      'aiEnabled': instance.aiEnabled,
      'vectorStoreId': instance.vectorStoreId,
      'documentCount': instance.documentCount,
      'totalSize': instance.totalSize,
      'lastActivity': instance.lastActivity.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'createdBy': instance.createdBy,
      'updatedBy': instance.updatedBy,
    };

const _$KnowledgeBaseTypeEnumMap = {
  KnowledgeBaseType.personal: 'personal',
  KnowledgeBaseType.team: 'team',
  KnowledgeBaseType.public: 'public',
};

const _$KnowledgeBaseContentTypeEnumMap = {
  KnowledgeBaseContentType.productManual: 'productManual',
  KnowledgeBaseContentType.faqSupport: 'faqSupport',
  KnowledgeBaseContentType.basicDocument: 'basicDocument',
};

const _$KnowledgeBaseStatusEnumMap = {
  KnowledgeBaseStatus.active: 'active',
  KnowledgeBaseStatus.archived: 'archived',
  KnowledgeBaseStatus.disabled: 'disabled',
};

CreateKnowledgeBaseRequest _$CreateKnowledgeBaseRequestFromJson(
        Map<String, dynamic> json) =>
    CreateKnowledgeBaseRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      coverImage: json['cover_image'] as String?,
      type: json['type'] as String,
      contentType: json['content_type'] as String,
      settings: json['settings'] as Map<String, dynamic>?,
      isPublic: json['is_public'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CreateKnowledgeBaseRequestToJson(
        CreateKnowledgeBaseRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'cover_image': instance.coverImage,
      'type': instance.type,
      'content_type': instance.contentType,
      'settings': instance.settings,
      'is_public': instance.isPublic,
      'tags': instance.tags,
    };

UpdateKnowledgeBaseRequest _$UpdateKnowledgeBaseRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateKnowledgeBaseRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      coverImage: json['cover_image'] as String?,
      type: json['type'] as String?,
      settings: json['settings'] as Map<String, dynamic>?,
      isPublic: json['is_public'] as bool?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$UpdateKnowledgeBaseRequestToJson(
        UpdateKnowledgeBaseRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'cover_image': instance.coverImage,
      'type': instance.type,
      'settings': instance.settings,
      'is_public': instance.isPublic,
      'tags': instance.tags,
    };

KnowledgeBaseListResponse _$KnowledgeBaseListResponseFromJson(
        Map<String, dynamic> json) =>
    KnowledgeBaseListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => KnowledgeBaseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      hasMore: json['has_more'] as bool,
    );

Map<String, dynamic> _$KnowledgeBaseListResponseToJson(
        KnowledgeBaseListResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'has_more': instance.hasMore,
    };
