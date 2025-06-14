import 'package:equatable/equatable.dart';

abstract class PermissionEvent extends Equatable {
  const PermissionEvent();

  @override
  List<Object?> get props => [];
}

/// 加载当前用户权限
class LoadCurrentUserPermissions extends PermissionEvent {}

/// 加载所有权限
class LoadAllPermissions extends PermissionEvent {}

/// 加载所有角色
class LoadAllRoles extends PermissionEvent {}

/// 检查权限
class CheckPermissionEvent extends PermissionEvent {
  final String action;
  final String resource;
  final String? userId;

  const CheckPermissionEvent({
    required this.action,
    required this.resource,
    this.userId,
  });

  @override
  List<Object?> get props => [action, resource, userId];
}

/// 刷新权限缓存
class RefreshPermissions extends PermissionEvent {} 