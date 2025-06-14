const JWTUtils = require('../utils/jwt');
const { User, UserSession } = require('../models');

/**
 * JWT认证中间件
 * 验证请求中的访问令牌并提取用户信息
 */
const authenticateJWT = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    const token = JWTUtils.extractBearerToken(authHeader);

    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'NO_TOKEN',
        message: '访问被拒绝，未提供认证令牌',
      });
    }

    // 验证访问令牌
    let decoded;
    try {
      decoded = JWTUtils.verifyAccessToken(token);
    } catch (jwtError) {
      return res.status(401).json({
        success: false,
        error: 'INVALID_TOKEN',
        message: '无效或过期的访问令牌',
      });
    }

    // 从数据库获取用户信息
    const user = await User.findByPk(decoded.userId, {
      attributes: ['id', 'username', 'email', 'role', 'status', 'email_verified']
    });

    if (!user) {
      return res.status(401).json({
        success: false,
        error: 'USER_NOT_FOUND',
        message: '用户不存在',
      });
    }

    // 检查用户状态
    if (user.status !== 'active') {
      return res.status(403).json({
        success: false,
        error: 'ACCOUNT_DISABLED',
        message: '账户已被禁用',
      });
    }

    // 检查邮箱验证状态
    if (!user.email_verified) {
      return res.status(403).json({
        success: false,
        error: 'EMAIL_NOT_VERIFIED',
        message: '请先验证您的邮箱',
      });
    }

    // 将用户信息添加到请求对象
    req.user = user;
    req.token = token;

    next();
  } catch (error) {
    console.error('JWT认证中间件错误:', error);
    return res.status(500).json({
      success: false,
      error: 'AUTH_MIDDLEWARE_ERROR',
      message: '认证中间件内部错误',
    });
  }
};

/**
 * 可选的JWT认证中间件
 * 如果提供了令牌则验证，否则继续执行（用于可选认证的接口）
 */
const optionalJWT = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    const token = JWTUtils.extractBearerToken(authHeader);

    if (!token) {
      // 没有令牌，直接继续
      req.user = null;
      return next();
    }

    // 有令牌则验证
    try {
      const decoded = JWTUtils.verifyAccessToken(token);
      const user = await User.findByPk(decoded.userId, {
        attributes: ['id', 'username', 'email', 'role', 'status', 'email_verified']
      });

      if (user && user.status === 'active' && user.email_verified) {
        req.user = user;
        req.token = token;
      } else {
        req.user = null;
      }
    } catch (jwtError) {
      // 令牌无效，但不阻止请求
      req.user = null;
    }

    next();
  } catch (error) {
    console.error('可选JWT认证中间件错误:', error);
    req.user = null;
    next();
  }
};

/**
 * 基于角色的访问控制中间件
 * @param {Array|string} allowedRoles - 允许的角色列表
 * @returns {Function} Express中间件函数
 */
const requireRole = (allowedRoles) => {
  return (req, res, next) => {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: 'AUTHENTICATION_REQUIRED',
          message: '需要身份认证',
        });
      }

      // 标准化角色列表
      const roles = Array.isArray(allowedRoles) ? allowedRoles : [allowedRoles];

      // 检查用户角色
      if (!roles.includes(req.user.role)) {
        return res.status(403).json({
          success: false,
          error: 'INSUFFICIENT_PERMISSIONS',
          message: '权限不足，无法访问此资源',
          details: {
            required: roles,
            current: req.user.role,
          },
        });
      }

      next();
    } catch (error) {
      console.error('角色权限中间件错误:', error);
      return res.status(500).json({
        success: false,
        error: 'PERMISSION_MIDDLEWARE_ERROR',
        message: '权限检查中间件内部错误',
      });
    }
  };
};

/**
 * 用户身份验证中间件（确保用户只能访问自己的资源）
 * @param {string} userIdParam - 参数名（默认为'userId'或'id'）
 * @returns {Function} Express中间件函数
 */
const requireOwnership = (userIdParam = 'userId') => {
  return (req, res, next) => {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: 'AUTHENTICATION_REQUIRED',
          message: '需要身份认证',
        });
      }

      // 从参数中获取目标用户ID
      const targetUserId = req.params[userIdParam] || req.params.id;

      if (!targetUserId) {
        return res.status(400).json({
          success: false,
          error: 'MISSING_USER_ID',
          message: '缺少用户ID参数',
        });
      }

      // 管理员可以访问所有资源
      if (req.user.role === 'admin') {
        return next();
      }

      // 检查是否为资源所有者
      if (req.user.id !== targetUserId) {
        return res.status(403).json({
          success: false,
          error: 'ACCESS_DENIED',
          message: '无权访问其他用户的资源',
        });
      }

      next();
    } catch (error) {
      console.error('所有权验证中间件错误:', error);
      return res.status(500).json({
        success: false,
        error: 'OWNERSHIP_MIDDLEWARE_ERROR',
        message: '所有权验证中间件内部错误',
      });
    }
  };
};

/**
 * 管理员专用中间件
 */
const requireAdmin = requireRole('admin');

/**
 * 管理员或版主中间件
 */
const requireModerator = requireRole(['admin', 'moderator']);

/**
 * 用户认证状态检查中间件（用于登出等需要验证当前会话的操作）
 */
const requireValidSession = async (req, res, next) => {
  try {
    if (!req.user || !req.token) {
      return res.status(401).json({
        success: false,
        error: 'AUTHENTICATION_REQUIRED',
        message: '需要有效的认证会话',
      });
    }

    // 验证当前访问令牌对应的会话是否有效
    const decoded = JWTUtils.verifyAccessToken(req.token);
    
    // 检查是否存在有效的用户会话
    const activeSession = await UserSession.findOne({
      where: {
        user_id: req.user.id,
        status: 'active',
      },
    });

    if (!activeSession) {
      return res.status(401).json({
        success: false,
        error: 'SESSION_EXPIRED',
        message: '会话已过期，请重新登录',
      });
    }

    req.session = activeSession;
    next();
  } catch (error) {
    console.error('会话验证中间件错误:', error);
    return res.status(500).json({
      success: false,
      error: 'SESSION_MIDDLEWARE_ERROR',
      message: '会话验证中间件内部错误',
    });
  }
};

/**
 * API调用频率限制装饰器
 * @param {Object} options - 限制选项
 * @param {number} options.maxRequests - 最大请求数
 * @param {number} options.windowMs - 时间窗口（毫秒）
 * @param {string} options.message - 超限消息
 * @returns {Function} Express中间件函数
 */
const createRateLimit = (options = {}) => {
  const {
    maxRequests = 100,
    windowMs = 15 * 60 * 1000, // 15分钟
    message = '请求过于频繁，请稍后再试',
  } = options;

  const requests = new Map();

  return (req, res, next) => {
    try {
      const identifier = req.user ? req.user.id : req.ip;
      const now = Date.now();
      const windowStart = now - windowMs;

      // 清理过期记录
      if (requests.has(identifier)) {
        const userRequests = requests.get(identifier).filter(time => time > windowStart);
        requests.set(identifier, userRequests);
      }

      // 获取当前窗口内的请求数
      const currentRequests = requests.get(identifier) || [];

      if (currentRequests.length >= maxRequests) {
        return res.status(429).json({
          success: false,
          error: 'RATE_LIMIT_EXCEEDED',
          message,
          retryAfter: Math.ceil((currentRequests[0] + windowMs - now) / 1000),
        });
      }

      // 记录当前请求
      currentRequests.push(now);
      requests.set(identifier, currentRequests);

      next();
    } catch (error) {
      console.error('频率限制中间件错误:', error);
      next(); // 出错时不阻止请求
    }
  };
};

module.exports = {
  authenticateJWT,
  optionalJWT,
  requireRole,
  requireOwnership,
  requireAdmin,
  requireModerator,
  requireValidSession,
  createRateLimit,
}; 