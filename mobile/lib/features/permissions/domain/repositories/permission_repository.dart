import '../entities/permission.dart';

/// 权限仓库接口
abstract class PermissionRepository {
  /// 获取当前用户权限
  Future<UserPermission> getCurrentUserPermissions();
  
  /// 获取指定用户权限
  Future<UserPermission> getUserPermissions(String userId);
  
  /// 检查权限
  Future<bool> checkPermission(String action, String resource, [String? userId]);
  
  /// 获取所有权限
  Future<List<Permission>> getAllPermissions();
  
  /// 获取所有角色
  Future<List<Role>> getAllRoles();
  
  /// 创建权限
  Future<Permission> createPermission(Permission permission);
  
  /// 更新权限
  Future<Permission> updatePermission(String id, Permission permission);
  
  /// 删除权限
  Future<void> deletePermission(String id);
  
  /// 创建角色
  Future<Role> createRole(Role role);
  
  /// 更新角色
  Future<Role> updateRole(String id, Role role);
  
  /// 删除角色
  Future<void> deleteRole(String id);
  
  /// 为角色分配权限
  Future<void> assignPermissionsToRole(String roleId, List<String> permissionIds);
  
  /// 为用户分配角色
  Future<void> assignRoleToUser(String userId, String roleId);
  
  /// 移除用户角色
  Future<void> removeRoleFromUser(String userId, String roleId);
} 