/// 权限实体
class Permission {
  final String id;
  final String name;
  final String displayName;
  final String action;
  final String resource;
  final String module;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Permission({
    required this.id,
    required this.name,
    required this.displayName,
    required this.action,
    required this.resource,
    required this.module,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Permission &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 角色实体
class Role {
  final String id;
  final String name;
  final String description;
  final List<Permission> permissions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Role({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Role &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 用户权限实体
class UserPermission {
  final String userId;
  final List<Role> roles;
  final List<Permission> directPermissions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserPermission({
    required this.userId,
    required this.roles,
    required this.directPermissions,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 获取所有权限（角色权限 + 直接权限）
  List<Permission> get allPermissions {
    final Set<Permission> permissions = {};
    
    // 添加角色中的权限
    for (final role in roles) {
      permissions.addAll(role.permissions);
    }
    
    // 添加直接权限
    permissions.addAll(directPermissions);
    
    return permissions.toList();
  }

  /// 检查是否有指定权限
  bool hasPermission(String action, String resource) {
    return allPermissions.any(
      (permission) => permission.action == action && permission.resource == resource,
    );
  }

  /// 检查是否有指定角色
  bool hasRole(String roleId) {
    return roles.any((role) => role.id == roleId);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPermission &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
} 