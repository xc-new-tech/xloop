const { param, query, body } = require('express-validator');

/**
 * UUID验证器
 * @param {string} field - 字段名
 */
const validateUUID = (field = 'id') => {
  return param(field)
    .isUUID()
    .withMessage(`${field}必须是有效的UUID格式`);
};

/**
 * 分页参数验证器
 */
const validatePagination = () => {
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
      .withMessage('排序方向必须是asc或desc')
  ];
};

/**
 * 搜索参数验证器
 */
const validateSearch = () => {
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
      .withMessage('状态必须是1-20字符的字符串')
  ];
};

/**
 * 必填字符串验证器
 * @param {string} field - 字段名
 * @param {number} minLength - 最小长度
 * @param {number} maxLength - 最大长度
 */
const validateRequiredString = (field, minLength = 1, maxLength = 255) => {
  return body(field)
    .notEmpty()
    .withMessage(`${field}不能为空`)
    .isString()
    .withMessage(`${field}必须是字符串`)
    .trim()
    .isLength({ min: minLength, max: maxLength })
    .withMessage(`${field}长度必须在${minLength}-${maxLength}字符之间`);
};

/**
 * 可选字符串验证器
 * @param {string} field - 字段名
 * @param {number} maxLength - 最大长度
 */
const validateOptionalString = (field, maxLength = 1000) => {
  return body(field)
    .optional()
    .isString()
    .withMessage(`${field}必须是字符串`)
    .trim()
    .isLength({ max: maxLength })
    .withMessage(`${field}长度不能超过${maxLength}字符`);
};

/**
 * 邮箱验证器
 * @param {string} field - 字段名
 */
const validateEmail = (field = 'email') => {
  return body(field)
    .notEmpty()
    .withMessage(`${field}不能为空`)
    .isEmail()
    .withMessage(`${field}格式不正确`)
    .normalizeEmail();
};

/**
 * 枚举值验证器
 * @param {string} field - 字段名
 * @param {Array} values - 允许的值
 */
const validateEnum = (field, values) => {
  return body(field)
    .isIn(values)
    .withMessage(`${field}必须是以下值之一: ${values.join(', ')}`);
};

/**
 * 布尔值验证器
 * @param {string} field - 字段名
 */
const validateBoolean = (field) => {
  return body(field)
    .optional()
    .isBoolean()
    .withMessage(`${field}必须是布尔值`)
    .toBoolean();
};

/**
 * 整数验证器
 * @param {string} field - 字段名
 * @param {number} min - 最小值
 * @param {number} max - 最大值
 */
const validateInteger = (field, min = 0, max = Number.MAX_SAFE_INTEGER) => {
  return body(field)
    .isInt({ min, max })
    .withMessage(`${field}必须是${min}-${max}之间的整数`)
    .toInt();
};

/**
 * 数组验证器
 * @param {string} field - 字段名
 * @param {number} minLength - 最小长度
 * @param {number} maxLength - 最大长度
 */
const validateArray = (field, minLength = 0, maxLength = 100) => {
  return body(field)
    .isArray({ min: minLength, max: maxLength })
    .withMessage(`${field}必须是数组，长度在${minLength}-${maxLength}之间`);
};

module.exports = {
  validateUUID,
  validatePagination,
  validateSearch,
  validateRequiredString,
  validateOptionalString,
  validateEmail,
  validateEnum,
  validateBoolean,
  validateInteger,
  validateArray
};