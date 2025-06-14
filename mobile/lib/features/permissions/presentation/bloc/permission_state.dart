import 'package:equatable/equatable.dart';
import '../../domain/entities/permission.dart';

abstract class PermissionState extends Equatable {
  const PermissionState();

  @override
  List<Object?> get props => [];
}

class PermissionInitial extends PermissionState {}

class PermissionLoading extends PermissionState {}

class PermissionLoaded extends PermissionState {
  final UserPermission? currentUserPermissions;
  final List<Permission> permissions;
  final List<Role> roles;
  final Map<String, bool> permissionChecks;

  const PermissionLoaded({
    this.currentUserPermissions,
    this.permissions = const [],
    this.roles = const [],
    this.permissionChecks = const {},
  });

  PermissionLoaded copyWith({
    UserPermission? currentUserPermissions,
    List<Permission>? permissions,
    List<Role>? roles,
    Map<String, bool>? permissionChecks,
  }) {
    return PermissionLoaded(
      currentUserPermissions: currentUserPermissions ?? this.currentUserPermissions,
      permissions: permissions ?? this.permissions,
      roles: roles ?? this.roles,
      permissionChecks: permissionChecks ?? this.permissionChecks,
    );
  }

  /// 检查权限的便捷方法
  bool hasPermission(String action, String resource) {
    final key = '${action}_$resource';
    return permissionChecks[key] ?? false;
  }

  @override
  List<Object?> get props => [currentUserPermissions, permissions, roles, permissionChecks];
}

class PermissionError extends PermissionState {
  final String message;

  const PermissionError(this.message);

  @override
  List<Object> get props => [message];
} 