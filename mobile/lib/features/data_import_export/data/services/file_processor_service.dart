import 'dart:io';
import 'dart:convert';

/// 文件处理服务
class FileProcessorService {
  /// 读取文本文件
  Future<String> readTextFile(File file) async {
    return await file.readAsString();
  }

  /// 写入文本文件
  Future<void> writeTextFile(File file, String content) async {
    await file.writeAsString(content);
  }

  /// 读取JSON文件
  Future<Map<String, dynamic>> readJsonFile(File file) async {
    final content = await readTextFile(file);
    return json.decode(content) as Map<String, dynamic>;
  }

  /// 写入JSON文件
  Future<void> writeJsonFile(File file, Map<String, dynamic> data) async {
    final content = json.encode(data);
    await writeTextFile(file, content);
  }

  /// 获取文件大小
  Future<int> getFileSize(File file) async {
    return await file.length();
  }

  /// 检查文件是否存在
  Future<bool> fileExists(File file) async {
    return await file.exists();
  }

  /// 创建目录
  Future<void> createDirectory(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  /// 复制文件
  Future<void> copyFile(File source, String destinationPath) async {
    await source.copy(destinationPath);
  }

  /// 删除文件
  Future<void> deleteFile(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// 获取文件扩展名
  String getFileExtension(File file) {
    return file.path.split('.').last.toLowerCase();
  }

  /// 获取文件名（不含扩展名）
  String getFileNameWithoutExtension(File file) {
    final fileName = file.path.split('/').last;
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1) return fileName;
    return fileName.substring(0, lastDotIndex);
  }

  /// 验证文件格式
  bool isValidFormat(File file, List<String> allowedExtensions) {
    final extension = getFileExtension(file);
    return allowedExtensions.contains(extension);
  }

  /// 获取MIME类型
  String getMimeType(File file) {
    final extension = getFileExtension(file);
    switch (extension) {
      case 'csv':
        return 'text/csv';
      case 'xlsx':
      case 'xls':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'json':
        return 'application/json';
      case 'pdf':
        return 'application/pdf';
      case 'zip':
        return 'application/zip';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
} 