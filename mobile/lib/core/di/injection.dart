import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../network/network_info.dart';
import '../storage/token_storage.dart';
import '../storage/app_preferences.dart';
import '../constants/api_constants.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/refresh_token_usecase.dart';
import '../../features/auth/presentation/blocs/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  // 配置Dio实例使用正确的base URL
  sl.registerLazySingleton(() {
    final dio = Dio();
    dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return dio;
  });
  
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => Logger());

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(connectivity: sl()));
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage(sl()));
  sl.registerLazySingleton<AppPreferences>(() => AppPreferences(sharedPreferences: sl()));

  // Auth data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  // Auth repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      tokenStorage: sl(),
      logger: sl(),
    ),
  );

  // Auth use cases
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));
  sl.registerLazySingleton(() => RefreshTokenUsecase(sl()));

  // Auth BLoC
  sl.registerFactory(() => AuthBloc(
    authRepository: sl(),
    logger: sl(),
  ));
} 