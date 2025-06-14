const axios = require('axios');
const logger = require('../config/logger');

/**
 * 认证中间件
 * 验证JWT token并获取用户信息
 */
const authenticate = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
   
    if (!token) {
      return res.status(401).json({
        success: false,
        error: '未提供认证令牌',
        code: 'NO_TOKEN'
      });
    }

    // 调用认证服务验证token
    const authServiceUrl = process.env.AUTH_SERVICE_URL || 'http://localhost:3001';
   
    try {
      const response = await axios.get(`${authServiceUrl}/api/auth/verify`, {
        headers: {
          'Authorization': `Bearer ${token}`
        },
        timeout: 5000
      });

      if (response.data.success) {
        // 将用户信息添加到请求对象
        req.user = response.data.user;
        next();
      } else {
        return res.status(401).json({
          success: false,
          error: '认证令牌无效',
          code: 'INVALID_TOKEN'
        });
      }
    } catch (authError) {
      logger.error('认证服务调用失败:', authError.message);
     
      // 如果认证服务不可用，在开发环境下允许跳过认证
      if (process.env.NODE_ENV === 'development') {
        logger.warn('开发环境：跳过认证验证');
        req.user = {
          id: 'dev-user-id',
          email: 'dev@example.com',
          role: 'admin'
        };
        return next();
      }
     
      return res.status(503).json({
        success: false,
        error: '认证服务不可用',
        code: 'AUTH_SERVICE_UNAVAILABLE'
      });
    }
  } catch (error) {
    logger.error('认证中间件错误:', error);
    return res.status(500).json({
      success: false,
      error: '认证处理失败',
      code: 'AUTH_ERROR'
    });
  }
};

/**
 * 可选认证中间件
 * 如果提供了token则验证，否则继续
 */
const optionalAuth = async (req, res, next) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
 
  if (!token) {
    return next();
  }
 
  return authenticate(req, res, next);
};

/**
 * 角色验证中间件
 * @param {string|array} roles - 允许的角色
 */
const requireRole = (roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: '需要认证',
        code: 'AUTHENTICATION_REQUIRED'
      });
    }

    const userRole = req.user.role;
    const allowedRoles = Array.isArray(roles) ? roles : [roles];
   
    if (!allowedRoles.includes(userRole)) {
      return res.status(403).json({
        success: false,
        error: '权限不足',
        code: 'INSUFFICIENT_PERMISSIONS',
        required: allowedRoles,
        current: userRole
      });
    }

    next();
  };
};

module.exports = {
  authenticate,
  authenticateToken: authenticate,  // 别名
  requireAuth: authenticate,        // 别名
  optionalAuth,
  requireRole
};