import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/import_export_entity.dart';
import '../../domain/repositories/import_export_repository.dart';
import '../models/import_export_model.dart';
import '../services/file_processor_service.dart';
import '../services/csv_processor_service.dart';
import '../services/excel_processor_service.dart';
import '../services/backup_service.dart';

class ImportExportRepositoryImpl implements ImportExportRepository {
  final FileProcessorService _fileProcessor;
  final CsvProcessorService _csvProcessor;
  final ExcelProcessorService _excelProcessor;
  final BackupService _backupService;
  final Uuid _uuid = const Uuid();

  // 内存中的任务存储（实际项目中应该使用数据库）
  final Map<String, ImportExportTaskModel> _tasks = {};
  final Map<String, StreamController<ImportExportTask>> _progressControllers = {};

  ImportExportRepositoryImpl({
    required FileProcessorService fileProcessor,
    required CsvProcessorService csvProcessor,
    required ExcelProcessorService excelProcessor,
    required BackupService backupService,
  })  : _fileProcessor = fileProcessor,
        _csvProcessor = csvProcessor,
        _excelProcessor = excelProcessor,
        _backupService = backupService;

  @override
  Future<List<ImportExportTask>> getTasks() async {
    return _tasks.values.map((model) => model.toEntity()).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<ImportExportTask?> getTask(String taskId) async {
    final model = _tasks[taskId];
    return model?.toEntity();
  }

  @override
  Future<ImportExportTask> createExportTask({
    required String name,
    required DataType dataType,
    required ExportFormat format,
    Map<String, dynamic>? config,
  }) async {
    final taskId = _uuid.v4();
    final task = ImportExportTaskModel(
      id: taskId,
      name: name,
      dataType: dataType,
      format: format,
      status: ImportExportStatus.pending,
      createdAt: DateTime.now(),
      metadata: config,
    );

    _tasks[taskId] = task;
    return task.toEntity();
  }

  @override
  Future<ImportExportTask> createImportTask({
    required String name,
    required DataType dataType,
    required File file,
    Map<String, dynamic>? config,
  }) async {
    final taskId = _uuid.v4();
    final task = ImportExportTaskModel(
      id: taskId,
      name: name,
      dataType: dataType,
      format: _getFormatFromFile(file),
      status: ImportExportStatus.pending,
      filePath: file.path,
      createdAt: DateTime.now(),
      metadata: config,
    );

    _tasks[taskId] = task;
    return task.toEntity();
  }

  @override
  Future<void> startTask(String taskId) async {
    final task = _tasks[taskId];
    if (task == null) throw Exception('Task not found');

    _updateTaskStatus(taskId, ImportExportStatus.inProgress);

    try {
      // 根据任务类型执行相应操作
      switch (task.dataType) {
        case DataType.faq:
          await _processFaqTask(task);
          break;
        case DataType.knowledgeBase:
          await _processKnowledgeBaseTask(task);
          break;
        case DataType.documents:
          await _processDocumentsTask(task);
          break;
        case DataType.conversations:
          await _processConversationsTask(task);
          break;
        case DataType.userSettings:
          await _processUserSettingsTask(task);
          break;
      }

      _updateTaskStatus(taskId, ImportExportStatus.completed);
    } catch (e) {
      _updateTaskStatus(taskId, ImportExportStatus.failed, errorMessage: e.toString());
    }
  }

  @override
  Future<void> cancelTask(String taskId) async {
    _updateTaskStatus(taskId, ImportExportStatus.cancelled);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final task = _tasks[taskId];
    if (task?.filePath != null) {
      final file = File(task!.filePath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _tasks.remove(taskId);
    _progressControllers[taskId]?.close();
    _progressControllers.remove(taskId);
  }

  @override
  Stream<ImportExportTask> getTaskProgress(String taskId) {
    if (!_progressControllers.containsKey(taskId)) {
      _progressControllers[taskId] = StreamController<ImportExportTask>.broadcast();
    }
    return _progressControllers[taskId]!.stream;
  }

  @override
  Future<ImportValidationResult> validateImportFile({
    required File file,
    required DataType dataType,
  }) async {
    try {
      switch (dataType) {
        case DataType.faq:
          return await _validateFaqFile(file);
        case DataType.knowledgeBase:
          return await _validateKnowledgeBaseFile(file);
        case DataType.documents:
          return await _validateDocumentsFile(file);
        case DataType.conversations:
          return await _validateConversationsFile(file);
        case DataType.userSettings:
          return await _validateUserSettingsFile(file);
      }
    } catch (e) {
      return ImportValidationResult(
        isValid: false,
        errors: ['文件验证失败: ${e.toString()}'],
      );
    }
  }

  @override
  Future<ImportExportTask> importFaqs({
    required File file,
    required String knowledgeBaseId,
    bool skipValidation = false,
  }) async {
    final task = await createImportTask(
      name: 'FAQ导入 - ${file.path.split('/').last}',
      dataType: DataType.faq,
      file: file,
      config: {
        'knowledgeBaseId': knowledgeBaseId,
        'skipValidation': skipValidation,
      },
    );

    // 自动开始任务
    unawaited(startTask(task.id));
    return task;
  }

  @override
  Future<ImportExportTask> exportFaqs({
    required String knowledgeBaseId,
    required ExportFormat format,
    List<String>? selectedFaqIds,
  }) async {
    final task = await createExportTask(
      name: 'FAQ导出 - ${DateTime.now().toString().substring(0, 19)}',
      dataType: DataType.faq,
      format: format,
      config: {
        'knowledgeBaseId': knowledgeBaseId,
        'selectedFaqIds': selectedFaqIds,
      },
    );

    // 自动开始任务
    unawaited(startTask(task.id));
    return task;
  }

  @override
  Future<ImportExportTask> exportKnowledgeBase({
    required String knowledgeBaseId,
    required ExportFormat format,
    required KnowledgeBaseExportConfig config,
  }) async {
    final task = await createExportTask(
      name: '知识库导出 - ${DateTime.now().toString().substring(0, 19)}',
      dataType: DataType.knowledgeBase,
      format: format,
      config: KnowledgeBaseExportConfigModel.fromEntity(config).toJson(),
    );

    // 自动开始任务
    unawaited(startTask(task.id));
    return task;
  }

  @override
  Future<ImportExportTask> exportDocuments({
    required String knowledgeBaseId,
    required ExportFormat format,
    List<String>? selectedDocumentIds,
  }) async {
    final task = await createExportTask(
      name: '文档导出 - ${DateTime.now().toString().substring(0, 19)}',
      dataType: DataType.documents,
      format: format,
      config: {
        'knowledgeBaseId': knowledgeBaseId,
        'selectedDocumentIds': selectedDocumentIds,
      },
    );

    // 自动开始任务
    unawaited(startTask(task.id));
    return task;
  }

  @override
  Future<ImportExportTask> exportConversations({
    required ExportFormat format,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? selectedConversationIds,
  }) async {
    final task = await createExportTask(
      name: '对话导出 - ${DateTime.now().toString().substring(0, 19)}',
      dataType: DataType.conversations,
      format: format,
      config: {
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'selectedConversationIds': selectedConversationIds,
      },
    );

    // 自动开始任务
    unawaited(startTask(task.id));
    return task;
  }

  @override
  Future<ImportExportTask> exportUserSettings({
    required ExportFormat format,
  }) async {
    final task = await createExportTask(
      name: '用户设置导出 - ${DateTime.now().toString().substring(0, 19)}',
      dataType: DataType.userSettings,
      format: format,
    );

    // 自动开始任务
    unawaited(startTask(task.id));
    return task;
  }

  @override
  Future<ImportExportTask> importUserSettings({
    required File file,
  }) async {
    final task = await createImportTask(
      name: '用户设置导入 - ${file.path.split('/').last}',
      dataType: DataType.userSettings,
      file: file,
    );

    // 自动开始任务
    unawaited(startTask(task.id));
    return task;
  }

  @override
  Future<ImportExportTask> createBackup({
    required String name,
    List<DataType>? dataTypes,
  }) async {
    final task = await createExportTask(
      name: '数据备份 - $name',
      dataType: DataType.knowledgeBase, // 使用知识库类型作为备份类型
      format: ExportFormat.zip,
      config: {
        'isBackup': true,
        'dataTypes': dataTypes?.map((e) => e.name).toList(),
      },
    );

    // 自动开始任务
    unawaited(startTask(task.id));
    return task;
  }

  @override
  Future<ImportExportTask> restoreBackup({
    required File backupFile,
  }) async {
    final task = await createImportTask(
      name: '数据恢复 - ${backupFile.path.split('/').last}',
      dataType: DataType.knowledgeBase,
      file: backupFile,
      config: {
        'isRestore': true,
      },
    );

    // 自动开始任务
    unawaited(startTask(task.id));
    return task;
  }

  @override
  Future<File?> getExportFile(String taskId) async {
    final task = _tasks[taskId];
    if (task?.filePath != null) {
      final file = File(task!.filePath!);
      if (await file.exists()) {
        return file;
      }
    }
    return null;
  }

  @override
  Future<void> shareExportFile(String taskId) async {
    final file = await getExportFile(taskId);
    if (file != null) {
      await Share.shareXFiles([XFile(file.path)]);
    }
  }

  @override
  Future<void> cleanupExpiredTasks() async {
    final expiredDate = DateTime.now().subtract(const Duration(days: 7));
    final expiredTasks = _tasks.entries
        .where((entry) => entry.value.createdAt.isBefore(expiredDate))
        .toList();

    for (final entry in expiredTasks) {
      await deleteTask(entry.key);
    }
  }

  // 私有辅助方法
  ExportFormat _getFormatFromFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    switch (extension) {
      case 'csv':
        return ExportFormat.csv;
      case 'xlsx':
      case 'xls':
        return ExportFormat.excel;
      case 'json':
        return ExportFormat.json;
      case 'pdf':
        return ExportFormat.pdf;
      case 'zip':
        return ExportFormat.zip;
      default:
        return ExportFormat.csv;
    }
  }

  void _updateTaskStatus(
    String taskId,
    ImportExportStatus status, {
    String? errorMessage,
    double? progress,
    int? processedItems,
  }) {
    final task = _tasks[taskId];
    if (task == null) return;

    final updatedTask = task.copyWith(
      status: status,
      errorMessage: errorMessage,
      progress: progress,
      processedItems: processedItems,
      completedAt: status == ImportExportStatus.completed ? DateTime.now() : null,
    );

    _tasks[taskId] = updatedTask as ImportExportTaskModel;

    // 通知进度监听器
    final controller = _progressControllers[taskId];
    if (controller != null && !controller.isClosed) {
      controller.add(updatedTask.toEntity());
    }
  }

  // 任务处理方法
  Future<void> _processFaqTask(ImportExportTaskModel task) async {
    // 模拟FAQ处理
    await Future.delayed(const Duration(seconds: 1));
    _updateTaskProgress(task.id, 0.5, 50);
    await Future.delayed(const Duration(seconds: 1));
    _updateTaskProgress(task.id, 1.0, 100);
  }

  Future<void> _processKnowledgeBaseTask(ImportExportTaskModel task) async {
    // 模拟知识库处理
    await Future.delayed(const Duration(seconds: 2));
    _updateTaskProgress(task.id, 1.0, 100);
  }

  Future<void> _processDocumentsTask(ImportExportTaskModel task) async {
    // 模拟文档处理
    await Future.delayed(const Duration(seconds: 1));
    _updateTaskProgress(task.id, 1.0, 100);
  }

  Future<void> _processConversationsTask(ImportExportTaskModel task) async {
    // 模拟对话处理
    await Future.delayed(const Duration(seconds: 1));
    _updateTaskProgress(task.id, 1.0, 100);
  }

  Future<void> _processUserSettingsTask(ImportExportTaskModel task) async {
    // 模拟用户设置处理
    await Future.delayed(const Duration(seconds: 1));
    _updateTaskProgress(task.id, 1.0, 100);
  }

  void _updateTaskProgress(String taskId, double progress, int processedItems) {
    _updateTaskStatus(
      taskId,
      ImportExportStatus.inProgress,
      progress: progress,
      processedItems: processedItems,
    );
  }

  // 验证方法
  Future<ImportValidationResult> _validateFaqFile(File file) async {
    // 模拟FAQ文件验证
    return const ImportValidationResult(
      isValid: true,
      validItemCount: 100,
      invalidItemCount: 0,
    );
  }

  Future<ImportValidationResult> _validateKnowledgeBaseFile(File file) async {
    // 模拟知识库文件验证
    return const ImportValidationResult(
      isValid: true,
      validItemCount: 50,
      invalidItemCount: 0,
    );
  }

  Future<ImportValidationResult> _validateDocumentsFile(File file) async {
    // 模拟文档文件验证
    return const ImportValidationResult(
      isValid: true,
      validItemCount: 25,
      invalidItemCount: 0,
    );
  }

  Future<ImportValidationResult> _validateConversationsFile(File file) async {
    // 模拟对话文件验证
    return const ImportValidationResult(
      isValid: true,
      validItemCount: 200,
      invalidItemCount: 0,
    );
  }

  Future<ImportValidationResult> _validateUserSettingsFile(File file) async {
    // 模拟用户设置文件验证
    return const ImportValidationResult(
      isValid: true,
      validItemCount: 1,
      invalidItemCount: 0,
    );
  }
} 