import '../../domain/entities/permission.dart';
import '../../domain/repositories/permission_repository.dart';
import '../datasources/permission_remote_data_source.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  final PermissionRemoteDataSource remoteDataSource;

  PermissionRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<UserPermission> getCurrentUserPermissions() {
    return remoteDataSource.getCurrentUserPermissions();
  }

  @override
  Future<UserPermission> getUserPermissions(String userId) {
    return remoteDataSource.getUserPermissions(userId);
  }

  @override
  Future<bool> checkPermission(String action, String resource, [String? userId]) {
    return remoteDataSource.checkPermission(action, resource, userId);
  }

  @override
  Future<List<Permission>> getAllPermissions() {
    return remoteDataSource.getAllPermissions();
  }

  @override
  Future<List<Role>> getAllRoles() {
    return remoteDataSource.getAllRoles();
  }

  @override
  Future<Permission> createPermission(Permission permission) {
    return remoteDataSource.createPermission(permission);
  }

  @override
  Future<Permission> updatePermission(String id, Permission permission) {
    return remoteDataSource.updatePermission(id, permission);
  }

  @override
  Future<void> deletePermission(String id) {
    return remoteDataSource.deletePermission(id);
  }

  @override
  Future<Role> createRole(Role role) {
    return remoteDataSource.createRole(role);
  }

  @override
  Future<Role> updateRole(String id, Role role) {
    return remoteDataSource.updateRole(id, role);
  }

  @override
  Future<void> deleteRole(String id) {
    return remoteDataSource.deleteRole(id);
  }

  @override
  Future<void> assignPermissionsToRole(String roleId, List<String> permissionIds) {
    return remoteDataSource.assignPermissionsToRole(roleId, permissionIds);
  }

  @override
  Future<void> assignRoleToUser(String userId, String roleId) {
    return remoteDataSource.assignRoleToUser(userId, roleId);
  }

  @override
  Future<void> removeRoleFromUser(String userId, String roleId) {
    return remoteDataSource.removeRoleFromUser(userId, roleId);
  }
} 