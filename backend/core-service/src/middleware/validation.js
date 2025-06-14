const { validationResult } = require('express-validator');
const logger = require('../config/logger');

/**
 * 验证中间件
 * 检查express-validator的验证结果
 */
const validateRequest = (req, res, next) => {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    const errorDetails = errors.array().map(error => ({
      field: error.path || error.param,
      message: error.msg,
      value: error.value,
      location: error.location
    }));

    logger.warn('请求验证失败:', {
      path: req.path,
      method: req.method,
      errors: errorDetails,
      ip: req.ip
    });

    return res.status(400).json({
      success: false,
      error: '请求参数验证失败',
      code: 'VALIDATION_ERROR',
      details: errorDetails
    });
  }

  next();
};

/**
 * 通用ID验证
 */
const validateId = (param = 'id') => {
  const { param: validateParam } = require('express-validator');

  return [
    validateParam(param)
      .isUUID()
      .withMessage(`${param}必须是有效的UUID格式`),
    validateRequest
  ];
};

/**
 * 分页参数验证
 */
const validatePagination = () => {
  const { query } = require('express-validator');

  return [
    query('page')
      .optional()
      .isInt({ min: 1 })
      .withMessage('页码必须是大于0的整数')
      .toInt(),
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('每页数量必须是1-100之间的整数')
      .toInt(),
    query('sortBy')
      .optional()
      .isString()
      .trim()
      .isLength({ min: 1, max: 50 })
      .withMessage('排序字段必须是1-50字符的字符串'),
    query('sortOrder')
      .optional()
      .isIn(['asc', 'desc'])
      .withMessage('排序方向必须是asc或desc'),
    validateRequest
  ];
};

/**
 * 搜索参数验证
 */
const validateSearch = () => {
  const { query } = require('express-validator');

  return [
    query('q')
      .optional()
      .isString()
      .trim()
      .isLength({ min: 1, max: 200 })
      .withMessage('搜索关键词必须是1-200字符的字符串'),
    query('category')
      .optional()
      .isString()
      .trim()
      .isLength({ min: 1, max: 50 })
      .withMessage('分类必须是1-50字符的字符串'),
    query('status')
      .optional()
      .isString()
      .trim()
      .isLength({ min: 1, max: 20 })
      .withMessage('状态必须是1-20字符的字符串'),
    validateRequest
  ];
};

/**
 * 文件上传验证
 */
const validateFileUpload = () => {
  const { body } = require('express-validator');

  return [
    body('name')
      .optional()
      .isString()
      .trim()
      .isLength({ min: 1, max: 255 })
      .withMessage('文件名必须是1-255字符的字符串'),
    body('description')
      .optional()
      .isString()
      .trim()
      .isLength({ max: 1000 })
      .withMessage('文件描述不能超过1000字符'),
    body('category')
      .optional()
      .isIn(['document', 'image', 'video', 'audio', 'other'])
      .withMessage('文件分类必须是指定的值之一'),
    validateRequest
  ];
};

module.exports = {
  validateRequest,
  validateId,
  validatePagination,
  validateSearch,
  validateFileUpload
};