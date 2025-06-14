import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/search_result.dart';

part 'search_models.g.dart';

/// 文档搜索结果模型
@JsonSerializable()
class DocumentSearchResultModel extends DocumentSearchResult {
  const DocumentSearchResultModel({
    required super.id,
    required super.title,
    required super.content,
    required super.similarity,
    super.knowledgeBaseId,
    super.metadata,
    required super.timestamp,
    required super.fileName,
    super.documentId,
  });

  factory DocumentSearchResultModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentSearchResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentSearchResultModelToJson(this);

  /// 从API响应JSON创建模型
  factory DocumentSearchResultModel.fromApiJson(Map<String, dynamic> json) {
    return DocumentSearchResultModel(
      id: json['documentId'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      similarity: (json['similarity'] ?? 0.0).toDouble(),
      knowledgeBaseId: json['knowledgeBaseId'],
      metadata: json['metadata'] as Map<String, dynamic>?,
      timestamp: DateTime.now(),
      fileName: json['fileName'] ?? '',
      documentId: json['documentId'],
    );
  }

  /// 转换为实体
  DocumentSearchResult toEntity() {
    return DocumentSearchResult(
      id: id,
      title: title,
      content: content,
      similarity: similarity,
      knowledgeBaseId: knowledgeBaseId,
      metadata: metadata,
      timestamp: timestamp,
      fileName: fileName,
      documentId: documentId,
    );
  }
}

/// FAQ搜索结果模型
@JsonSerializable()
class FaqSearchResultModel extends FaqSearchResult {
  const FaqSearchResultModel({
    required super.id,
    required super.title,
    required super.content,
    required super.similarity,
    super.knowledgeBaseId,
    super.metadata,
    required super.timestamp,
    required super.question,
    required super.answer,
    required super.category,
    required super.tags,
    required super.priority,
    required super.status,
    super.faqId,
  });

  factory FaqSearchResultModel.fromJson(Map<String, dynamic> json) =>
      _$FaqSearchResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$FaqSearchResultModelToJson(this);

  /// 从API响应JSON创建模型
  factory FaqSearchResultModel.fromApiJson(Map<String, dynamic> json) {
    return FaqSearchResultModel(
      id: json['faqId'] ?? json['id'] ?? '',
      title: json['question'] ?? '',
      content: json['answer'] ?? '',
      similarity: (json['similarity'] ?? 0.0).toDouble(),
      knowledgeBaseId: json['knowledgeBaseId'],
      metadata: json['metadata'] as Map<String, dynamic>?,
      timestamp: DateTime.now(),
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'published',
      faqId: json['faqId'],
    );
  }

  /// 转换为实体
  FaqSearchResult toEntity() {
    return FaqSearchResult(
      id: id,
      title: title,
      content: content,
      similarity: similarity,
      knowledgeBaseId: knowledgeBaseId,
      metadata: metadata,
      timestamp: timestamp,
      question: question,
      answer: answer,
      category: category,
      tags: tags,
      priority: priority,
      status: status,
      faqId: faqId,
    );
  }
}

/// 混合搜索结果模型
@JsonSerializable()
class HybridSearchResultsModel extends HybridSearchResults {
  const HybridSearchResultsModel({
    required super.documents,
    required super.faqs,
    required super.mixed,
    required super.total,
    required super.query,
    required super.timestamp,
  });

  factory HybridSearchResultsModel.fromJson(Map<String, dynamic> json) =>
      _$HybridSearchResultsModelFromJson(json);

  Map<String, dynamic> toJson() => _$HybridSearchResultsModelToJson(this);

  /// 从API响应JSON创建模型
  factory HybridSearchResultsModel.fromApiJson(
    Map<String, dynamic> json,
    String query,
  ) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    // 解析文档结果
    final documentList = data['documents'] as List<dynamic>? ?? [];
    final documents = documentList
        .map((doc) => DocumentSearchResultModel.fromApiJson(doc))
        .toList();

    // 解析FAQ结果
    final faqList = data['faqs'] as List<dynamic>? ?? [];
    final faqs = faqList
        .map((faq) => FaqSearchResultModel.fromApiJson(faq))
        .toList();

    // 解析混合结果
    final mixedList = data['mixed'] as List<dynamic>? ?? [];
    final mixed = <SearchResult>[];
    
    for (final item in mixedList) {
      final type = item['type'] as String?;
      if (type == 'document') {
        mixed.add(DocumentSearchResultModel.fromApiJson(item));
      } else if (type == 'faq') {
        mixed.add(FaqSearchResultModel.fromApiJson(item));
      }
    }

    return HybridSearchResultsModel(
      documents: documents,
      faqs: faqs,
      mixed: mixed,
      total: data['total'] as int? ?? mixed.length,
      query: query,
      timestamp: DateTime.now(),
    );
  }

  /// 转换为实体
  HybridSearchResults toEntity() {
    return HybridSearchResults(
      documents: documents.map((doc) => doc.toEntity()).toList(),
      faqs: faqs.map((faq) => faq.toEntity()).toList(),
      mixed: mixed,
      total: total,
      query: query,
      timestamp: timestamp,
    );
  }
}

/// 搜索统计信息模型
@JsonSerializable()
class SearchStatsModel extends SearchStats {
  const SearchStatsModel({
    required super.documentVectors,
    required super.faqVectors,
    required super.cacheInfo,
    required super.timestamp,
  });

  factory SearchStatsModel.fromJson(Map<String, dynamic> json) =>
      _$SearchStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$SearchStatsModelToJson(this);

  /// 从API响应JSON创建模型
  factory SearchStatsModel.fromApiJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    return SearchStatsModel(
      documentVectors: data['documentVectors'] as int? ?? 0,
      faqVectors: data['faqVectors'] as int? ?? 0,
      cacheInfo: data['cacheInfo']?.toString() ?? '',
      timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  /// 转换为实体
  SearchStats toEntity() {
    return SearchStats(
      documentVectors: documentVectors,
      faqVectors: faqVectors,
      cacheInfo: cacheInfo,
      timestamp: timestamp,
    );
  }
}

/// API响应包装器
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? meta;
  final List<Map<String, dynamic>>? errors;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.meta,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  /// 是否成功且有数据
  bool get hasData => success && data != null;

  /// 是否有错误
  bool get hasErrors => !success || (errors?.isNotEmpty ?? false);

  /// 获取错误消息
  String get errorMessage {
    if (message?.isNotEmpty ?? false) return message!;
    if (errors?.isNotEmpty ?? false) {
      return errors!.first['message']?.toString() ?? '未知错误';
    }
    return '请求失败';
  }
}

/// 向量化请求模型
class VectorizeDocumentRequest {
  final String documentId;

  const VectorizeDocumentRequest({
    required this.documentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
    };
  }
}

/// FAQ向量化请求模型
class VectorizeFaqRequest {
  final String faqId;

  const VectorizeFaqRequest({
    required this.faqId,
  });

  Map<String, dynamic> toJson() {
    return {
      'faqId': faqId,
    };
  }
}

/// 批量向量化请求模型
class BatchVectorizeRequest {
  final List<String> documentIds;
  final List<String> faqIds;

  const BatchVectorizeRequest({
    this.documentIds = const [],
    this.faqIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'documentIds': documentIds,
      'faqIds': faqIds,
    };
  }
}

/// 批量向量化结果模型
@JsonSerializable()
class BatchVectorizeResultModel {
  final int successful;
  final int failed;
  final List<Map<String, dynamic>> results;
  final List<Map<String, dynamic>> errors;
  final DateTime timestamp;

  const BatchVectorizeResultModel({
    required this.successful,
    required this.failed,
    required this.results,
    required this.errors,
    required this.timestamp,
  });

  factory BatchVectorizeResultModel.fromJson(Map<String, dynamic> json) =>
      _$BatchVectorizeResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$BatchVectorizeResultModelToJson(this);

  /// 从API响应JSON创建模型
  factory BatchVectorizeResultModel.fromApiJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    return BatchVectorizeResultModel(
      successful: data['successful'] as int? ?? 0,
      failed: data['failed'] as int? ?? 0,
      results: List<Map<String, dynamic>>.from(data['results'] ?? []),
      errors: List<Map<String, dynamic>>.from(data['errors'] ?? []),
      timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  /// 转换为领域实体
  BatchVectorizeResult toEntity() {
    return BatchVectorizeResult(
      successful: successful,
      failed: failed,
      results: results,
      errors: errors,
      timestamp: timestamp,
    );
  }
}

/// 清理缓存请求模型
class ClearCacheRequest {
  final String? pattern;

  const ClearCacheRequest({
    this.pattern,
  });

  Map<String, dynamic> toJson() {
    return {
      if (pattern != null) 'pattern': pattern,
    };
  }
} 