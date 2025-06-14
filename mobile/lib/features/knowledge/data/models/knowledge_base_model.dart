import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/knowledge_base.dart';

part 'knowledge_base_model.g.dart';

/// 知识库数据模型
@JsonSerializable()
class KnowledgeBaseModel extends KnowledgeBase {
  const KnowledgeBaseModel({
    required super.id,
    required super.name,
    super.description,
    required super.ownerId,
    required super.type,
    required super.status,
    super.settings,
    super.tags,
    required super.indexingEnabled,
    required super.searchEnabled,
    required super.aiEnabled,
    super.vectorStoreId,
    required super.documentCount,
    required super.totalSize,
    required super.lastActivity,
    required super.createdAt,
    super.updatedAt,
    required super.createdBy,
    super.updatedBy,
  });

  factory KnowledgeBaseModel.fromJson(Map<String, dynamic> json) =>
      _$KnowledgeBaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$KnowledgeBaseModelToJson(this);

  /// 从实体转换为模型
  factory KnowledgeBaseModel.fromEntity(KnowledgeBase entity) {
    return KnowledgeBaseModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      ownerId: entity.ownerId,
      type: entity.type,
      status: entity.status,
      settings: entity.settings,
      tags: entity.tags,
      indexingEnabled: entity.indexingEnabled,
      searchEnabled: entity.searchEnabled,
      aiEnabled: entity.aiEnabled,
      vectorStoreId: entity.vectorStoreId,
      documentCount: entity.documentCount,
      totalSize: entity.totalSize,
      lastActivity: entity.lastActivity,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
    );
  }

  /// 转换为实体
  KnowledgeBase toEntity() => KnowledgeBase(
        id: id,
        name: name,
        description: description,
        ownerId: ownerId,
        type: type,
        status: status,
        settings: settings,
        tags: tags,
        indexingEnabled: indexingEnabled,
        searchEnabled: searchEnabled,
        aiEnabled: aiEnabled,
        vectorStoreId: vectorStoreId,
        documentCount: documentCount,
        totalSize: totalSize,
        lastActivity: lastActivity,
        createdAt: createdAt,
        updatedAt: updatedAt,
        createdBy: createdBy,
        updatedBy: updatedBy,
      );

  @override
  KnowledgeBaseModel copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    String? coverImage,
    KnowledgeBaseStatus? status,
    KnowledgeBaseType? type,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? documentCount,
    int? faqCount,
    bool? isPublic,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return KnowledgeBaseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      coverImage: coverImage ?? this.coverImage,
      status: status ?? this.status,
      type: type ?? this.type,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      documentCount: documentCount ?? this.documentCount,
      faqCount: faqCount ?? this.faqCount,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 知识库创建请求模型
@JsonSerializable()
class CreateKnowledgeBaseRequest {
  final String name;
  final String? description;
  @JsonKey(name: 'cover_image')
  final String? coverImage;
  final String type;
  final Map<String, dynamic>? settings;
  @JsonKey(name: 'is_public')
  final bool isPublic;
  final List<String>? tags;

  const CreateKnowledgeBaseRequest({
    required this.name,
    this.description,
    this.coverImage,
    required this.type,
    this.settings,
    this.isPublic = false,
    this.tags,
  });

  factory CreateKnowledgeBaseRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateKnowledgeBaseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateKnowledgeBaseRequestToJson(this);
}

/// 知识库更新请求模型
@JsonSerializable()
class UpdateKnowledgeBaseRequest {
  final String? name;
  final String? description;
  @JsonKey(name: 'cover_image')
  final String? coverImage;
  final String? type;
  final Map<String, dynamic>? settings;
  @JsonKey(name: 'is_public')
  final bool? isPublic;
  final List<String>? tags;

  const UpdateKnowledgeBaseRequest({
    this.name,
    this.description,
    this.coverImage,
    this.type,
    this.settings,
    this.isPublic,
    this.tags,
  });

  factory UpdateKnowledgeBaseRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateKnowledgeBaseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateKnowledgeBaseRequestToJson(this);
}

/// 知识库列表响应模型
@JsonSerializable()
class KnowledgeBaseListResponse {
  final List<KnowledgeBaseModel> data;
  final int total;
  final int page;
  final int limit;
  @JsonKey(name: 'has_more')
  final bool hasMore;

  const KnowledgeBaseListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory KnowledgeBaseListResponse.fromJson(Map<String, dynamic> json) =>
      _$KnowledgeBaseListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$KnowledgeBaseListResponseToJson(this);
} 