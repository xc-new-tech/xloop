import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../datasources/conversation_local_data_source.dart';
import '../datasources/conversation_remote_data_source.dart';
import '../models/conversation_model.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationRemoteDataSource _remoteDataSource;
  final ConversationLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  ConversationRepositoryImpl({
    required ConversationRemoteDataSource remoteDataSource,
    required ConversationLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, Conversation>> createConversation({
    String? knowledgeBaseId,
    String? title,
    ConversationType type = ConversationType.chat,
    Map<String, dynamic> settings = const {},
    List<String> tags = const [],
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure(message: '网络连接不可用'));
      }

      final conversation = await _remoteDataSource.createConversation(
        knowledgeBaseId: knowledgeBaseId,
        title: title,
        type: type,
        settings: settings,
        tags: tags,
      );

      // 缓存新创建的对话
      await _localDataSource.cacheConversation(conversation);

      return Right(conversation.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: '创建对话时发生未知错误: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Conversation>>> getConversations({
    int page = 1,
    int limit = 20,
    ConversationType? type,
    ConversationStatus? status,
    String? knowledgeBaseId,
    String? search,
    String sortBy = 'lastMessageAt',
    String sortOrder = 'DESC',
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        // 网络可用时从远程获取
        final paginatedResponse = await _remoteDataSource.getConversations(
          page: page,
          limit: limit,
          type: type,
          status: status,
          knowledgeBaseId: knowledgeBaseId,
          search: search,
          sortBy: sortBy,
          sortOrder: sortOrder,
        );

        final conversations = paginatedResponse.items;

        // 缓存获取到的对话
        if (conversations.isNotEmpty) {
          await _localDataSource.cacheConversations(conversations);
        }

        return Right(conversations.map((c) => c.toEntity()).toList());
      } else {
        // 网络不可用时从缓存获取
        final cachedConversations = await _localDataSource.getCachedConversations();
        
        // 应用筛选条件
        var filteredConversations = cachedConversations.where((conversation) {
          if (type != null && conversation.type != type) return false;
          if (status != null && conversation.status != status) return false;
          if (knowledgeBaseId != null && conversation.knowledgeBaseId != knowledgeBaseId) return false;
          if (search != null && search.isNotEmpty) {
            final searchLower = search.toLowerCase();
            final titleMatch = conversation.title?.toLowerCase().contains(searchLower) ?? false;
            final messageMatch = conversation.messages.any((m) => 
                m.content.toLowerCase().contains(searchLower));
            if (!titleMatch && !messageMatch) return false;
          }
          return true;
        }).toList();

        // 应用排序
        filteredConversations.sort((a, b) {
          switch (sortBy) {
            case 'createdAt':
              final aTime = a.createdAt;
              final bTime = b.createdAt;
              return sortOrder == 'DESC' ? bTime.compareTo(aTime) : aTime.compareTo(bTime);
            case 'lastMessageAt':
            default:
              final aTime = a.lastMessageAt ?? a.createdAt;
              final bTime = b.lastMessageAt ?? b.createdAt;
              return sortOrder == 'DESC' ? bTime.compareTo(aTime) : aTime.compareTo(bTime);
          }
        });

        // 应用分页
        final startIndex = (page - 1) * limit;
        final endIndex = startIndex + limit;
        final paginatedConversations = filteredConversations.skip(startIndex).take(limit).toList();

        return Right(paginatedConversations.map((c) => c.toEntity()).toList());
      }
    } on AppException catch (e) {
      // 网络错误时尝试从缓存获取
      if (e is NetworkException) {
        try {
          final cachedConversations = await _localDataSource.getCachedConversations();
          return Right(cachedConversations.map((c) => c.toEntity()).toList());
        } catch (cacheError) {
          return Left(CacheFailure(message: '无法获取缓存的对话列表'));
        }
      }
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: '获取对话列表时发生未知错误: $e'));
    }
  }

  @override
  Future<Either<Failure, Conversation>> getConversationById(String id) async {
    try {
      if (await _networkInfo.isConnected) {
        // 网络可用时从远程获取
        final conversation = await _remoteDataSource.getConversationById(id);
        
        // 缓存获取到的对话
        await _localDataSource.cacheConversation(conversation);
        
        return Right(conversation.toEntity());
      } else {
        // 网络不可用时从缓存获取
        final cachedConversation = await _localDataSource.getCachedConversation(id);
        if (cachedConversation != null) {
          return Right(cachedConversation.toEntity());
        } else {
          return Left(CacheFailure(message: '对话在缓存中不存在'));
        }
      }
    } on AppException catch (e) {
      // 网络错误时尝试从缓存获取
      if (e is NetworkException || e is ServerException) {
        try {
          final cachedConversation = await _localDataSource.getCachedConversation(id);
          if (cachedConversation != null) {
            return Right(cachedConversation.toEntity());
          }
        } catch (cacheError) {
          // 忽略缓存错误，返回原始错误
        }
      }
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: '获取对话详情时发生未知错误: $e'));
    }
  }

  @override
  Future<Either<Failure, SendMessageResponse>> sendMessage({
    required String conversationId,
    required SendMessageRequest request,
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure(message: '发送消息需要网络连接'));
      }

      final requestModel = SendMessageRequestModel.fromEntity(request);
      final response = await _remoteDataSource.sendMessage(
        conversationId: conversationId,
        request: requestModel,
      );

      // 更新本地缓存的对话（添加新消息）
      try {
        final cachedConversation = await _localDataSource.getCachedConversation(conversationId);
        if (cachedConversation != null) {
          final updatedMessages = List<ConversationMessage>.from(cachedConversation.messages)
            ..add(response.userMessage.toEntity())
            ..add(response.assistantMessage.toEntity());

          final updatedConversation = cachedConversation.copyWith(
            messages: updatedMessages.map((m) => ConversationMessageModel.fromEntity(m)).toList(),
            messageCount: updatedMessages.length,
            lastMessageAt: response.assistantMessage.timestamp,
            updatedAt: DateTime.now(),
          ) as ConversationModel;

          await _localDataSource.cacheConversation(updatedConversation);
        }
      } catch (cacheError) {
        // 忽略缓存更新错误
      }

      return Right(response.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: '发送消息时发生未知错误: $e'));
    }
  }

  @override
  Future<Either<Failure, Conversation>> updateConversation({
    required String id,
    String? title,
    List<String>? tags,
    Map<String, dynamic>? settings,
    ConversationStatus? status,
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure(message: '更新对话需要网络连接'));
      }

      final conversation = await _remoteDataSource.updateConversation(
        id: id,
        title: title,
        tags: tags,
        settings: settings,
        status: status,
      );

      // 更新缓存
      await _localDataSource.cacheConversation(conversation);

      return Right(conversation.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: '更新对话时发生未知错误: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(String id) async {
    try {
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure(message: '删除对话需要网络连接'));
      }

      await _remoteDataSource.deleteConversation(id);

      // 删除本地缓存
      await _localDataSource.deleteCachedConversation(id);

      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: '删除对话时发生未知错误: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> bulkDeleteConversations(List<String> ids) async {
    try {
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure(message: '批量删除对话需要网络连接'));
      }

      final deletedCount = await _remoteDataSource.bulkDeleteConversations(ids);

      // 删除本地缓存
      for (final id in ids) {
        await _localDataSource.deleteCachedConversation(id);
      }

      return Right(deletedCount);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: '批量删除对话时发生未知错误: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rateConversation({
    required String id,
    required int rating,
    String? feedback,
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure(message: '评分对话需要网络连接'));
      }

      await _remoteDataSource.rateConversation(
        id: id,
        rating: rating,
        feedback: feedback,
      );

      // 更新本地缓存的评分信息
      try {
        final cachedConversation = await _localDataSource.getCachedConversation(id);
        if (cachedConversation != null) {
          final updatedConversation = cachedConversation.copyWith(
            rating: rating,
            feedback: feedback,
            updatedAt: DateTime.now(),
          ) as ConversationModel;

          await _localDataSource.cacheConversation(updatedConversation);
        }
      } catch (cacheError) {
        // 忽略缓存更新错误
      }

      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: '评分对话时发生未知错误: $e'));
    }
  }

  @override
  Future<Either<Failure, ConversationStats>> getConversationStats({
    DateTime? startDate,
    DateTime? endDate,
    String? knowledgeBaseId,
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure(message: '获取统计信息需要网络连接'));
      }

      final stats = await _remoteDataSource.getConversationStats(
        startDate: startDate,
        endDate: endDate,
        knowledgeBaseId: knowledgeBaseId,
      );

      return Right(stats.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure(message: '获取统计信息时发生未知错误: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Conversation>>> getCachedConversations() async {
    try {
      final conversations = await _localDataSource.getCachedConversations();
      return Right(conversations.map((c) => c.toEntity()).toList());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(CacheFailure(message: '获取缓存对话时发生错误: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheConversation(Conversation conversation) async {
    try {
      final conversationModel = ConversationModel.fromEntity(conversation);
      await _localDataSource.cacheConversation(conversationModel);
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(CacheFailure(message: '缓存对话时发生错误: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCachedConversation(String id) async {
    try {
      await _localDataSource.deleteCachedConversation(id);
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(CacheFailure(message: '删除缓存对话时发生错误: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await _localDataSource.clearCache();
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(CacheFailure(message: '清空缓存时发生错误: $e'));
    }
  }

  /// 将异常映射为失败对象
  Failure _mapExceptionToFailure(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return NetworkFailure(message: exception.message);
      case ServerException:
        return ServerFailure(message: exception.message);
      case ValidationException:
        return ValidationFailure(message: exception.message);
      case AuthenticationException:
        return AuthenticationFailure(message: exception.message);
      case AuthorizationException:
        return AuthorizationFailure(message: exception.message);
      case NotFoundException:
        return NotFoundFailure(message: exception.message);
      case RateLimitException:
        return RateLimitFailure(message: exception.message);
      case CacheException:
        return CacheFailure(message: exception.message);
      default:
        return UnknownFailure(message: exception.message);
    }
  }
} 