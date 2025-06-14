const Permission = require('../models/Permission');
const Role = require('../models/Role');
const UserRole = require('../models/UserRole');
const RolePermission = require('../models/RolePermission');
const User = require('../models/User');
const PermissionMiddleware = require('../middleware/permission');
const { Op } = require('sequelize');
const asyncHandler = require('express-async-handler');

/**
 * 权限管理控制器
 */
class PermissionController {

  /**
   * 获取所有权限列表
   */
  static getAllPermissions = asyncHandler(async (req, res) => {
    try {
      const { module, resource, action, isActive = true } = req.query;
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 20;
      const offset = (page - 1) * limit;

      const where = {};
      if (module) where.module = module;
      if (resource) where.resource = resource;
      if (action) where.action = action;
      if (isActive !== 'all') where.isActive = isActive === 'true';

      const { count, rows: permissions } = await Permission.findAndCountAll({
        where,
        order: [['module', 'ASC'], ['resource', 'ASC'], ['priority', 'DESC']],
        limit,
        offset
      });

      res.json({
        success: true,
        data: {
          permissions,
          pagination: {
            total: count,
            page,
            limit,
            totalPages: Math.ceil(count / limit)
          }
        }
      });
    } catch (error) {
      console.error('获取权限列表错误:', error);
      res.status(500).json({
        success: false,
        error: '获取权限列表失败'
      });
    }
  });

  /**
   * 创建新权限
   */
  static createPermission = asyncHandler(async (req, res) => {
    try {
      const {
        name,
        displayName,
        description,
        resource,
        action,
        module,
        priority = 0,
        conditions
      } = req.body;

      // 验证必需字段
      if (!name || !displayName || !resource || !action || !module) {
        return res.status(400).json({
          success: false,
          error: '缺少必需字段'
        });
      }

      // 检查权限名称是否已存在
      const existingPermission = await Permission.findOne({
        where: { name }
      });

      if (existingPermission) {
        return res.status(409).json({
          success: false,
          error: '权限名称已存在'
        });
      }

      // 检查资源-操作组合是否已存在
      const existingResourceAction = await Permission.findOne({
        where: { resource, action }
      });

      if (existingResourceAction) {
        return res.status(409).json({
          success: false,
          error: '该资源的操作权限已存在'
        });
      }

      const permission = await Permission.create({
        name,
        displayName,
        description,
        resource,
        action,
        module,
        priority,
        conditions
      });

      res.status(201).json({
        success: true,
        data: { permission }
      });
    } catch (error) {
      console.error('创建权限错误:', error);
      res.status(500).json({
        success: false,
        error: '创建权限失败'
      });
    }
  });

  /**
   * 更新权限
   */
  static updatePermission = asyncHandler(async (req, res) => {
    try {
      const { id } = req.params;
      const {
        displayName,
        description,
        priority,
        conditions,
        isActive
      } = req.body;

      const permission = await Permission.findByPk(id);
      if (!permission) {
        return res.status(404).json({
          success: false,
          error: '权限不存在'
        });
      }

      // 系统权限的某些字段不允许修改
      if (permission.isSystem) {
        const restrictedFields = ['name', 'resource', 'action', 'module'];
        const hasRestrictedFields = restrictedFields.some(field => req.body[field]);
        
        if (hasRestrictedFields) {
          return res.status(403).json({
            success: false,
            error: '系统权限的核心字段不能修改'
          });
        }
      }

      await permission.update({
        displayName: displayName || permission.displayName,
        description: description || permission.description,
        priority: priority !== undefined ? priority : permission.priority,
        conditions: conditions || permission.conditions,
        isActive: isActive !== undefined ? isActive : permission.isActive
      });

      res.json({
        success: true,
        data: { permission }
      });
    } catch (error) {
      console.error('更新权限错误:', error);
      res.status(500).json({
        success: false,
        error: '更新权限失败'
      });
    }
  });

  /**
   * 删除权限
   */
  static deletePermission = asyncHandler(async (req, res) => {
    try {
      const { id } = req.params;

      const permission = await Permission.findByPk(id);
      if (!permission) {
        return res.status(404).json({
          success: false,
          error: '权限不存在'
        });
      }

      if (permission.isSystem) {
        return res.status(403).json({
          success: false,
          error: '系统权限不能删除'
        });
      }

      // 检查是否有角色正在使用该权限
      const rolePermissionCount = await RolePermission.count({
        where: {
          permissionId: id,
          isActive: true
        }
      });

      if (rolePermissionCount > 0) {
        return res.status(409).json({
          success: false,
          error: '该权限正在被角色使用，无法删除'
        });
      }

      await permission.destroy();

      res.json({
        success: true,
        message: '权限已删除'
      });
    } catch (error) {
      console.error('删除权限错误:', error);
      res.status(500).json({
        success: false,
        error: '删除权限失败'
      });
    }
  });

  /**
   * 获取所有角色列表
   */
  static getAllRoles = asyncHandler(async (req, res) => {
    try {
      const { type, isActive = true } = req.query;
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 20;
      const offset = (page - 1) * limit;

      const where = {};
      if (type) where.type = type;
      if (isActive !== 'all') where.isActive = isActive === 'true';

      const { count, rows: roles } = await Role.findAndCountAll({
        where,
        include: [
          {
            model: Role,
            as: 'parentRole',
            attributes: ['id', 'name', 'displayName']
          }
        ],
        order: [['level', 'DESC'], ['name', 'ASC']],
        limit,
        offset
      });

      res.json({
        success: true,
        data: {
          roles,
          pagination: {
            total: count,
            page,
            limit,
            totalPages: Math.ceil(count / limit)
          }
        }
      });
    } catch (error) {
      console.error('获取角色列表错误:', error);
      res.status(500).json({
        success: false,
        error: '获取角色列表失败'
      });
    }
  });

  /**
   * 创建新角色
   */
  static createRole = asyncHandler(async (req, res) => {
    try {
      const {
        name,
        displayName,
        description,
        type = 'custom',
        level = 0,
        parentRoleId,
        settings
      } = req.body;

      // 验证必需字段
      if (!name || !displayName) {
        return res.status(400).json({
          success: false,
          error: '缺少必需字段'
        });
      }

      // 检查角色名称是否已存在
      const existingRole = await Role.findOne({
        where: { name }
      });

      if (existingRole) {
        return res.status(409).json({
          success: false,
          error: '角色名称已存在'
        });
      }

      // 验证父角色是否存在
      if (parentRoleId) {
        const parentRole = await Role.findByPk(parentRoleId);
        if (!parentRole) {
          return res.status(404).json({
            success: false,
            error: '父角色不存在'
          });
        }
      }

      const role = await Role.create({
        name,
        displayName,
        description,
        type,
        level,
        parentRoleId,
        settings,
        createdBy: req.user.id
      });

      res.status(201).json({
        success: true,
        data: { role }
      });
    } catch (error) {
      console.error('创建角色错误:', error);
      res.status(500).json({
        success: false,
        error: '创建角色失败'
      });
    }
  });

  /**
   * 更新角色
   */
  static updateRole = asyncHandler(async (req, res) => {
    try {
      const { id } = req.params;
      const {
        displayName,
        description,
        level,
        parentRoleId,
        settings,
        isActive
      } = req.body;

      const role = await Role.findByPk(id);
      if (!role) {
        return res.status(404).json({
          success: false,
          error: '角色不存在'
        });
      }

      // 系统角色的某些字段不允许修改
      if (role.isSystem) {
        const restrictedFields = ['name', 'type'];
        const hasRestrictedFields = restrictedFields.some(field => req.body[field]);
        
        if (hasRestrictedFields) {
          return res.status(403).json({
            success: false,
            error: '系统角色的核心字段不能修改'
          });
        }
      }

      // 验证父角色是否存在
      if (parentRoleId) {
        const parentRole = await Role.findByPk(parentRoleId);
        if (!parentRole) {
          return res.status(404).json({
            success: false,
            error: '父角色不存在'
          });
        }

        // 防止循环继承
        if (parentRoleId === id) {
          return res.status(400).json({
            success: false,
            error: '角色不能继承自己'
          });
        }
      }

      await role.update({
        displayName: displayName || role.displayName,
        description: description || role.description,
        level: level !== undefined ? level : role.level,
        parentRoleId: parentRoleId !== undefined ? parentRoleId : role.parentRoleId,
        settings: settings || role.settings,
        isActive: isActive !== undefined ? isActive : role.isActive
      });

      res.json({
        success: true,
        data: { role }
      });
    } catch (error) {
      console.error('更新角色错误:', error);
      res.status(500).json({
        success: false,
        error: '更新角色失败'
      });
    }
  });

  /**
   * 删除角色
   */
  static deleteRole = asyncHandler(async (req, res) => {
    try {
      const { id } = req.params;

      const role = await Role.findByPk(id);
      if (!role) {
        return res.status(404).json({
          success: false,
          error: '角色不存在'
        });
      }

      if (role.isSystem) {
        return res.status(403).json({
          success: false,
          error: '系统角色不能删除'
        });
      }

      // 检查是否有用户正在使用该角色
      const userRoleCount = await UserRole.count({
        where: {
          roleId: id,
          isActive: true
        }
      });

      if (userRoleCount > 0) {
        return res.status(409).json({
          success: false,
          error: '该角色正在被用户使用，无法删除'
        });
      }

      // 检查是否有子角色
      const childRoleCount = await Role.count({
        where: {
          parentRoleId: id,
          isActive: true
        }
      });

      if (childRoleCount > 0) {
        return res.status(409).json({
          success: false,
          error: '该角色有子角色，无法删除'
        });
      }

      await role.destroy();

      res.json({
        success: true,
        message: '角色已删除'
      });
    } catch (error) {
      console.error('删除角色错误:', error);
      res.status(500).json({
        success: false,
        error: '删除角色失败'
      });
    }
  });

  /**
   * 为角色分配权限
   */
  static assignPermissionsToRole = asyncHandler(async (req, res) => {
    try {
      const { roleId } = req.params;
      const { permissionIds } = req.body;

      if (!Array.isArray(permissionIds) || permissionIds.length === 0) {
        return res.status(400).json({
          success: false,
          error: '权限ID列表不能为空'
        });
      }

      const role = await Role.findByPk(roleId);
      if (!role) {
        return res.status(404).json({
          success: false,
          error: '角色不存在'
        });
      }

      // 验证权限是否存在
      const permissions = await Permission.findAll({
        where: {
          id: { [Op.in]: permissionIds },
          isActive: true
        }
      });

      if (permissions.length !== permissionIds.length) {
        return res.status(404).json({
          success: false,
          error: '部分权限不存在'
        });
      }

      // 删除现有权限关联
      await RolePermission.destroy({
        where: { roleId }
      });

      // 创建新的权限关联
      const rolePermissions = permissionIds.map(permissionId => ({
        roleId,
        permissionId,
        grantedBy: req.user.id
      }));

      await RolePermission.bulkCreate(rolePermissions);

      res.json({
        success: true,
        message: '权限分配成功'
      });
    } catch (error) {
      console.error('分配权限错误:', error);
      res.status(500).json({
        success: false,
        error: '分配权限失败'
      });
    }
  });

  /**
   * 获取角色的权限列表
   */
  static getRolePermissions = asyncHandler(async (req, res) => {
    try {
      const { roleId } = req.params;

      const role = await Role.findByPk(roleId);
      if (!role) {
        return res.status(404).json({
          success: false,
          error: '角色不存在'
        });
      }

      const rolePermissions = await RolePermission.findAll({
        where: {
          roleId,
          isActive: true
        },
        include: [{
          model: Permission,
          as: 'permission',
          where: { isActive: true }
        }],
        order: [
          [{ model: Permission, as: 'permission' }, 'module', 'ASC'],
          [{ model: Permission, as: 'permission' }, 'priority', 'DESC']
        ]
      });

      const permissions = rolePermissions.map(rp => rp.permission);

      res.json({
        success: true,
        data: {
          role,
          permissions
        }
      });
    } catch (error) {
      console.error('获取角色权限错误:', error);
      res.status(500).json({
        success: false,
        error: '获取角色权限失败'
      });
    }
  });

  /**
   * 为用户分配角色
   */
  static assignRoleToUser = asyncHandler(async (req, res) => {
    try {
      const { userId } = req.params;
      const { roleId, expiresAt, scope = 'global', scopeId } = req.body;

      if (!roleId) {
        return res.status(400).json({
          success: false,
          error: '角色ID不能为空'
        });
      }

      // 验证用户是否存在
      const user = await User.findByPk(userId);
      if (!user) {
        return res.status(404).json({
          success: false,
          error: '用户不存在'
        });
      }

      // 验证角色是否存在
      const role = await Role.findByPk(roleId);
      if (!role) {
        return res.status(404).json({
          success: false,
          error: '角色不存在'
        });
      }

      // 检查是否已经分配过该角色
      const existingUserRole = await UserRole.findOne({
        where: {
          userId,
          roleId,
          isActive: true
        }
      });

      if (existingUserRole) {
        return res.status(409).json({
          success: false,
          error: '用户已拥有该角色'
        });
      }

      const userRole = await UserRole.create({
        userId,
        roleId,
        scope,
        scopeId,
        expiresAt: expiresAt ? new Date(expiresAt) : null,
        grantedBy: req.user.id
      });

      res.status(201).json({
        success: true,
        data: { userRole }
      });
    } catch (error) {
      console.error('分配角色错误:', error);
      res.status(500).json({
        success: false,
        error: '分配角色失败'
      });
    }
  });

  /**
   * 移除用户角色
   */
  static removeRoleFromUser = asyncHandler(async (req, res) => {
    try {
      const { userId, roleId } = req.params;

      const userRole = await UserRole.findOne({
        where: {
          userId,
          roleId,
          isActive: true
        }
      });

      if (!userRole) {
        return res.status(404).json({
          success: false,
          error: '用户角色关联不存在'
        });
      }

      await userRole.update({ isActive: false });

      res.json({
        success: true,
        message: '角色已移除'
      });
    } catch (error) {
      console.error('移除角色错误:', error);
      res.status(500).json({
        success: false,
        error: '移除角色失败'
      });
    }
  });

  /**
   * 获取用户权限列表
   */
  static getUserPermissions = asyncHandler(async (req, res) => {
    try {
      const { userId } = req.params;

      const user = await User.findByPk(userId);
      if (!user) {
        return res.status(404).json({
          success: false,
          error: '用户不存在'
        });
      }

      const roles = await PermissionMiddleware.getUserRoles(userId);
      const permissions = await PermissionMiddleware.getUserPermissions(userId);

      res.json({
        success: true,
        data: {
          user: {
            id: user.id,
            username: user.username,
            email: user.email,
            status: user.status
          },
          roles,
          permissions
        }
      });
    } catch (error) {
      console.error('获取用户权限错误:', error);
      res.status(500).json({
        success: false,
        error: '获取用户权限失败'
      });
    }
  });

  /**
   * 检查用户权限
   */
  static checkUserPermission = asyncHandler(async (req, res) => {
    try {
      const { userId } = req.params;
      const { resource, action } = req.body;

      if (!resource || !action) {
        return res.status(400).json({
          success: false,
          error: '资源和操作不能为空'
        });
      }

      const hasPermission = await PermissionMiddleware.checkUserPermission(
        userId, 
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
      console.error('检查用户权限错误:', error);
      res.status(500).json({
        success: false,
        error: '检查权限失败'
      });
    }
  });
}

module.exports = PermissionController; 