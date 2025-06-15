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
    super.ownerId,
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
    super.createdBy,
    super.updatedBy,
  });

  factory KnowledgeBaseModel.fromJson(Map<String, dynamic> json) {
    return KnowledgeBaseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['owner_id'] as String? ?? json['ownerId'] as String? ?? 'unknown',
      type: _parseKnowledgeBaseType(json['type'] as String),
      status: _parseKnowledgeBaseStatus(json['status'] as String),
      settings: json['settings'] as Map<String, dynamic>?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      indexingEnabled: json['indexing_enabled'] as bool? ?? json['indexingEnabled'] as bool? ?? false,
      searchEnabled: json['search_enabled'] as bool? ?? json['searchEnabled'] as bool? ?? false,
      aiEnabled: json['ai_enabled'] as bool? ?? json['aiEnabled'] as bool? ?? false,
      vectorStoreId: json['vector_store_id'] as String? ?? json['vectorStoreId'] as String?,
      documentCount: _parseIntFromDynamic(json['document_count'] ?? json['documentCount'] ?? 0),
      totalSize: _parseIntFromDynamic(json['total_size'] ?? json['totalSize'] ?? 0),
      lastActivity: DateTime.parse(json['last_activity'] as String? ?? json['lastActivity'] as String? ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['created_at'] as String? ?? json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : (json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null),
      createdBy: json['created_by'] as String? ?? json['createdBy'] as String? ?? 'system',
      updatedBy: json['updated_by'] as String? ?? json['updatedBy'] as String?,
    );
  }

  static KnowledgeBaseType _parseKnowledgeBaseType(String type) {
    switch (type.toLowerCase()) {
      case 'personal':
        return KnowledgeBaseType.personal;
      case 'team':
        return KnowledgeBaseType.team;
      case 'public':
        return KnowledgeBaseType.public;
      default:
        return KnowledgeBaseType.personal;
    }
  }

  static KnowledgeBaseStatus _parseKnowledgeBaseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return KnowledgeBaseStatus.active;
      case 'archived':
        return KnowledgeBaseStatus.archived;
      case 'disabled':
        return KnowledgeBaseStatus.disabled;
      default:
        return KnowledgeBaseStatus.active;
    }
  }

  static int _parseIntFromDynamic(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

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
    KnowledgeBaseType? type,
    KnowledgeBaseStatus? status,
    Map<String, dynamic>? settings,
    List<String>? tags,
    bool? indexingEnabled,
    bool? searchEnabled,
    bool? aiEnabled,
    String? vectorStoreId,
    int? documentCount,
    int? totalSize,
    DateTime? lastActivity,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return KnowledgeBaseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      type: type ?? this.type,
      status: status ?? this.status,
      settings: settings ?? this.settings,
      tags: tags ?? this.tags,
      indexingEnabled: indexingEnabled ?? this.indexingEnabled,
      searchEnabled: searchEnabled ?? this.searchEnabled,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      vectorStoreId: vectorStoreId ?? this.vectorStoreId,
      documentCount: documentCount ?? this.documentCount,
      totalSize: totalSize ?? this.totalSize,
      lastActivity: lastActivity ?? this.lastActivity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
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