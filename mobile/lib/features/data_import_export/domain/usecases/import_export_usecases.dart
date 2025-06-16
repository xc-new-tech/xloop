import 'dart:io';
import '../entities/import_export_entity.dart';
import '../repositories/import_export_repository.dart';

/// 获取导入导出任务列表用例
class GetImportExportTasksUseCase {
  final ImportExportRepository repository;

  GetImportExportTasksUseCase(this.repository);

  Future<List<ImportExportTask>> call() async {
    return await repository.getTasks();
  }
}

/// 创建FAQ导出任务用例
class ExportFaqsUseCase {
  final ImportExportRepository repository;

  ExportFaqsUseCase(this.repository);

  Future<ImportExportTask> call({
    required String knowledgeBaseId,
    required ExportFormat format,
    List<String>? selectedFaqIds,
  }) async {
    return await repository.exportFaqs(
      knowledgeBaseId: knowledgeBaseId,
      format: format,
      selectedFaqIds: selectedFaqIds,
    );
  }
}

/// 导入FAQ用例
class ImportFaqsUseCase {
  final ImportExportRepository repository;

  ImportFaqsUseCase(this.repository);

  Future<ImportExportTask> call({
    required File file,
    required String knowledgeBaseId,
    bool skipValidation = false,
  }) async {
    return await repository.importFaqs(
      file: file,
      knowledgeBaseId: knowledgeBaseId,
      skipValidation: skipValidation,
    );
  }
}

/// 验证导入文件用例
class ValidateImportFileUseCase {
  final ImportExportRepository repository;

  ValidateImportFileUseCase(this.repository);

  Future<ImportValidationResult> call({
    required File file,
    required DataType dataType,
  }) async {
    return await repository.validateImportFile(
      file: file,
      dataType: dataType,
    );
  }
}

/// 导出知识库用例
class ExportKnowledgeBaseUseCase {
  final ImportExportRepository repository;

  ExportKnowledgeBaseUseCase(this.repository);

  Future<ImportExportTask> call({
    required String knowledgeBaseId,
    required ExportFormat format,
    required KnowledgeBaseExportConfig config,
  }) async {
    return await repository.exportKnowledgeBase(
      knowledgeBaseId: knowledgeBaseId,
      format: format,
      config: config,
    );
  }
}

/// 导出文档用例
class ExportDocumentsUseCase {
  final ImportExportRepository repository;

  ExportDocumentsUseCase(this.repository);

  Future<ImportExportTask> call({
    required String knowledgeBaseId,
    required ExportFormat format,
    List<String>? selectedDocumentIds,
  }) async {
    return await repository.exportDocuments(
      knowledgeBaseId: knowledgeBaseId,
      format: format,
      selectedDocumentIds: selectedDocumentIds,
    );
  }
}

/// 导出对话记录用例
class ExportConversationsUseCase {
  final ImportExportRepository repository;

  ExportConversationsUseCase(this.repository);

  Future<ImportExportTask> call({
    required ExportFormat format,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? selectedConversationIds,
  }) async {
    return await repository.exportConversations(
      format: format,
      startDate: startDate,
      endDate: endDate,
      selectedConversationIds: selectedConversationIds,
    );
  }
}

/// 创建数据备份用例
class CreateBackupUseCase {
  final ImportExportRepository repository;

  CreateBackupUseCase(this.repository);

  Future<ImportExportTask> call({
    required String name,
    List<DataType>? dataTypes,
  }) async {
    return await repository.createBackup(
      name: name,
      dataTypes: dataTypes,
    );
  }
}

/// 恢复数据备份用例
class RestoreBackupUseCase {
  final ImportExportRepository repository;

  RestoreBackupUseCase(this.repository);

  Future<ImportExportTask> call({
    required File backupFile,
  }) async {
    return await repository.restoreBackup(
      backupFile: backupFile,
    );
  }
}

/// 开始任务用例
class StartTaskUseCase {
  final ImportExportRepository repository;

  StartTaskUseCase(this.repository);

  Future<void> call(String taskId) async {
    return await repository.startTask(taskId);
  }
}

/// 取消任务用例
class CancelTaskUseCase {
  final ImportExportRepository repository;

  CancelTaskUseCase(this.repository);

  Future<void> call(String taskId) async {
    return await repository.cancelTask(taskId);
  }
}

/// 删除任务用例
class DeleteTaskUseCase {
  final ImportExportRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<void> call(String taskId) async {
    return await repository.deleteTask(taskId);
  }
}

/// 获取任务进度用例
class GetTaskProgressUseCase {
  final ImportExportRepository repository;

  GetTaskProgressUseCase(this.repository);

  Stream<ImportExportTask> call(String taskId) {
    return repository.getTaskProgress(taskId);
  }
}

/// 分享导出文件用例
class ShareExportFileUseCase {
  final ImportExportRepository repository;

  ShareExportFileUseCase(this.repository);

  Future<void> call(String taskId) async {
    return await repository.shareExportFile(taskId);
  }
}

/// 获取导出文件用例
class GetExportFileUseCase {
  final ImportExportRepository repository;

  GetExportFileUseCase(this.repository);

  Future<File?> call(String taskId) async {
    return await repository.getExportFile(taskId);
  }
} 