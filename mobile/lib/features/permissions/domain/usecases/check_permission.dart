import '../entities/permission.dart';
import '../repositories/permission_repository.dart';

/// 检查权限用例
class CheckPermission {
  final PermissionRepository repository;

  CheckPermission(this.repository);

  Future<bool> call(String action, String resource, [String? userId]) {
    return repository.checkPermission(action, resource, userId);
  }
}

/// 获取当前用户权限用例
class GetCurrentUserPermissions {
  final PermissionRepository repository;

  GetCurrentUserPermissions(this.repository);

  Future<UserPermission> call() {
    return repository.getCurrentUserPermissions();
  }
}

/// 获取权限列表用例
class GetAllPermissions {
  final PermissionRepository repository;

  GetAllPermissions(this.repository);

  Future<List<Permission>> call() {
    return repository.getAllPermissions();
  }
}

/// 获取角色列表用例
class GetAllRoles {
  final PermissionRepository repository;

  GetAllRoles(this.repository);

  Future<List<Role>> call() {
    return repository.getAllRoles();
  }
} 