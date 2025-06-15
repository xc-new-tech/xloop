import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// 知识库实体
class KnowledgeBase extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? ownerId;
  final KnowledgeBaseType type;
  final KnowledgeBaseStatus status;
  final Map<String, dynamic>? settings;
  final List<String> tags;
  final bool indexingEnabled;
  final bool searchEnabled;
  final bool aiEnabled;
  final String? vectorStoreId;
  final int documentCount;
  final int totalSize;
  final DateTime lastActivity;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const KnowledgeBase({
    required this.id,
    required this.name,
    this.description,
    this.ownerId,
    required this.type,
    required this.status,
    this.settings,
    this.tags = const [],
    required this.indexingEnabled,
    required this.searchEnabled,
    required this.aiEnabled,
    this.vectorStoreId,
    required this.documentCount,
    required this.totalSize,
    required this.lastActivity,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        ownerId,
        type,
        status,
        settings,
        tags,
        indexingEnabled,
        searchEnabled,
        aiEnabled,
        vectorStoreId,
        documentCount,
        totalSize,
        lastActivity,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];

  /// 创建副本并更新部分字段
  KnowledgeBase copyWith({
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
    return KnowledgeBase(
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

  /// 检查是否处于活动状态
  bool get isActive => status == KnowledgeBaseStatus.active;

  /// 检查是否已归档
  bool get isArchived => status == KnowledgeBaseStatus.archived;

  /// 检查是否已禁用
  bool get isDisabled => status == KnowledgeBaseStatus.disabled;

  /// 检查是否为个人知识库
  bool get isPersonal => type == KnowledgeBaseType.personal;

  /// 检查是否为团队知识库
  bool get isTeam => type == KnowledgeBaseType.team;

  /// 检查是否为公开知识库
  bool get isPublic => type == KnowledgeBaseType.public;

  /// 获取格式化的大小
  String get formattedSize {
    if (totalSize < 1024) return '${totalSize}B';
    if (totalSize < 1024 * 1024) return '${(totalSize / 1024).toStringAsFixed(1)}KB';
    if (totalSize < 1024 * 1024 * 1024) return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// 获取所有者名称（暂时返回ID，实际应该从用户服务获取）
  String get ownerName => ownerId ?? 'unknown';

  /// 获取格式化的创建时间
  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 获取格式化的更新时间
  String get formattedUpdatedAt {
    if (updatedAt == null) return '未更新';
    
    final now = DateTime.now();
    final difference = now.difference(updatedAt!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 获取格式化的最后活动时间
  String get formattedLastActivity {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 获取向量数量（暂时返回文档数量，实际应该从向量存储获取）
  int get vectorCount => documentCount;
}

/// 知识库状态枚举
enum KnowledgeBaseStatus {
  active,     // 活动状态
  archived,   // 已归档
  disabled,   // 已禁用
}

/// 知识库类型枚举
enum KnowledgeBaseType {
  personal,   // 个人知识库
  team,       // 团队知识库
  public,     // 公开知识库
}

/// 知识库状态扩展
extension KnowledgeBaseStatusExtension on KnowledgeBaseStatus {
  String get displayName {
    switch (this) {
      case KnowledgeBaseStatus.active:
        return '活动';
      case KnowledgeBaseStatus.archived:
        return '已归档';
      case KnowledgeBaseStatus.disabled:
        return '已禁用';
    }
  }

  String get value {
    switch (this) {
      case KnowledgeBaseStatus.active:
        return 'active';
      case KnowledgeBaseStatus.archived:
        return 'archived';
      case KnowledgeBaseStatus.disabled:
        return 'disabled';
    }
  }

  Color get color {
    switch (this) {
      case KnowledgeBaseStatus.active:
        return const Color(0xFF4CAF50); // 绿色
      case KnowledgeBaseStatus.archived:
        return const Color(0xFFFF9800); // 橙色
      case KnowledgeBaseStatus.disabled:
        return const Color(0xFFF44336); // 红色
    }
  }
}

/// 知识库类型扩展
extension KnowledgeBaseTypeExtension on KnowledgeBaseType {
  String get displayName {
    switch (this) {
      case KnowledgeBaseType.personal:
        return '个人知识库';
      case KnowledgeBaseType.team:
        return '团队知识库';
      case KnowledgeBaseType.public:
        return '公开知识库';
    }
  }

  String get value {
    switch (this) {
      case KnowledgeBaseType.personal:
        return 'personal';
      case KnowledgeBaseType.team:
        return 'team';
      case KnowledgeBaseType.public:
        return 'public';
    }
  }

  IconData get icon {
    switch (this) {
      case KnowledgeBaseType.personal:
        return Icons.person;
      case KnowledgeBaseType.team:
        return Icons.group;
      case KnowledgeBaseType.public:
        return Icons.public;
    }
  }
} 