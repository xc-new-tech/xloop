import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

/// 文件事件基类
abstract class FileEvent extends Equatable {
  const FileEvent();

  @override
  List<Object?> get props => [];
}

/// 获取文件列表事件
class GetFilesEvent extends FileEvent {
  final String? knowledgeBaseId;
  final String? category;
  final String? status;
  final int page;
  final int limit;
  final String? search;
  final bool refresh;

  const GetFilesEvent({
    this.knowledgeBaseId,
    this.category,
    this.status,
    this.page = 1,
    this.limit = 20,
    this.search,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [
    knowledgeBaseId,
    category,
    status,
    page,
    limit,
    search,
    refresh,
  ];
}

/// 获取文件详情事件
class GetFileDetailEvent extends FileEvent {
  final String fileId;

  const GetFileDetailEvent(this.fileId);

  @override
  List<Object> get props => [fileId];
}

/// 上传文件事件
class UploadFilesEvent extends FileEvent {
  final List<File> files;
  final String knowledgeBaseId;
  final String category;
  final List<String>? tags;

  const UploadFilesEvent({
    required this.files,
    required this.knowledgeBaseId,
    required this.category,
    this.tags,
  });

  @override
  List<Object?> get props => [files, knowledgeBaseId, category, tags];
}

/// 上传单个文件事件
class UploadFileEvent extends FileEvent {
  final File file;
  final String knowledgeBaseId;
  final String category;
  final List<String>? tags;

  const UploadFileEvent({
    required this.file,
    required this.knowledgeBaseId,
    required this.category,
    this.tags,
  });

  @override
  List<Object?> get props => [file, knowledgeBaseId, category, tags];
}

/// 上传PlatformFile事件（支持Web和移动端）
class UploadPlatformFilesEvent extends FileEvent {
  final List<PlatformFile> platformFiles;
  final String knowledgeBaseId;
  final String category;
  final List<String>? tags;

  const UploadPlatformFilesEvent({
    required this.platformFiles,
    required this.knowledgeBaseId,
    required this.category,
    this.tags,
  });

  @override
  List<Object?> get props => [platformFiles, knowledgeBaseId, category, tags];
}

/// 下载文件事件
class DownloadFileEvent extends FileEvent {
  final String fileId;
  final String savePath;

  const DownloadFileEvent({
    required this.fileId,
    required this.savePath,
  });

  @override
  List<Object> get props => [fileId, savePath];
}

/// 删除文件事件
class DeleteFileEvent extends FileEvent {
  final String fileId;

  const DeleteFileEvent(this.fileId);

  @override
  List<Object> get props => [fileId];
}

/// 批量删除文件事件
class DeleteFilesEvent extends FileEvent {
  final List<String> fileIds;

  const DeleteFilesEvent(this.fileIds);

  @override
  List<Object> get props => [fileIds];
}

/// 重新解析文件事件
class ReparseFileEvent extends FileEvent {
  final String fileId;

  const ReparseFileEvent(this.fileId);

  @override
  List<Object> get props => [fileId];
}

/// 更新文件信息事件
class UpdateFileEvent extends FileEvent {
  final String fileId;
  final String? name;
  final String? category;
  final List<String>? tags;

  const UpdateFileEvent({
    required this.fileId,
    this.name,
    this.category,
    this.tags,
  });

  @override
  List<Object?> get props => [fileId, name, category, tags];
}

/// 搜索文件事件
class SearchFilesEvent extends FileEvent {
  final String query;
  final String? knowledgeBaseId;
  final String? category;
  final String? status;
  final int page;
  final int limit;

  const SearchFilesEvent({
    required this.query,
    this.knowledgeBaseId,
    this.category,
    this.status,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [
    query,
    knowledgeBaseId,
    category,
    status,
    page,
    limit,
  ];
}

/// 获取文件统计信息事件
class GetFileStatsEvent extends FileEvent {
  final String? knowledgeBaseId;

  const GetFileStatsEvent({this.knowledgeBaseId});

  @override
  List<Object?> get props => [knowledgeBaseId];
}

/// 清除文件错误事件
class ClearFileErrorEvent extends FileEvent {
  const ClearFileErrorEvent();
}

/// 清除文件状态事件
class ClearFileStateEvent extends FileEvent {
  const ClearFileStateEvent();
}

/// 重置文件列表事件
class ResetFileListEvent extends FileEvent {
  const ResetFileListEvent();
}

/// 选择文件事件
class SelectFileEvent extends FileEvent {
  final String fileId;
  final bool isSelected;

  const SelectFileEvent({
    required this.fileId,
    required this.isSelected,
  });

  @override
  List<Object> get props => [fileId, isSelected];
}

/// 选择所有文件事件
class SelectAllFilesEvent extends FileEvent {
  final bool isSelected;

  const SelectAllFilesEvent(this.isSelected);

  @override
  List<Object> get props => [isSelected];
}

/// 取消上传事件
class CancelUploadEvent extends FileEvent {
  final String? uploadId;

  const CancelUploadEvent({this.uploadId});

  @override
  List<Object?> get props => [uploadId];
}

/// 取消下载事件
class CancelDownloadEvent extends FileEvent {
  final String fileId;

  const CancelDownloadEvent(this.fileId);

  @override
  List<Object> get props => [fileId];
}

/// 设置文件筛选条件事件
class SetFileFilterEvent extends FileEvent {
  final String? category;
  final String? status;
  final String? sortBy;
  final String? sortOrder;

  const SetFileFilterEvent({
    this.category,
    this.status,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [category, status, sortBy, sortOrder];
}

/// 加载更多文件事件
class LoadMoreFilesEvent extends FileEvent {
  const LoadMoreFilesEvent();
}

/// 刷新文件列表事件
class RefreshFilesEvent extends FileEvent {
  const RefreshFilesEvent();
} 