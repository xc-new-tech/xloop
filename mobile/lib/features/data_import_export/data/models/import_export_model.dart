import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/import_export_entity.dart';

part 'import_export_model.g.dart';

@JsonSerializable()
class ImportExportTaskModel extends ImportExportTask {
  const ImportExportTaskModel({
    required super.id,
    required super.name,
    required super.dataType,
    required super.format,
    required super.status,
    super.filePath,
    super.totalItems,
    super.processedItems,
    super.progress,
    required super.createdAt,
    super.completedAt,
    super.errorMessage,
    super.metadata,
  });

  factory ImportExportTaskModel.fromJson(Map<String, dynamic> json) =>
      _$ImportExportTaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImportExportTaskModelToJson(this);

  factory ImportExportTaskModel.fromEntity(ImportExportTask entity) {
    return ImportExportTaskModel(
      id: entity.id,
      name: entity.name,
      dataType: entity.dataType,
      format: entity.format,
      status: entity.status,
      filePath: entity.filePath,
      totalItems: entity.totalItems,
      processedItems: entity.processedItems,
      progress: entity.progress,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
      errorMessage: entity.errorMessage,
      metadata: entity.metadata,
    );
  }

  ImportExportTask toEntity() {
    return ImportExportTask(
      id: id,
      name: name,
      dataType: dataType,
      format: format,
      status: status,
      filePath: filePath,
      totalItems: totalItems,
      processedItems: processedItems,
      progress: progress,
      createdAt: createdAt,
      completedAt: completedAt,
      errorMessage: errorMessage,
      metadata: metadata,
    );
  }
}

@JsonSerializable()
class FaqImportDataModel extends FaqImportData {
  const FaqImportDataModel({
    required super.question,
    required super.answer,
    super.category,
    super.tags,
    super.priority,
    super.isActive,
  });

  factory FaqImportDataModel.fromJson(Map<String, dynamic> json) =>
      _$FaqImportDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$FaqImportDataModelToJson(this);

  factory FaqImportDataModel.fromEntity(FaqImportData entity) {
    return FaqImportDataModel(
      question: entity.question,
      answer: entity.answer,
      category: entity.category,
      tags: entity.tags,
      priority: entity.priority,
      isActive: entity.isActive,
    );
  }

  FaqImportData toEntity() {
    return FaqImportData(
      question: question,
      answer: answer,
      category: category,
      tags: tags,
      priority: priority,
      isActive: isActive,
    );
  }
}

@JsonSerializable()
class KnowledgeBaseExportConfigModel extends KnowledgeBaseExportConfig {
  const KnowledgeBaseExportConfigModel({
    required super.knowledgeBaseId,
    super.includeDocuments,
    super.includeFaqs,
    super.includeMetadata,
    super.includeStatistics,
    super.selectedDocumentIds,
    super.selectedFaqIds,
  });

  factory KnowledgeBaseExportConfigModel.fromJson(Map<String, dynamic> json) =>
      _$KnowledgeBaseExportConfigModelFromJson(json);

  Map<String, dynamic> toJson() => _$KnowledgeBaseExportConfigModelToJson(this);

  factory KnowledgeBaseExportConfigModel.fromEntity(
      KnowledgeBaseExportConfig entity) {
    return KnowledgeBaseExportConfigModel(
      knowledgeBaseId: entity.knowledgeBaseId,
      includeDocuments: entity.includeDocuments,
      includeFaqs: entity.includeFaqs,
      includeMetadata: entity.includeMetadata,
      includeStatistics: entity.includeStatistics,
      selectedDocumentIds: entity.selectedDocumentIds,
      selectedFaqIds: entity.selectedFaqIds,
    );
  }

  KnowledgeBaseExportConfig toEntity() {
    return KnowledgeBaseExportConfig(
      knowledgeBaseId: knowledgeBaseId,
      includeDocuments: includeDocuments,
      includeFaqs: includeFaqs,
      includeMetadata: includeMetadata,
      includeStatistics: includeStatistics,
      selectedDocumentIds: selectedDocumentIds,
      selectedFaqIds: selectedFaqIds,
    );
  }
}

@JsonSerializable()
class ImportValidationResultModel extends ImportValidationResult {
  const ImportValidationResultModel({
    required super.isValid,
    super.errors,
    super.warnings,
    super.validItemCount,
    super.invalidItemCount,
    super.validItems,
    super.invalidItems,
  });

  factory ImportValidationResultModel.fromJson(Map<String, dynamic> json) =>
      _$ImportValidationResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImportValidationResultModelToJson(this);

  factory ImportValidationResultModel.fromEntity(
      ImportValidationResult entity) {
    return ImportValidationResultModel(
      isValid: entity.isValid,
      errors: entity.errors,
      warnings: entity.warnings,
      validItemCount: entity.validItemCount,
      invalidItemCount: entity.invalidItemCount,
      validItems: entity.validItems,
      invalidItems: entity.invalidItems,
    );
  }

  ImportValidationResult toEntity() {
    return ImportValidationResult(
      isValid: isValid,
      errors: errors,
      warnings: warnings,
      validItemCount: validItemCount,
      invalidItemCount: invalidItemCount,
      validItems: validItems,
      invalidItems: invalidItems,
    );
  }
} 