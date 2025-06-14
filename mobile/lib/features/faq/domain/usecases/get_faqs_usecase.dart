import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/faq_entity.dart';
import '../repositories/faq_repository.dart';

class GetFaqsUseCase implements UseCase<List<FaqEntity>, GetFaqsParams> {
  final FaqRepository repository;

  GetFaqsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FaqEntity>>> call(GetFaqsParams params) async {
    return await repository.getFaqs(
      search: params.search,
      category: params.category,
      status: params.status,
      knowledgeBaseId: params.knowledgeBaseId,
      isPublic: params.isPublic,
      sort: params.sort,
      tags: params.tags,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetFaqsParams {
  final String? search;
  final String? category;
  final FaqStatus? status;
  final String? knowledgeBaseId;
  final bool? isPublic;
  final FaqSort? sort;
  final List<String>? tags;
  final int page;
  final int limit;

  const GetFaqsParams({
    this.search,
    this.category,
    this.status,
    this.knowledgeBaseId,
    this.isPublic,
    this.sort,
    this.tags,
    this.page = 1,
    this.limit = 20,
  });

  GetFaqsParams copyWith({
    String? search,
    String? category,
    FaqStatus? status,
    String? knowledgeBaseId,
    bool? isPublic,
    FaqSort? sort,
    List<String>? tags,
    int? page,
    int? limit,
  }) {
    return GetFaqsParams(
      search: search ?? this.search,
      category: category ?? this.category,
      status: status ?? this.status,
      knowledgeBaseId: knowledgeBaseId ?? this.knowledgeBaseId,
      isPublic: isPublic ?? this.isPublic,
      sort: sort ?? this.sort,
      tags: tags ?? this.tags,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
} 