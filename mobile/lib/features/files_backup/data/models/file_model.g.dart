// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentChunkModel _$DocumentChunkModelFromJson(Map<String, dynamic> json) =>
    DocumentChunkModel(
      id: (json['id'] as num).toInt(),
      text: json['text'] as String,
      startPosition: (json['startPosition'] as num).toInt(),
      endPosition: (json['endPosition'] as num).toInt(),
      length: (json['length'] as num).toInt(),
    );

Map<String, dynamic> _$DocumentChunkModelToJson(DocumentChunkModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'startPosition': instance.startPosition,
      'endPosition': instance.endPosition,
      'length': instance.length,
    };

FileModel _$FileModelFromJson(Map<String, dynamic> json) => FileModel(
      id: json['id'] as String,
      originalName: json['originalName'] as String,
      filename: json['filename'] as String,
      mimetype: json['mimetype'] as String,
      size: (json['size'] as num).toInt(),
      hash: json['hash'] as String,
      path: json['path'] as String,
      userId: json['userId'] as String,
      knowledgeBaseId: json['knowledgeBaseId'] as String?,
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      contentType: json['contentType'] as String?,
      extractedText: json['extractedText'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      chunks: (json['chunks'] as List<dynamic>)
          .map((e) => DocumentChunkModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
      processingErrors: (json['processingErrors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      downloadCount: (json['downloadCount'] as num).toInt(),
      lastAccessedAt: json['lastAccessedAt'] == null
          ? null
          : DateTime.parse(json['lastAccessedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FileModelToJson(FileModel instance) => <String, dynamic>{
      'id': instance.id,
      'originalName': instance.originalName,
      'filename': instance.filename,
      'mimetype': instance.mimetype,
      'size': instance.size,
      'hash': instance.hash,
      'path': instance.path,
      'userId': instance.userId,
      'knowledgeBaseId': instance.knowledgeBaseId,
      'category': instance.category,
      'tags': instance.tags,
      'contentType': instance.contentType,
      'extractedText': instance.extractedText,
      'metadata': instance.metadata,
      'chunks': instance.chunks,
      'status': instance.status,
      'processingErrors': instance.processingErrors,
      'downloadCount': instance.downloadCount,
      'lastAccessedAt': instance.lastAccessedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
