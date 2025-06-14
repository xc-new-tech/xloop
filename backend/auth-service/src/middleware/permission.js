const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Role = require('../models/Role');
const Permission = require('../models/Permission');
const UserRole = require('../models/UserRole');
const RolePermission = require('../models/RolePermission');
const { promisify } = require('util');
const asyncHandler = require('express-async-handler');

// JWT验证工具
const verifyToken = promisify(jwt.verify);

/**
 * 权限验证中间件
 */
class PermissionMiddleware {
  
  /**
   * 基础JWT认证中间件
   * 验证JWT token并将用户信息添加到req.user
   */
  static authenticate = asyncHandler(async (req, res, next) => {
    let token;

    // 从请求头获取token
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      try {
        // 提取token
        token = req.headers.authorization.split(' ')[1];
        
        // 验证token
        const decoded = await verifyToken(token, process.env.JWT_SECRET);
        
        // 获取用户信息（不包含密码）
        req.user = await User.findByPk(decoded.id, {
          attributes: { exclude: ['password', 'refreshTokenHash'] }
        });

        if (!req.user) {
          return res.status(401).json({
            success: false,
            error: 'Token无效，用户不存在'
          });
        }

        // 检查用户状态
        if (req.user.status !== 'active') {
          return res.status(401).json({
            success: false,
            error: '用户账户已被禁用'
          });
        }

        next();
      } catch (error) {
        console.error('JWT验证错误:', error);
        return res.status(401).json({
          success: false,
          error: 'Token无效'
        });
      }
    } else {
      return res.status(401).json({
        success: false,
        error: '未提供认证token'
      });
    }
  });

  /**
   * 权限检查中间件工厂函数
   * @param {string} resource - 资源名称
   * @param {string} action - 操作名称
   * @param {object} options - 额外选项
   */
  static requirePermission(resource, action, options = {}) {
    return asyncHandler(async (req, res, next) => {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: '未认证的请求'
        });
      }

      try {
        const hasPermission = await this.checkUserPermission(
          req.user.id, 
          resource, 
          action, 
          options
        );

        if (!hasPermission) {
          return res.status(403).json({
            success: false,
            error: '权限不足',
            required: `${resource}.${action}`
          });
        }

        next();
      } catch (error) {
        console.error('权限检查错误:', error);
        return res.status(500).json({
          success: false,
          error: '权限检查失败'
        });
      }
    });
  }

  /**
   * 角色检查中间件
   * @param {string|Array} roles - 需要的角色名称或角色名称数组
   */
  static requireRole(roles) {
    const requiredRoles = Array.isArray(roles) ? roles : [roles];
    
    return asyncHandler(async (req, res, next) => {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: '未认证的请求'
        });
      }

      try {
        const userRoles = await this.getUserRoles(req.user.id);
        const userRoleNames = userRoles.map(role => role.name);
        
        const hasRequiredRole = requiredRoles.some(role => userRoleNames.includes(role));
        
        if (!hasRequiredRole) {
          return res.status(403).json({
            success: false,
            error: '角色权限不足',
            required: requiredRoles,
            current: userRoleNames
          });
        }

        req.userRoles = userRoles;
        next();
      } catch (error) {
        console.error('角色检查错误:', error);
        return res.status(500).json({
          success: false,
          error: '角色检查失败'
        });
      }
    });
  }

  /**
   * 管理员权限检查
   */
  static requireAdmin = this.requireRole(['admin', 'super_admin']);

  /**
   * 超级管理员权限检查
   */
  static requireSuperAdmin = this.requireRole('super_admin');

  /**
   * 资源所有权检查中间件
   * @param {string} resourceModel - 资源模型名称
   * @param {string} resourceIdParam - 请求参数中的资源ID字段名
   * @param {string} ownerField - 资源模型中的所有者字段名
   */
  static requireOwnership(resourceModel, resourceIdParam = 'id', ownerField = 'ownerId') {
    return asyncHandler(async (req, res, next) => {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: '未认证的请求'
        });
      }

      try {
        const resourceId = req.params[resourceIdParam];
        const Model = require(`../models/${resourceModel}`);
        
        const resource = await Model.findByPk(resourceId);
        
        if (!resource) {
          return res.status(404).json({
            success: false,
            error: '资源不存在'
          });
        }

        // 检查是否为管理员（管理员可以访问所有资源）
        const userRoles = await this.getUserRoles(req.user.id);
        const isAdmin = userRoles.some(role => ['admin', 'super_admin'].includes(role.name));
        
        if (isAdmin || resource[ownerField] === req.user.id) {
          req.resource = resource;
          next();
        } else {
          return res.status(403).json({
            success: false,
            error: '无权访问此资源'
          });
        }
      } catch (error) {
        console.error('资源所有权检查错误:', error);
        return res.status(500).json({
          success: false,
          error: '权限检查失败'
        });
      }
    });
  }

  /**
   * 检查用户是否有特定权限
   * @param {string} userId - 用户ID
   * @param {string} resource - 资源名称
   * @param {string} action - 操作名称
   * @param {object} options - 额外选项
   */
  static async checkUserPermission(userId, resource, action, options = {}) {
    try {
      // 1. 获取用户所有有效角色
      const userRoles = await UserRole.findAll({
        where: {
          userId,
          isActive: true,
          [require('sequelize').Op.or]: [
            { expiresAt: null },
            { expiresAt: { [require('sequelize').Op.gt]: new Date() } }
          ]
        },
        include: [{
          model: Role,
          as: 'role',
          where: { isActive: true }
        }]
      });

      if (!userRoles.length) {
        return false;
      }

      // 2. 获取所需权限
      const permission = await Permission.findOne({
        where: {
          resource,
          action,
          isActive: true
        }
      });

      if (!permission) {
        console.warn(`权限不存在: ${resource}.${action}`);
        return false;
      }

      // 3. 检查角色是否包含该权限
      for (const userRole of userRoles) {
        const rolePermission = await RolePermission.findOne({
          where: {
            roleId: userRole.roleId,
            permissionId: permission.id,
            isActive: true
          }
        });

        if (rolePermission) {
          return true;
        }

        // 检查父角色权限（角色继承）
        const hasInheritedPermission = await this.checkRoleInheritedPermission(
          userRole.role, 
          permission.id
        );
        
        if (hasInheritedPermission) {
          return true;
        }
      }

      return false;
    } catch (error) {
      console.error('权限检查错误:', error);
      return false;
    }
  }

  /**
   * 检查角色继承权限
   * @param {object} role - 角色对象
   * @param {string} permissionId - 权限ID
   */
  static async checkRoleInheritedPermission(role, permissionId) {
    if (!role.parentRoleId) {
      return false;
    }

    try {
      // 检查父角色是否有该权限
      const parentRolePermission = await RolePermission.findOne({
        where: {
          roleId: role.parentRoleId,
          permissionId,
          isActive: true
        }
      });

      if (parentRolePermission) {
        return true;
      }

      // 递归检查祖先角色
      const parentRole = await Role.findByPk(role.parentRoleId);
      if (parentRole) {
        return await this.checkRoleInheritedPermission(parentRole, permissionId);
      }

      return false;
    } catch (error) {
      console.error('角色继承权限检查错误:', error);
      return false;
    }
  }

  /**
   * 获取用户角色列表
   * @param {string} userId - 用户ID
   */
  static async getUserRoles(userId) {
    try {
      const userRoles = await UserRole.findAll({
        where: {
          userId,
          isActive: true,
          [require('sequelize').Op.or]: [
            { expiresAt: null },
            { expiresAt: { [require('sequelize').Op.gt]: new Date() } }
          ]
        },
        include: [{
          model: Role,
          as: 'role',
          where: { isActive: true }
        }],
        order: [
          [{ model: Role, as: 'role' }, 'level', 'DESC']
        ]
      });

      return userRoles.map(ur => ur.role);
    } catch (error) {
      console.error('获取用户角色错误:', error);
      return [];
    }
  }

  /**
   * 获取用户权限列表
   * @param {string} userId - 用户ID
   */
  static async getUserPermissions(userId) {
    try {
      const userRoles = await this.getUserRoles(userId);
      const permissions = new Set();

      for (const role of userRoles) {
        const rolePermissions = await RolePermission.findAll({
          where: {
            roleId: role.id,
            isActive: true
          },
          include: [{
            model: Permission,
            as: 'permission',
            where: { isActive: true }
          }]
        });

        rolePermissions.forEach(rp => {
          permissions.add(rp.permission);
        });

        // 添加继承的权限
        const inheritedPermissions = await this.getRoleInheritedPermissions(role);
        inheritedPermissions.forEach(p => permissions.add(p));
      }

      return Array.from(permissions);
    } catch (error) {
      console.error('获取用户权限错误:', error);
      return [];
    }
  }

  /**
   * 获取角色继承权限
   * @param {object} role - 角色对象
   */
  static async getRoleInheritedPermissions(role) {
    const permissions = [];
    
    if (!role.parentRoleId) {
      return permissions;
    }

    try {
      const parentRolePermissions = await RolePermission.findAll({
        where: {
          roleId: role.parentRoleId,
          isActive: true
        },
        include: [{
          model: Permission,
          as: 'permission',
          where: { isActive: true }
        }]
      });

      permissions.push(...parentRolePermissions.map(rp => rp.permission));

      // 递归获取祖先角色权限
      const parentRole = await Role.findByPk(role.parentRoleId);
      if (parentRole) {
        const ancestorPermissions = await this.getRoleInheritedPermissions(parentRole);
        permissions.push(...ancestorPermissions);
      }

      return permissions;
    } catch (error) {
      console.error('获取角色继承权限错误:', error);
      return [];
    }
  }
}

module.exports = PermissionMiddleware; 