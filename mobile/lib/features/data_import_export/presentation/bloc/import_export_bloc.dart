import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/import_export_entity.dart';
import '../../domain/usecases/import_export_usecases.dart';

// Events
abstract class ImportExportEvent extends Equatable {
  const ImportExportEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends ImportExportEvent {}

class CreateExportTaskEvent extends ImportExportEvent {
  final String name;
  final DataType dataType;
  final ExportFormat format;
  final Map<String, dynamic>? config;

  const CreateExportTaskEvent({
    required this.name,
    required this.dataType,
    required this.format,
    this.config,
  });

  @override
  List<Object?> get props => [name, dataType, format, config];
}

class CreateImportTaskEvent extends ImportExportEvent {
  final String name;
  final DataType dataType;
  final File file;
  final Map<String, dynamic>? config;

  const CreateImportTaskEvent({
    required this.name,
    required this.dataType,
    required this.file,
    this.config,
  });

  @override
  List<Object?> get props => [name, dataType, file, config];
}

class StartTaskEvent extends ImportExportEvent {
  final String taskId;

  const StartTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class CancelTaskEvent extends ImportExportEvent {
  final String taskId;

  const CancelTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class DeleteTaskEvent extends ImportExportEvent {
  final String taskId;

  const DeleteTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ValidateFileEvent extends ImportExportEvent {
  final File file;
  final DataType dataType;

  const ValidateFileEvent({
    required this.file,
    required this.dataType,
  });

  @override
  List<Object?> get props => [file, dataType];
}

class ExportFaqsEvent extends ImportExportEvent {
  final String knowledgeBaseId;
  final ExportFormat format;
  final List<String>? selectedFaqIds;

  const ExportFaqsEvent({
    required this.knowledgeBaseId,
    required this.format,
    this.selectedFaqIds,
  });

  @override
  List<Object?> get props => [knowledgeBaseId, format, selectedFaqIds];
}

class ImportFaqsEvent extends ImportExportEvent {
  final File file;
  final String knowledgeBaseId;
  final bool skipValidation;

  const ImportFaqsEvent({
    required this.file,
    required this.knowledgeBaseId,
    this.skipValidation = false,
  });

  @override
  List<Object?> get props => [file, knowledgeBaseId, skipValidation];
}

class CreateBackupEvent extends ImportExportEvent {
  final String name;
  final List<DataType>? dataTypes;

  const CreateBackupEvent({
    required this.name,
    this.dataTypes,
  });

  @override
  List<Object?> get props => [name, dataTypes];
}

class RestoreBackupEvent extends ImportExportEvent {
  final File backupFile;

  const RestoreBackupEvent(this.backupFile);

  @override
  List<Object?> get props => [backupFile];
}

class ShareExportFileEvent extends ImportExportEvent {
  final String taskId;

  const ShareExportFileEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ShareTaskEvent extends ImportExportEvent {
  final String taskId;

  const ShareTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

// States
abstract class ImportExportState extends Equatable {
  const ImportExportState();

  @override
  List<Object?> get props => [];
}

class ImportExportInitial extends ImportExportState {}

class ImportExportLoading extends ImportExportState {}

class ImportExportLoaded extends ImportExportState {
  final List<ImportExportTask> tasks;

  const ImportExportLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class ImportExportError extends ImportExportState {
  final String message;

  const ImportExportError(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskCreated extends ImportExportState {
  final ImportExportTask task;

  const TaskCreated(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskStarted extends ImportExportState {
  final String taskId;

  const TaskStarted(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class TaskCancelled extends ImportExportState {
  final String taskId;

  const TaskCancelled(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class TaskDeleted extends ImportExportState {
  final String taskId;

  const TaskDeleted(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class FileValidated extends ImportExportState {
  final ImportValidationResult result;

  const FileValidated(this.result);

  @override
  List<Object?> get props => [result];
}

class FileShared extends ImportExportState {
  final String taskId;

  const FileShared(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

// Bloc
class ImportExportBloc extends Bloc<ImportExportEvent, ImportExportState> {
  final GetImportExportTasksUseCase _getTasksUseCase;
  final ExportFaqsUseCase _exportFaqsUseCase;
  final ImportFaqsUseCase _importFaqsUseCase;
  final ValidateImportFileUseCase _validateFileUseCase;
  final ExportKnowledgeBaseUseCase _exportKnowledgeBaseUseCase;
  final ExportDocumentsUseCase _exportDocumentsUseCase;
  final ExportConversationsUseCase _exportConversationsUseCase;
  final CreateBackupUseCase _createBackupUseCase;
  final RestoreBackupUseCase _restoreBackupUseCase;
  final StartTaskUseCase _startTaskUseCase;
  final CancelTaskUseCase _cancelTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final ShareExportFileUseCase _shareExportFileUseCase;

  ImportExportBloc({
    required GetImportExportTasksUseCase getTasksUseCase,
    required ExportFaqsUseCase exportFaqsUseCase,
    required ImportFaqsUseCase importFaqsUseCase,
    required ValidateImportFileUseCase validateFileUseCase,
    required ExportKnowledgeBaseUseCase exportKnowledgeBaseUseCase,
    required ExportDocumentsUseCase exportDocumentsUseCase,
    required ExportConversationsUseCase exportConversationsUseCase,
    required CreateBackupUseCase createBackupUseCase,
    required RestoreBackupUseCase restoreBackupUseCase,
    required StartTaskUseCase startTaskUseCase,
    required CancelTaskUseCase cancelTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
    required ShareExportFileUseCase shareExportFileUseCase,
  })  : _getTasksUseCase = getTasksUseCase,
        _exportFaqsUseCase = exportFaqsUseCase,
        _importFaqsUseCase = importFaqsUseCase,
        _validateFileUseCase = validateFileUseCase,
        _exportKnowledgeBaseUseCase = exportKnowledgeBaseUseCase,
        _exportDocumentsUseCase = exportDocumentsUseCase,
        _exportConversationsUseCase = exportConversationsUseCase,
        _createBackupUseCase = createBackupUseCase,
        _restoreBackupUseCase = restoreBackupUseCase,
        _startTaskUseCase = startTaskUseCase,
        _cancelTaskUseCase = cancelTaskUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        _shareExportFileUseCase = shareExportFileUseCase,
        super(ImportExportInitial()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<CreateExportTaskEvent>(_onCreateExportTask);
    on<CreateImportTaskEvent>(_onCreateImportTask);
    on<StartTaskEvent>(_onStartTask);
    on<CancelTaskEvent>(_onCancelTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<ValidateFileEvent>(_onValidateFile);
    on<ExportFaqsEvent>(_onExportFaqs);
    on<ImportFaqsEvent>(_onImportFaqs);
    on<CreateBackupEvent>(_onCreateBackup);
    on<RestoreBackupEvent>(_onRestoreBackup);
    on<ShareExportFileEvent>(_onShareExportFile);
    on<ShareTaskEvent>(_onShareTask);
  }

  Future<void> _onLoadTasks(
    LoadTasksEvent event,
    Emitter<ImportExportState> emit,
  ) async {
    try {
      emit(ImportExportLoading());
      final tasks = await _getTasksUseCase();
      emit(ImportExportLoaded(tasks));
    } catch (e) {
      emit(ImportExportError('加载任务失败: ${e.toString()}'));
    }
  }

  Future<void> _onCreateExportTask(
    CreateExportTaskEvent event,
    Emitter<ImportExportState> emit,
  ) async {
    try {
      emit(ImportExportLoading());
      // 这里需要根据数据类型调用相应的用例
      // 暂时使用FAQ导出作为示例
      final task = await _exportFaqsUseCase(
        knowledgeBaseId: event.config?['knowledgeBaseId'] ?? '1',
        format: event.format,
        selectedFaqIds: event.config?['selectedFaqIds'],
      );
      emit(TaskCreated(task));
    } catch (e) {
      emit(ImportExportError('创建导出任务失败: ${e.toString()}'));
    }
  }

  Future<void> _onCreateImportTask(
    CreateImportTaskEvent event,
    Emitter<ImportExportState> emit,
  ) async {
    try {
      emit(ImportExportLoading());
      // 这里需要根据数据类型调用相应的用例
      // 暂时使用FAQ导入作为示例
      final task = await _importFaqsUseCase(
        file: event.file,
        knowledgeBaseId: event.config?['knowledgeBaseId'] ?? '1',
        skipValidation: event.config?['skipValidation'] ?? false,
      );
      emit(TaskCreated(task));
    } catch (e) {
      emit(ImportExportError('创建导入任务失败: ${e.toString()}'));
    }
  }

  Future<void> _onStartTask(
    StartTaskEvent event,
    Emitter<ImportExportState> emit,
  ) async {
    try {
      await _startTaskUseCase(event.taskId);
      emit(TaskStarted(event.taskId));
    } catch (e) {
      emit(ImportExportError('启动任务失败: ${e.toString()}'));
    }
  }

  Future<void> _onCancelTask(
    CancelTaskEvent event,
    Emitter<ImportExportState> emit,
  ) async {
    try {
      await _cancelTaskUseCase(event.taskId);
      emit(TaskCancelled(event.taskId));
    } catch (e) {
      emit(ImportExportError('取消任务失败: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<ImportExportState> emit,
  ) async {
    try {
      await _deleteTaskUseCase(event.taskId);
      emit(TaskDeleted(event.taskId));
    } catch (e) {
      emit(ImportExportError('删除任务失败: ${e.toString()}'));
    }
  }

  Future<void> _onValidateFile(
    ValidateFileEvent event,
    Emitter<ImportExportState> emit,
  ) async {
    try {
      emit(ImportExportLoading());
      final result = await _validateFileUseCase(
        file: event.file,
        dataType: event.dataType,
      );
      emit(FileValidated(result));
    } catch (e) {
      emit(ImportExportError('文件验证失败: ${e.toString()}'));
    }
  }

  Future<void> _onExportFaqs(
    ExportFaqsEvent event,
    Emitter<ImportExportState> emit,
  ) async {
    try {
      emit(ImportExportLoading());
      final task = await _exportFaqsUseCase(
        knowledgeBaseId: event.knowledgeBaseId,
        format: event.format,
        selectedFaqIds: event.selectedFaqIds,
      );
      emit(TaskCreated(task));
    } catch (e) {
      emit(ImportExportError('导出FAQ失败: ${e.toString()}'));
    }
  }

  Future<void> _onImportFaqs(
    ImportFaqsEvent event,
    Emitter<ImportExportState> emit,
  ) async {
    try {
      emit(ImportExportLoading());
      final task = await _importFaqsUseCase(
        file: event.file,
        knowledgeBaseId: event.knowledgeBaseId,
        skipValidation: event.skipValidation,
      );
      emit(TaskCreated(task));
    } catch (e) {
      emit(ImportExportError('导入FAQ失败: ${e.toString()}'));
    }
  }

  Future<void> _onCreateBackup(
    CreateBackupEvent event,
    Emitter<ImportExportState> emit,
  ) async {
    try {
      emit(ImportExportLoading());
      final task = await _createBackupUseCase(
        name: event.name,
        dataTypes: event.dataTypes,
      );
      emit(TaskCreated(task));
    } catch (e) {
      emit(ImportExportError('创建备份失败: ${e.toString()}'));
    }
  }

  Future<void> _onRestoreBackup(
    RestoreBackupEvent event,
    Emitter<ImportExportState> emit,
  ) async {
    try {
      emit(ImportExportLoading());
      final task = await _restoreBackupUseCase(
        backupFile: event.backupFile,
      );
      emit(TaskCreated(task));
    } catch (e) {
      emit(ImportExportError('恢复备份失败: ${e.toString()}'));
    }
  }

  Future<void> _onShareExportFile(
    ShareExportFileEvent event,
    Emitter<ImportExportState> emit,
  ) async {
    try {
      await _shareExportFileUseCase(event.taskId);
      emit(FileShared(event.taskId));
    } catch (e) {
      emit(ImportExportError('分享文件失败: ${e.toString()}'));
    }
  }

  Future<void> _onShareTask(
    ShareTaskEvent event,
    Emitter<ImportExportState> emit,
  ) async {
    try {
      await _shareExportFileUseCase(event.taskId);
      emit(FileShared(event.taskId));
    } catch (e) {
      emit(ImportExportError('分享任务失败: ${e.toString()}'));
    }
  }
} 