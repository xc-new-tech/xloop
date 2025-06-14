import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/file_entity.dart';

/// 文件存储库接口
abstract class FileRepository {
  /// 上传多个文件
  /// [files] 要上传的文件列表
  /// [knowledgeBaseId] 知识库ID
  /// [category] 文件分类
  /// [tags] 文件标签
  /// [onProgress] 上传进度回调(当前文件索引, 总文件数)
  /// 返回上传成功的文件列表
  Future<Either<Failure, List<FileEntity>>> uploadFiles({
    required List<File> files,
    required String knowledgeBaseId,
    required String category,
    List<String>? tags,
    void Function(int count, int total)? onProgress,
  });

  /// 上传单个文件
  /// [file] 要上传的文件
  /// [knowledgeBaseId] 知识库ID
  /// [category] 文件分类
  /// [tags] 文件标签
  /// [onProgress] 上传进度回调(已上传字节数, 总字节数)
  /// 返回上传成功的文件信息
  Future<Either<Failure, FileEntity>> uploadFile({
    required File file,
    required String knowledgeBaseId,
    required String category,
    List<String>? tags,
    void Function(int sent, int total)? onProgress,
  });

  /// 获取文件列表
  /// [knowledgeBaseId] 知识库ID，可选
  /// [category] 文件分类过滤，可选
  /// [status] 文件状态过滤，可选
  /// [page] 页码，从1开始
  /// [limit] 每页数量，默认20
  /// [search] 搜索关键词，可选
  /// 返回文件列表
  Future<Either<Failure, List<FileEntity>>> getFiles({
    String? knowledgeBaseId,
    String? category,
    String? status,
    int page = 1,
    int limit = 20,
    String? search,
  });

  /// 根据ID获取文件详情
  /// [fileId] 文件ID
  /// 返回文件详情
  Future<Either<Failure, FileEntity>> getFileById(String fileId);

  /// 下载文件
  /// [fileId] 文件ID
  /// [savePath] 保存路径
  /// [onProgress] 下载进度回调(已下载字节数, 总字节数)
  /// 返回下载后的文件路径
  Future<Either<Failure, String>> downloadFile({
    required String fileId,
    required String savePath,
    void Function(int received, int total)? onProgress,
  });

  /// 删除文件
  /// [fileId] 文件ID
  /// 返回是否删除成功
  Future<Either<Failure, bool>> deleteFile(String fileId);

  /// 批量删除文件
  /// [fileIds] 文件ID列表
  /// 返回删除成功的文件ID列表
  Future<Either<Failure, List<String>>> deleteFiles(List<String> fileIds);

  /// 重新解析文件
  /// [fileId] 文件ID
  /// 返回重新解析后的文件信息
  Future<Either<Failure, FileEntity>> reparseFile(String fileId);

  /// 更新文件信息
  /// [fileId] 文件ID
  /// [name] 新文件名，可选
  /// [category] 新分类，可选
  /// [tags] 新标签，可选
  /// 返回更新后的文件信息
  Future<Either<Failure, FileEntity>> updateFile({
    required String fileId,
    String? name,
    String? category,
    List<String>? tags,
  });

  /// 获取文件统计信息
  /// [knowledgeBaseId] 知识库ID，可选
  /// 返回文件统计信息
  Future<Either<Failure, Map<String, dynamic>>> getFileStats({
    String? knowledgeBaseId,
  });

  /// 搜索文件
  /// [query] 搜索关键词
  /// [knowledgeBaseId] 知识库ID，可选
  /// [category] 文件分类过滤，可选
  /// [status] 文件状态过滤，可选
  /// [page] 页码，从1开始
  /// [limit] 每页数量，默认20
  /// 返回搜索结果
  Future<Either<Failure, List<FileEntity>>> searchFiles({
    required String query,
    String? knowledgeBaseId,
    String? category,
    String? status,
    int page = 1,
    int limit = 20,
  });

  /// 获取文件预览URL
  /// [fileId] 文件ID
  /// 返回预览URL
  Future<Either<Failure, String>> getFilePreviewUrl(String fileId);

  /// 检查文件是否存在
  /// [fileId] 文件ID
  /// 返回文件是否存在
  Future<Either<Failure, bool>> fileExists(String fileId);
} 