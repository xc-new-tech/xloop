import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/file_entity.dart';
import '../repositories/file_repository.dart';

/// 上传文件用例
class UploadFilesUseCase implements UseCase<List<FileEntity>, UploadFilesParams> {
  final FileRepository repository;

  UploadFilesUseCase(this.repository);

  @override
  Future<Either<Failure, List<FileEntity>>> call(UploadFilesParams params) async {
    return await repository.uploadFiles(
      files: params.files,
      knowledgeBaseId: params.knowledgeBaseId,
      category: params.category,
      tags: params.tags,
      onProgress: params.onProgress,
    );
  }
}

/// 上传文件参数
class UploadFilesParams {
  final List<File> files;
  final String knowledgeBaseId;
  final String category;
  final List<String>? tags;
  final void Function(int count, int total)? onProgress;

  const UploadFilesParams({
    required this.files,
    required this.knowledgeBaseId,
    required this.category,
    this.tags,
    this.onProgress,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UploadFilesParams &&
        other.files == files &&
        other.knowledgeBaseId == knowledgeBaseId &&
        other.category == category &&
        other.tags == tags;
  }

  @override
  int get hashCode {
    return files.hashCode ^
        knowledgeBaseId.hashCode ^
        category.hashCode ^
        tags.hashCode;
  }

  @override
  String toString() {
    return 'UploadFilesParams('
        'files: ${files.length} files, '
        'knowledgeBaseId: $knowledgeBaseId, '
        'category: $category, '
        'tags: $tags'
        ')';
  }
} 