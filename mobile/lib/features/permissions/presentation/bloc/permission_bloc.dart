import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/check_permission.dart';
import 'permission_event.dart';
import 'permission_state.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  final CheckPermission checkPermission;
  final GetCurrentUserPermissions getCurrentUserPermissions;
  final GetAllPermissions getAllPermissions;
  final GetAllRoles getAllRoles;

  PermissionBloc({
    required this.checkPermission,
    required this.getCurrentUserPermissions,
    required this.getAllPermissions,
    required this.getAllRoles,
  }) : super(PermissionInitial()) {
    on<LoadCurrentUserPermissions>(_onLoadCurrentUserPermissions);
    on<LoadAllPermissions>(_onLoadAllPermissions);
    on<LoadAllRoles>(_onLoadAllRoles);
    on<CheckPermissionEvent>(_onCheckPermission);
    on<RefreshPermissions>(_onRefreshPermissions);
  }

  Future<void> _onLoadCurrentUserPermissions(
    LoadCurrentUserPermissions event,
    Emitter<PermissionState> emit,
  ) async {
    emit(PermissionLoading());
    try {
      final userPermissions = await getCurrentUserPermissions();
      
      if (state is PermissionLoaded) {
        emit((state as PermissionLoaded).copyWith(
          currentUserPermissions: userPermissions,
        ));
      } else {
        emit(PermissionLoaded(currentUserPermissions: userPermissions));
      }
    } catch (e) {
      emit(PermissionError(e.toString()));
    }
  }

  Future<void> _onLoadAllPermissions(
    LoadAllPermissions event,
    Emitter<PermissionState> emit,
  ) async {
    emit(PermissionLoading());
    try {
      final permissions = await getAllPermissions();
      
      if (state is PermissionLoaded) {
        emit((state as PermissionLoaded).copyWith(permissions: permissions));
      } else {
        emit(PermissionLoaded(permissions: permissions));
      }
    } catch (e) {
      emit(PermissionError(e.toString()));
    }
  }

  Future<void> _onLoadAllRoles(
    LoadAllRoles event,
    Emitter<PermissionState> emit,
  ) async {
    emit(PermissionLoading());
    try {
      final roles = await getAllRoles();
      
      if (state is PermissionLoaded) {
        emit((state as PermissionLoaded).copyWith(roles: roles));
      } else {
        emit(PermissionLoaded(roles: roles));
      }
    } catch (e) {
      emit(PermissionError(e.toString()));
    }
  }

  Future<void> _onCheckPermission(
    CheckPermissionEvent event,
    Emitter<PermissionState> emit,
  ) async {
    try {
      final hasPermission = await checkPermission(
        event.action,
        event.resource,
        event.userId,
      );

      if (state is PermissionLoaded) {
        final currentState = state as PermissionLoaded;
        final updatedChecks = Map<String, bool>.from(currentState.permissionChecks);
        updatedChecks['${event.action}_${event.resource}'] = hasPermission;
        
        emit(currentState.copyWith(permissionChecks: updatedChecks));
      }
    } catch (e) {
      emit(PermissionError(e.toString()));
    }
  }

  Future<void> _onRefreshPermissions(
    RefreshPermissions event,
    Emitter<PermissionState> emit,
  ) async {
    add(LoadCurrentUserPermissions());
    add(LoadAllPermissions());
    add(LoadAllRoles());
  }
} 