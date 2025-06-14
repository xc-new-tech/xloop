const rateLimit = require('express-rate-limit');
const logger = require('../config/logger');

/**
 * 默认速率限制配置
 */
const defaultLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15分钟
  max: 100, // 限制每个IP在窗口期内最多100个请求
  message: {
    success: false,
    error: '请求过于频繁，请稍后再试',
    code: 'RATE_LIMIT_EXCEEDED',
    retryAfter: '15分钟'
  },
  standardHeaders: true, // 返回限制信息在 `RateLimit-*` headers
  legacyHeaders: false, // 禁用 `X-RateLimit-*` headers
  handler: (req, res) => {
    logger.warn('速率限制触发:', {
      ip: req.ip,
      path: req.path,
      method: req.method,
      userAgent: req.get('User-Agent')
    });

    res.status(429).json({
      success: false,
      error: '请求过于频繁，请稍后再试',
      code: 'RATE_LIMIT_EXCEEDED',
      retryAfter: '15分钟'
    });
  }
});

/**
 * 严格的速率限制（用于敏感操作）
 */
const strictLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15分钟
  max: 10, // 限制每个IP在窗口期内最多10个请求
  message: {
    success: false,
    error: '敏感操作请求过于频繁，请稍后再试',
    code: 'RATE_LIMIT_EXCEEDED',
    retryAfter: '15分钟'
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    logger.warn('严格速率限制触发:', {
      ip: req.ip,
      path: req.path,
      method: req.method,
      userAgent: req.get('User-Agent')
    });

    res.status(429).json({
      success: false,
      error: '敏感操作请求过于频繁，请稍后再试',
      code: 'RATE_LIMIT_EXCEEDED',
      retryAfter: '15分钟'
    });
  }
});

/**
 * 宽松的速率限制（用于查询操作）
 */
const looseLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15分钟
  max: 1000, // 限制每个IP在窗口期内最多1000个请求
  message: {
    success: false,
    error: '请求过于频繁，请稍后再试',
    code: 'RATE_LIMIT_EXCEEDED',
    retryAfter: '15分钟'
  },
  standardHeaders: true,
  legacyHeaders: false
});

/**
 * 文件上传速率限制
 */
const uploadLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1小时
  max: 50, // 限制每个IP每小时最多50个文件上传请求
  message: {
    success: false,
    error: '文件上传请求过于频繁，请稍后再试',
    code: 'UPLOAD_RATE_LIMIT_EXCEEDED',
    retryAfter: '1小时'
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    logger.warn('文件上传速率限制触发:', {
      ip: req.ip,
      path: req.path,
      method: req.method,
      userAgent: req.get('User-Agent')
    });

    res.status(429).json({
      success: false,
      error: '文件上传请求过于频繁，请稍后再试',
      code: 'UPLOAD_RATE_LIMIT_EXCEEDED',
      retryAfter: '1小时'
    });
  }
});

/**
 * 自定义速率限制器创建函数
 * @param {Object} options - 速率限制配置
 * @returns {Function} 速率限制中间件
 */
const createLimiter = (options = {}) => {
  const defaultOptions = {
    windowMs: 15 * 60 * 1000,
    max: 100,
    standardHeaders: true,
    legacyHeaders: false
  };

  return rateLimit({ ...defaultOptions, ...options });
};

module.exports = {
  defaultLimiter,
  strictLimiter,
  looseLimiter,
  uploadLimiter,
  createLimiter
};