/**
 * 自定义API错误类
 */
class ApiError extends Error {
  constructor(message, statusCode = 500, code = 'INTERNAL_ERROR', details = null) {
    super(message);
    this.name = 'ApiError';
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
    this.isOperational = true;

    // 保持错误堆栈跟踪
    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * 验证错误类
 */
class ValidationError extends ApiError {
  constructor(message, details = null) {
    super(message, 400, 'VALIDATION_ERROR', details);
    this.name = 'ValidationError';
  }
}

/**
 * 认证错误类
 */
class AuthenticationError extends ApiError {
  constructor(message = '认证失败') {
    super(message, 401, 'AUTHENTICATION_ERROR');
    this.name = 'AuthenticationError';
  }
}

/**
 * 授权错误类
 */
class AuthorizationError extends ApiError {
  constructor(message = '权限不足') {
    super(message, 403, 'AUTHORIZATION_ERROR');
    this.name = 'AuthorizationError';
  }
}

/**
 * 资源未找到错误类
 */
class NotFoundError extends ApiError {
  constructor(message = '资源不存在') {
    super(message, 404, 'NOT_FOUND');
    this.name = 'NotFoundError';
  }
}

/**
 * 冲突错误类
 */
class ConflictError extends ApiError {
  constructor(message = '资源冲突') {
    super(message, 409, 'CONFLICT');
    this.name = 'ConflictError';
  }
}

/**
 * 服务不可用错误类
 */
class ServiceUnavailableError extends ApiError {
  constructor(message = '服务暂时不可用') {
    super(message, 503, 'SERVICE_UNAVAILABLE');
    this.name = 'ServiceUnavailableError';
  }
}

/**
 * 创建标准化的错误响应
 * @param {Error} error - 错误对象
 * @param {Object} req - 请求对象
 * @param {Object} res - 响应对象
 * @param {Function} next - 下一个中间件
 */
const handleError = (error, req, res, next) => {
  // 如果响应已经发送，交给默认错误处理器
  if (res.headersSent) {
    return next(error);
  }

  let statusCode = 500;
  let code = 'INTERNAL_ERROR';
  let message = '服务器内部错误';
  let details = null;

  // 处理已知的API错误
  if (error instanceof ApiError) {
    statusCode = error.statusCode;
    code = error.code;
    message = error.message;
    details = error.details;
  }
  // 处理Sequelize错误
  else if (error.name === 'SequelizeValidationError') {
    statusCode = 400;
    code = 'VALIDATION_ERROR';
    message = '数据验证失败';
    details = error.errors.map(err => ({
      field: err.path,
      message: err.message,
      value: err.value
    }));
  }
  else if (error.name === 'SequelizeUniqueConstraintError') {
    statusCode = 409;
    code = 'DUPLICATE_ENTRY';
    message = '数据已存在';
    details = error.errors.map(err => ({
      field: err.path,
      message: err.message,
      value: err.value
    }));
  }
  else if (error.name === 'SequelizeForeignKeyConstraintError') {
    statusCode = 400;
    code = 'FOREIGN_KEY_ERROR';
    message = '关联数据不存在';
  }
  // 处理其他已知错误类型
  else if (error.name === 'CastError') {
    statusCode = 400;
    code = 'INVALID_ID';
    message = '无效的ID格式';
  }
  else if (error.code === 'LIMIT_FILE_SIZE') {
    statusCode = 413;
    code = 'FILE_TOO_LARGE';
    message = '文件大小超出限制';
  }

  // 在开发环境中包含堆栈跟踪
  const response = {
    success: false,
    error: message,
    code,
    timestamp: new Date().toISOString(),
    path: req.path,
    method: req.method
  };

  if (details) {
    response.details = details;
  }

  if (process.env.NODE_ENV !== 'production') {
    response.stack = error.stack;
  }

  // 记录错误日志
  const logger = require('../config/logger');
  logger.error('API错误:', {
    error: {
      name: error.name,
      message: error.message,
      stack: error.stack,
      statusCode,
      code
    },
    request: {
      method: req.method,
      path: req.path,
      query: req.query,
      body: req.body,
      ip: req.ip,
      userAgent: req.get('User-Agent')
    }
  });

  res.status(statusCode).json(response);
};

/**
 * 处理404错误的中间件
 */
const handle404 = (req, res) => {
  res.status(404).json({
    success: false,
    error: '接口不存在',
    code: 'NOT_FOUND',
    timestamp: new Date().toISOString(),
    path: req.path,
    method: req.method
  });
};

module.exports = {
  ApiError,
  ValidationError,
  AuthenticationError,
  AuthorizationError,
  NotFoundError,
  ConflictError,
  ServiceUnavailableError,
  handleError,
  handle404
};