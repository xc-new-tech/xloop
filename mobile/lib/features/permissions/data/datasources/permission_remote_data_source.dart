import '../../domain/entities/permission.dart';

/// 权限远程数据源接口
abstract class PermissionRemoteDataSource {
  Future<UserPermission> getCurrentUserPermissions();
  Future<UserPermission> getUserPermissions(String userId);
  Future<bool> checkPermission(String action, String resource, [String? userId]);
  Future<List<Permission>> getAllPermissions();
  Future<List<Role>> getAllRoles();
  Future<Permission> createPermission(Permission permission);
  Future<Permission> updatePermission(String id, Permission permission);
  Future<void> deletePermission(String id);
  Future<Role> createRole(Role role);
  Future<Role> updateRole(String id, Role role);
  Future<void> deleteRole(String id);
  Future<void> assignPermissionsToRole(String roleId, List<String> permissionIds);
  Future<void> assignRoleToUser(String userId, String roleId);
  Future<void> removeRoleFromUser(String userId, String roleId);
}

/// 权限远程数据源实现
class PermissionRemoteDataSourceImpl implements PermissionRemoteDataSource {
  // 模拟数据 - 在实际项目中应该连接真实API
  final List<Permission> _mockPermissions = [
    Permission(
      id: '1',
      name: 'read_users',
      displayName: '查看用户',
      action: 'read',
      resource: 'users',
      module: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Permission(
      id: '2',
      name: 'create_knowledge_base',
      displayName: '创建知识库',
      action: 'create',
      resource: 'knowledge_bases',
      module: 'knowledge',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final List<Role> _mockRoles = [
    Role(
      id: '1',
      name: 'admin',
      description: '系统管理员',
      permissions: [],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<UserPermission> getCurrentUserPermissions() async {
    // 模拟API调用延迟
    await Future.delayed(const Duration(milliseconds: 500));
    
    return UserPermission(
      userId: 'current_user',
      roles: _mockRoles,
      directPermissions: _mockPermissions,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<UserPermission> getUserPermissions(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return UserPermission(
      userId: userId,
      roles: _mockRoles,
      directPermissions: _mockPermissions,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<bool> checkPermission(String action, String resource, [String? userId]) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 简单的模拟逻辑
    return _mockPermissions.any(
      (p) => p.action == action && p.resource == resource,
    );
  }

  @override
  Future<List<Permission>> getAllPermissions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockPermissions;
  }

  @override
  Future<List<Role>> getAllRoles() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockRoles;
  }

  @override
  Future<Permission> createPermission(Permission permission) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockPermissions.add(permission);
    return permission;
  }

  @override
  Future<Permission> updatePermission(String id, Permission permission) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockPermissions.indexWhere((p) => p.id == id);
    if (index != -1) {
      _mockPermissions[index] = permission;
    }
    return permission;
  }

  @override
  Future<void> deletePermission(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockPermissions.removeWhere((p) => p.id == id);
  }

  @override
  Future<Role> createRole(Role role) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockRoles.add(role);
    return role;
  }

  @override
  Future<Role> updateRole(String id, Role role) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockRoles.indexWhere((r) => r.id == id);
    if (index != -1) {
      _mockRoles[index] = role;
    }
    return role;
  }

  @override
  Future<void> deleteRole(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockRoles.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> assignPermissionsToRole(String roleId, List<String> permissionIds) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // 模拟实现
  }

  @override
  Future<void> assignRoleToUser(String userId, String roleId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // 模拟实现
  }

  @override
  Future<void> removeRoleFromUser(String userId, String roleId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // 模拟实现
  }
} 