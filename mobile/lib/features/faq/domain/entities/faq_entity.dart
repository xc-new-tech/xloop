import 'package:equatable/equatable.dart';

/// FAQ优先级枚举
enum FaqPriority {
  low('low', '低'),
  medium('medium', '中'),
  high('high', '高');

  const FaqPriority(this.value, this.label);
  
  final String value;
  final String label;

  static FaqPriority fromString(String value) {
    return FaqPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => FaqPriority.medium,
    );
  }
}

/// FAQ状态枚举
enum FaqStatus {
  draft('draft', '草稿'),
  published('published', '已发布'),
  archived('archived', '已归档');

  const FaqStatus(this.value, this.label);
  
  final String value;
  final String label;

  static FaqStatus fromString(String value) {
    return FaqStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => FaqStatus.draft,
    );
  }

  /// 获取状态颜色
  String get colorHex {
    switch (this) {
      case FaqStatus.draft:
        return '#FFA726';
      case FaqStatus.published:
        return '#66BB6A';
      case FaqStatus.archived:
        return '#9E9E9E';
    }
  }

  /// 获取状态图标
  String get iconName {
    switch (this) {
      case FaqStatus.draft:
        return 'edit';
      case FaqStatus.published:
        return 'check_circle';
      case FaqStatus.archived:
        return 'archive';
    }
  }
}

/// FAQ分类信息
class FaqCategory extends Equatable {
  final String category;
  final int count;

  const FaqCategory({
    required this.category,
    required this.count,
  });

  @override
  List<Object?> get props => [category, count];

  @override
  String toString() => 'FaqCategory(category: $category, count: $count)';
}

/// 用户引用信息（简化版）
class UserReference extends Equatable {
  final String id;
  final String username;
  final String email;

  const UserReference({
    required this.id,
    required this.username,
    required this.email,
  });

  @override
  List<Object?> get props => [id, username, email];

  @override
  String toString() => 'UserReference(id: $id, username: $username)';
}

/// 知识库引用信息（简化版）
class KnowledgeBaseReference extends Equatable {
  final String id;
  final String name;
  final String? description;

  const KnowledgeBaseReference({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, description];

  @override
  String toString() => 'KnowledgeBaseReference(id: $id, name: $name)';
}

/// FAQ实体类
class FaqEntity extends Equatable {
  final String id;
  final String question;
  final String answer;
  final String category;
  final List<String> tags;
  final FaqPriority priority;
  final FaqStatus status;
  final bool isPublic;
  final int viewCount;
  final int likeCount;
  final int dislikeCount;
  final String? knowledgeBaseId;
  final String createdBy;
  final String? updatedBy;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  
  // 关联对象
  final KnowledgeBaseReference? knowledgeBase;
  final UserReference? creator;
  final UserReference? updater;

  const FaqEntity({
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

  @override
  List<Object?> get props => [
        id,
        question,
        answer,
        category,
        tags,
        priority,
        status,
        isPublic,
        viewCount,
        likeCount,
        dislikeCount,
        knowledgeBaseId,
        createdBy,
        updatedBy,
        metadata,
        createdAt,
        updatedAt,
        deletedAt,
        knowledgeBase,
        creator,
        updater,
      ];

  /// 复制实体并更新指定字段
  FaqEntity copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    List<String>? tags,
    FaqPriority? priority,
    FaqStatus? status,
    bool? isPublic,
    int? viewCount,
    int? likeCount,
    int? dislikeCount,
    String? knowledgeBaseId,
    String? createdBy,
    String? updatedBy,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    KnowledgeBaseReference? knowledgeBase,
    UserReference? creator,
    UserReference? updater,
  }) {
    return FaqEntity(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      isPublic: isPublic ?? this.isPublic,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
      knowledgeBaseId: knowledgeBaseId ?? this.knowledgeBaseId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      knowledgeBase: knowledgeBase ?? this.knowledgeBase,
      creator: creator ?? this.creator,
      updater: updater ?? this.updater,
    );
  }

  /// 计算有用率百分比
  double get helpfulnessRate {
    final totalFeedback = likeCount + dislikeCount;
    if (totalFeedback == 0) return 0.0;
    return (likeCount / totalFeedback) * 100;
  }

  /// 是否为热门FAQ
  bool get isPopular => viewCount > 100 || likeCount > 10;

  /// 是否为新FAQ
  bool get isNew {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    return diff.inDays <= 7;
  }

  /// 是否为最近更新
  bool get isRecentlyUpdated {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);
    return diff.inDays <= 3;
  }

  /// 获取简短的问题文本（用于列表显示）
  String get shortQuestion {
    if (question.length <= 50) return question;
    return '${question.substring(0, 47)}...';
  }

  /// 获取简短的答案文本（用于预览）
  String get shortAnswer {
    if (answer.length <= 100) return answer;
    return '${answer.substring(0, 97)}...';
  }

  /// 检查是否包含指定标签
  bool hasTag(String tag) {
    return tags.any((t) => t.toLowerCase() == tag.toLowerCase());
  }

  /// 检查是否匹配搜索关键词
  bool matchesKeyword(String keyword) {
    final lowercaseKeyword = keyword.toLowerCase();
    return question.toLowerCase().contains(lowercaseKeyword) ||
           answer.toLowerCase().contains(lowercaseKeyword) ||
           category.toLowerCase().contains(lowercaseKeyword) ||
           tags.any((tag) => tag.toLowerCase().contains(lowercaseKeyword));
  }

  @override
  String toString() => 'FaqEntity(id: $id, question: $shortQuestion, status: $status)';
}

/// FAQ筛选条件
class FaqFilter extends Equatable {
  final String? search;
  final String? query;
  final String? category;
  final FaqStatus? status;
  final String? knowledgeBaseId;
  final bool? isPublic;
  final List<String> tags;
  final FaqPriority? priority;

  const FaqFilter({
    this.search,
    this.query,
    this.category,
    this.status,
    this.knowledgeBaseId,
    this.isPublic,
    this.tags = const [],
    this.priority,
  });

  @override
  List<Object?> get props => [
        search,
        query,
        category,
        status,
        knowledgeBaseId,
        isPublic,
        tags,
        priority,
      ];

  FaqFilter copyWith({
    String? search,
    String? query,
    String? category,
    FaqStatus? status,
    String? knowledgeBaseId,
    bool? isPublic,
    List<String>? tags,
    FaqPriority? priority,
    bool clearSearch = false,
    bool clearQuery = false,
  }) {
    return FaqFilter(
      search: clearSearch ? null : (search ?? this.search),
      query: clearQuery ? null : (query ?? this.query),
      category: category ?? this.category,
      status: status ?? this.status,
      knowledgeBaseId: knowledgeBaseId ?? this.knowledgeBaseId,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
    );
  }

  /// 清除所有筛选条件
  FaqFilter clear() {
    return const FaqFilter();
  }

  /// 是否有任何筛选条件
  bool get hasFilters {
    return search != null ||
           query != null ||
           category != null ||
           status != null ||
           knowledgeBaseId != null ||
           isPublic != null ||
           tags.isNotEmpty ||
           priority != null;
  }

  /// 是否有活跃的筛选条件
  bool get hasActiveFilters {
    return hasFilters;
  }

  @override
  String toString() => 'FaqFilter(search: $search, query: $query, category: $category, status: $status)';
}

/// FAQ排序选项
enum FaqSortBy {
  createdAt('createdAt', '创建时间'),
  updatedAt('updatedAt', '更新时间'),
  viewCount('viewCount', '查看次数'),
  likeCount('likeCount', '点赞数'),
  question('question', '问题'),
  category('category', '分类'),
  priority('priority', '优先级');

  const FaqSortBy(this.value, this.label);
  
  final String value;
  final String label;

  static FaqSortBy fromString(String value) {
    return FaqSortBy.values.firstWhere(
      (sortBy) => sortBy.value == value,
      orElse: () => FaqSortBy.createdAt,
    );
  }
}

/// FAQ排序方向
enum FaqSortOrder {
  asc('ASC', '升序'),
  desc('DESC', '降序');

  const FaqSortOrder(this.value, this.label);
  
  final String value;
  final String label;

  static FaqSortOrder fromString(String value) {
    return FaqSortOrder.values.firstWhere(
      (order) => order.value == value,
      orElse: () => FaqSortOrder.desc,
    );
  }
}

/// FAQ排序配置
class FaqSort extends Equatable {
  final FaqSortBy sortBy;
  final FaqSortOrder sortOrder;

  const FaqSort({
    this.sortBy = FaqSortBy.createdAt,
    this.sortOrder = FaqSortOrder.desc,
  });

  @override
  List<Object?> get props => [sortBy, sortOrder];

  FaqSort copyWith({
    FaqSortBy? sortBy,
    FaqSortOrder? sortOrder,
  }) {
    return FaqSort(
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  String toString() => 'FaqSort(sortBy: $sortBy, sortOrder: $sortOrder)';
} 