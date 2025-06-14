import 'package:equatable/equatable.dart';

import '../../domain/entities/faq_entity.dart';

/// FAQ BLoC状态枚举
enum FaqBlocStatus {
  initial,
  loading,
  success,
  error,
  loadingMore,
  refreshing,
}

class FaqState extends Equatable {
  final FaqBlocStatus status;
  final List<FaqEntity> faqs;
  final List<FaqCategory> categories;
  final List<FaqEntity> popularFaqs;
  final FaqEntity? selectedFaq;
  final FaqFilter filter;
  final FaqSort sort;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;
  final int totalCount;
  final bool isSelectionMode;
  final Set<String> selectedIds;

  const FaqState({
    this.status = FaqBlocStatus.initial,
    this.faqs = const [],
    this.categories = const [],
    this.popularFaqs = const [],
    this.selectedFaq,
    this.filter = const FaqFilter(),
    this.sort = const FaqSort(),
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.totalCount = 0,
    this.isSelectionMode = false,
    this.selectedIds = const {},
  });

  FaqState copyWith({
    FaqBlocStatus? status,
    List<FaqEntity>? faqs,
    List<FaqCategory>? categories,
    List<FaqEntity>? popularFaqs,
    FaqEntity? selectedFaq,
    FaqFilter? filter,
    FaqSort? sort,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
    int? totalCount,
    bool? isSelectionMode,
    Set<String>? selectedIds,
    bool clearSelectedFaq = false,
    bool clearError = false,
  }) {
    return FaqState(
      status: status ?? this.status,
      faqs: faqs ?? this.faqs,
      categories: categories ?? this.categories,
      popularFaqs: popularFaqs ?? this.popularFaqs,
      selectedFaq: clearSelectedFaq ? null : (selectedFaq ?? this.selectedFaq),
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  /// 是否正在加载
  bool get isLoading => status == FaqBlocStatus.loading;

  /// 是否正在加载更多
  bool get isLoadingMore => status == FaqBlocStatus.loadingMore;

  /// 是否正在刷新
  bool get isRefreshing => status == FaqBlocStatus.refreshing;

  /// 是否正在提交
  bool get isSubmitting => status == FaqBlocStatus.loading;

  /// 是否有错误
  bool get hasError => status == FaqBlocStatus.error;

  /// 是否成功加载
  bool get isSuccess => status == FaqBlocStatus.success;

  /// 是否为初始状态
  bool get isInitial => status == FaqBlocStatus.initial;

  /// 是否有FAQ
  bool get hasFaqs => faqs.isNotEmpty;

  /// 是否有分类
  bool get hasCategories => categories.isNotEmpty;

  /// 是否有热门FAQ
  bool get hasPopularFaqs => popularFaqs.isNotEmpty;

  /// 是否有选中的FAQ
  bool get hasSelectedFaq => selectedFaq != null;

  /// 当前FAQ（详情页使用）
  FaqEntity? get currentFaq => selectedFaq;

  /// 是否有选中的项目
  bool get hasSelectedItems => selectedIds.isNotEmpty;

  /// 是否全部选中
  bool get isAllSelected => selectedIds.length == faqs.length && faqs.isNotEmpty;

  /// 是否还有更多数据
  bool get hasMore => !hasReachedMax;

  /// 获取选中的FAQ IDs
  Set<String> get selectedFaqIds => selectedIds;

  /// 获取选中的FAQ
  List<FaqEntity> get selectedFaqs {
    return faqs.where((faq) => selectedIds.contains(faq.id)).toList();
  }

  /// 获取已发布的FAQ
  List<FaqEntity> get publishedFaqs {
    return faqs.where((faq) => faq.status == FaqStatus.published).toList();
  }

  /// 获取草稿FAQ
  List<FaqEntity> get draftFaqs {
    return faqs.where((faq) => faq.status == FaqStatus.draft).toList();
  }

  /// 获取已归档的FAQ
  List<FaqEntity> get archivedFaqs {
    return faqs.where((faq) => faq.status == FaqStatus.archived).toList();
  }

  /// 根据ID查找FAQ
  FaqEntity? findFaqById(String id) {
    try {
      return faqs.firstWhere((faq) => faq.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取当前筛选的FAQ列表
  List<FaqEntity> get filteredFaqs {
    var filtered = faqs.toList();

    // 按搜索关键词筛选
    if (filter.search != null && filter.search!.isNotEmpty) {
      final keyword = filter.search!.toLowerCase();
      filtered = filtered.where((faq) => 
        faq.question.toLowerCase().contains(keyword) ||
        faq.answer.toLowerCase().contains(keyword) ||
        faq.tags.any((tag) => tag.toLowerCase().contains(keyword))
      ).toList();
    }

    // 按分类筛选
    if (filter.category != null && filter.category!.isNotEmpty) {
      filtered = filtered.where((faq) => faq.category == filter.category).toList();
    }

    // 按状态筛选
    if (filter.status != null) {
      filtered = filtered.where((faq) => faq.status == filter.status).toList();
    }

    // 按公开性筛选
    if (filter.isPublic != null) {
      filtered = filtered.where((faq) => faq.isPublic == filter.isPublic).toList();
    }

    // 按标签筛选
    if (filter.tags.isNotEmpty) {
      filtered = filtered.where((faq) => 
        filter.tags.every((tag) => faq.tags.contains(tag))
      ).toList();
    }

    // 按知识库筛选
    if (filter.knowledgeBaseId != null && filter.knowledgeBaseId!.isNotEmpty) {
      filtered = filtered.where((faq) => 
        faq.knowledgeBaseId == filter.knowledgeBaseId
      ).toList();
    }

    return filtered;
  }

  /// 获取公开FAQ数量
  int get publicCount {
    return faqs.where((faq) => faq.isPublic && faq.status == FaqStatus.published).length;
  }

  /// 获取草稿FAQ数量
  int get draftCount {
    return faqs.where((faq) => faq.status == FaqStatus.draft).length;
  }

  /// 获取所有标签
  List<String> get tags {
    final Set<String> allTags = <String>{};
    for (final faq in faqs) {
      allTags.addAll(faq.tags);
    }
    return allTags.toList()..sort();
  }

  /// 获取统计信息
  Map<String, int> get statistics {
    return {
      'total': faqs.length,
      'published': publishedFaqs.length,
      'draft': draftFaqs.length,
      'archived': archivedFaqs.length,
      'selected': selectedIds.length,
      'public': publicCount,
    };
  }

  @override
  List<Object?> get props => [
        status,
        faqs,
        categories,
        popularFaqs,
        selectedFaq,
        filter,
        sort,
        errorMessage,
        hasReachedMax,
        currentPage,
        totalCount,
        isSelectionMode,
        selectedIds,
      ];
} 