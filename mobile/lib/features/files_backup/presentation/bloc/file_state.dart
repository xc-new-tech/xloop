import 'package:equatable/equatable.dart';
import '../../domain/entities/file_entity.dart';

/// 文件状态基类
abstract class FileState extends Equatable {
  const FileState();

  @override
  List<Object?> get props => [];
}

/// 文件初始状态
class FileInitial extends FileState {
  const FileInitial();
}

/// 文件加载中状态
class FileLoading extends FileState {
  const FileLoading();
}

/// 文件列表加载成功状态
class FileListLoaded extends FileState {
  final List<FileEntity> files;
  final bool hasReachedMax;
  final int currentPage;
  final int totalCount;
  final Map<String, dynamic>? filters;
  final List<String> selectedFileIds;

  const FileListLoaded({
    required this.files,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.totalCount = 0,
    this.filters,
    this.selectedFileIds = const [],
  });

  @override
  List<Object?> get props => [
    files,
    hasReachedMax,
    currentPage,
    totalCount,
    filters,
    selectedFileIds,
  ];

  FileListLoaded copyWith({
    List<FileEntity>? files,
    bool? hasReachedMax,
    int? currentPage,
    int? totalCount,
    Map<String, dynamic>? filters,
    List<String>? selectedFileIds,
  }) {
    return FileListLoaded(
      files: files ?? this.files,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      filters: filters ?? this.filters,
      selectedFileIds: selectedFileIds ?? this.selectedFileIds,
    );
  }
}

/// 文件详情加载成功状态
class FileDetailLoaded extends FileState {
  final FileEntity file;

  const FileDetailLoaded(this.file);

  @override
  List<Object> get props => [file];
}

/// 文件上传中状态
class FileUploading extends FileState {
  final List<FileUploadProgress> uploads;

  const FileUploading(this.uploads);

  @override
  List<Object> get props => [uploads];
}

/// 文件上传成功状态
class FileUploadSuccess extends FileState {
  final List<FileEntity> uploadedFiles;
  final String message;

  const FileUploadSuccess({
    required this.uploadedFiles,
    this.message = '文件上传成功',
  });

  @override
  List<Object> get props => [uploadedFiles, message];
}

/// 文件下载中状态
class FileDownloading extends FileState {
  final String fileId;
  final double progress;
  final int received;
  final int total;

  const FileDownloading({
    required this.fileId,
    required this.progress,
    required this.received,
    required this.total,
  });

  @override
  List<Object> get props => [fileId, progress, received, total];
}

/// 文件下载成功状态
class FileDownloadSuccess extends FileState {
  final String fileId;
  final String filePath;
  final String message;

  const FileDownloadSuccess({
    required this.fileId,
    required this.filePath,
    this.message = '文件下载成功',
  });

  @override
  List<Object> get props => [fileId, filePath, message];
}

/// 文件删除成功状态
class FileDeleteSuccess extends FileState {
  final String message;
  final List<String> deletedFileIds;

  const FileDeleteSuccess({
    required this.deletedFileIds,
    this.message = '文件删除成功',
  });

  @override
  List<Object> get props => [deletedFileIds, message];
}

/// 文件更新成功状态
class FileUpdateSuccess extends FileState {
  final FileEntity updatedFile;
  final String message;

  const FileUpdateSuccess({
    required this.updatedFile,
    this.message = '文件更新成功',
  });

  @override
  List<Object> get props => [updatedFile, message];
}

/// 文件重新解析成功状态
class FileReparseSuccess extends FileState {
  final FileEntity reparsedFile;
  final String message;

  const FileReparseSuccess({
    required this.reparsedFile,
    this.message = '文件重新解析成功',
  });

  @override
  List<Object> get props => [reparsedFile, message];
}

/// 文件统计信息加载成功状态
class FileStatsLoaded extends FileState {
  final Map<String, dynamic> stats;

  const FileStatsLoaded(this.stats);

  @override
  List<Object> get props => [stats];
}

/// 文件搜索结果加载成功状态
class FileSearchLoaded extends FileState {
  final List<FileEntity> searchResults;
  final String query;
  final bool hasReachedMax;
  final int currentPage;
  final int totalCount;

  const FileSearchLoaded({
    required this.searchResults,
    required this.query,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.totalCount = 0,
  });

  @override
  List<Object> get props => [
    searchResults,
    query,
    hasReachedMax,
    currentPage,
    totalCount,
  ];

  FileSearchLoaded copyWith({
    List<FileEntity>? searchResults,
    String? query,
    bool? hasReachedMax,
    int? currentPage,
    int? totalCount,
  }) {
    return FileSearchLoaded(
      searchResults: searchResults ?? this.searchResults,
      query: query ?? this.query,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

/// 文件操作成功状态
class FileOperationSuccess extends FileState {
  final String message;
  final String? operationType;

  const FileOperationSuccess({
    required this.message,
    this.operationType,
  });

  @override
  List<Object?> get props => [message, operationType];
}

/// 文件错误状态
class FileError extends FileState {
  final String message;
  final String? errorCode;
  final String? operationType;

  const FileError({
    required this.message,
    this.errorCode,
    this.operationType,
  });

  @override
  List<Object?> get props => [message, errorCode, operationType];
}

/// 文件上传进度信息
class FileUploadProgress {
  final String fileName;
  final String filePath;
  final double progress;
  final int sent;
  final int total;
  final String status; // uploading, success, error, cancelled
  final String? error;
  final String? uploadId;

  const FileUploadProgress({
    required this.fileName,
    required this.filePath,
    required this.progress,
    required this.sent,
    required this.total,
    required this.status,
    this.error,
    this.uploadId,
  });

  FileUploadProgress copyWith({
    String? fileName,
    String? filePath,
    double? progress,
    int? sent,
    int? total,
    String? status,
    String? error,
    String? uploadId,
  }) {
    return FileUploadProgress(
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      progress: progress ?? this.progress,
      sent: sent ?? this.sent,
      total: total ?? this.total,
      status: status ?? this.status,
      error: error ?? this.error,
      uploadId: uploadId ?? this.uploadId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileUploadProgress &&
        other.fileName == fileName &&
        other.filePath == filePath &&
        other.progress == progress &&
        other.sent == sent &&
        other.total == total &&
        other.status == status &&
        other.error == error &&
        other.uploadId == uploadId;
  }

  @override
  int get hashCode {
    return fileName.hashCode ^
        filePath.hashCode ^
        progress.hashCode ^
        sent.hashCode ^
        total.hashCode ^
        status.hashCode ^
        error.hashCode ^
        uploadId.hashCode;
  }

  @override
  String toString() {
    return 'FileUploadProgress('
        'fileName: $fileName, '
        'progress: ${(progress * 100).toStringAsFixed(1)}%, '
        'status: $status'
        ')';
  }
}

/// 文件筛选条件
class FileFilter {
  final String? category;
  final String? status;
  final String? sortBy;
  final String? sortOrder;
  final String? search;

  const FileFilter({
    this.category,
    this.status,
    this.sortBy,
    this.sortOrder,
    this.search,
  });

  FileFilter copyWith({
    String? category,
    String? status,
    String? sortBy,
    String? sortOrder,
    String? search,
  }) {
    return FileFilter(
      category: category ?? this.category,
      status: status ?? this.status,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      search: search ?? this.search,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (category != null) 'category': category,
      if (status != null) 'status': status,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (search != null) 'search': search,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileFilter &&
        other.category == category &&
        other.status == status &&
        other.sortBy == sortBy &&
        other.sortOrder == sortOrder &&
        other.search == search;
  }

  @override
  int get hashCode {
    return category.hashCode ^
        status.hashCode ^
        sortBy.hashCode ^
        sortOrder.hashCode ^
        search.hashCode;
  }

  @override
  String toString() {
    return 'FileFilter('
        'category: $category, '
        'status: $status, '
        'sortBy: $sortBy, '
        'sortOrder: $sortOrder, '
        'search: $search'
        ')';
  }
} 