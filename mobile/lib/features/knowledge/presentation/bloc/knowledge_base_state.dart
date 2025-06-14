import 'package:equatable/equatable.dart';

import '../../domain/entities/knowledge_base.dart';

/// 知识库状态
abstract class KnowledgeBaseState extends Equatable {
  const KnowledgeBaseState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class KnowledgeBaseInitial extends KnowledgeBaseState {
  const KnowledgeBaseInitial();
}

/// 加载中状态
class KnowledgeBaseLoading extends KnowledgeBaseState {
  const KnowledgeBaseLoading();
}

/// 列表加载成功状态
class KnowledgeBaseListLoaded extends KnowledgeBaseState {
  final List<KnowledgeBase> knowledgeBases;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  const KnowledgeBaseListLoaded({
    required this.knowledgeBases,
    this.hasMore = false,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [knowledgeBases, hasMore, currentPage, isLoadingMore];

  KnowledgeBaseListLoaded copyWith({
    List<KnowledgeBase>? knowledgeBases,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return KnowledgeBaseListLoaded(
      knowledgeBases: knowledgeBases ?? this.knowledgeBases,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// 知识库详情加载成功状态
class KnowledgeBaseDetailLoaded extends KnowledgeBaseState {
  final KnowledgeBase knowledgeBase;
  final Map<String, dynamic>? stats;

  const KnowledgeBaseDetailLoaded({
    required this.knowledgeBase,
    this.stats,
  });

  @override
  List<Object?> get props => [knowledgeBase, stats];

  KnowledgeBaseDetailLoaded copyWith({
    KnowledgeBase? knowledgeBase,
    Map<String, dynamic>? stats,
  }) {
    return KnowledgeBaseDetailLoaded(
      knowledgeBase: knowledgeBase ?? this.knowledgeBase,
      stats: stats ?? this.stats,
    );
  }
}

/// 创建成功状态
class KnowledgeBaseCreated extends KnowledgeBaseState {
  final KnowledgeBase knowledgeBase;
  final String message;

  const KnowledgeBaseCreated({
    required this.knowledgeBase,
    this.message = '知识库创建成功',
  });

  @override
  List<Object?> get props => [knowledgeBase, message];
}

/// 更新成功状态
class KnowledgeBaseUpdated extends KnowledgeBaseState {
  final KnowledgeBase knowledgeBase;
  final String message;

  const KnowledgeBaseUpdated({
    required this.knowledgeBase,
    this.message = '知识库更新成功',
  });

  @override
  List<Object?> get props => [knowledgeBase, message];
}

/// 创建/更新成功状态
class KnowledgeBaseOperationSuccess extends KnowledgeBaseState {
  final KnowledgeBase knowledgeBase;
  final String message;

  const KnowledgeBaseOperationSuccess({
    required this.knowledgeBase,
    required this.message,
  });

  @override
  List<Object?> get props => [knowledgeBase, message];
}

/// 删除成功状态
class KnowledgeBaseDeleteSuccess extends KnowledgeBaseState {
  final String message;

  const KnowledgeBaseDeleteSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// 知识库已删除状态（用于详情页）
class KnowledgeBaseDeleted extends KnowledgeBaseState {
  const KnowledgeBaseDeleted();
}

/// 分享成功状态
class KnowledgeBaseShareSuccess extends KnowledgeBaseState {
  final String shareUrl;
  final String message;

  const KnowledgeBaseShareSuccess({
    required this.shareUrl,
    required this.message,
  });

  @override
  List<Object?> get props => [shareUrl, message];
}

/// 导出成功状态
class KnowledgeBaseExportSuccess extends KnowledgeBaseState {
  final String downloadUrl;
  final String message;

  const KnowledgeBaseExportSuccess({
    required this.downloadUrl,
    required this.message,
  });

  @override
  List<Object?> get props => [downloadUrl, message];
}

/// 导入成功状态
class KnowledgeBaseImportSuccess extends KnowledgeBaseState {
  final String? message;

  const KnowledgeBaseImportSuccess({this.message});

  @override
  List<Object?> get props => [message];
}

/// 统计信息加载成功状态
class KnowledgeBaseStatsLoaded extends KnowledgeBaseState {
  final Map<String, dynamic> stats;

  const KnowledgeBaseStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

/// 标签加载成功状态
class KnowledgeBaseTagsLoaded extends KnowledgeBaseState {
  final List<String> tags;

  const KnowledgeBaseTagsLoaded(this.tags);

  @override
  List<Object?> get props => [tags];
}

/// 搜索结果状态
class KnowledgeBaseSearchLoaded extends KnowledgeBaseState {
  final List<KnowledgeBase> searchResults;
  final String query;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  const KnowledgeBaseSearchLoaded({
    required this.searchResults,
    required this.query,
    this.hasMore = false,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [searchResults, query, hasMore, currentPage, isLoadingMore];

  KnowledgeBaseSearchLoaded copyWith({
    List<KnowledgeBase>? searchResults,
    String? query,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return KnowledgeBaseSearchLoaded(
      searchResults: searchResults ?? this.searchResults,
      query: query ?? this.query,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// 批量操作成功状态
class KnowledgeBaseBatchOperationSuccess extends KnowledgeBaseState {
  final List<KnowledgeBase>? updatedKnowledgeBases;
  final String message;

  const KnowledgeBaseBatchOperationSuccess({
    this.updatedKnowledgeBases,
    required this.message,
  });

  @override
  List<Object?> get props => [updatedKnowledgeBases, message];
}

/// 错误状态
class KnowledgeBaseError extends KnowledgeBaseState {
  final String message;
  final String? errorCode;

  const KnowledgeBaseError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// 网络错误状态
class KnowledgeBaseNetworkError extends KnowledgeBaseState {
  final String message;

  const KnowledgeBaseNetworkError(this.message);

  @override
  List<Object?> get props => [message];
}

/// 认证错误状态
class KnowledgeBaseAuthError extends KnowledgeBaseState {
  final String message;

  const KnowledgeBaseAuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// 验证错误状态
class KnowledgeBaseValidationError extends KnowledgeBaseState {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  const KnowledgeBaseValidationError({
    required this.message,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, fieldErrors];
}

/// 空状态
class KnowledgeBaseEmpty extends KnowledgeBaseState {
  final String message;

  const KnowledgeBaseEmpty(this.message);

  @override
  List<Object?> get props => [message];
} 