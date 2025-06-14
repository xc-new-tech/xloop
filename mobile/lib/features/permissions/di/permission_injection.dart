import 'package:get_it/get_it.dart';

import '../data/datasources/permission_remote_data_source.dart';
import '../data/repositories/permission_repository_impl.dart';
import '../domain/repositories/permission_repository.dart';
import '../domain/usecases/check_permission.dart';
import '../presentation/bloc/permission_bloc.dart';

final sl = GetIt.instance;

class PermissionInjection {
  static void configureDependencies() {
    // Data sources
    sl.registerLazySingleton<PermissionRemoteDataSource>(
      () => PermissionRemoteDataSourceImpl(),
    );

    // Repository
    sl.registerLazySingleton<PermissionRepository>(
      () => PermissionRepositoryImpl(
        remoteDataSource: sl(),
      ),
    );

    // Use cases
    sl.registerLazySingleton(() => CheckPermission(sl()));
    sl.registerLazySingleton(() => GetCurrentUserPermissions(sl()));
    sl.registerLazySingleton(() => GetAllPermissions(sl()));
    sl.registerLazySingleton(() => GetAllRoles(sl()));

    // BLoC
    sl.registerFactory(
      () => PermissionBloc(
        checkPermission: sl(),
        getCurrentUserPermissions: sl(),
        getAllPermissions: sl(),
        getAllRoles: sl(),
      ),
    );
  }
} 