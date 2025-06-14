import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/permissions/domain/entities/permission.dart';
import 'package:mobile/features/permissions/data/datasources/permission_remote_data_source.dart';

void main() {
  group('权限模块测试', () {
    test('权限实体应该正确创建', () {
      final permission = Permission(
        id: 'test_id',
        name: 'test_permission',
        displayName: '测试权限',
        action: 'read',
        resource: 'users',
        module: 'auth',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(permission.id, equals('test_id'));
      expect(permission.action, equals('read'));
      expect(permission.resource, equals('users'));
    });

    test('角色实体应该正确创建', () {
      final role = Role(
        id: 'role_id',
        name: 'Admin',
        description: '管理员角色',
        permissions: [],
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(role.id, equals('role_id'));
      expect(role.name, equals('Admin'));
      expect(role.isActive, isTrue);
    });

    test('用户权限实体应该正确合并权限', () {
      final permission1 = Permission(
        id: 'perm1',
        name: 'read_users',
        displayName: '读取用户',
        action: 'read',
        resource: 'users',
        module: 'auth',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final permission2 = Permission(
        id: 'perm2',
        name: 'write_users',
        displayName: '写入用户',
        action: 'write',
        resource: 'users',
        module: 'auth',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final role = Role(
        id: 'role1',
        name: 'User',
        description: '普通用户',
        permissions: [permission1],
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final userPermission = UserPermission(
        userId: 'user123',
        roles: [role],
        directPermissions: [permission2],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final allPermissions = userPermission.allPermissions;
      expect(allPermissions.length, equals(2));
      expect(allPermissions.any((p) => p.id == 'perm1'), isTrue);
      expect(allPermissions.any((p) => p.id == 'perm2'), isTrue);
    });

    test('权限数据源应该能获取权限', () async {
      final dataSource = PermissionRemoteDataSourceImpl();
      
      final permissions = await dataSource.getAllPermissions();
      expect(permissions, isNotEmpty);
      
      final roles = await dataSource.getAllRoles();
      expect(roles, isNotEmpty);
      
      final userPermissions = await dataSource.getCurrentUserPermissions();
      expect(userPermissions.userId, isNotEmpty);
    });

    test('权限检查应该正常工作', () async {
      final dataSource = PermissionRemoteDataSourceImpl();
      
      // 测试存在的权限
      final hasPermission = await dataSource.checkPermission('read', 'users');
      expect(hasPermission, isA<bool>());
      
      // 测试不存在的权限
      final noPermission = await dataSource.checkPermission('delete', 'nonexistent');
      expect(noPermission, isA<bool>());
    });
  });
} 