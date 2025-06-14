/// 文件相关常量
class FileConstants {
  FileConstants._();

  /// 支持的文件扩展名
  static const List<String> supportedExtensions = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'md',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'jpg',
    'jpeg',
    'png',
    'gif',
    'mp3',
    'wav',
    'mp4',
    'zip',
    'rar',
  ];

  /// 文档类型扩展名
  static const List<String> documentExtensions = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'md',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
  ];

  /// 图片类型扩展名
  static const List<String> imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
  ];

  /// 音频类型扩展名
  static const List<String> audioExtensions = [
    'mp3',
    'wav',
    'aac',
    'flac',
    'ogg',
  ];

  /// 视频类型扩展名
  static const List<String> videoExtensions = [
    'mp4',
    'avi',
    'mov',
    'wmv',
    'flv',
    'mkv',
  ];

  /// 压缩文件扩展名
  static const List<String> archiveExtensions = [
    'zip',
    'rar',
    '7z',
    'tar',
    'gz',
  ];

  /// 最大文件大小 (50MB)
  static const int maxFileSize = 50 * 1024 * 1024;

  /// 最大批量上传文件数
  static const int maxBatchFiles = 20;

  /// 图片文件最大大小 (10MB)
  static const int maxImageSize = 10 * 1024 * 1024;

  /// 文档文件最大大小 (50MB)
  static const int maxDocumentSize = 50 * 1024 * 1024;

  /// 音频文件最大大小 (100MB)
  static const int maxAudioSize = 100 * 1024 * 1024;

  /// 视频文件最大大小 (500MB)
  static const int maxVideoSize = 500 * 1024 * 1024;

  /// 支持的MIME类型
  static const Map<String, String> mimeTypes = {
    'pdf': 'application/pdf',
    'doc': 'application/msword',
    'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'txt': 'text/plain',
    'md': 'text/markdown',
    'xls': 'application/vnd.ms-excel',
    'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'ppt': 'application/vnd.ms-powerpoint',
    'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'bmp': 'image/bmp',
    'webp': 'image/webp',
    'mp3': 'audio/mpeg',
    'wav': 'audio/wav',
    'aac': 'audio/aac',
    'flac': 'audio/flac',
    'ogg': 'audio/ogg',
    'mp4': 'video/mp4',
    'avi': 'video/x-msvideo',
    'mov': 'video/quicktime',
    'wmv': 'video/x-ms-wmv',
    'flv': 'video/x-flv',
    'mkv': 'video/x-matroska',
    'zip': 'application/zip',
    'rar': 'application/vnd.rar',
    '7z': 'application/x-7z-compressed',
    'tar': 'application/x-tar',
    'gz': 'application/gzip',
  };

  /// 根据扩展名获取MIME类型
  static String? getMimeType(String extension) {
    return mimeTypes[extension.toLowerCase()];
  }

  /// 根据扩展名获取文件类型
  static FileType getFileType(String extension) {
    final ext = extension.toLowerCase();
    
    if (documentExtensions.contains(ext)) {
      return FileType.document;
    } else if (imageExtensions.contains(ext)) {
      return FileType.image;
    } else if (audioExtensions.contains(ext)) {
      return FileType.audio;
    } else if (videoExtensions.contains(ext)) {
      return FileType.video;
    } else if (archiveExtensions.contains(ext)) {
      return FileType.archive;
    } else {
      return FileType.other;
    }
  }

  /// 根据文件类型获取最大文件大小
  static int getMaxSizeForType(FileType type) {
    switch (type) {
      case FileType.image:
        return maxImageSize;
      case FileType.document:
        return maxDocumentSize;
      case FileType.audio:
        return maxAudioSize;
      case FileType.video:
        return maxVideoSize;
      case FileType.archive:
      case FileType.other:
        return maxFileSize;
    }
  }

  /// 检查文件扩展名是否支持
  static bool isSupportedExtension(String extension) {
    return supportedExtensions.contains(extension.toLowerCase());
  }

  /// 检查文件大小是否合规
  static bool isValidFileSize(int fileSize, String extension) {
    final fileType = getFileType(extension);
    final maxSize = getMaxSizeForType(fileType);
    return fileSize <= maxSize;
  }
}

/// 文件类型枚举
enum FileType {
  document,
  image,
  audio,
  video,
  archive,
  other,
}

/// 文件状态枚举
enum FileStatus {
  pending,
  uploading,
  processing,
  completed,
  failed,
  deleted,
}

/// 文件处理状态枚举
enum ProcessingStatus {
  pending,
  extracting,
  indexing,
  completed,
  failed,
} 