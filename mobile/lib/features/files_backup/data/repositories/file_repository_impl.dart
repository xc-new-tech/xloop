import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/file_repository.dart';
import '../data_sources/file_remote_data_source.dart';

/// 文件存储库实现类
class FileRepositoryImpl implements FileRepository {
  final FileRemoteDataSource _remoteDataSource;

  FileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<FileEntity>>> uploadFiles({
    required List<File> files,
    required String knowledgeBaseId,
    required String category,
    List<String>? tags,
    void Function(int count, int total)? onProgress,
  }) async {
    try {
      final result = await _remoteDataSource.uploadFiles(
        files: files,
        knowledgeBaseId: knowledgeBaseId,
        category: category,
        tags: tags,
        onProgress: onProgress,
      );

      final entities = result.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(e.message));
    } on OperationCancelledException catch (e) {
      return Left(CancelFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('批量上传文件失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FileEntity>> uploadFile({
    required File file,
    required String knowledgeBaseId,
    required String category,
    List<String>? tags,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final result = await _remoteDataSource.uploadFile(
        file: file,
        knowledgeBaseId: knowledgeBaseId,
        category: category,
        tags: tags,
        onProgress: onProgress,
      );

      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(e.message));
    } on OperationCancelledException catch (e) {
      return Left(CancelFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('上传文件失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FileEntity>>> getFiles({
    String? knowledgeBaseId,
    String? category,
    String? status,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final result = await _remoteDataSource.getFiles(
        knowledgeBaseId: knowledgeBaseId,
        category: category,
        status: status,
        page: page,
        limit: limit,
        search: search,
      );

      final entities = result.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('获取文件列表失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FileEntity>> getFileById(String fileId) async {
    try {
      final result = await _remoteDataSource.getFileById(fileId);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('获取文件详情失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> downloadFile({
    required String fileId,
    required String savePath,
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final result = await _remoteDataSource.downloadFile(
        fileId: fileId,
        savePath: savePath,
        onProgress: onProgress,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on OperationCancelledException catch (e) {
      return Left(CancelFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('下载文件失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteFile(String fileId) async {
    try {
      final result = await _remoteDataSource.deleteFile(fileId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('删除文件失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> deleteFiles(List<String> fileIds) async {
    try {
      final result = await _remoteDataSource.deleteFiles(fileIds);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('批量删除文件失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FileEntity>> reparseFile(String fileId) async {
    try {
      final result = await _remoteDataSource.reparseFile(fileId);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('重新解析文件失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FileEntity>> updateFile({
    required String fileId,
    String? name,
    String? category,
    List<String>? tags,
  }) async {
    try {
      final result = await _remoteDataSource.updateFile(
        fileId: fileId,
        name: name,
        category: category,
        tags: tags,
      );
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('更新文件信息失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getFileStats({
    String? knowledgeBaseId,
  }) async {
    try {
      final result = await _remoteDataSource.getFileStats(
        knowledgeBaseId: knowledgeBaseId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('获取文件统计信息失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FileEntity>>> searchFiles({
    required String query,
    String? knowledgeBaseId,
    String? category,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await _remoteDataSource.getFiles(
        knowledgeBaseId: knowledgeBaseId,
        category: category,
        status: status,
        page: page,
        limit: limit,
        search: query,
      );

      final entities = result.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('搜索文件失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> getFilePreviewUrl(String fileId) async {
    try {
      // 构建预览URL
      final previewUrl = '${_remoteDataSource.toString()}/files/$fileId/preview';
      return Right(previewUrl);
    } catch (e) {
      return Left(UnknownFailure('获取文件预览URL失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> fileExists(String fileId) async {
    try {
      await _remoteDataSource.getFileById(fileId);
      return const Right(true);
    } on NotFoundException {
      return const Right(false);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('检查文件是否存在失败: ${e.toString()}'));
    }
  }
} 