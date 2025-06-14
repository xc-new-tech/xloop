import 'package:equatable/equatable.dart';

/// 文件分类枚举
enum FileCategory {
  document('document', '文档'),
  image('image', '图片'),
  audio('audio', '音频'),
  video('video', '视频'),
  other('other', '其他');

  const FileCategory(this.value, this.label);
  
  final String value;
  final String label;

  static FileCategory fromString(String value) {
    return FileCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => FileCategory.other,
    );
  }
}

/// 文件处理状态枚举
enum FileStatus {
  uploading('uploading', '上传中'),
  processing('processing', '处理中'),
  processed('processed', '已处理'),
  failed('failed', '处理失败');

  const FileStatus(this.value, this.label);
  
  final String value;
  final String label;

  static FileStatus fromString(String value) {
    return FileStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => FileStatus.failed,
    );
  }
}

/// 文档切片
class DocumentChunk extends Equatable {
  final int id;
  final String text;
  final int startPosition;
  final int endPosition;
  final int length;

  const DocumentChunk({
    required this.id,
    required this.text,
    required this.startPosition,
    required this.endPosition,
    required this.length,
  });

  @override
  List<Object?> get props => [id, text, startPosition, endPosition, length];
}

/// 文件实体
class FileEntity extends Equatable {
  final String id;
  final String originalName;
  final String filename;
  final String mimetype;
  final int size;
  final String hash;
  final String path;
  final String userId;
  final String? knowledgeBaseId;
  final FileCategory category;
  final List<String> tags;
  final String? contentType;
  final String? extractedText;
  final Map<String, dynamic>? metadata;
  final List<DocumentChunk> chunks;
  final FileStatus status;
  final List<String> processingErrors;
  final int downloadCount;
  final DateTime? lastAccessedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FileEntity({
    required this.id,
    required this.originalName,
    required this.filename,
    required this.mimetype,
    required this.size,
    required this.hash,
    required this.path,
    required this.userId,
    this.knowledgeBaseId,
    required this.category,
    required this.tags,
    this.contentType,
    this.extractedText,
    this.metadata,
    required this.chunks,
    required this.status,
    required this.processingErrors,
    required this.downloadCount,
    this.lastAccessedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        originalName,
        filename,
        mimetype,
        size,
        hash,
        path,
        userId,
        knowledgeBaseId,
        category,
        tags,
        contentType,
        extractedText,
        metadata,
        chunks,
        status,
        processingErrors,
        downloadCount,
        lastAccessedAt,
        createdAt,
        updatedAt,
      ];

  /// 获取文件扩展名
  String get fileExtension {
    final dotIndex = originalName.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return originalName.substring(dotIndex + 1).toLowerCase();
  }

  /// 文件扩展名的别名（为了兼容）
  String get extension => fileExtension;

  /// 文件名的别名（为了兼容）
  String get name => originalName;

  /// 获取格式化的文件大小
  String get formattedSize {
    if (size < 1024) {
      return '${size}B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)}KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }

  /// 是否为图片文件
  bool get isImage => category == FileCategory.image;

  /// 是否为音频文件
  bool get isAudio => category == FileCategory.audio;

  /// 是否为视频文件
  bool get isVideo => category == FileCategory.video;

  /// 是否为文档文件
  bool get isDocument => category == FileCategory.document;

  /// 是否处理完成
  bool get isProcessed => status == FileStatus.processed;

  /// 是否处理失败
  bool get isFailed => status == FileStatus.failed;

  /// 是否正在处理
  bool get isProcessing => 
      status == FileStatus.uploading || status == FileStatus.processing;

  /// 获取文件类型图标
  String get typeIcon {
    switch (category) {
      case FileCategory.document:
        switch (fileExtension) {
          case 'pdf':
            return '📄';
          case 'doc':
          case 'docx':
            return '📝';
          case 'xls':
          case 'xlsx':
            return '📊';
          case 'ppt':
          case 'pptx':
            return '📎';
          case 'txt':
            return '📋';
          default:
            return '📄';
        }
      case FileCategory.image:
        return '🖼️';
      case FileCategory.audio:
        return '🎵';
      case FileCategory.video:
        return '🎬';
      case FileCategory.other:
        return '📎';
    }
  }

  /// 获取状态颜色（Material颜色名称）
  String get statusColor {
    switch (status) {
      case FileStatus.uploading:
        return 'blue';
      case FileStatus.processing:
        return 'orange';
      case FileStatus.processed:
        return 'green';
      case FileStatus.failed:
        return 'red';
    }
  }

  /// 获取处理进度描述
  String get progressDescription {
    switch (status) {
      case FileStatus.uploading:
        return '上传中...';
      case FileStatus.processing:
        return '解析中...';
      case FileStatus.processed:
        return '已完成';
      case FileStatus.failed:
        return '处理失败';
    }
  }

  /// 是否有错误
  bool get hasErrors => processingErrors.isNotEmpty;

  /// 获取错误信息摘要
  String get errorSummary {
    if (!hasErrors) return '';
    if (processingErrors.length == 1) {
      return processingErrors.first;
    }
    return '${processingErrors.first}等${processingErrors.length}个错误';
  }

  /// 是否有提取的文本内容
  bool get hasExtractedText => 
      extractedText != null && extractedText!.isNotEmpty;

  /// 获取文本内容摘要
  String getTextSummary([int maxLength = 100]) {
    if (!hasExtractedText) return '';
    
    final text = extractedText!.trim();
    if (text.length <= maxLength) return text;
    
    return '${text.substring(0, maxLength)}...';
  }

  /// 获取元数据信息
  String get metadataInfo {
    if (metadata == null || metadata!.isEmpty) return '';
    
    final info = <String>[];
    
    // 根据文件类型显示相关元数据
    switch (category) {
      case FileCategory.document:
        if (metadata!.containsKey('pages')) {
          info.add('${metadata!['pages']}页');
        }
        if (metadata!.containsKey('words')) {
          info.add('${metadata!['words']}字');
        }
        break;
      case FileCategory.image:
        if (metadata!.containsKey('width') && metadata!.containsKey('height')) {
          info.add('${metadata!['width']}×${metadata!['height']}');
        }
        break;
      case FileCategory.audio:
        if (metadata!.containsKey('duration')) {
          final duration = Duration(seconds: metadata!['duration']);
          info.add(_formatDuration(duration));
        }
        break;
      case FileCategory.video:
        if (metadata!.containsKey('duration')) {
          final duration = Duration(seconds: metadata!['duration']);
          info.add(_formatDuration(duration));
        }
        if (metadata!.containsKey('width') && metadata!.containsKey('height')) {
          info.add('${metadata!['width']}×${metadata!['height']}');
        }
        break;
      case FileCategory.other:
        break;
    }
    
    return info.join(' • ');
  }

  /// 格式化时长
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// 复制并更新文件实体
  FileEntity copyWith({
    String? id,
    String? originalName,
    String? filename,
    String? mimetype,
    int? size,
    String? hash,
    String? path,
    String? userId,
    String? knowledgeBaseId,
    FileCategory? category,
    List<String>? tags,
    String? contentType,
    String? extractedText,
    Map<String, dynamic>? metadata,
    List<DocumentChunk>? chunks,
    FileStatus? status,
    List<String>? processingErrors,
    int? downloadCount,
    DateTime? lastAccessedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FileEntity(
      id: id ?? this.id,
      originalName: originalName ?? this.originalName,
      filename: filename ?? this.filename,
      mimetype: mimetype ?? this.mimetype,
      size: size ?? this.size,
      hash: hash ?? this.hash,
      path: path ?? this.path,
      userId: userId ?? this.userId,
      knowledgeBaseId: knowledgeBaseId ?? this.knowledgeBaseId,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      contentType: contentType ?? this.contentType,
      extractedText: extractedText ?? this.extractedText,
      metadata: metadata ?? this.metadata,
      chunks: chunks ?? this.chunks,
      status: status ?? this.status,
      processingErrors: processingErrors ?? this.processingErrors,
      downloadCount: downloadCount ?? this.downloadCount,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 