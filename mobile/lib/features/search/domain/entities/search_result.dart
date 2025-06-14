import 'package:equatable/equatable.dart';

/// 搜索结果类型枚举
enum SearchResultType {
  /// 文档类型
  document,
  /// FAQ类型
  faq,
  /// 混合类型（包含文档和FAQ）
  mixed,
}

/// 抽象搜索结果基类
abstract class SearchResult extends Equatable {
  final String id;
  final String title;
  final String content;
  final double score;
  final SearchResultType type;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SearchResult({
    required this.id,
    required this.title,
    required this.content,
    required this.score,
    required this.type,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        score,
        type,
        metadata,
        createdAt,
        updatedAt,
      ];
}

/// 文档搜索结果
class DocumentSearchResult extends SearchResult {
  final String knowledgeBaseId;
  final String? knowledgeBaseName;
  final String fileName;
  final String filePath;
  final String fileType;
  final int fileSize;
  final String? category;
  final List<String> tags;
  final String? description;

  const DocumentSearchResult({
    required super.id,
    required super.title,
    required super.content,
    required super.score,
    required this.knowledgeBaseId,
    this.knowledgeBaseName,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    this.category,
    this.tags = const [],
    this.description,
    super.metadata,
    super.createdAt,
    super.updatedAt,
  }) : super(type: SearchResultType.document);

  @override
  List<Object?> get props => [
        ...super.props,
        knowledgeBaseId,
        knowledgeBaseName,
        fileName,
        filePath,
        fileType,
        fileSize,
        category,
        tags,
        description,
      ];

  DocumentSearchResult copyWith({
    String? id,
    String? title,
    String? content,
    double? score,
    String? knowledgeBaseId,
    String? knowledgeBaseName,
    String? fileName,
    String? filePath,
    String? fileType,
    int? fileSize,
    String? category,
    List<String>? tags,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentSearchResult(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      score: score ?? this.score,
      knowledgeBaseId: knowledgeBaseId ?? this.knowledgeBaseId,
      knowledgeBaseName: knowledgeBaseName ?? this.knowledgeBaseName,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 获取文件大小的可读格式
  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// 获取文件扩展名
  String get fileExtension {
    return filePath.split('.').last.toLowerCase();
  }
}

/// FAQ搜索结果
class FaqSearchResult extends SearchResult {
  final String question;
  final String answer;
  final String? knowledgeBaseId;
  final String? knowledgeBaseName;
  final String? category;
  final List<String> tags;
  final int likes;
  final int dislikes;
  final int views;
  final String? status;

  const FaqSearchResult({
    required super.id,
    required super.title,
    required super.content,
    required super.score,
    required this.question,
    required this.answer,
    this.knowledgeBaseId,
    this.knowledgeBaseName,
    this.category,
    this.tags = const [],
    this.likes = 0,
    this.dislikes = 0,
    this.views = 0,
    this.status,
    super.metadata,
    super.createdAt,
    super.updatedAt,
  }) : super(type: SearchResultType.faq);

  @override
  List<Object?> get props => [
        ...super.props,
        question,
        answer,
        knowledgeBaseId,
        knowledgeBaseName,
        category,
        tags,
        likes,
        dislikes,
        views,
        status,
      ];

  FaqSearchResult copyWith({
    String? id,
    String? title,
    String? content,
    double? score,
    String? question,
    String? answer,
    String? knowledgeBaseId,
    String? knowledgeBaseName,
    String? category,
    List<String>? tags,
    int? likes,
    int? dislikes,
    int? views,
    String? status,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FaqSearchResult(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      score: score ?? this.score,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      knowledgeBaseId: knowledgeBaseId ?? this.knowledgeBaseId,
      knowledgeBaseName: knowledgeBaseName ?? this.knowledgeBaseName,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      views: views ?? this.views,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 获取点赞率
  double get likeRatio {
    final total = likes + dislikes;
    return total > 0 ? likes / total : 0.0;
  }

  /// 是否有效（状态为active）
  bool get isActive => status == 'active';
}

/// 混合搜索结果
class HybridSearchResults extends Equatable {
  final List<DocumentSearchResult> documents;
  final List<FaqSearchResult> faqs;
  final List<SearchResult> mixed;
  final int total;
  final String query;
  final DateTime timestamp;
  final int? totalDocuments;
  final int? totalFaqs;

  const HybridSearchResults({
    required this.documents,
    required this.faqs,
    this.mixed = const [],
    required this.total,
    required this.query,
    required this.timestamp,
    this.totalDocuments,
    this.totalFaqs,
  });

  @override
  List<Object?> get props => [
        documents,
        faqs,
        mixed,
        total,
        query,
        timestamp,
        totalDocuments,
        totalFaqs,
      ];

  HybridSearchResults copyWith({
    List<DocumentSearchResult>? documents,
    List<FaqSearchResult>? faqs,
    List<SearchResult>? mixed,
    int? total,
    String? query,
    DateTime? timestamp,
    int? totalDocuments,
    int? totalFaqs,
  }) {
    return HybridSearchResults(
      documents: documents ?? this.documents,
      faqs: faqs ?? this.faqs,
      mixed: mixed ?? this.mixed,
      total: total ?? this.total,
      query: query ?? this.query,
      timestamp: timestamp ?? this.timestamp,
      totalDocuments: totalDocuments ?? this.totalDocuments,
      totalFaqs: totalFaqs ?? this.totalFaqs,
    );
  }

  /// 是否为空结果
  bool get isEmpty => documents.isEmpty && faqs.isEmpty && mixed.isEmpty;

  /// 是否有结果
  bool get hasResults => !isEmpty;

  /// 获取所有结果数量
  int get totalResults => documents.length + faqs.length;
}

/// 搜索选项
class SearchOptions extends Equatable {
  final SearchResultType type;
  final int? limit;
  final int? offset;
  final double? minScore;
  final String? knowledgeBaseId;
  final String? category;
  final bool? includeMetadata;

  const SearchOptions({
    this.type = SearchResultType.mixed,
    this.limit,
    this.offset,
    this.minScore,
    this.knowledgeBaseId,
    this.category,
    this.includeMetadata,
  });

  @override
  List<Object?> get props => [
        type,
        limit,
        offset,
        minScore,
        knowledgeBaseId,
        category,
        includeMetadata,
      ];

  SearchOptions copyWith({
    SearchResultType? type,
    int? limit,
    int? offset,
    double? minScore,
    String? knowledgeBaseId,
    String? category,
    bool? includeMetadata,
  }) {
    return SearchOptions(
      type: type ?? this.type,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      minScore: minScore ?? this.minScore,
      knowledgeBaseId: knowledgeBaseId ?? this.knowledgeBaseId,
      category: category ?? this.category,
      includeMetadata: includeMetadata ?? this.includeMetadata,
    );
  }

  /// 转换为查询参数
  Map<String, String> toQueryParameters() {
    final params = <String, String>{};

    if (limit != null) {
      params['limit'] = limit.toString();
    }
    if (offset != null) {
      params['offset'] = offset.toString();
    }
    if (minScore != null) {
      params['minScore'] = minScore.toString();
    }
    if (includeMetadata != null) {
      params['includeMetadata'] = includeMetadata.toString();
    }
    if (knowledgeBaseId != null) {
      params['knowledgeBaseId'] = knowledgeBaseId!;
    }
    if (category != null) {
      params['category'] = category!;
    }

    switch (type) {
      case SearchResultType.document:
        params['type'] = 'documents';
        break;
      case SearchResultType.faq:
        params['type'] = 'faqs';
        break;
      case SearchResultType.mixed:
        params['type'] = 'hybrid';
        break;
    }

    return params;
  }
}

/// 推荐选项
class RecommendationOptions extends Equatable {
  final int? limit;
  final String? userId;
  final String? knowledgeBaseId;
  final String? category;
  final bool? excludeRecent;

  const RecommendationOptions({
    this.limit,
    this.userId,
    this.knowledgeBaseId,
    this.category,
    this.excludeRecent,
  });

  @override
  List<Object?> get props => [
        limit,
        userId,
        knowledgeBaseId,
        category,
        excludeRecent,
      ];

  RecommendationOptions copyWith({
    int? limit,
    String? userId,
    String? knowledgeBaseId,
    String? category,
    bool? excludeRecent,
  }) {
    return RecommendationOptions(
      limit: limit ?? this.limit,
      userId: userId ?? this.userId,
      knowledgeBaseId: knowledgeBaseId ?? this.knowledgeBaseId,
      category: category ?? this.category,
      excludeRecent: excludeRecent ?? this.excludeRecent,
    );
  }

  /// 转换为查询参数
  Map<String, String> toQueryParameters() {
    final params = <String, String>{};

    if (limit != null) {
      params['limit'] = limit.toString();
    }
    if (userId != null) {
      params['userId'] = userId!;
    }
    if (knowledgeBaseId != null) {
      params['knowledgeBaseId'] = knowledgeBaseId!;
    }
    if (category != null) {
      params['category'] = category!;
    }
    if (excludeRecent != null) {
      params['excludeRecent'] = excludeRecent.toString();
    }

    return params;
  }
}

/// 搜索统计信息
class SearchStats extends Equatable {
  final int documentVectors;
  final int faqVectors;
  final String cacheInfo;
  final DateTime timestamp;

  const SearchStats({
    required this.documentVectors,
    required this.faqVectors,
    required this.cacheInfo,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        documentVectors,
        faqVectors,
        cacheInfo,
        timestamp,
      ];

  SearchStats copyWith({
    int? documentVectors,
    int? faqVectors,
    String? cacheInfo,
    DateTime? timestamp,
  }) {
    return SearchStats(
      documentVectors: documentVectors ?? this.documentVectors,
      faqVectors: faqVectors ?? this.faqVectors,
      cacheInfo: cacheInfo ?? this.cacheInfo,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// 总向量数量
  int get totalVectors => documentVectors + faqVectors;

  /// 是否有数据
  bool get hasData => totalVectors > 0;
}

/// 批量向量化结果
class BatchVectorizeResult extends Equatable {
  final int successful;
  final int failed;
  final List<Map<String, dynamic>> results;
  final List<Map<String, dynamic>> errors;
  final DateTime timestamp;

  const BatchVectorizeResult({
    required this.successful,
    required this.failed,
    required this.results,
    required this.errors,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        successful,
        failed,
        results,
        errors,
        timestamp,
      ];

  /// 检查是否有错误
  bool get hasErrors => failed > 0 || errors.isNotEmpty;

  /// 检查是否所有项目都成功
  bool get isAllSuccessful => failed == 0 && errors.isEmpty;

  /// 获取成功率
  double get successRate {
    final total = successful + failed;
    return total > 0 ? successful / total : 0.0;
  }

  /// 获取总处理数
  int get totalProcessed => successful + failed;

  BatchVectorizeResult copyWith({
    int? successful,
    int? failed,
    List<Map<String, dynamic>>? results,
    List<Map<String, dynamic>>? errors,
    DateTime? timestamp,
  }) {
    return BatchVectorizeResult(
      successful: successful ?? this.successful,
      failed: failed ?? this.failed,
      results: results ?? this.results,
      errors: errors ?? this.errors,
      timestamp: timestamp ?? this.timestamp,
    );
  }
} 