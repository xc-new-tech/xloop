import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// 移动端文件操作工具类
class MobileFileUtils {
  MobileFileUtils._();

  static final ImagePicker _imagePicker = ImagePicker();

  /// 检查并请求权限
  static Future<bool> requestPermission(Permission permission) async {
    final status = await permission.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      // 引导用户到设置页面
      await openAppSettings();
      return false;
    }
    
    return false;
  }

  /// 从相机拍照
  static Future<File?> takePhoto({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    try {
      // 检查相机权限
      final hasPermission = await requestPermission(Permission.camera);
      if (!hasPermission) {
        throw Exception('相机权限被拒绝');
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 85,
        preferredCameraDevice: preferredCameraDevice,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('拍照失败: $e');
      return null;
    }
  }

  /// 从相册选择图片
  static Future<File?> pickImageFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      // 检查存储权限
      final hasPermission = await requestPermission(Permission.photos);
      if (!hasPermission) {
        throw Exception('相册权限被拒绝');
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('选择图片失败: $e');
      return null;
    }
  }

  /// 选择多张图片
  static Future<List<File>> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
  }) async {
    try {
      // 检查存储权限
      final hasPermission = await requestPermission(Permission.photos);
      if (!hasPermission) {
        throw Exception('相册权限被拒绝');
      }

      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 85,
        limit: limit,
      );

      return images.map((image) => File(image.path)).toList();
    } catch (e) {
      debugPrint('选择多张图片失败: $e');
      return [];
    }
  }

  /// 录制视频
  static Future<File?> recordVideo({
    Duration? maxDuration,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    try {
      // 检查相机权限
      final hasPermission = await requestPermission(Permission.camera);
      if (!hasPermission) {
        throw Exception('相机权限被拒绝');
      }

      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: maxDuration,
        preferredCameraDevice: preferredCameraDevice,
      );

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      debugPrint('录制视频失败: $e');
      return null;
    }
  }

  /// 从相册选择视频
  static Future<File?> pickVideoFromGallery({
    Duration? maxDuration,
  }) async {
    try {
      // 检查存储权限
      final hasPermission = await requestPermission(Permission.photos);
      if (!hasPermission) {
        throw Exception('相册权限被拒绝');
      }

      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: maxDuration,
      );

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      debugPrint('选择视频失败: $e');
      return null;
    }
  }

  /// 选择文件
  static Future<File?> pickFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
    bool allowMultiple = false,
  }) async {
    try {
      // 检查存储权限
      final hasPermission = await requestPermission(Permission.storage);
      if (!hasPermission) {
        throw Exception('存储权限被拒绝');
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          return File(file.path!);
        }
      }
      return null;
    } catch (e) {
      debugPrint('选择文件失败: $e');
      return null;
    }
  }

  /// 选择多个文件
  static Future<List<File>> pickMultipleFiles({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      // 检查存储权限
      final hasPermission = await requestPermission(Permission.storage);
      if (!hasPermission) {
        throw Exception('存储权限被拒绝');
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result != null) {
        return result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('选择多个文件失败: $e');
      return [];
    }
  }

  /// 保存文件到设备
  static Future<String?> saveFile({
    required String fileName,
    required Uint8List fileBytes,
    String? dialogTitle,
    String? initialDirectory,
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      // 检查存储权限
      final hasPermission = await requestPermission(Permission.storage);
      if (!hasPermission) {
        throw Exception('存储权限被拒绝');
      }

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: dialogTitle ?? '保存文件',
        fileName: fileName,
        initialDirectory: initialDirectory,
        type: type,
        allowedExtensions: allowedExtensions,
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsBytes(fileBytes);
        return outputFile;
      }
      return null;
    } catch (e) {
      debugPrint('保存文件失败: $e');
      return null;
    }
  }

  /// 获取应用文档目录
  static Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// 获取应用缓存目录
  static Future<Directory> getCacheDirectory() async {
    return await getTemporaryDirectory();
  }

  /// 获取外部存储目录（Android）
  static Future<Directory?> getExternalStorageDirectory() async {
    if (Platform.isAndroid) {
      return await getExternalStorageDirectory();
    }
    return null;
  }

  /// 创建临时文件
  static Future<File> createTempFile({
    required String fileName,
    required Uint8List data,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(data);
    return file;
  }

  /// 复制文件
  static Future<File?> copyFile({
    required File sourceFile,
    required String destinationPath,
  }) async {
    try {
      return await sourceFile.copy(destinationPath);
    } catch (e) {
      debugPrint('复制文件失败: $e');
      return null;
    }
  }

  /// 移动文件
  static Future<File?> moveFile({
    required File sourceFile,
    required String destinationPath,
  }) async {
    try {
      final newFile = await sourceFile.copy(destinationPath);
      await sourceFile.delete();
      return newFile;
    } catch (e) {
      debugPrint('移动文件失败: $e');
      return null;
    }
  }

  /// 删除文件
  static Future<bool> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('删除文件失败: $e');
      return false;
    }
  }

  /// 获取文件大小
  static Future<int> getFileSize(File file) async {
    try {
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      debugPrint('获取文件大小失败: $e');
      return 0;
    }
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// 获取文件扩展名
  static String getFileExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex != -1 && lastDotIndex < fileName.length - 1) {
      return fileName.substring(lastDotIndex + 1).toLowerCase();
    }
    return '';
  }

  /// 获取文件MIME类型
  static String getMimeType(String fileName) {
    final extension = getFileExtension(fileName);
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt':
        return 'text/plain';
      case 'mp4':
        return 'video/mp4';
      case 'mp3':
        return 'audio/mpeg';
      default:
        return 'application/octet-stream';
    }
  }

  /// 分享文件
  static Future<void> shareFile({
    required File file,
    String? subject,
    String? text,
  }) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: subject,
        text: text,
      );
    } catch (e) {
      debugPrint('分享文件失败: $e');
    }
  }

  /// 分享多个文件
  static Future<void> shareMultipleFiles({
    required List<File> files,
    String? subject,
    String? text,
  }) async {
    try {
      final xFiles = files.map((file) => XFile(file.path)).toList();
      await Share.shareXFiles(
        xFiles,
        subject: subject,
        text: text,
      );
    } catch (e) {
      debugPrint('分享多个文件失败: $e');
    }
  }

  /// 检查文件是否存在
  static Future<bool> fileExists(String path) async {
    try {
      return await File(path).exists();
    } catch (e) {
      debugPrint('检查文件存在性失败: $e');
      return false;
    }
  }

  /// 创建目录
  static Future<Directory?> createDirectory(String path) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) {
        return await directory.create(recursive: true);
      }
      return directory;
    } catch (e) {
      debugPrint('创建目录失败: $e');
      return null;
    }
  }

  /// 清理缓存目录
  static Future<void> clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create();
      }
    } catch (e) {
      debugPrint('清理缓存失败: $e');
    }
  }

  /// 获取缓存大小
  static Future<int> getCacheSize() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      return await _getDirectorySize(cacheDir);
    } catch (e) {
      debugPrint('获取缓存大小失败: $e');
      return 0;
    }
  }

  /// 计算目录大小
  static Future<int> _getDirectorySize(Directory directory) async {
    int size = 0;
    try {
      if (await directory.exists()) {
        await for (final entity in directory.list(recursive: true)) {
          if (entity is File) {
            size += await entity.length();
          }
        }
      }
    } catch (e) {
      debugPrint('计算目录大小失败: $e');
    }
    return size;
  }

  /// 显示文件选择对话框
  static Future<File?> showFilePickerDialog(
    BuildContext context, {
    List<FilePickerOption>? options,
  }) async {
    final selectedOption = await showModalBottomSheet<FilePickerOption>(
      context: context,
      builder: (context) => FilePickerBottomSheet(options: options),
    );

    if (selectedOption != null) {
      switch (selectedOption.type) {
        case FilePickerType.camera:
          return await takePhoto();
        case FilePickerType.gallery:
          return await pickImageFromGallery();
        case FilePickerType.file:
          return await pickFile();
        case FilePickerType.video:
          return await pickVideoFromGallery();
      }
    }
    return null;
  }
}

/// 文件选择器选项
class FilePickerOption {
  final String title;
  final IconData icon;
  final FilePickerType type;

  const FilePickerOption({
    required this.title,
    required this.icon,
    required this.type,
  });
}

/// 文件选择器类型
enum FilePickerType {
  camera,
  gallery,
  file,
  video,
}

/// 文件选择器底部弹窗
class FilePickerBottomSheet extends StatelessWidget {
  final List<FilePickerOption>? options;

  const FilePickerBottomSheet({
    super.key,
    this.options,
  });

  static const List<FilePickerOption> defaultOptions = [
    FilePickerOption(
      title: '拍照',
      icon: Icons.camera_alt,
      type: FilePickerType.camera,
    ),
    FilePickerOption(
      title: '从相册选择',
      icon: Icons.photo_library,
      type: FilePickerType.gallery,
    ),
    FilePickerOption(
      title: '选择文件',
      icon: Icons.folder,
      type: FilePickerType.file,
    ),
    FilePickerOption(
      title: '选择视频',
      icon: Icons.videocam,
      type: FilePickerType.video,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final optionList = options ?? defaultOptions;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '选择文件',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...optionList.map((option) => ListTile(
            leading: Icon(option.icon),
            title: Text(option.title),
            onTap: () => Navigator.of(context).pop(option),
          )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ),
        ],
      ),
    );
  }
} 