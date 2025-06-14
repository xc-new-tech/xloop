import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/file_entity.dart';

part 'file_model.g.dart';

@JsonSerializable()
class DocumentChunkModel {
  final int id;
  final String text;
  @JsonKey(name: 'startPosition')
  final int startPosition;
  @JsonKey(name: 'endPosition')
  final int endPosition;
  final int length;

  const DocumentChunkModel({
    required this.id,
    required this.text,
    required this.startPosition,
    required this.endPosition,
    required this.length,
  });

  factory DocumentChunkModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentChunkModelFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentChunkModelToJson(this);

  DocumentChunk toEntity() {
    return DocumentChunk(
      id: id,
      text: text,
      startPosition: startPosition,
      endPosition: endPosition,
      length: length,
    );
  }

  factory DocumentChunkModel.fromEntity(DocumentChunk entity) {
    return DocumentChunkModel(
      id: entity.id,
      text: entity.text,
      startPosition: entity.startPosition,
      endPosition: entity.endPosition,
      length: entity.length,
    );
  }
}

@JsonSerializable()
class FileModel {
  final String id;
  @JsonKey(name: 'originalName')
  final String originalName;
  final String filename;
  final String mimetype;
  final int size;
  final String hash;
  final String path;
  @JsonKey(name: 'userId')
  final String userId;
  @JsonKey(name: 'knowledgeBaseId')
  final String? knowledgeBaseId;
  final String category;
  final List<String> tags;
  @JsonKey(name: 'contentType')
  final String? contentType;
  @JsonKey(name: 'extractedText')
  final String? extractedText;
  final Map<String, dynamic>? metadata;
  final List<DocumentChunkModel> chunks;
  final String status;
  @JsonKey(name: 'processingErrors')
  final List<String> processingErrors;
  @JsonKey(name: 'downloadCount')
  final int downloadCount;
  @JsonKey(name: 'lastAccessedAt')
  final DateTime? lastAccessedAt;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  const FileModel({
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

  factory FileModel.fromJson(Map<String, dynamic> json) =>
      _$FileModelFromJson(json);

  Map<String, dynamic> toJson() => _$FileModelToJson(this);

  FileEntity toEntity() {
    return FileEntity(
      id: id,
      originalName: originalName,
      filename: filename,
      mimetype: mimetype,
      size: size,
      hash: hash,
      path: path,
      userId: userId,
      knowledgeBaseId: knowledgeBaseId,
      category: FileCategory.fromString(category),
      tags: tags,
      contentType: contentType,
      extractedText: extractedText,
      metadata: metadata,
      chunks: chunks.map((chunk) => chunk.toEntity()).toList(),
      status: FileStatus.fromString(status),
      processingErrors: processingErrors,
      downloadCount: downloadCount,
      lastAccessedAt: lastAccessedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory FileModel.fromEntity(FileEntity entity) {
    return FileModel(
      id: entity.id,
      originalName: entity.originalName,
      filename: entity.filename,
      mimetype: entity.mimetype,
      size: entity.size,
      hash: entity.hash,
      path: entity.path,
      userId: entity.userId,
      knowledgeBaseId: entity.knowledgeBaseId,
      category: entity.category.value,
      tags: entity.tags,
      contentType: entity.contentType,
      extractedText: entity.extractedText,
      metadata: entity.metadata,
      chunks: entity.chunks
          .map((chunk) => DocumentChunkModel.fromEntity(chunk))
          .toList(),
      status: entity.status.value,
      processingErrors: entity.processingErrors,
      downloadCount: entity.downloadCount,
      lastAccessedAt: entity.lastAccessedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  FileModel copyWith({
    String? id,
    String? originalName,
    String? filename,
    String? mimetype,
    int? size,
    String? hash,
    String? path,
    String? userId,
    String? knowledgeBaseId,
    String? category,
    List<String>? tags,
    String? contentType,
    String? extractedText,
    Map<String, dynamic>? metadata,
    List<DocumentChunkModel>? chunks,
    String? status,
    List<String>? processingErrors,
    int? downloadCount,
    DateTime? lastAccessedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FileModel(
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