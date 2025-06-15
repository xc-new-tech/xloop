import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/network/network_info.dart';
import '../../core/network/api_client.dart';
import 'data/datasources/conversation_local_data_source.dart';
import 'data/datasources/conversation_remote_data_source.dart';
import 'data/repositories/conversation_repository_impl.dart';
import 'domain/repositories/conversation_repository.dart';
import 'domain/usecases/create_conversation_usecase.dart';
import 'domain/usecases/delete_conversation_usecase.dart';
import 'domain/usecases/get_conversation_usecase.dart';
import 'domain/usecases/get_conversations_usecase.dart';
import 'domain/usecases/get_conversation_stats_usecase.dart';
import 'domain/usecases/rate_conversation_usecase.dart';
import 'domain/usecases/send_message_usecase.dart';
import 'domain/usecases/update_conversation_usecase.dart';
import 'presentation/bloc/conversation_bloc.dart';

final sl = GetIt.instance;

Future<void> initConversationInjection() async {
  // External dependencies (should be registered globally)
  if (!sl.isRegistered<SharedPreferences>()) {
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  }

  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() => Dio());
  }

  if (!sl.isRegistered<Connectivity>()) {
    sl.registerLazySingleton<Connectivity>(() => Connectivity());
  }

  if (!sl.isRegistered<NetworkInfo>()) {
    sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(connectivity: sl<Connectivity>()),
    );
  }

  if (!sl.isRegistered<ApiClient>()) {
    sl.registerLazySingleton<ApiClient>(() => ApiClient());
  }

  // Data Sources
  sl.registerLazySingleton<ConversationRemoteDataSource>(
    () => ConversationRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<ConversationLocalDataSource>(
    () => ConversationLocalDataSourceImpl(prefs: sl<SharedPreferences>()),
  );

  // Repository
  sl.registerLazySingleton<ConversationRepository>(
    () => ConversationRepositoryImpl(
      remoteDataSource: sl<ConversationRemoteDataSource>(),
      localDataSource: sl<ConversationLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<CreateConversationUseCase>(
    () => CreateConversationUseCase(sl<ConversationRepository>()),
  );

  sl.registerLazySingleton<GetConversationsUseCase>(
    () => GetConversationsUseCase(sl<ConversationRepository>()),
  );

  sl.registerLazySingleton<GetConversationUseCase>(
    () => GetConversationUseCase(sl<ConversationRepository>()),
  );

  sl.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(sl<ConversationRepository>()),
  );

  sl.registerLazySingleton<UpdateConversationUseCase>(
    () => UpdateConversationUseCase(sl<ConversationRepository>()),
  );

  sl.registerLazySingleton<DeleteConversationUseCase>(
    () => DeleteConversationUseCase(sl<ConversationRepository>()),
  );

  sl.registerLazySingleton<BulkDeleteConversationsUseCase>(
    () => BulkDeleteConversationsUseCase(sl<ConversationRepository>()),
  );

  sl.registerLazySingleton<RateConversationUseCase>(
    () => RateConversationUseCase(sl<ConversationRepository>()),
  );

  sl.registerLazySingleton<GetConversationStatsUseCase>(
    () => GetConversationStatsUseCase(sl<ConversationRepository>()),
  );

  // Bloc
  sl.registerFactory<ConversationBloc>(
    () => ConversationBloc(
      createConversationUseCase: sl<CreateConversationUseCase>(),
      getConversationsUseCase: sl<GetConversationsUseCase>(),
      getConversationUseCase: sl<GetConversationUseCase>(),
      sendMessageUseCase: sl<SendMessageUseCase>(),
      updateConversationUseCase: sl<UpdateConversationUseCase>(),
      deleteConversationUseCase: sl<DeleteConversationUseCase>(),
      bulkDeleteConversationsUseCase: sl<BulkDeleteConversationsUseCase>(),
      rateConversationUseCase: sl<RateConversationUseCase>(),
      getConversationStatsUseCase: sl<GetConversationStatsUseCase>(),
    ),
  );
}

/// 清理对话系统的依赖注入
void cleanupConversationInjection() {
  // 清理 Bloc
  if (sl.isRegistered<ConversationBloc>()) {
    sl.unregister<ConversationBloc>();
  }

  // 清理 Use Cases
  if (sl.isRegistered<CreateConversationUseCase>()) {
    sl.unregister<CreateConversationUseCase>();
  }
  if (sl.isRegistered<GetConversationsUseCase>()) {
    sl.unregister<GetConversationsUseCase>();
  }
  if (sl.isRegistered<GetConversationUseCase>()) {
    sl.unregister<GetConversationUseCase>();
  }
  if (sl.isRegistered<SendMessageUseCase>()) {
    sl.unregister<SendMessageUseCase>();
  }
  if (sl.isRegistered<UpdateConversationUseCase>()) {
    sl.unregister<UpdateConversationUseCase>();
  }
  if (sl.isRegistered<DeleteConversationUseCase>()) {
    sl.unregister<DeleteConversationUseCase>();
  }
  if (sl.isRegistered<BulkDeleteConversationsUseCase>()) {
    sl.unregister<BulkDeleteConversationsUseCase>();
  }
  if (sl.isRegistered<RateConversationUseCase>()) {
    sl.unregister<RateConversationUseCase>();
  }
  if (sl.isRegistered<GetConversationStatsUseCase>()) {
    sl.unregister<GetConversationStatsUseCase>();
  }

  // 清理 Repository
  if (sl.isRegistered<ConversationRepository>()) {
    sl.unregister<ConversationRepository>();
  }

  // 清理 Data Sources  
  if (sl.isRegistered<ConversationRemoteDataSource>()) {
    sl.unregister<ConversationRemoteDataSource>();
  }
  if (sl.isRegistered<ConversationLocalDataSource>()) {
    sl.unregister<ConversationLocalDataSource>();
  }
} 