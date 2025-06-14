const logger = require('../utils/logger');
const { AuditLog } = require('../models');

/**
 * 安全审计日志中间件
 * Security Audit Logging Middleware
 */

/**
 * 审计日志级别
 */
const AUDIT_LEVELS = {
  INFO: 'info',
  WARNING: 'warning',
  ERROR: 'error',
  CRITICAL: 'critical'
};

/**
 * 审计事件类型
 */
const AUDIT_EVENTS = {
  // 认证相关
  LOGIN_SUCCESS: 'auth.login.success',
  LOGIN_FAILED: 'auth.login.failed',
  LOGOUT: 'auth.logout',
  PASSWORD_CHANGE: 'auth.password.change',
  PASSWORD_RESET: 'auth.password.reset',
  TOKEN_REFRESH: 'auth.token.refresh',
  
  // 权限相关
  ACCESS_DENIED: 'permission.access.denied',
  PERMISSION_GRANTED: 'permission.access.granted',
  ROLE_ASSIGNED: 'permission.role.assigned',
  ROLE_REMOVED: 'permission.role.removed',
  
  // 数据操作
  DATA_CREATE: 'data.create',
  DATA_READ: 'data.read',
  DATA_UPDATE: 'data.update',
  DATA_DELETE: 'data.delete',
  DATA_EXPORT: 'data.export',
  DATA_IMPORT: 'data.import',
  
  // 系统管理
  SYSTEM_CONFIG_CHANGE: 'system.config.change',
  SYSTEM_BACKUP: 'system.backup',
  SYSTEM_RESTORE: 'system.restore',
  SYSTEM_MAINTENANCE: 'system.maintenance',
  
  // 安全事件
  SECURITY_BREACH_ATTEMPT: 'security.breach.attempt',
  SUSPICIOUS_ACTIVITY: 'security.suspicious.activity',
  RATE_LIMIT_EXCEEDED: 'security.rate_limit.exceeded',
  INVALID_TOKEN: 'security.token.invalid'
};

/**
 * 创建审计日志记录
 * @param {Object} auditData - 审计数据
 */
async function createAuditLog(auditData) {
  try {
    const {
      event,
      level = AUDIT_LEVELS.INFO,
      userId,
      resource,
      resourceId,
      action,
      details = {},
      ipAddress,
      userAgent,
      success = true,
      errorMessage,
      metadata = {}
    } = auditData;

    const auditLog = await AuditLog.create({
      event,
      level,
      userId,
      resource,
      resourceId,
      action,
      details: {
        ...details,
        timestamp: new Date().toISOString(),
        success,
        errorMessage
      },
      ipAddress,
      userAgent,
      metadata
    });

    // 记录到系统日志
    const logMessage = `审计日志: ${event} - ${success ? '成功' : '失败'}`;
    const logData = {
      auditId: auditLog.id,
      userId,
      resource,
      resourceId,
      action,
      ipAddress,
      userAgent
    };

    switch (level) {
      case AUDIT_LEVELS.CRITICAL:
        logger.error(logMessage, logData);
        break;
      case AUDIT_LEVELS.ERROR:
        logger.error(logMessage, logData);
        break;
      case AUDIT_LEVELS.WARNING:
        logger.warn(logMessage, logData);
        break;
      default:
        logger.info(logMessage, logData);
    }

    return auditLog;

  } catch (error) {
    logger.error('创建审计日志失败:', error);
  }
}

/**
 * 审计日志中间件
 * @param {Object} config - 配置选项
 * @returns {Function} Express中间件函数
 */
function auditLog(config = {}) {
  const {
    event,
    resource,
    action,
    level = AUDIT_LEVELS.INFO,
    captureRequest = false,
    captureResponse = false,
    excludeFields = ['password', 'token', 'secret'],
    skipSuccessLog = false
  } = config;

  return async (req, res, next) => {
    const startTime = Date.now();
    
    // 保存原始的 res.json 方法
    const originalJson = res.json;
    let responseData = null;
    let statusCode = null;

    // 重写 res.json 方法以捕获响应数据
    res.json = function(data) {
      responseData = data;
      statusCode = res.statusCode;
      return originalJson.call(this, data);
    };

    // 在响应结束后记录审计日志
    res.on('finish', async () => {
      try {
        const duration = Date.now() - startTime;
        const success = statusCode >= 200 && statusCode < 400;
        
        // 如果配置跳过成功日志且当前是成功响应，则跳过
        if (skipSuccessLog && success) {
          return;
        }

        const auditData = {
          event: event || inferEventFromRequest(req),
          level: success ? level : AUDIT_LEVELS.ERROR,
          userId: req.user?.id,
          resource: resource || inferResourceFromPath(req.path),
          resourceId: req.params.id,
          action: action || inferActionFromMethod(req.method),
          details: {
            method: req.method,
            path: req.path,
            statusCode,
            duration,
            ...(captureRequest && {
              requestBody: sanitizeData(req.body, excludeFields),
              requestParams: req.params,
              requestQuery: req.query
            }),
            ...(captureResponse && {
              responseBody: sanitizeData(responseData, excludeFields)
            })
          },
          ipAddress: getClientIP(req),
          userAgent: req.get('User-Agent'),
          success,
          errorMessage: !success ? responseData?.message : undefined,
          metadata: {
            requestId: req.id,
            sessionId: req.sessionID,
            correlationId: req.headers['x-correlation-id']
          }
        };

        await createAuditLog(auditData);

      } catch (error) {
        logger.error('审计日志记录失败:', error);
      }
    });

    next();
  };
}

/**
 * 从请求推断事件类型
 * @param {Object} req - 请求对象
 * @returns {string} 事件类型
 */
function inferEventFromRequest(req) {
  const method = req.method.toLowerCase();
  const path = req.path.toLowerCase();

  if (path.includes('/auth/login')) {
    return AUDIT_EVENTS.LOGIN_SUCCESS;
  }
  if (path.includes('/auth/logout')) {
    return AUDIT_EVENTS.LOGOUT;
  }
  if (path.includes('/auth/password')) {
    return AUDIT_EVENTS.PASSWORD_CHANGE;
  }

  switch (method) {
    case 'post':
      return AUDIT_EVENTS.DATA_CREATE;
    case 'get':
      return AUDIT_EVENTS.DATA_READ;
    case 'put':
    case 'patch':
      return AUDIT_EVENTS.DATA_UPDATE;
    case 'delete':
      return AUDIT_EVENTS.DATA_DELETE;
    default:
      return 'api.request';
  }
}

/**
 * 从路径推断资源类型
 * @param {string} path - 请求路径
 * @returns {string} 资源类型
 */
function inferResourceFromPath(path) {
  const segments = path.split('/').filter(Boolean);
  
  if (segments[0] === 'api' && segments[1]) {
    return segments[1].replace(/-/g, '_');
  }
  
  return 'unknown';
}

/**
 * 从HTTP方法推断操作类型
 * @param {string} method - HTTP方法
 * @returns {string} 操作类型
 */
function inferActionFromMethod(method) {
  const actionMap = {
    'GET': 'read',
    'POST': 'create',
    'PUT': 'update',
    'PATCH': 'update',
    'DELETE': 'delete'
  };
  
  return actionMap[method.toUpperCase()] || 'unknown';
}

/**
 * 清理敏感数据
 * @param {any} data - 原始数据
 * @param {string[]} excludeFields - 要排除的字段
 * @returns {any} 清理后的数据
 */
function sanitizeData(data, excludeFields = []) {
  if (!data || typeof data !== 'object') {
    return data;
  }

  if (Array.isArray(data)) {
    return data.map(item => sanitizeData(item, excludeFields));
  }

  const sanitized = {};
  
  for (const [key, value] of Object.entries(data)) {
    if (excludeFields.some(field => 
      key.toLowerCase().includes(field.toLowerCase())
    )) {
      sanitized[key] = '[REDACTED]';
    } else if (typeof value === 'object') {
      sanitized[key] = sanitizeData(value, excludeFields);
    } else {
      sanitized[key] = value;
    }
  }
  
  return sanitized;
}

/**
 * 获取客户端真实IP地址
 * @param {Object} req - 请求对象
 * @returns {string} IP地址
 */
function getClientIP(req) {
  return req.ip ||
    req.connection.remoteAddress ||
    req.socket.remoteAddress ||
    (req.connection.socket ? req.connection.socket.remoteAddress : null) ||
    req.headers['x-forwarded-for']?.split(',')[0] ||
    req.headers['x-real-ip'] ||
    'unknown';
}

/**
 * 记录认证事件
 * @param {string} event - 事件类型
 * @param {Object} data - 事件数据
 */
async function logAuthEvent(event, data) {
  const {
    userId,
    username,
    success,
    reason,
    ipAddress,
    userAgent,
    metadata = {}
  } = data;

  await createAuditLog({
    event,
    level: success ? AUDIT_LEVELS.INFO : AUDIT_LEVELS.WARNING,
    userId,
    resource: 'auth',
    action: event.split('.')[1], // 从事件名提取动作
    details: {
      username,
      success,
      reason
    },
    ipAddress,
    userAgent,
    success,
    errorMessage: !success ? reason : undefined,
    metadata
  });
}

/**
 * 记录权限事件
 * @param {string} event - 事件类型
 * @param {Object} data - 事件数据
 */
async function logPermissionEvent(event, data) {
  const {
    userId,
    resource,
    resourceId,
    permission,
    granted,
    reason,
    ipAddress,
    userAgent
  } = data;

  await createAuditLog({
    event,
    level: granted ? AUDIT_LEVELS.INFO : AUDIT_LEVELS.WARNING,
    userId,
    resource,
    resourceId,
    action: 'access',
    details: {
      permission,
      granted,
      reason
    },
    ipAddress,
    userAgent,
    success: granted,
    errorMessage: !granted ? reason : undefined
  });
}

/**
 * 记录安全事件
 * @param {string} event - 事件类型
 * @param {Object} data - 事件数据
 */
async function logSecurityEvent(event, data) {
  const {
    userId,
    threat,
    severity = AUDIT_LEVELS.WARNING,
    details = {},
    ipAddress,
    userAgent
  } = data;

  await createAuditLog({
    event,
    level: severity,
    userId,
    resource: 'security',
    action: 'threat_detected',
    details: {
      threat,
      ...details
    },
    ipAddress,
    userAgent,
    success: false,
    errorMessage: threat
  });
}

/**
 * 预定义的审计日志中间件
 */
const auditMiddlewares = {
  // 记录所有API请求
  apiRequests: auditLog({
    captureRequest: true,
    skipSuccessLog: true
  }),

  // 记录敏感操作
  sensitiveOperations: auditLog({
    level: AUDIT_LEVELS.WARNING,
    captureRequest: true,
    captureResponse: true
  }),

  // 记录认证操作
  authOperations: auditLog({
    level: AUDIT_LEVELS.INFO,
    captureRequest: true,
    excludeFields: ['password', 'token', 'secret', 'key']
  }),

  // 记录数据修改操作
  dataModifications: auditLog({
    level: AUDIT_LEVELS.INFO,
    captureRequest: true,
    captureResponse: false
  })
};

module.exports = {
  auditLog,
  createAuditLog,
  logAuthEvent,
  logPermissionEvent,
  logSecurityEvent,
  auditMiddlewares,
  AUDIT_LEVELS,
  AUDIT_EVENTS
}; 