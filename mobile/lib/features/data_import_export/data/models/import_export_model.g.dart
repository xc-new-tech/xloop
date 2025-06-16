// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_export_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportExportTaskModel _$ImportExportTaskModelFromJson(
        Map<String, dynamic> json) =>
    ImportExportTaskModel(
      id: json['id'] as String,
      name: json['name'] as String,
      dataType: $enumDecode(_$DataTypeEnumMap, json['dataType']),
      format: $enumDecode(_$ExportFormatEnumMap, json['format']),
      status: $enumDecode(_$ImportExportStatusEnumMap, json['status']),
      filePath: json['filePath'] as String?,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      processedItems: (json['processedItems'] as num?)?.toInt() ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      errorMessage: json['errorMessage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ImportExportTaskModelToJson(
        ImportExportTaskModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'dataType': _$DataTypeEnumMap[instance.dataType]!,
      'format': _$ExportFormatEnumMap[instance.format]!,
      'status': _$ImportExportStatusEnumMap[instance.status]!,
      'filePath': instance.filePath,
      'totalItems': instance.totalItems,
      'processedItems': instance.processedItems,
      'progress': instance.progress,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'errorMessage': instance.errorMessage,
      'metadata': instance.metadata,
    };

const _$DataTypeEnumMap = {
  DataType.faq: 'faq',
  DataType.knowledgeBase: 'knowledgeBase',
  DataType.documents: 'documents',
  DataType.conversations: 'conversations',
  DataType.userSettings: 'userSettings',
};

const _$ExportFormatEnumMap = {
  ExportFormat.csv: 'csv',
  ExportFormat.excel: 'excel',
  ExportFormat.json: 'json',
  ExportFormat.pdf: 'pdf',
  ExportFormat.zip: 'zip',
};

const _$ImportExportStatusEnumMap = {
  ImportExportStatus.pending: 'pending',
  ImportExportStatus.inProgress: 'inProgress',
  ImportExportStatus.completed: 'completed',
  ImportExportStatus.failed: 'failed',
  ImportExportStatus.cancelled: 'cancelled',
};

FaqImportDataModel _$FaqImportDataModelFromJson(Map<String, dynamic> json) =>
    FaqImportDataModel(
      question: json['question'] as String,
      answer: json['answer'] as String,
      category: json['category'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      priority: (json['priority'] as num?)?.toInt() ?? 1,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$FaqImportDataModelToJson(FaqImportDataModel instance) =>
    <String, dynamic>{
      'question': instance.question,
      'answer': instance.answer,
      'category': instance.category,
      'tags': instance.tags,
      'priority': instance.priority,
      'isActive': instance.isActive,
    };

KnowledgeBaseExportConfigModel _$KnowledgeBaseExportConfigModelFromJson(
        Map<String, dynamic> json) =>
    KnowledgeBaseExportConfigModel(
      knowledgeBaseId: json['knowledgeBaseId'] as String,
      includeDocuments: json['includeDocuments'] as bool? ?? true,
      includeFaqs: json['includeFaqs'] as bool? ?? true,
      includeMetadata: json['includeMetadata'] as bool? ?? true,
      includeStatistics: json['includeStatistics'] as bool? ?? false,
      selectedDocumentIds: (json['selectedDocumentIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      selectedFaqIds: (json['selectedFaqIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$KnowledgeBaseExportConfigModelToJson(
        KnowledgeBaseExportConfigModel instance) =>
    <String, dynamic>{
      'knowledgeBaseId': instance.knowledgeBaseId,
      'includeDocuments': instance.includeDocuments,
      'includeFaqs': instance.includeFaqs,
      'includeMetadata': instance.includeMetadata,
      'includeStatistics': instance.includeStatistics,
      'selectedDocumentIds': instance.selectedDocumentIds,
      'selectedFaqIds': instance.selectedFaqIds,
    };

ImportValidationResultModel _$ImportValidationResultModelFromJson(
        Map<String, dynamic> json) =>
    ImportValidationResultModel(
      isValid: json['isValid'] as bool,
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      validItemCount: (json['validItemCount'] as num?)?.toInt() ?? 0,
      invalidItemCount: (json['invalidItemCount'] as num?)?.toInt() ?? 0,
      validItems: (json['validItems'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      invalidItems: (json['invalidItems'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ImportValidationResultModelToJson(
        ImportValidationResultModel instance) =>
    <String, dynamic>{
      'isValid': instance.isValid,
      'errors': instance.errors,
      'warnings': instance.warnings,
      'validItemCount': instance.validItemCount,
      'invalidItemCount': instance.invalidItemCount,
      'validItems': instance.validItems,
      'invalidItems': instance.invalidItems,
    };
