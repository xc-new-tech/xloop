import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/knowledge_base.dart';
import '../repositories/knowledge_base_repository.dart';
import 'get_knowledge_bases_params.dart';

/// 更新知识库用例
class UpdateKnowledgeBase implements UseCase<KnowledgeBase, UpdateKnowledgeBaseParams> {
  final KnowledgeBaseRepository repository;

  UpdateKnowledgeBase(this.repository);

  @override
  Future<Either<Failure, KnowledgeBase>> call(UpdateKnowledgeBaseParams params) async {
    return await repository.updateKnowledgeBase(
      id: params.id,
      name: params.name,
      description: params.description,
      coverImage: params.coverImage,
      type: params.type,
      settings: params.settings,
      isPublic: params.isPublic,
      tags: params.tags,
    );
  }

  /// 更新知识库状态
  Future<Either<Failure, KnowledgeBase>> updateStatus(UpdateKnowledgeBaseStatusParams params) async {
    return await repository.updateKnowledgeBaseStatus(
      id: params.id,
      status: params.status,
    );
  }

  /// 复制知识库
  Future<Either<Failure, KnowledgeBase>> duplicate(DuplicateKnowledgeBaseParams params) async {
    return await repository.duplicateKnowledgeBase(
      id: params.id,
      newName: params.newName,
    );
  }

  /// 分享知识库
  Future<Either<Failure, void>> share(ShareKnowledgeBaseParams params) async {
    return await repository.shareKnowledgeBase(
      id: params.id,
      userIds: params.userIds,
      message: params.message,
    );
  }

  /// 导出知识库
  Future<Either<Failure, String>> export(ExportKnowledgeBaseParams params) async {
    return await repository.exportKnowledgeBase(
      id: params.id,
      format: params.format,
    );
  }

  /// 批量更新知识库状态
  Future<Either<Failure, List<KnowledgeBase>>> batchUpdateStatus(BatchUpdateKnowledgeBaseStatusParams params) async {
    return await repository.batchUpdateStatus(
      ids: params.ids,
      status: params.status,
    );
  }
}

/// 更新知识库参数
class UpdateKnowledgeBaseParams extends Equatable {
  final String id;
  final String? name;
  final String? description;
  final String? coverImage;
  final KnowledgeBaseType? type;
  final Map<String, dynamic>? settings;
  final bool? isPublic;
  final List<String>? tags;

  const UpdateKnowledgeBaseParams({
    required this.id,
    this.name,
    this.description,
    this.coverImage,
    this.type,
    this.settings,
    this.isPublic,
    this.tags,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        coverImage,
        type,
        settings,
        isPublic,
        tags,
      ];
} 