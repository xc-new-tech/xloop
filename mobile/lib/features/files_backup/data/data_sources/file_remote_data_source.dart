import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/file_model.dart';

/// 文件远程数据源抽象接口
abstract class FileRemoteDataSource {
  /// 上传文件到服务器
  /// [file] 要上传的文件
  /// [knowledgeBaseId] 知识库ID
  /// [category] 文件分类
  /// [tags] 文件标签
  /// [onProgress] 上传进度回调
  /// 返回上传后的文件信息
  Future<List<FileModel>> uploadFiles({
    required List<File> files,
    required String knowledgeBaseId,
    required String category,
    List<String>? tags,
    void Function(int count, int total)? onProgress,
  });

  /// 上传单个文件到服务器
  /// [file] 要上传的文件
  /// [knowledgeBaseId] 知识库ID
  /// [category] 文件分类
  /// [tags] 文件标签
  /// [onProgress] 上传进度回调(字节数, 总字节数)
  /// 返回上传后的文件信息
  Future<FileModel> uploadFile({
    required File file,
    required String knowledgeBaseId,
    required String category,
    List<String>? tags,
    void Function(int sent, int total)? onProgress,
  });

  /// 上传PlatformFile到服务器（支持Web和移动端）
  /// [platformFiles] 要上传的PlatformFile列表
  /// [knowledgeBaseId] 知识库ID
  /// [category] 文件分类
  /// [tags] 文件标签
  /// [onProgress] 上传进度回调
  /// 返回上传后的文件信息列表
  Future<List<FileModel>> uploadPlatformFiles({
    required List<PlatformFile> platformFiles,
    required String knowledgeBaseId,
    required String category,
    List<String>? tags,
    void Function(int count, int total)? onProgress,
  });

  /// 获取文件列表
  /// [knowledgeBaseId] 知识库ID，可选
  /// [category] 文件分类过滤，可选
  /// [status] 文件状态过滤，可选
  /// [page] 页码，从1开始
  /// [limit] 每页数量，默认20
  /// [search] 搜索关键词，可选
  /// 返回文件列表
  Future<List<FileModel>> getFiles({
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
  Future<FileModel> getFileById(String fileId);

  /// 下载文件
  /// [fileId] 文件ID
  /// [savePath] 保存路径
  /// [onProgress] 下载进度回调(已下载字节数, 总字节数)
  /// 返回下载后的文件路径
  Future<String> downloadFile({
    required String fileId,
    required String savePath,
    void Function(int received, int total)? onProgress,
  });

  /// 删除文件
  /// [fileId] 文件ID
  /// 返回是否删除成功
  Future<bool> deleteFile(String fileId);

  /// 批量删除文件
  /// [fileIds] 文件ID列表
  /// 返回删除成功的文件ID列表
  Future<List<String>> deleteFiles(List<String> fileIds);

  /// 重新解析文件
  /// [fileId] 文件ID
  /// 返回重新解析后的文件信息
  Future<FileModel> reparseFile(String fileId);

  /// 更新文件信息
  /// [fileId] 文件ID
  /// [name] 新文件名，可选
  /// [category] 新分类，可选
  /// [tags] 新标签，可选
  /// 返回更新后的文件信息
  Future<FileModel> updateFile({
    required String fileId,
    String? name,
    String? category,
    List<String>? tags,
  });

  /// 获取文件统计信息
  /// [knowledgeBaseId] 知识库ID，可选
  /// 返回文件统计信息
  Future<Map<String, dynamic>> getFileStats({String? knowledgeBaseId});
}

/// 文件远程数据源实现类
class FileRemoteDataSourceImpl implements FileRemoteDataSource {
  final ApiClient _apiClient;

  FileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<FileModel>> uploadFiles({
    required List<File> files,
    required String knowledgeBaseId,
    required String category,
    List<String>? tags,
    void Function(int count, int total)? onProgress,
  }) async {
    try {
      final results = <FileModel>[];
      
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        onProgress?.call(i, files.length);
        
        final result = await uploadFile(
          file: file,
          knowledgeBaseId: knowledgeBaseId,
          category: category,
          tags: tags,
        );
        
        results.add(result);
      }
      
      onProgress?.call(files.length, files.length);
      return results;
    } catch (e) {
      throw ServerException('批量上传文件失败: ${e.toString()}');
    }
  }

  @override
  Future<FileModel> uploadFile({
    required File file,
    required String knowledgeBaseId,
    required String category,
    List<String>? tags,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final response = await _apiClient.uploadFile(
        '/files/upload',
        file.path,
        'file',
        fields: {
          'knowledgeBaseId': knowledgeBaseId,
          'category': category,
          if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
        },
      );

      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return FileModel.fromJson(data);
        } else if (data is List && data.isNotEmpty) {
          return FileModel.fromJson(data.first);
        }
      }
      
      throw ServerException('上传响应格式错误');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('上传文件失败: ${e.toString()}');
    }
  }

  @override
  Future<List<FileModel>> uploadPlatformFiles({
    required List<PlatformFile> platformFiles,
    required String knowledgeBaseId,
    required String category,
    List<String>? tags,
    void Function(int count, int total)? onProgress,
  }) async {
    try {
      final results = <FileModel>[];
      
      for (int i = 0; i < platformFiles.length; i++) {
        final platformFile = platformFiles[i];
        onProgress?.call(i, platformFiles.length);
        
        final result = await _uploadPlatformFile(
          platformFile: platformFile,
          knowledgeBaseId: knowledgeBaseId,
          category: category,
          tags: tags,
        );
        
        results.add(result);
      }
      
      onProgress?.call(platformFiles.length, platformFiles.length);
      return results;
    } catch (e) {
      throw ServerException('批量上传文件失败: ${e.toString()}');
    }
  }

  /// 上传单个PlatformFile
  Future<FileModel> _uploadPlatformFile({
    required PlatformFile platformFile,
    required String knowledgeBaseId,
    required String category,
    List<String>? tags,
  }) async {
    try {
      final response = await _apiClient.uploadPlatformFile(
        '/files/upload',
        platformFile,
        'file',
        fields: {
          'knowledgeBaseId': knowledgeBaseId,
          'category': category,
          if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
        },
      );

      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return FileModel.fromJson(data);
        } else if (data is List && data.isNotEmpty) {
          return FileModel.fromJson(data.first);
        }
      }
      
      throw ServerException('上传响应格式错误');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('上传文件失败: ${e.toString()}');
    }
  }

  @override
  Future<List<FileModel>> getFiles({
    String? knowledgeBaseId,
    String? category,
    String? status,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (knowledgeBaseId != null) 'knowledgeBaseId': knowledgeBaseId,
        if (category != null) 'category': category,
        if (status != null) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _apiClient.get(
        '/files',
        queryParameters: queryParams,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final files = data['files'] as List;
        return files.map((json) => FileModel.fromJson(json)).toList();
      }
      
      throw ServerException('获取文件列表响应格式错误');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('获取文件列表失败: ${e.toString()}');
    }
  }

  @override
  Future<FileModel> getFileById(String fileId) async {
    try {
      final response = await _apiClient.get('/files/$fileId');

      if (response['success'] == true) {
        return FileModel.fromJson(response['data']);
      }
      
      throw ServerException('获取文件详情响应格式错误');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('获取文件详情失败: ${e.toString()}');
    }
  }

  @override
  Future<String> downloadFile({
    required String fileId,
    required String savePath,
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final response = await _apiClient.get('/files/$fileId/download');
      
      if (response['success'] == true) {
        return savePath;
      }
      
      throw ServerException('下载文件失败');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('下载文件失败: ${e.toString()}');
    }
  }

  @override
  Future<bool> deleteFile(String fileId) async {
    try {
      final response = await _apiClient.delete('/files/$fileId');
      return response['success'] == true;
    } catch (e) {
      throw ServerException('删除文件失败: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> deleteFiles(List<String> fileIds) async {
    try {
      final response = await _apiClient.post(
        '/files/batch-delete',
        body: {'fileIds': fileIds},
      );

      if (response['success'] == true) {
        final deletedIds = response['data']['deletedIds'] as List;
        return deletedIds.cast<String>();
      }
      
      return [];
    } catch (e) {
      throw ServerException('批量删除文件失败: ${e.toString()}');
    }
  }

  @override
  Future<FileModel> reparseFile(String fileId) async {
    try {
      final response = await _apiClient.post('/files/$fileId/reparse');

      if (response['success'] == true) {
        return FileModel.fromJson(response['data']);
      }
      
      throw ServerException('重新解析文件响应格式错误');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('重新解析文件失败: ${e.toString()}');
    }
  }

  @override
  Future<FileModel> updateFile({
    required String fileId,
    String? name,
    String? category,
    List<String>? tags,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (category != null) data['category'] = category;
      if (tags != null) data['tags'] = tags;

      final response = await _apiClient.put(
        '/files/$fileId',
        body: data,
      );

      if (response['success'] == true) {
        return FileModel.fromJson(response['data']);
      }
      
      throw ServerException('更新文件信息响应格式错误');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('更新文件信息失败: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getFileStats({String? knowledgeBaseId}) async {
    try {
      final queryParams = <String, String>{};
      if (knowledgeBaseId != null) {
        queryParams['knowledgeBaseId'] = knowledgeBaseId;
      }

      final response = await _apiClient.get(
        '/files/stats',
        queryParameters: queryParams,
      );

      if (response['success'] == true) {
        return response['data'] as Map<String, dynamic>;
      }
      
      throw ServerException('获取文件统计信息响应格式错误');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('获取文件统计信息失败: ${e.toString()}');
    }
  }
} 