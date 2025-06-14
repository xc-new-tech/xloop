import 'dart:io';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/file_repository.dart';
import 'file_event.dart';
import 'file_state.dart';

/// 文件BLoC - 处理文件相关的业务逻辑
class FileBloc extends Bloc<FileEvent, FileState> {
  final FileRepository _fileRepository;
  
  // 当前状态缓存
  List<FileEntity> _currentFiles = [];
  Map<String, dynamic> _currentFilters = {};
  List<String> _selectedFileIds = [];
  int _currentPage = 1;
  bool _hasReachedMax = false;
  int _totalCount = 0;

  FileBloc(this._fileRepository) : super(const FileInitial()) {
    // 注册事件处理器
    on<GetFilesEvent>(_onGetFiles);
    on<GetFileDetailEvent>(_onGetFileDetail);
    on<UploadFilesEvent>(_onUploadFiles);
    on<UploadFileEvent>(_onUploadFile);
    on<DownloadFileEvent>(_onDownloadFile);
    on<DeleteFileEvent>(_onDeleteFile);
    on<DeleteFilesEvent>(_onDeleteFiles);
    on<ReparseFileEvent>(_onReparseFile);
    on<UpdateFileEvent>(_onUpdateFile);
    on<SearchFilesEvent>(_onSearchFiles);
    on<GetFileStatsEvent>(_onGetFileStats);
    on<ClearFileErrorEvent>(_onClearFileError);
    on<ClearFileStateEvent>(_onClearFileState);
    on<ResetFileListEvent>(_onResetFileList);
    on<SelectFileEvent>(_onSelectFile);
    on<SelectAllFilesEvent>(_onSelectAllFiles);
    on<SetFileFilterEvent>(_onSetFileFilter);
    on<LoadMoreFilesEvent>(_onLoadMoreFiles);
    on<RefreshFilesEvent>(_onRefreshFiles);
  }

  /// 获取文件列表
  Future<void> _onGetFiles(GetFilesEvent event, Emitter<FileState> emit) async {
    if (event.refresh) {
      _currentPage = 1;
      _currentFiles.clear();
      _hasReachedMax = false;
    }

    if (_hasReachedMax && !event.refresh) return;

    emit(const FileLoading());

    try {
      final result = await _fileRepository.getFiles(
        knowledgeBaseId: event.knowledgeBaseId,
        category: event.category,
        status: event.status,
        page: event.page,
        limit: event.limit,
        search: event.search,
      );

      result.fold(
        (failure) => emit(FileError(message: failure.message)),
        (response) {
          final files = response['files'] as List<FileEntity>;
          final totalCount = response['totalCount'] as int;
          final hasMore = response['hasMore'] as bool;

          if (event.refresh) {
            _currentFiles = files;
          } else {
            _currentFiles.addAll(files);
          }

          _currentPage = event.page;
          _hasReachedMax = !hasMore;
          _totalCount = totalCount;
          _currentFilters = {
            'knowledgeBaseId': event.knowledgeBaseId,
            'category': event.category,
            'status': event.status,
            'search': event.search,
          };

          emit(FileListLoaded(
            files: List.from(_currentFiles),
            hasReachedMax: _hasReachedMax,
            currentPage: _currentPage,
            totalCount: _totalCount,
            filters: Map.from(_currentFilters),
            selectedFileIds: List.from(_selectedFileIds),
          ));
        },
      );
    } catch (e) {
      emit(FileError(message: '获取文件列表失败: $e'));
    }
  }

  /// 获取文件详情
  Future<void> _onGetFileDetail(GetFileDetailEvent event, Emitter<FileState> emit) async {
    emit(const FileLoading());

    try {
      final result = await _fileRepository.getFileDetail(event.fileId);

      result.fold(
        (failure) => emit(FileError(message: failure.message)),
        (file) => emit(FileDetailLoaded(file)),
      );
    } catch (e) {
      emit(FileError(message: '获取文件详情失败: $e'));
    }
  }

  /// 上传多个文件
  Future<void> _onUploadFiles(UploadFilesEvent event, Emitter<FileState> emit) async {
    final uploads = <FileUploadProgress>[];
    
    // 初始化上传进度
    for (int i = 0; i < event.files.length; i++) {
      final file = event.files[i];
      uploads.add(FileUploadProgress(
        fileName: file.path.split('/').last,
        filePath: file.path,
        progress: 0.0,
        sent: 0,
        total: await file.length(),
        status: 'uploading',
        uploadId: 'upload_${DateTime.now().millisecondsSinceEpoch}_$i',
      ));
    }

    emit(FileUploading(uploads));

    try {
      final result = await _fileRepository.uploadFiles(
        files: event.files,
        knowledgeBaseId: event.knowledgeBaseId,
        category: event.category,
        tags: event.tags,
        onProgress: (current, total) {
          // 更新总体进度
          final updatedUploads = uploads.map((upload) {
            final index = uploads.indexOf(upload);
            if (index < current) {
              return upload.copyWith(
                progress: 1.0,
                sent: upload.total,
                status: 'success',
              );
            } else if (index == current) {
              return upload.copyWith(
                progress: 0.5, // 当前文件正在上传
                status: 'uploading',
              );
            }
            return upload;
          }).toList();
          
          emit(FileUploading(updatedUploads));
        },
      );

      result.fold(
        (failure) {
          // 标记所有上传为失败
          final failedUploads = uploads.map((upload) => 
            upload.copyWith(
              status: 'error',
              error: failure.message,
            )
          ).toList();
          emit(FileUploading(failedUploads));
          emit(FileError(message: failure.message, operationType: 'upload'));
        },
        (uploadedFiles) {
          // 标记所有上传为成功
          final successUploads = uploads.map((upload) => 
            upload.copyWith(
              progress: 1.0,
              sent: upload.total,
              status: 'success',
            )
          ).toList();
          emit(FileUploading(successUploads));
          emit(FileUploadSuccess(uploadedFiles: uploadedFiles));
          
          // 刷新文件列表
          add(const RefreshFilesEvent());
        },
      );
    } catch (e) {
      final errorUploads = uploads.map((upload) => 
        upload.copyWith(
          status: 'error',
          error: e.toString(),
        )
      ).toList();
      emit(FileUploading(errorUploads));
      emit(FileError(message: '文件上传失败: $e', operationType: 'upload'));
    }
  }

  /// 上传单个文件  
  Future<void> _onUploadFile(UploadFileEvent event, Emitter<FileState> emit) async {
    final fileName = event.file.path.split('/').last;
    final fileSize = await event.file.length();
    final uploadId = 'upload_${DateTime.now().millisecondsSinceEpoch}';
    
    var uploadProgress = FileUploadProgress(
      fileName: fileName,
      filePath: event.file.path,
      progress: 0.0,
      sent: 0,
      total: fileSize,
      status: 'uploading',
      uploadId: uploadId,
    );

    emit(FileUploading([uploadProgress]));

    try {
      final result = await _fileRepository.uploadFile(
        file: event.file,
        knowledgeBaseId: event.knowledgeBaseId,
        category: event.category,
        tags: event.tags,
        onProgress: (sent, total) {
          uploadProgress = uploadProgress.copyWith(
            progress: sent / total,
            sent: sent,
            total: total,
          );
          emit(FileUploading([uploadProgress]));
        },
      );

      result.fold(
        (failure) {
          uploadProgress = uploadProgress.copyWith(
            status: 'error',
            error: failure.message,
          );
          emit(FileUploading([uploadProgress]));
          emit(FileError(message: failure.message, operationType: 'upload'));
        },
        (uploadedFile) {
          uploadProgress = uploadProgress.copyWith(
            progress: 1.0,
            sent: uploadProgress.total,
            status: 'success',
          );
          emit(FileUploading([uploadProgress]));
          emit(FileUploadSuccess(uploadedFiles: [uploadedFile]));
          
          // 刷新文件列表
          add(const RefreshFilesEvent());
        },
      );
    } catch (e) {
      uploadProgress = uploadProgress.copyWith(
        status: 'error',
        error: e.toString(),
      );
      emit(FileUploading([uploadProgress]));
      emit(FileError(message: '文件上传失败: $e', operationType: 'upload'));
    }
  }

  /// 下载文件
  Future<void> _onDownloadFile(DownloadFileEvent event, Emitter<FileState> emit) async {
    emit(FileDownloading(
      fileId: event.fileId,
      progress: 0.0,
      received: 0,
      total: 0,
    ));

    try {
      final result = await _fileRepository.downloadFile(
        fileId: event.fileId,
        savePath: event.savePath,
        onProgress: (received, total) {
          emit(FileDownloading(
            fileId: event.fileId,
            progress: received / total,
            received: received,
            total: total,
          ));
        },
      );

      result.fold(
        (failure) => emit(FileError(message: failure.message, operationType: 'download')),
        (filePath) => emit(FileDownloadSuccess(
          fileId: event.fileId,
          filePath: filePath,
        )),
      );
    } catch (e) {
      emit(FileError(message: '文件下载失败: $e', operationType: 'download'));
    }
  }

  /// 删除文件
  Future<void> _onDeleteFile(DeleteFileEvent event, Emitter<FileState> emit) async {
    emit(const FileLoading());

    try {
      final result = await _fileRepository.deleteFile(event.fileId);

      result.fold(
        (failure) => emit(FileError(message: failure.message, operationType: 'delete')),
        (_) {
          emit(FileDeleteSuccess(deletedFileIds: [event.fileId]));
          
          // 从当前列表中移除已删除的文件
          _currentFiles.removeWhere((file) => file.id == event.fileId);
          _selectedFileIds.remove(event.fileId);
          
          // 更新文件列表状态
          emit(FileListLoaded(
            files: List.from(_currentFiles),
            hasReachedMax: _hasReachedMax,
            currentPage: _currentPage,
            totalCount: _totalCount - 1,
            filters: Map.from(_currentFilters),
            selectedFileIds: List.from(_selectedFileIds),
          ));
        },
      );
    } catch (e) {
      emit(FileError(message: '删除文件失败: $e', operationType: 'delete'));
    }
  }

  /// 批量删除文件
  Future<void> _onDeleteFiles(DeleteFilesEvent event, Emitter<FileState> emit) async {
    emit(const FileLoading());

    try {
      final result = await _fileRepository.deleteFiles(event.fileIds);

      result.fold(
        (failure) => emit(FileError(message: failure.message, operationType: 'delete')),
        (_) {
          emit(FileDeleteSuccess(deletedFileIds: event.fileIds));
          
          // 从当前列表中移除已删除的文件
          _currentFiles.removeWhere((file) => event.fileIds.contains(file.id));
          _selectedFileIds.removeWhere((id) => event.fileIds.contains(id));
          
          // 更新文件列表状态
          emit(FileListLoaded(
            files: List.from(_currentFiles),
            hasReachedMax: _hasReachedMax,
            currentPage: _currentPage,
            totalCount: _totalCount - event.fileIds.length,
            filters: Map.from(_currentFilters),
            selectedFileIds: List.from(_selectedFileIds),
          ));
        },
      );
    } catch (e) {
      emit(FileError(message: '批量删除文件失败: $e', operationType: 'delete'));
    }
  }

  /// 重新解析文件
  Future<void> _onReparseFile(ReparseFileEvent event, Emitter<FileState> emit) async {
    emit(const FileLoading());

    try {
      final result = await _fileRepository.reparseFile(event.fileId);

      result.fold(
        (failure) => emit(FileError(message: failure.message, operationType: 'reparse')),
        (reparsedFile) {
          emit(FileReparseSuccess(reparsedFile: reparsedFile));
          
          // 更新当前列表中的文件
          final index = _currentFiles.indexWhere((file) => file.id == event.fileId);
          if (index != -1) {
            _currentFiles[index] = reparsedFile;
            emit(FileListLoaded(
              files: List.from(_currentFiles),
              hasReachedMax: _hasReachedMax,
              currentPage: _currentPage,
              totalCount: _totalCount,
              filters: Map.from(_currentFilters),
              selectedFileIds: List.from(_selectedFileIds),
            ));
          }
        },
      );
    } catch (e) {
      emit(FileError(message: '重新解析文件失败: $e', operationType: 'reparse'));
    }
  }

  /// 更新文件信息
  Future<void> _onUpdateFile(UpdateFileEvent event, Emitter<FileState> emit) async {
    emit(const FileLoading());

    try {
      final result = await _fileRepository.updateFile(
        fileId: event.fileId,
        name: event.name,
        category: event.category,
        tags: event.tags,
      );

      result.fold(
        (failure) => emit(FileError(message: failure.message, operationType: 'update')),
        (updatedFile) {
          emit(FileUpdateSuccess(updatedFile: updatedFile));
          
          // 更新当前列表中的文件
          final index = _currentFiles.indexWhere((file) => file.id == event.fileId);
          if (index != -1) {
            _currentFiles[index] = updatedFile;
            emit(FileListLoaded(
              files: List.from(_currentFiles),
              hasReachedMax: _hasReachedMax,
              currentPage: _currentPage,
              totalCount: _totalCount,
              filters: Map.from(_currentFilters),
              selectedFileIds: List.from(_selectedFileIds),
            ));
          }
        },
      );
    } catch (e) {
      emit(FileError(message: '更新文件信息失败: $e', operationType: 'update'));
    }
  }

  /// 搜索文件
  Future<void> _onSearchFiles(SearchFilesEvent event, Emitter<FileState> emit) async {
    emit(const FileLoading());

    try {
      final result = await _fileRepository.searchFiles(
        query: event.query,
        knowledgeBaseId: event.knowledgeBaseId,
        category: event.category,
        status: event.status,
        page: event.page,
        limit: event.limit,
      );

      result.fold(
        (failure) => emit(FileError(message: failure.message, operationType: 'search')),
        (response) {
          final searchResults = response['files'] as List<FileEntity>;
          final totalCount = response['totalCount'] as int;
          final hasMore = response['hasMore'] as bool;

          emit(FileSearchLoaded(
            searchResults: searchResults,
            query: event.query,
            hasReachedMax: !hasMore,
            currentPage: event.page,
            totalCount: totalCount,
          ));
        },
      );
    } catch (e) {
      emit(FileError(message: '搜索文件失败: $e', operationType: 'search'));
    }
  }

  /// 获取文件统计信息
  Future<void> _onGetFileStats(GetFileStatsEvent event, Emitter<FileState> emit) async {
    emit(const FileLoading());

    try {
      final result = await _fileRepository.getFileStats(
        knowledgeBaseId: event.knowledgeBaseId,
      );

      result.fold(
        (failure) => emit(FileError(message: failure.message, operationType: 'stats')),
        (stats) => emit(FileStatsLoaded(stats)),
      );
    } catch (e) {
      emit(FileError(message: '获取文件统计信息失败: $e', operationType: 'stats'));
    }
  }

  /// 清除错误状态
  void _onClearFileError(ClearFileErrorEvent event, Emitter<FileState> emit) {
    if (state is FileError) {
      emit(const FileInitial());
    }
  }

  /// 清除文件状态
  void _onClearFileState(ClearFileStateEvent event, Emitter<FileState> emit) {
    _currentFiles.clear();
    _currentFilters.clear();
    _selectedFileIds.clear();
    _currentPage = 1;
    _hasReachedMax = false;
    _totalCount = 0;
    emit(const FileInitial());
  }

  /// 重置文件列表
  void _onResetFileList(ResetFileListEvent event, Emitter<FileState> emit) {
    _currentFiles.clear();
    _selectedFileIds.clear();
    _currentPage = 1;
    _hasReachedMax = false;
    _totalCount = 0;
    
    emit(const FileListLoaded(
      files: [],
      hasReachedMax: false,
      currentPage: 1,
      totalCount: 0,
      selectedFileIds: [],
    ));
  }

  /// 选择文件
  void _onSelectFile(SelectFileEvent event, Emitter<FileState> emit) {
    if (event.isSelected) {
      if (!_selectedFileIds.contains(event.fileId)) {
        _selectedFileIds.add(event.fileId);
      }
    } else {
      _selectedFileIds.remove(event.fileId);
    }

    if (state is FileListLoaded) {
      final currentState = state as FileListLoaded;
      emit(currentState.copyWith(
        selectedFileIds: List.from(_selectedFileIds),
      ));
    }
  }

  /// 选择所有文件
  void _onSelectAllFiles(SelectAllFilesEvent event, Emitter<FileState> emit) {
    if (event.isSelected) {
      _selectedFileIds = _currentFiles.map((file) => file.id).toList();
    } else {
      _selectedFileIds.clear();
    }

    if (state is FileListLoaded) {
      final currentState = state as FileListLoaded;
      emit(currentState.copyWith(
        selectedFileIds: List.from(_selectedFileIds),
      ));
    }
  }

  /// 设置文件筛选条件
  void _onSetFileFilter(SetFileFilterEvent event, Emitter<FileState> emit) {
    _currentFilters = {
      if (event.category != null) 'category': event.category,
      if (event.status != null) 'status': event.status,
      if (event.sortBy != null) 'sortBy': event.sortBy,
      if (event.sortOrder != null) 'sortOrder': event.sortOrder,
    };

    // 应用筛选并重新获取文件列表
    add(GetFilesEvent(
      category: event.category,
      status: event.status,
      page: 1,
      refresh: true,
    ));
  }

  /// 加载更多文件
  void _onLoadMoreFiles(LoadMoreFilesEvent event, Emitter<FileState> emit) {
    if (!_hasReachedMax) {
      add(GetFilesEvent(
        knowledgeBaseId: _currentFilters['knowledgeBaseId'],
        category: _currentFilters['category'],
        status: _currentFilters['status'],
        search: _currentFilters['search'],
        page: _currentPage + 1,
        refresh: false,
      ));
    }
  }

  /// 刷新文件列表
  void _onRefreshFiles(RefreshFilesEvent event, Emitter<FileState> emit) {
    add(GetFilesEvent(
      knowledgeBaseId: _currentFilters['knowledgeBaseId'],
      category: _currentFilters['category'],
      status: _currentFilters['status'],
      search: _currentFilters['search'],
      page: 1,
      refresh: true,
    ));
  }
} 