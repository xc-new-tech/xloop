import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

// Core
import '../api/api_client.dart';
import '../network/network_info.dart';
import '../storage/app_preferences.dart';
import '../storage/token_storage.dart';
import '../storage/token_manager.dart';
import '../utils/logger_utils.dart';

// Features - Auth
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/refresh_token_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/verify_email_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/blocs/auth_bloc.dart';

// Features - Knowledge Base
import '../../features/knowledge/data/datasources/knowledge_base_remote_data_source.dart';
import '../../features/knowledge/data/repositories/knowledge_base_repository_impl.dart';
import '../../features/knowledge/domain/repositories/knowledge_base_repository.dart';
import '../../features/knowledge/domain/usecases/get_knowledge_bases.dart';
import '../../features/knowledge/domain/usecases/get_knowledge_base.dart';
import '../../features/knowledge/domain/usecases/create_knowledge_base.dart';
import '../../features/knowledge/domain/usecases/update_knowledge_base.dart';
import '../../features/knowledge/domain/usecases/delete_knowledge_base.dart';
import '../../features/knowledge/presentation/bloc/knowledge_base_bloc.dart';

// Features - FAQ
import '../../features/faq/data/datasources/faq_remote_data_source.dart';
import '../../features/faq/data/repositories/faq_repository_impl.dart';
import '../../features/faq/domain/repositories/faq_repository.dart';
import '../../features/faq/domain/usecases/get_faqs_usecase.dart';
import '../../features/faq/domain/usecases/create_faq_usecase.dart';
import '../../features/faq/domain/usecases/delete_faq_usecase.dart';
import '../../features/faq/presentation/bloc/faq_bloc.dart';

// Features - Analytics
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';

// Features - Permissions
import '../../features/permissions/di/permission_injection.dart' as permission_di;

// 临时BLoC实现
import '../../features/search/presentation/bloc/search_bloc_impl.dart';

// 核心功能
import '../localization/localization_manager.dart';

/// 服务定位器 - 管理所有依赖注入
final GetIt sl = GetIt.instance;

/// 初始化所有依赖
Future<void> initializeDependencies() async {
  // ===============================
  // 外部依赖（第三方库）
  // ===============================
  
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  
  // FlutterSecureStorage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  );
  
  // Connectivity
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  
  // Logger
  sl.registerLazySingleton<Logger>(() => LoggerUtils.logger);
  
  // LocalizationManager
  sl.registerLazySingleton<LocalizationManager>(() => LocalizationManager());

  // ===============================
  // 核心功能
  // ===============================
  
  // 网络连接检查
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl()),
  );
  
  // Token存储
  final tokenStorage = await TokenStorage.getInstance();
  sl.registerLazySingleton<TokenStorage>(() => tokenStorage);
  
  // Token管理器
  sl.registerLazySingleton<TokenManager>(
    () => TokenManager(sl()),
  );
  
  // 应用偏好设置
  sl.registerLazySingleton<AppPreferences>(
    () => AppPreferences(sharedPreferences: sl()),
  );
  
  // 认证服务Dio实例
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options = BaseOptions(
      baseUrl: 'http://localhost:3001',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return dio;
  }, instanceName: 'authDio');

  // 核心服务Dio实例（知识库、文件、对话等）
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options = BaseOptions(
      baseUrl: 'http://localhost:3000', // 暂时使用3000端口，因为后端服务可能在这个端口
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return dio;
  }, instanceName: 'coreDio');

  // 默认Dio实例（向后兼容）
  sl.registerLazySingleton<Dio>(() => sl<Dio>(instanceName: 'authDio'));
  
  // API客户端
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(),
  );

  // ===============================
  // 认证功能
  // ===============================
  
  // 数据源
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: sl<Dio>(instanceName: 'authDio'),
    ),
  );
  
  // 存储库
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      tokenStorage: sl(),
      logger: sl(),
    ),
  );
  
  // 用例
  sl.registerLazySingleton<LoginUsecase>(
    () => LoginUsecase(sl()),
  );
  
  // LogoutUsecase 暂时注释掉，因为还未实现
  // sl.registerLazySingleton<LogoutUsecase>(
  //   () => LogoutUsecase(sl()),
  // );
  
  sl.registerLazySingleton<RegisterUsecase>(
    () => RegisterUsecase(sl()),
  );
  
  sl.registerLazySingleton<RefreshTokenUsecase>(
    () => RefreshTokenUsecase(sl()),
  );
  
  sl.registerLazySingleton<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCase(sl()),
  );
  
  sl.registerLazySingleton<VerifyEmailUseCase>(
    () => VerifyEmailUseCase(sl()),
  );
  
  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl()),
  );
  
  // BLoC
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: sl(),
      logger: sl(),
    ),
  );

  // ===============================
  // 知识库功能
  // ===============================
  
  // 数据源
  sl.registerLazySingleton<KnowledgeBaseRemoteDataSource>(
    () => KnowledgeBaseRemoteDataSourceImpl(sl<ApiClient>()),
  );
  
  // 存储库
  sl.registerLazySingleton<KnowledgeBaseRepository>(
    () => KnowledgeBaseRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
      logger: sl(),
    ),
  );
  
  // 用例
  sl.registerLazySingleton<GetKnowledgeBases>(
    () => GetKnowledgeBases(sl()),
  );
  
  sl.registerLazySingleton<GetKnowledgeBase>(
    () => GetKnowledgeBase(sl()),
  );
  
  sl.registerLazySingleton<CreateKnowledgeBase>(
    () => CreateKnowledgeBase(sl()),
  );
  
  sl.registerLazySingleton<UpdateKnowledgeBase>(
    () => UpdateKnowledgeBase(sl()),
  );
  
  sl.registerLazySingleton<DeleteKnowledgeBase>(
    () => DeleteKnowledgeBase(sl()),
  );
  
  // BLoC
  sl.registerFactory<KnowledgeBaseBloc>(
    () => KnowledgeBaseBloc(
      getKnowledgeBases: sl(),
      getKnowledgeBase: sl(),
      createKnowledgeBase: sl(),
      updateKnowledgeBase: sl(),
      deleteKnowledgeBase: sl(),
      localizationManager: sl(),
      logger: sl(),
    ),
  );

  // ===============================
  // FAQ功能
  // ===============================
  
  // 数据源
  sl.registerLazySingleton<FaqRemoteDataSource>(
    () => FaqRemoteDataSourceImpl(
      apiClient: sl(),
    ),
  );
  
  // 存储库
  sl.registerLazySingleton<FaqRepository>(
    () => FaqRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // 用例
  sl.registerLazySingleton<GetFaqsUseCase>(
    () => GetFaqsUseCase(sl()),
  );
  
  sl.registerLazySingleton<CreateFaqUseCase>(
    () => CreateFaqUseCase(sl()),
  );
  
  sl.registerLazySingleton<DeleteFaqUseCase>(
    () => DeleteFaqUseCase(sl()),
  );
  
  // BLoC
  sl.registerFactory<FaqBloc>(
    () => FaqBloc(
      faqRepository: sl(),
      getFaqsUseCase: sl(),
      createFaqUseCase: sl(),
      deleteFaqUseCase: sl(),
    ),
  );

  // ===============================
  // 权限管理功能
  // ===============================
  permission_di.PermissionInjection.configureDependencies();

  // ===============================
  // 搜索功能 (临时注册，实际应该有完整的实现)
  // ===============================
  
  // 临时BLoC注册 - 实际使用时需要添加完整的数据源、存储库、用例等
  sl.registerFactory(() => SearchBlocImpl());

  // ===============================
  // 分析功能 (临时注册，实际应该有完整的实现)
  // ===============================
  
  // 临时BLoC注册 - 实际使用时需要添加完整的数据源、存储库、用例等
  sl.registerFactory(() => AnalyticsBloc());
}

/// 重置所有依赖（主要用于测试）
Future<void> resetDependencies() async {
  await sl.reset();
}

 