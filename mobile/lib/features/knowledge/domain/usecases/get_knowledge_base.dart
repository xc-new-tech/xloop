import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/knowledge_base.dart';
import '../repositories/knowledge_base_repository.dart';
import 'get_knowledge_bases_params.dart';

/// 获取单个知识库用例
class GetKnowledgeBase implements UseCase<KnowledgeBase, GetKnowledgeBaseParams> {
  final KnowledgeBaseRepository repository;

  GetKnowledgeBase(this.repository);

  @override
  Future<Either<Failure, KnowledgeBase>> call(GetKnowledgeBaseParams params) async {
    return await repository.getKnowledgeBase(params.id);
  }

  /// 获取知识库统计信息
  Future<Either<Failure, Map<String, dynamic>>> getStats(GetKnowledgeBaseStatsParams params) async {
    return await repository.getKnowledgeBaseStats(
      userId: params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

/// 获取单个知识库参数
class GetKnowledgeBaseParams extends Equatable {
  final String id;

  const GetKnowledgeBaseParams({required this.id});

  @override
  List<Object?> get props => [id];
} 