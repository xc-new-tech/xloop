import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/knowledge_base.dart';
import '../repositories/knowledge_base_repository.dart';
import 'get_knowledge_bases_params.dart';

/// 创建知识库用例
class CreateKnowledgeBase implements UseCase<KnowledgeBase, CreateKnowledgeBaseParams> {
  final KnowledgeBaseRepository repository;

  CreateKnowledgeBase(this.repository);

  @override
  Future<Either<Failure, KnowledgeBase>> call(CreateKnowledgeBaseParams params) async {
    return await repository.createKnowledgeBase(
      name: params.name,
      description: params.description,
      coverImage: params.coverImage,
      type: params.type,
      contentType: params.contentType,
      settings: params.settings,
      isPublic: params.isPublic,
      tags: params.tags,
    );
  }

  /// 导入知识库
  Future<Either<Failure, KnowledgeBase>> import(ImportKnowledgeBaseParams params) async {
    return await repository.importKnowledgeBase(
      filePath: params.filePath,
      name: params.name,
      description: params.description,
      type: params.type,
    );
  }
}

/// 创建知识库参数
class CreateKnowledgeBaseParams extends Equatable {
  final String name;
  final String? description;
  final String? coverImage;
  final KnowledgeBaseType type;
  final KnowledgeBaseContentType contentType; // 新增内容类型
  final Map<String, dynamic>? settings;
  final bool isPublic;
  final List<String>? tags;

  const CreateKnowledgeBaseParams({
    required this.name,
    this.description,
    this.coverImage,
    required this.type,
    required this.contentType, // 新增必需参数
    this.settings,
    this.isPublic = false,
    this.tags,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        coverImage,
        type,
        contentType, // 添加到props中
        settings,
        isPublic,
        tags,
      ];
} 