// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentSearchResultModel _$DocumentSearchResultModelFromJson(
        Map<String, dynamic> json) =>
    DocumentSearchResultModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      score: (json['score'] as num).toDouble(),
      knowledgeBaseId: json['knowledgeBaseId'] as String,
      knowledgeBaseName: json['knowledgeBaseName'] as String?,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      fileType: json['fileType'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      category: json['category'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DocumentSearchResultModelToJson(
        DocumentSearchResultModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'score': instance.score,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'knowledgeBaseId': instance.knowledgeBaseId,
      'knowledgeBaseName': instance.knowledgeBaseName,
      'fileName': instance.fileName,
      'filePath': instance.filePath,
      'fileType': instance.fileType,
      'fileSize': instance.fileSize,
      'category': instance.category,
      'tags': instance.tags,
      'description': instance.description,
    };

FaqSearchResultModel _$FaqSearchResultModelFromJson(
        Map<String, dynamic> json) =>
    FaqSearchResultModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      score: (json['score'] as num).toDouble(),
      question: json['question'] as String,
      answer: json['answer'] as String,
      knowledgeBaseId: json['knowledgeBaseId'] as String?,
      knowledgeBaseName: json['knowledgeBaseName'] as String?,
      category: json['category'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      dislikes: (json['dislikes'] as num?)?.toInt() ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
      status: json['status'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FaqSearchResultModelToJson(
        FaqSearchResultModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'score': instance.score,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'question': instance.question,
      'answer': instance.answer,
      'knowledgeBaseId': instance.knowledgeBaseId,
      'knowledgeBaseName': instance.knowledgeBaseName,
      'category': instance.category,
      'tags': instance.tags,
      'likes': instance.likes,
      'dislikes': instance.dislikes,
      'views': instance.views,
      'status': instance.status,
    };

HybridSearchResultsModel _$HybridSearchResultsModelFromJson(
        Map<String, dynamic> json) =>
    HybridSearchResultsModel(
      documents: (json['documents'] as List<dynamic>)
          .map((e) =>
              DocumentSearchResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      faqs: (json['faqs'] as List<dynamic>)
          .map((e) => FaqSearchResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      mixed: json['mixed'] == null
          ? const []
          : HybridSearchResultsModel._mixedFromJson(json['mixed'] as List),
      total: (json['total'] as num).toInt(),
      query: json['query'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$HybridSearchResultsModelToJson(
        HybridSearchResultsModel instance) =>
    <String, dynamic>{
      'total': instance.total,
      'query': instance.query,
      'timestamp': instance.timestamp.toIso8601String(),
      'documents': instance.documents,
      'faqs': instance.faqs,
      'mixed': HybridSearchResultsModel._mixedToJson(instance.mixed),
    };

SearchStatsModel _$SearchStatsModelFromJson(Map<String, dynamic> json) =>
    SearchStatsModel(
      documentVectors: (json['documentVectors'] as num).toInt(),
      faqVectors: (json['faqVectors'] as num).toInt(),
      cacheInfo: json['cacheInfo'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$SearchStatsModelToJson(SearchStatsModel instance) =>
    <String, dynamic>{
      'documentVectors': instance.documentVectors,
      'faqVectors': instance.faqVectors,
      'cacheInfo': instance.cacheInfo,
      'timestamp': instance.timestamp.toIso8601String(),
    };

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
      meta: json['meta'] as Map<String, dynamic>?,
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$ApiResponseToJson<T>(
  ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': _$nullableGenericToJson(instance.data, toJsonT),
      'meta': instance.meta,
      'errors': instance.errors,
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);

BatchVectorizeResultModel _$BatchVectorizeResultModelFromJson(
        Map<String, dynamic> json) =>
    BatchVectorizeResultModel(
      successful: (json['successful'] as num).toInt(),
      failed: (json['failed'] as num).toInt(),
      results: (json['results'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      errors: (json['errors'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$BatchVectorizeResultModelToJson(
        BatchVectorizeResultModel instance) =>
    <String, dynamic>{
      'successful': instance.successful,
      'failed': instance.failed,
      'results': instance.results,
      'errors': instance.errors,
      'timestamp': instance.timestamp.toIso8601String(),
    };
