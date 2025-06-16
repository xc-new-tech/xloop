import 'package:equatable/equatable.dart';

/// 导入导出任务状态
enum ImportExportStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled,
}

/// 导入导出数据类型
enum DataType {
  faq,
  knowledgeBase,
  documents,
  conversations,
  userSettings,
}

/// 导入导出格式
enum ExportFormat {
  csv,
  excel,
  json,
  pdf,
  zip,
}

/// 导入导出任务实体
class ImportExportTask extends Equatable {
  final String id;
  final String name;
  final DataType dataType;
  final ExportFormat format;
  final ImportExportStatus status;
  final String? filePath;
  final int totalItems;
  final int processedItems;
  final double progress;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  const ImportExportTask({
    required this.id,
    required this.name,
    required this.dataType,
    required this.format,
    required this.status,
    this.filePath,
    this.totalItems = 0,
    this.processedItems = 0,
    this.progress = 0.0,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
    this.metadata,
  });

  ImportExportTask copyWith({
    String? id,
    String? name,
    DataType? dataType,
    ExportFormat? format,
    ImportExportStatus? status,
    String? filePath,
    int? totalItems,
    int? processedItems,
    double? progress,
    DateTime? createdAt,
    DateTime? completedAt,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return ImportExportTask(
      id: id ?? this.id,
      name: name ?? this.name,
      dataType: dataType ?? this.dataType,
      format: format ?? this.format,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      totalItems: totalItems ?? this.totalItems,
      processedItems: processedItems ?? this.processedItems,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        dataType,
        format,
        status,
        filePath,
        totalItems,
        processedItems,
        progress,
        createdAt,
        completedAt,
        errorMessage,
        metadata,
      ];
}

/// FAQ导入数据实体
class FaqImportData extends Equatable {
  final String question;
  final String answer;
  final String? category;
  final List<String> tags;
  final int priority;
  final bool isActive;

  const FaqImportData({
    required this.question,
    required this.answer,
    this.category,
    this.tags = const [],
    this.priority = 1,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        question,
        answer,
        category,
        tags,
        priority,
        isActive,
      ];
}

/// 知识库导出配置
class KnowledgeBaseExportConfig extends Equatable {
  final String knowledgeBaseId;
  final bool includeDocuments;
  final bool includeFaqs;
  final bool includeMetadata;
  final bool includeStatistics;
  final List<String>? selectedDocumentIds;
  final List<String>? selectedFaqIds;

  const KnowledgeBaseExportConfig({
    required this.knowledgeBaseId,
    this.includeDocuments = true,
    this.includeFaqs = true,
    this.includeMetadata = true,
    this.includeStatistics = false,
    this.selectedDocumentIds,
    this.selectedFaqIds,
  });

  @override
  List<Object?> get props => [
        knowledgeBaseId,
        includeDocuments,
        includeFaqs,
        includeMetadata,
        includeStatistics,
        selectedDocumentIds,
        selectedFaqIds,
      ];
}

/// 导入验证结果
class ImportValidationResult extends Equatable {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final int validItemCount;
  final int invalidItemCount;
  final List<Map<String, dynamic>> validItems;
  final List<Map<String, dynamic>> invalidItems;

  const ImportValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    this.validItemCount = 0,
    this.invalidItemCount = 0,
    this.validItems = const [],
    this.invalidItems = const [],
  });

  @override
  List<Object?> get props => [
        isValid,
        errors,
        warnings,
        validItemCount,
        invalidItemCount,
        validItems,
        invalidItems,
      ];
} 