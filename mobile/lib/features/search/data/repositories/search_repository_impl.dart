import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_data_source.dart';
import '../models/search_models.dart';

/// 搜索仓库实现
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  const SearchRepositoryImpl({
    required SearchRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, HybridSearchResults>> search(
    String query,
    SearchOptions options,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      final queryParams = _buildSearchParams(options);
      final result = await _remoteDataSource.search(query, queryParams);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: '搜索失败: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DocumentSearchResult>>> searchDocuments(
    String query,
    SearchOptions options,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      final queryParams = _buildSearchParams(options);
      final results = await _remoteDataSource.searchDocuments(query, queryParams);
      return Right(results.map((result) => result.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: '文档搜索失败: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FaqSearchResult>>> searchFaqs(
    String query,
    SearchOptions options,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      final queryParams = _buildSearchParams(options);
      final results = await _remoteDataSource.searchFaqs(query, queryParams);
      return Right(results.map((result) => result.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: 'FAQ搜索失败: $e'));
    }
  }

  @override
  Future<Either<Failure, HybridSearchResults>> getRecommendations(
    RecommendationOptions options,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      final queryParams = _buildRecommendationParams(options);
      final result = await _remoteDataSource.getRecommendations(queryParams);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: '获取推荐内容失败: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> vectorizeDocument(
    String documentId,
    String content, [
    Map<String, dynamic>? metadata,
  ]) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      final request = VectorizeDocumentRequest(
        documentId: documentId,
        content: content,
        metadata: metadata,
      );
      await _remoteDataSource.vectorizeDocument(request);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: '文档向量化失败: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> vectorizeFaq(
    String faqId,
    String question,
    String answer, [
    Map<String, dynamic>? metadata,
  ]) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      final request = VectorizeFaqRequest(
        faqId: faqId,
        question: question,
        answer: answer,
        metadata: metadata,
      );
      await _remoteDataSource.vectorizeFaq(request);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: 'FAQ向量化失败: $e'));
    }
  }

  @override
  Future<Either<Failure, BatchVectorizeResult>> batchVectorize(
    String type,
    List<Map<String, dynamic>> items,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      final request = BatchVectorizeRequest(
        type: type,
        items: items,
      );
      final result = await _remoteDataSource.batchVectorize(request);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: '批量向量化失败: $e'));
    }
  }

  @override
  Future<Either<Failure, SearchStats>> getSearchStats() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      final result = await _remoteDataSource.getSearchStats();
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: '获取搜索统计失败: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCache([String? pattern]) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      await _remoteDataSource.clearCache(pattern);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: '清理缓存失败: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> checkHealth() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      final result = await _remoteDataSource.checkHealth();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: '健康检查失败: $e'));
    }
  }

  /// 构建搜索参数
  Map<String, String> _buildSearchParams(SearchOptions options) {
    final params = <String, String>{};

    if (options.limit != null) {
      params['limit'] = options.limit.toString();
    }
    if (options.offset != null) {
      params['offset'] = options.offset.toString();
    }
    if (options.minScore != null) {
      params['minScore'] = options.minScore.toString();
    }
    if (options.knowledgeBaseId != null) {
      params['knowledgeBaseId'] = options.knowledgeBaseId!;
    }
    if (options.category != null) {
      params['category'] = options.category!;
    }
    if (options.includeMetadata != null) {
      params['includeMetadata'] = options.includeMetadata.toString();
    }

    return params;
  }

  /// 构建推荐参数
  Map<String, String> _buildRecommendationParams(RecommendationOptions options) {
    final params = <String, String>{};

    if (options.limit != null) {
      params['limit'] = options.limit.toString();
    }
    if (options.userId != null) {
      params['userId'] = options.userId!;
    }
    if (options.knowledgeBaseId != null) {
      params['knowledgeBaseId'] = options.knowledgeBaseId!;
    }
    if (options.category != null) {
      params['category'] = options.category!;
    }
    if (options.excludeRecent != null) {
      params['excludeRecent'] = options.excludeRecent.toString();
    }

    return params;
  }
} 