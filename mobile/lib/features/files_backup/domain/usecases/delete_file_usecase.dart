import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/file_repository.dart';

/// 删除文件用例
class DeleteFileUseCase implements UseCase<void, DeleteFileParams> {
  final FileRepository repository;

  DeleteFileUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteFileParams params) async {
    final result = await repository.deleteFile(params.fileId);
    return result.fold(
      (failure) => Left(failure),
      (success) => const Right(null),
    );
  }
}

/// 删除文件参数
class DeleteFileParams {
  final String fileId;

  const DeleteFileParams({required this.fileId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteFileParams && other.fileId == fileId;
  }

  @override
  int get hashCode => fileId.hashCode;

  @override
  String toString() => 'DeleteFileParams(fileId: $fileId)';
}

/// 批量删除文件用例
class DeleteFilesUseCase implements UseCase<void, DeleteFilesParams> {
  final FileRepository repository;

  DeleteFilesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteFilesParams params) async {
    final result = await repository.deleteFiles(params.fileIds);
    return result.fold(
      (failure) => Left(failure),
      (deletedIds) => const Right(null),
    );
  }
}

/// 批量删除文件参数
class DeleteFilesParams {
  final List<String> fileIds;

  const DeleteFilesParams({required this.fileIds});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteFilesParams && 
           other.fileIds.length == fileIds.length &&
           other.fileIds.every((id) => fileIds.contains(id));
  }

  @override
  int get hashCode => fileIds.hashCode;

  @override
  String toString() => 'DeleteFilesParams(fileIds: $fileIds)';
} 