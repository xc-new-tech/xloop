import 'dart:io';
import '../entities/import_export_entity.dart';

abstract class ImportExportRepository {
  /// 获取导入导出任务列表
  Future<List<ImportExportTask>> getTasks();

  /// 获取特定任务详情
  Future<ImportExportTask?> getTask(String taskId);

  /// 创建导出任务
  Future<ImportExportTask> createExportTask({
    required String name,
    required DataType dataType,
    required ExportFormat format,
    Map<String, dynamic>? config,
  });

  /// 创建导入任务
  Future<ImportExportTask> createImportTask({
    required String name,
    required DataType dataType,
    required File file,
    Map<String, dynamic>? config,
  });

  /// 开始执行任务
  Future<void> startTask(String taskId);

  /// 取消任务
  Future<void> cancelTask(String taskId);

  /// 删除任务
  Future<void> deleteTask(String taskId);

  /// 获取任务进度
  Stream<ImportExportTask> getTaskProgress(String taskId);

  /// 验证导入文件
  Future<ImportValidationResult> validateImportFile({
    required File file,
    required DataType dataType,
  });

  /// FAQ批量导入
  Future<ImportExportTask> importFaqs({
    required File file,
    required String knowledgeBaseId,
    bool skipValidation = false,
  });

  /// FAQ批量导出
  Future<ImportExportTask> exportFaqs({
    required String knowledgeBaseId,
    required ExportFormat format,
    List<String>? selectedFaqIds,
  });

  /// 知识库导出
  Future<ImportExportTask> exportKnowledgeBase({
    required String knowledgeBaseId,
    required ExportFormat format,
    required KnowledgeBaseExportConfig config,
  });

  /// 文档批量导出
  Future<ImportExportTask> exportDocuments({
    required String knowledgeBaseId,
    required ExportFormat format,
    List<String>? selectedDocumentIds,
  });

  /// 对话记录导出
  Future<ImportExportTask> exportConversations({
    required ExportFormat format,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? selectedConversationIds,
  });

  /// 用户设置导出
  Future<ImportExportTask> exportUserSettings({
    required ExportFormat format,
  });

  /// 用户设置导入
  Future<ImportExportTask> importUserSettings({
    required File file,
  });

  /// 创建数据备份
  Future<ImportExportTask> createBackup({
    required String name,
    List<DataType>? dataTypes,
  });

  /// 恢复数据备份
  Future<ImportExportTask> restoreBackup({
    required File backupFile,
  });

  /// 获取导出文件
  Future<File?> getExportFile(String taskId);

  /// 分享导出文件
  Future<void> shareExportFile(String taskId);

  /// 清理过期任务
  Future<void> cleanupExpiredTasks();
} 