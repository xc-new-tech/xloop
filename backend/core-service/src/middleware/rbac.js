const { User, Role, Permission } = require('../models');
const logger = require('../utils/logger');
const { ApiError } = require('../utils/errors');

/**
 * 基于角色的访问控制中间件
 * Role-Based Access Control (RBAC) Middleware
 */

/**
 * 检查用户权限
 * @param {string|string[]} requiredPermissions - 所需权限
 * @param {Object} options - 选项配置
 * @returns {Function} Express中间件函数
 */
function requirePermissions(requiredPermissions, options = {}) {
  const {
    allowSelf = false, // 是否允许用户访问自己的资源
    resourceIdParam = 'id', // 资源ID参数名
    userIdField = 'userId', // 用户ID字段名
    strict = true // 严格模式，需要所有权限
  } = options;

  return async (req, res, next) => {
    try {
      // 确保用户已认证
      if (!req.user) {
        return res.status(401).json({
          success: false,
          message: '未认证用户'
        });
      }

      const userId = req.user.id;
      const permissions = Array.isArray(requiredPermissions) 
        ? requiredPermissions 
        : [requiredPermissions];

      // 获取用户及其角色权限
      const user = await User.findByPk(userId, {
        include: [
          {
            model: Role,
            as: 'roles',
            include: [
              {
                model: Permission,
                as: 'permissions',
                attributes: ['name', 'resource', 'action']
              }
            ]
          }
        ]
      });

      if (!user) {
        return res.status(401).json({
          success: false,
          message: '用户不存在'
        });
      }

      // 检查用户状态
      if (user.status !== 'active') {
        return res.status(403).json({
          success: false,
          message: '用户账户已被禁用'
        });
      }

      // 超级管理员拥有所有权限
      const isSuperAdmin = user.roles.some(role => role.name === 'super_admin');
      if (isSuperAdmin) {
        req.userPermissions = ['*'];
        return next();
      }

      // 收集用户所有权限
      const userPermissions = new Set();
      user.roles.forEach(role => {
        if (role.status === 'active') {
          role.permissions.forEach(permission => {
            userPermissions.add(permission.name);
            // 添加资源.动作格式的权限
            userPermissions.add(`${permission.resource}.${permission.action}`);
          });
        }
      });

      req.userPermissions = Array.from(userPermissions);

      // 检查是否允许访问自己的资源
      if (allowSelf && req.params[resourceIdParam]) {
        const resourceId = req.params[resourceIdParam];
        
        // 检查资源是否属于当前用户
        if (await isOwnResource(req, resourceId, userIdField)) {
          return next();
        }
      }

      // 检查权限
      const hasPermission = strict 
        ? permissions.every(permission => userPermissions.has(permission))
        : permissions.some(permission => userPermissions.has(permission));

      if (!hasPermission) {
        logger.warn(`用户 ${userId} 尝试访问需要权限 [${permissions.join(', ')}] 的资源`, {
          userId,
          requiredPermissions: permissions,
          userPermissions: Array.from(userPermissions),
          ip: req.ip,
          userAgent: req.get('User-Agent')
        });

        return res.status(403).json({
          success: false,
          message: '权限不足',
          details: {
            required: permissions,
            missing: permissions.filter(p => !userPermissions.has(p))
          }
        });
      }

      next();

    } catch (error) {
      logger.error('权限检查失败:', error);
      
      if (error instanceof ApiError) {
        return res.status(error.statusCode).json({
          success: false,
          message: error.message
        });
      }

      res.status(500).json({
        success: false,
        message: '权限验证过程中发生错误'
      });
    }
  };
}

/**
 * 检查用户角色
 * @param {string|string[]} requiredRoles - 所需角色
 * @param {Object} options - 选项配置
 * @returns {Function} Express中间件函数
 */
function requireRoles(requiredRoles, options = {}) {
  const { strict = false } = options; // 严格模式，需要所有角色

  return async (req, res, next) => {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          message: '未认证用户'
        });
      }

      const userId = req.user.id;
      const roles = Array.isArray(requiredRoles) ? requiredRoles : [requiredRoles];

      // 获取用户角色
      const user = await User.findByPk(userId, {
        include: [
          {
            model: Role,
            as: 'roles',
            attributes: ['name', 'status']
          }
        ]
      });

      if (!user) {
        return res.status(401).json({
          success: false,
          message: '用户不存在'
        });
      }

      const userRoles = user.roles
        .filter(role => role.status === 'active')
        .map(role => role.name);

      req.userRoles = userRoles;

      // 超级管理员角色
      if (userRoles.includes('super_admin')) {
        return next();
      }

      // 检查角色
      const hasRole = strict 
        ? roles.every(role => userRoles.includes(role))
        : roles.some(role => userRoles.includes(role));

      if (!hasRole) {
        logger.warn(`用户 ${userId} 尝试访问需要角色 [${roles.join(', ')}] 的资源`, {
          userId,
          requiredRoles: roles,
          userRoles,
          ip: req.ip,
          userAgent: req.get('User-Agent')
        });

        return res.status(403).json({
          success: false,
          message: '角色权限不足',
          details: {
            required: roles,
            current: userRoles
          }
        });
      }

      next();

    } catch (error) {
      logger.error('角色检查失败:', error);
      
      res.status(500).json({
        success: false,
        message: '角色验证过程中发生错误'
      });
    }
  };
}

/**
 * 检查资源所有权
 * @param {Object} req - 请求对象
 * @param {string} resourceId - 资源ID
 * @param {string} userIdField - 用户ID字段名
 * @returns {Promise<boolean>} 是否拥有资源
 */
async function isOwnResource(req, resourceId, userIdField = 'userId') {
  try {
    const userId = req.user.id;
    
    // 根据路由路径确定资源类型
    const resourceType = getResourceTypeFromPath(req.path);
    
    if (!resourceType) {
      return false;
    }

    // 动态导入模型
    const Model = require('../models')[resourceType];
    if (!Model) {
      return false;
    }

    const resource = await Model.findByPk(resourceId);
    
    if (!resource) {
      return false;
    }

    // 检查资源是否属于当前用户
    return resource[userIdField] === userId;

  } catch (error) {
    logger.error('检查资源所有权失败:', error);
    return false;
  }
}

/**
 * 从路径获取资源类型
 * @param {string} path - 请求路径
 * @returns {string|null} 资源类型
 */
function getResourceTypeFromPath(path) {
  const pathMappings = {
    '/api/conversations': 'Conversation',
    '/api/knowledge-bases': 'KnowledgeBase',
    '/api/documents': 'Document',
    '/api/faqs': 'FAQ',
    '/api/files': 'File',
    '/api/users': 'User'
  };

  for (const [pathPrefix, modelName] of Object.entries(pathMappings)) {
    if (path.startsWith(pathPrefix)) {
      return modelName;
    }
  }

  return null;
}

/**
 * 资源所有权检查中间件
 * @param {string} userIdField - 用户ID字段名
 * @param {string} resourceIdParam - 资源ID参数名
 * @returns {Function} Express中间件函数
 */
function requireOwnership(userIdField = 'userId', resourceIdParam = 'id') {
  return async (req, res, next) => {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          message: '未认证用户'
        });
      }

      const resourceId = req.params[resourceIdParam];
      if (!resourceId) {
        return res.status(400).json({
          success: false,
          message: '缺少资源ID'
        });
      }

      const isOwner = await isOwnResource(req, resourceId, userIdField);
      
      if (!isOwner) {
        logger.warn(`用户 ${req.user.id} 尝试访问不属于自己的资源 ${resourceId}`, {
          userId: req.user.id,
          resourceId,
          ip: req.ip,
          userAgent: req.get('User-Agent')
        });

        return res.status(403).json({
          success: false,
          message: '无权访问此资源'
        });
      }

      next();

    } catch (error) {
      logger.error('资源所有权检查失败:', error);
      
      res.status(500).json({
        success: false,
        message: '权限验证过程中发生错误'
      });
    }
  };
}

/**
 * 组合权限检查中间件
 * @param {Object} config - 配置对象
 * @returns {Function} Express中间件函数
 */
function requireAccess(config) {
  const {
    permissions = [],
    roles = [],
    allowSelf = false,
    ownership = false,
    userIdField = 'userId',
    resourceIdParam = 'id'
  } = config;

  return async (req, res, next) => {
    try {
      // 首先检查角色（如果指定）
      if (roles.length > 0) {
        const roleCheck = requireRoles(roles);
        const roleResult = await new Promise((resolve) => {
          roleCheck(req, res, (error) => {
            resolve(error);
          });
        });

        if (roleResult) {
          return;
        }
      }

      // 检查所有权（如果启用）
      if (ownership) {
        const ownershipCheck = requireOwnership(userIdField, resourceIdParam);
        const ownershipResult = await new Promise((resolve) => {
          ownershipCheck(req, res, (error) => {
            resolve(error);
          });
        });

        if (ownershipResult) {
          return;
        }
      }

      // 检查权限（如果指定）
      if (permissions.length > 0) {
        const permissionCheck = requirePermissions(permissions, {
          allowSelf,
          resourceIdParam,
          userIdField
        });
        
        const permissionResult = await new Promise((resolve) => {
          permissionCheck(req, res, (error) => {
            resolve(error);
          });
        });

        if (permissionResult) {
          return;
        }
      }

      next();

    } catch (error) {
      logger.error('组合权限检查失败:', error);
      
      res.status(500).json({
        success: false,
        message: '权限验证过程中发生错误'
      });
    }
  };
}

/**
 * 预定义权限常量
 */
const PERMISSIONS = {
  // 用户管理
  USER_CREATE: 'users.create',
  USER_READ: 'users.read',
  USER_UPDATE: 'users.update',
  USER_DELETE: 'users.delete',
  USER_MANAGE: 'users.manage',

  // 知识库管理
  KNOWLEDGE_BASE_CREATE: 'knowledge_bases.create',
  KNOWLEDGE_BASE_READ: 'knowledge_bases.read',
  KNOWLEDGE_BASE_UPDATE: 'knowledge_bases.update',
  KNOWLEDGE_BASE_DELETE: 'knowledge_bases.delete',
  KNOWLEDGE_BASE_MANAGE: 'knowledge_bases.manage',

  // 文档管理
  DOCUMENT_CREATE: 'documents.create',
  DOCUMENT_READ: 'documents.read',
  DOCUMENT_UPDATE: 'documents.update',
  DOCUMENT_DELETE: 'documents.delete',
  DOCUMENT_MANAGE: 'documents.manage',

  // FAQ管理
  FAQ_CREATE: 'faqs.create',
  FAQ_READ: 'faqs.read',
  FAQ_UPDATE: 'faqs.update',
  FAQ_DELETE: 'faqs.delete',
  FAQ_MANAGE: 'faqs.manage',

  // 对话管理
  CONVERSATION_CREATE: 'conversations.create',
  CONVERSATION_READ: 'conversations.read',
  CONVERSATION_UPDATE: 'conversations.update',
  CONVERSATION_DELETE: 'conversations.delete',
  CONVERSATION_MANAGE: 'conversations.manage',

  // 系统管理
  SYSTEM_CONFIG: 'system.config',
  SYSTEM_MONITOR: 'system.monitor',
  SYSTEM_BACKUP: 'system.backup',
  SYSTEM_ADMIN: 'system.admin'
};

/**
 * 预定义角色常量
 */
const ROLES = {
  SUPER_ADMIN: 'super_admin',
  ADMIN: 'admin',
  MANAGER: 'manager',
  EDITOR: 'editor',
  USER: 'user',
  GUEST: 'guest'
};

module.exports = {
  requirePermissions,
  requireRoles,
  requireOwnership,
  requireAccess,
  isOwnResource,
  PERMISSIONS,
  ROLES
}; 