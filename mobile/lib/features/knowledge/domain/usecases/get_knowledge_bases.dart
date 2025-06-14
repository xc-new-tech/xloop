import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/knowledge_base.dart';
import '../repositories/knowledge_base_repository.dart';
import 'get_knowledge_bases_params.dart';

/// 获取知识库列表用例
class GetKnowledgeBases implements UseCase<List<KnowledgeBase>, GetKnowledgeBasesParams> {
  final KnowledgeBaseRepository repository;

  GetKnowledgeBases(this.repository);

  @override
  Future<Either<Failure, List<KnowledgeBase>>> call(GetKnowledgeBasesParams params) async {
    return await repository.getKnowledgeBases(
      page: params.page,
      limit: params.limit,
      status: params.status,
      type: params.type,
      search: params.search,
      tags: params.tags,
    );
  }

  /// 获取我的知识库列表
  Future<Either<Failure, List<KnowledgeBase>>> getMyKnowledgeBases(GetMyKnowledgeBasesParams params) async {
    return await repository.getMyKnowledgeBases(
      page: params.page,
      limit: params.limit,
      status: params.status,
      type: params.type,
    );
  }

  /// 获取公开知识库列表
  Future<Either<Failure, List<KnowledgeBase>>> getPublicKnowledgeBases(GetPublicKnowledgeBasesParams params) async {
    return await repository.getPublicKnowledgeBases(
      page: params.page,
      limit: params.limit,
      search: params.search,
      tags: params.tags,
    );
  }

  /// 搜索知识库
  Future<Either<Failure, List<KnowledgeBase>>> search(SearchKnowledgeBasesParams params) async {
    return await repository.searchKnowledgeBases(
      query: params.query,
      page: params.page,
      limit: params.limit,
      type: params.type,
      tags: params.tags,
    );
  }

  /// 获取知识库标签列表
  Future<Either<Failure, List<String>>> getTags() async {
    return await repository.getKnowledgeBaseTags();
  }
} 