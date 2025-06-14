const express = require('express');
const router = express.Router();
const PermissionController = require('../controllers/permissionController');
const PermissionMiddleware = require('../middleware/permission');

// 应用基础认证中间件
router.use(PermissionMiddleware.authenticate);

/**
 * 权限管理路由
 */

// 获取所有权限列表
router.get(
  '/permissions',
  PermissionMiddleware.requirePermission('permissions', 'read'),
  PermissionController.getAllPermissions
);

// 创建新权限
router.post(
  '/permissions',
  PermissionMiddleware.requirePermission('permissions', 'create'),
  PermissionController.createPermission
);

// 更新权限
router.put(
  '/permissions/:id',
  PermissionMiddleware.requirePermission('permissions', 'update'),
  PermissionController.updatePermission
);

// 删除权限
router.delete(
  '/permissions/:id',
  PermissionMiddleware.requirePermission('permissions', 'delete'),
  PermissionController.deletePermission
);

/**
 * 角色管理路由
 */

// 获取所有角色列表
router.get(
  '/roles',
  PermissionMiddleware.requirePermission('roles', 'read'),
  PermissionController.getAllRoles
);

// 创建新角色
router.post(
  '/roles',
  PermissionMiddleware.requirePermission('roles', 'create'),
  PermissionController.createRole
);

// 更新角色
router.put(
  '/roles/:id',
  PermissionMiddleware.requirePermission('roles', 'update'),
  PermissionController.updateRole
);

// 删除角色
router.delete(
  '/roles/:id',
  PermissionMiddleware.requirePermission('roles', 'delete'),
  PermissionController.deleteRole
);

// 为角色分配权限
router.post(
  '/roles/:roleId/permissions',
  PermissionMiddleware.requirePermission('roles', 'update'),
  PermissionController.assignPermissionsToRole
);

// 获取角色的权限列表
router.get(
  '/roles/:roleId/permissions',
  PermissionMiddleware.requirePermission('roles', 'read'),
  PermissionController.getRolePermissions
);

/**
 * 用户角色管理路由
 */

// 为用户分配角色
router.post(
  '/users/:userId/roles',
  PermissionMiddleware.requirePermission('users', 'update'),
  PermissionController.assignRoleToUser
);

// 移除用户角色
router.delete(
  '/users/:userId/roles/:roleId',
  PermissionMiddleware.requirePermission('users', 'update'),
  PermissionController.removeRoleFromUser
);

// 获取用户权限列表
router.get(
  '/users/:userId/permissions',
  PermissionMiddleware.requirePermission('users', 'read'),
  PermissionController.getUserPermissions
);

// 检查用户权限
router.post(
  '/users/:userId/check-permission',
  PermissionMiddleware.requirePermission('users', 'read'),
  PermissionController.checkUserPermission
);

/**
 * 当前用户权限相关路由（不需要特殊权限）
 */

// 获取当前用户的角色和权限
router.get('/me/permissions', async (req, res) => {
  try {
    const roles = await PermissionMiddleware.getUserRoles(req.user.id);
    const permissions = await PermissionMiddleware.getUserPermissions(req.user.id);

    res.json({
      success: true,
      data: {
        user: {
          id: req.user.id,
          username: req.user.username,
          email: req.user.email
        },
        roles,
        permissions
      }
    });
  } catch (error) {
    console.error('获取当前用户权限错误:', error);
    res.status(500).json({
      success: false,
      error: '获取权限信息失败'
    });
  }
});

// 检查当前用户是否有特定权限
router.post('/me/check-permission', async (req, res) => {
  try {
    const { resource, action } = req.body;

    if (!resource || !action) {
      return res.status(400).json({
        success: false,
        error: '资源和操作不能为空'
      });
    }

    const hasPermission = await PermissionMiddleware.checkUserPermission(
      req.user.id, 
      resource, 
      action
    );

    res.json({
      success: true,
      data: {
        hasPermission,
        resource,
        action
      }
    });
  } catch (error) {
    console.error('检查当前用户权限错误:', error);
    res.status(500).json({
      success: false,
      error: '检查权限失败'
    });
  }
});

module.exports = router; 