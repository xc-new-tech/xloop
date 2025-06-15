import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/search_result.dart';
import '../repositories/search_repository.dart';

/// 语义搜索用例
class SearchUseCase implements UseCase<HybridSearchResults, SearchParams> {
  final SearchRepository _repository;

  const SearchUseCase(this._repository);

  @override
  Future<Either<Failure, HybridSearchResults>> call(SearchParams params) {
    return _repository.search(params.query, params.options);
  }
}

/// 文档搜索用例
class SearchDocumentsUseCase implements UseCase<List<DocumentSearchResult>, SearchParams> {
  final SearchRepository _repository;

  const SearchDocumentsUseCase(this._repository);

  @override
  Future<Either<Failure, List<DocumentSearchResult>>> call(SearchParams params) {
    return _repository.searchDocuments(params.query, params.options);
  }
}

/// FAQ搜索用例
class SearchFaqsUseCase implements UseCase<List<FaqSearchResult>, SearchParams> {
  final SearchRepository _repository;

  const SearchFaqsUseCase(this._repository);

  @override
  Future<Either<Failure, List<FaqSearchResult>>> call(SearchParams params) {
    return _repository.searchFaqs(params.query, params.options);
  }
}

/// 获取推荐内容用例
class GetRecommendationsUseCase implements UseCase<HybridSearchResults, RecommendationParams> {
  final SearchRepository _repository;

  const GetRecommendationsUseCase(this._repository);

  @override
  Future<Either<Failure, HybridSearchResults>> call(RecommendationParams params) {
    return _repository.getRecommendations(params.options);
  }
}

/// 文档向量化用例
class VectorizeDocumentUseCase implements UseCase<Unit, VectorizeDocumentParams> {
  final SearchRepository _repository;

  const VectorizeDocumentUseCase(this._repository);

  @override
  Future<Either<Failure, Unit>> call(VectorizeDocumentParams params) {
    return _repository.vectorizeDocument(
      params.documentId,
      params.content,
      params.metadata,
    );
  }
}

/// FAQ向量化用例
class VectorizeFaqUseCase implements UseCase<Unit, VectorizeFaqParams> {
  final SearchRepository _repository;

  const VectorizeFaqUseCase(this._repository);

  @override
  Future<Either<Failure, Unit>> call(VectorizeFaqParams params) {
    return _repository.vectorizeFaq(
      params.faqId,
      params.question,
      params.answer,
      params.metadata,
    );
  }
}

/// 批量向量化用例
class BatchVectorizeUseCase implements UseCase<BatchVectorizeResult, BatchVectorizeParams> {
  final SearchRepository _repository;

  const BatchVectorizeUseCase(this._repository);

  @override
  Future<Either<Failure, BatchVectorizeResult>> call(BatchVectorizeParams params) {
    return _repository.batchVectorize(params.type, params.items);
  }
}

/// 获取搜索统计用例
class GetSearchStatsUseCase implements UseCase<SearchStats, NoParams> {
  final SearchRepository _repository;

  const GetSearchStatsUseCase(this._repository);

  @override
  Future<Either<Failure, SearchStats>> call(NoParams params) {
    return _repository.getSearchStats();
  }
}

/// 清理缓存用例
class ClearCacheUseCase implements UseCase<Unit, ClearCacheParams> {
  final SearchRepository _repository;

  const ClearCacheUseCase(this._repository);

  @override
  Future<Either<Failure, Unit>> call(ClearCacheParams params) {
    return _repository.clearCache(params.pattern);
  }
}

/// 健康检查用例
class CheckHealthUseCase implements UseCase<Map<String, dynamic>, NoParams> {
  final SearchRepository _repository;

  const CheckHealthUseCase(this._repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) {
    return _repository.checkHealth();
  }
}

// ======================== 参数类 ========================

/// 搜索参数
class SearchParams {
  final String query;
  final SearchOptions options;

  const SearchParams({
    required this.query,
    this.options = const SearchOptions(),
  });
}

/// 推荐参数
class RecommendationParams {
  final RecommendationOptions options;

  const RecommendationParams({
    this.options = const RecommendationOptions(),
  });
}

/// 文档向量化参数
class VectorizeDocumentParams {
  final String documentId;
  final String content;
  final Map<String, dynamic>? metadata;

  const VectorizeDocumentParams({
    required this.documentId,
    required this.content,
    this.metadata,
  });
}

/// FAQ向量化参数
class VectorizeFaqParams {
  final String faqId;
  final String question;
  final String answer;
  final Map<String, dynamic>? metadata;

  const VectorizeFaqParams({
    required this.faqId,
    required this.question,
    required this.answer,
    this.metadata,
  });
}

/// 批量向量化参数
class BatchVectorizeParams {
  final String type;
  final List<Map<String, dynamic>> items;

  const BatchVectorizeParams({
    required this.type,
    required this.items,
  });
}

/// 清理缓存参数
class ClearCacheParams {
  final String? pattern;

  const ClearCacheParams({
    this.pattern,
  });
} 