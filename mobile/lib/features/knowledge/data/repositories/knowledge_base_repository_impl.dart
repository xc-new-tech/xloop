import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/knowledge_base.dart';
import '../../domain/repositories/knowledge_base_repository.dart';
import '../datasources/knowledge_base_remote_data_source.dart';
import '../models/knowledge_base_model.dart';

/// 知识库仓库实现
class KnowledgeBaseRepositoryImpl implements KnowledgeBaseRepository {
  final KnowledgeBaseRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final Logger _logger;

  KnowledgeBaseRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required Logger logger,
  }) : _logger = logger;

  @override
  Future<Either<Failure, List<KnowledgeBase>>> getKnowledgeBases({
    int page = 1,
    int limit = 20,
    KnowledgeBaseType? type,
    KnowledgeBaseStatus? status,
    String? search,
    List<String>? tags,
    String? sortBy,
    String? sortOrder,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final knowledgeBases = await remoteDataSource.getKnowledgeBases(
          page: page,
          limit: limit,
          search: search,
          tags: tags,
          sortBy: sortBy,
          sortOrder: sortOrder,
        );
        return Right(knowledgeBases);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接'));
    }
  }

  @override
  Future<Either<Failure, List<KnowledgeBase>>> getMyKnowledgeBases({
    int page = 1,
    int limit = 20,
    KnowledgeBaseType? type,
    KnowledgeBaseStatus? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final knowledgeBases = await remoteDataSource.getMyKnowledgeBases(
          page: page,
          limit: limit,
          type: type?.name,
          status: status?.name,
          sortBy: sortBy,
          sortOrder: sortOrder,
        );
        return Right(knowledgeBases);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接'));
    }
  }

  @override
  Future<Either<Failure, List<KnowledgeBase>>> getPublicKnowledgeBases({
    int page = 1,
    int limit = 20,
    String? search,
    List<String>? tags,
    String? sortBy,
    String? sortOrder,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final knowledgeBases = await remoteDataSource.getPublicKnowledgeBases(
          page: page,
          limit: limit,
          search: search,
          tags: tags,
          sortBy: sortBy,
          sortOrder: sortOrder,
        );
        return Right(knowledgeBases);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接'));
    }
  }

  @override
  Future<Either<Failure, KnowledgeBase>> getKnowledgeBase(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final knowledgeBase = await remoteDataSource.getKnowledgeBase(id);
        return Right(knowledgeBase);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接'));
    }
  }

  @override
  Future<Either<Failure, KnowledgeBase>> createKnowledgeBase({
    required String name,
    String? description,
    String? coverImage,
    required KnowledgeBaseType type,
    Map<String, dynamic>? settings,
    bool isPublic = false,
    List<String>? tags,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final data = {
          'name': name,
          if (description != null) 'description': description,
          if (coverImage != null) 'coverImage': coverImage,
          'type': type.name,
          if (settings != null) 'settings': settings,
          if (tags != null) 'tags': tags,
        };
        
        final knowledgeBase = await remoteDataSource.createKnowledgeBase(data);
        return Right(knowledgeBase);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接'));
    }
  }

  @override
  Future<Either<Failure, KnowledgeBase>> updateKnowledgeBase({
    required String id,
    String? name,
    String? description,
    String? coverImage,
    KnowledgeBaseType? type,
    Map<String, dynamic>? settings,
    bool? isPublic,
    List<String>? tags,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final data = <String, dynamic>{};
        if (name != null) data['name'] = name;
        if (description != null) data['description'] = description;
        if (coverImage != null) data['coverImage'] = coverImage;
        if (type != null) data['type'] = type.name;
        if (settings != null) data['settings'] = settings;
        if (tags != null) data['tags'] = tags;
        
        final knowledgeBase = await remoteDataSource.updateKnowledgeBase(id, data);
        return Right(knowledgeBase);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteKnowledgeBase(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteKnowledgeBase(id);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: '无网络连接'));
    }
  }

  @override
  Future<Either<Failure, KnowledgeBase>> updateKnowledgeBaseStatus({
    required String id,
    required KnowledgeBaseStatus status,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      final result = await remoteDataSource.updateKnowledgeBaseStatus(id, status.name);
      return Right(result);
    } on NetworkException catch (e) {
      _logger.e('更新知识库状态网络异常', error: e);
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      _logger.e('更新知识库状态认证异常', error: e);
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      _logger.e('更新知识库状态服务器异常', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      _logger.e('更新知识库状态未知异常', error: e);
      return Left(UnknownFailure(message: '更新知识库状态失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, KnowledgeBase>> duplicateKnowledgeBase({
    required String id,
    String? newName,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      final result = await remoteDataSource.duplicateKnowledgeBase(id, newName ?? '$id-copy', null);
      return Right(result);
    } on NetworkException catch (e) {
      _logger.e('复制知识库网络异常', error: e);
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      _logger.e('复制知识库认证异常', error: e);
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      _logger.e('复制知识库服务器异常', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      _logger.e('复制知识库未知异常', error: e);
      return Left(UnknownFailure(message: '复制知识库失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> shareKnowledgeBase({
    required String id,
    required List<String> userIds,
    String? message,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      await remoteDataSource.shareKnowledgeBase(id, userIds, message);
      return const Right(null);
    } on NetworkException catch (e) {
      _logger.e('分享知识库网络异常', error: e);
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      _logger.e('分享知识库认证异常', error: e);
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      _logger.e('分享知识库服务器异常', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      _logger.e('分享知识库未知异常', error: e);
      return Left(UnknownFailure(message: '分享知识库失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, KnowledgeBase>> importKnowledgeBase({
    required String filePath,
    String? name,
    String? description,
    required KnowledgeBaseType type,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      final result = await remoteDataSource.importKnowledgeBase(
        filePath,
        name ?? 'Imported Knowledge Base',
        description,
      );
      return Right(result);
    } on NetworkException catch (e) {
      _logger.e('导入知识库网络异常', error: e);
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      _logger.e('导入知识库认证异常', error: e);
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      _logger.e('导入知识库服务器异常', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      _logger.e('导入知识库未知异常', error: e);
      return Left(UnknownFailure(message: '导入知识库失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> exportKnowledgeBase({
    required String id,
    String format = 'json',
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      final result = await remoteDataSource.exportKnowledgeBase(id, format);
      return Right(result);
    } on NetworkException catch (e) {
      _logger.e('导出知识库网络异常', error: e);
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      _logger.e('导出知识库认证异常', error: e);
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      _logger.e('导出知识库服务器异常', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      _logger.e('导出知识库未知异常', error: e);
      return Left(UnknownFailure(message: '导出知识库失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getKnowledgeBaseStats({String? userId, DateTime? startDate, DateTime? endDate}) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      final result = await remoteDataSource.getKnowledgeBaseStats(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } on NetworkException catch (e) {
      _logger.e('获取知识库统计信息网络异常', error: e);
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      _logger.e('获取知识库统计信息认证异常', error: e);
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      _logger.e('获取知识库统计信息服务器异常', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      _logger.e('获取知识库统计信息未知异常', error: e);
      return Left(UnknownFailure(message: '获取知识库统计信息失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<KnowledgeBase>>> searchKnowledgeBases({
    required String query,
    int page = 1,
    int limit = 20,
    KnowledgeBaseType? type,
    List<String>? tags,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      final result = await remoteDataSource.searchKnowledgeBases(
        query: query,
        page: page,
        limit: limit,
        type: type?.name,
        tags: tags,
      );

      return Right(result);
    } on NetworkException catch (e) {
      _logger.e('搜索知识库网络异常', error: e);
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      _logger.e('搜索知识库服务器异常', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      _logger.e('搜索知识库未知异常', error: e);
      return Left(UnknownFailure(message: '搜索知识库失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getKnowledgeBaseTags() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      final result = await remoteDataSource.getKnowledgeBaseTags();
      return Right(result);
    } on NetworkException catch (e) {
      _logger.e('获取知识库标签列表网络异常', error: e);
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      _logger.e('获取知识库标签列表服务器异常', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      _logger.e('获取知识库标签列表未知异常', error: e);
      return Left(UnknownFailure(message: '获取知识库标签列表失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> batchDeleteKnowledgeBases(List<String> ids) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      await remoteDataSource.deleteKnowledgeBases(ids);
      return const Right(null);
    } on NetworkException catch (e) {
      _logger.e('批量删除知识库网络异常', error: e);
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      _logger.e('批量删除知识库认证异常', error: e);
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      _logger.e('批量删除知识库服务器异常', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      _logger.e('批量删除知识库未知异常', error: e);
      return Left(UnknownFailure(message: '批量删除知识库失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<KnowledgeBase>>> batchUpdateStatus({
    required List<String> ids,
    required KnowledgeBaseStatus status,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }

    try {
      final result = await remoteDataSource.batchUpdateStatus(ids, status.name);
      return Right(result);
    } on NetworkException catch (e) {
      _logger.e('批量更新知识库状态网络异常', error: e);
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      _logger.e('批量更新知识库状态认证异常', error: e);
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      _logger.e('批量更新知识库状态服务器异常', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      _logger.e('批量更新知识库状态未知异常', error: e);
      return Left(UnknownFailure(message: '批量更新知识库状态失败: ${e.toString()}'));
    }
  }
} 