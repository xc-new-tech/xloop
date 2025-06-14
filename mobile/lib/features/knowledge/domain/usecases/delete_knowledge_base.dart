import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/knowledge_base_repository.dart';
import 'get_knowledge_bases_params.dart';

/// 删除知识库用例
class DeleteKnowledgeBase implements UseCase<void, DeleteKnowledgeBaseParams> {
  final KnowledgeBaseRepository repository;

  DeleteKnowledgeBase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteKnowledgeBaseParams params) async {
    return await repository.deleteKnowledgeBase(params.id);
  }

  /// 批量删除知识库
  Future<Either<Failure, void>> batchDelete(BatchDeleteKnowledgeBasesParams params) async {
    return await repository.batchDeleteKnowledgeBases(params.ids);
  }
}

/// 删除知识库参数
class DeleteKnowledgeBaseParams extends Equatable {
  final String id;

  const DeleteKnowledgeBaseParams({required this.id});

  @override
  List<Object?> get props => [id];
}
