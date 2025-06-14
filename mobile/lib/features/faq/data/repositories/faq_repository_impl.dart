import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/faq_entity.dart';
import '../../domain/repositories/faq_repository.dart';
import '../datasources/faq_remote_data_source.dart';
import '../models/faq_model.dart';

class FaqRepositoryImpl implements FaqRepository {
  final FaqRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  FaqRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<FaqEntity>>> getFaqs({
    String? search,
    String? category,
    FaqStatus? status,
    String? knowledgeBaseId,
    bool? isPublic,
    FaqSort? sort,
    List<String>? tags,
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getFaqs(
          search: search,
          category: category,
          status: status?.value,
          knowledgeBaseId: knowledgeBaseId,
          isPublic: isPublic,
          sortBy: sort?.sortBy.value,
          sortOrder: sort?.sortOrder.value,
          tags: tags,
          page: page,
          limit: limit,
        );

        if (response.success && response.data != null) {
          final faqs = response.data!.faqs
              .map((model) => model.toEntity())
              .toList();
          return Right(faqs);
        } else {
          return Left(ServerFailure(message: response.message ?? '获取FAQ列表失败'));
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: '获取FAQ列表失败: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }
  }

  @override
  Future<Either<Failure, List<FaqEntity>>> searchFaqs({
    required FaqFilter filter,
    required FaqSort sort,
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final params = FaqSearchParams.fromFilter(
          filter: filter,
          sort: sort,
          page: page,
          limit: limit,
        );

        final response = await remoteDataSource.searchFaqs(params);

        if (response.success && response.data != null) {
          final faqs = response.data!.faqs
              .map((model) => model.toEntity())
              .toList();
          return Right(faqs);
        } else {
          return Left(ServerFailure(message: response.message ?? '搜索FAQ失败'));
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: '搜索FAQ失败: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }
  }

  @override
  Future<Either<Failure, FaqEntity>> getFaqById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getFaqById(id);

        if (response.success && response.faq != null) {
          return Right(response.faq!.toEntity());
        } else {
          return Left(ServerFailure(message: response.message ?? '获取FAQ详情失败'));
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: '获取FAQ详情失败: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }
  }

  @override
  Future<Either<Failure, FaqEntity>> createFaq(FaqEntity faq) async {
    if (await networkInfo.isConnected) {
      try {
        final request = FaqCreateRequest.fromEntity(faq);
        final response = await remoteDataSource.createFaq(request);

        if (response.success && response.faq != null) {
          return Right(response.faq!.toEntity());
        } else {
          return Left(ServerFailure(message: response.message ?? '创建FAQ失败'));
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: '创建FAQ失败: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }
  }

  @override
  Future<Either<Failure, FaqEntity>> updateFaq(FaqEntity faq) async {
    if (await networkInfo.isConnected) {
      try {
        final request = FaqCreateRequest.fromEntity(faq);
        final response = await remoteDataSource.updateFaq(faq.id, request);

        if (response.success && response.faq != null) {
          return Right(response.faq!.toEntity());
        } else {
          return Left(ServerFailure(message: response.message ?? '更新FAQ失败'));
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: '更新FAQ失败: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFaq(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteFaq(id);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: '删除FAQ失败: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }
  }

  @override
  Future<Either<Failure, void>> bulkDeleteFaqs(List<String> ids) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.bulkDeleteFaqs(ids);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: '批量删除FAQ失败: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }
  }

  @override
  Future<Either<Failure, List<FaqCategory>>> getCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getCategories();

        if (response.success && response.data != null) {
          final categories = response.data!.categories
              .map((model) => model.toEntity())
              .toList();
          return Right(categories);
        } else {
          return Left(ServerFailure(message: response.message ?? '获取FAQ分类失败'));
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: '获取FAQ分类失败: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }
  }

  @override
  Future<Either<Failure, List<FaqEntity>>> getPopularFaqs({
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getPopularFaqs(limit: limit);

        if (response.success && response.data != null) {
          final faqs = response.data!.faqs
              .map((model) => model.toEntity())
              .toList();
          return Right(faqs);
        } else {
          return Left(ServerFailure(message: response.message ?? '获取热门FAQ失败'));
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: '获取热门FAQ失败: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }
  }

  @override
  Future<Either<Failure, FaqEntity>> likeFaq(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.likeFaq(id);

        if (response.success && response.faq != null) {
          return Right(response.faq!.toEntity());
        } else {
          return Left(ServerFailure(message: response.message ?? '点赞FAQ失败'));
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: '点赞FAQ失败: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }
  }

  @override
  Future<Either<Failure, FaqEntity>> dislikeFaq(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.dislikeFaq(id);

        if (response.success && response.faq != null) {
          return Right(response.faq!.toEntity());
        } else {
          return Left(ServerFailure(message: response.message ?? '点踩FAQ失败'));
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: '点踩FAQ失败: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }
  }

  @override
  Future<Either<Failure, FaqEntity>> toggleFaqStatus(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.toggleFaqStatus(id);

        if (response.success && response.faq != null) {
          return Right(response.faq!.toEntity());
        } else {
          return Left(ServerFailure(message: response.message ?? '切换FAQ状态失败'));
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: '切换FAQ状态失败: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure(message: '网络连接不可用'));
    }
  }
} 