const { body, validationResult } = require('express-validator');
const { validateUUID } = require('./common');

/**
 * FAQ创建输入验证
 */
const validateFAQInput = [
  body('question')
    .notEmpty()
    .withMessage('问题不能为空')
    .isLength({ min: 1, max: 1000 })
    .withMessage('问题长度必须在1-1000字符之间')
    .trim(),

  body('answer')
    .notEmpty()
    .withMessage('答案不能为空')
    .isLength({ min: 1, max: 5000 })
    .withMessage('答案长度必须在1-5000字符之间')
    .trim(),

  body('category')
    .optional()
    .isLength({ max: 100 })
    .withMessage('分类名称长度不能超过100字符')
    .trim(),

  body('tags')
    .optional()
    .isArray()
    .withMessage('标签必须是数组格式')
    .custom((tags) => {
      if (tags && tags.length > 0) {
        for (const tag of tags) {
          if (typeof tag !== 'string' || tag.length > 50) {
            throw new Error('每个标签必须是字符串且长度不超过50字符');
          }
        }
      }
      return true;
    }),

  body('priority')
    .optional()
    .isIn(['low', 'medium', 'high'])
    .withMessage('优先级必须是 low、medium 或 high'),

  body('status')
    .optional()
    .isIn(['draft', 'published', 'archived'])
    .withMessage('状态必须是 draft、published 或 archived'),

  body('isPublic')
    .optional()
    .isBoolean()
    .withMessage('isPublic 必须是布尔值'),

  body('knowledgeBaseId')
    .optional()
    .custom((value) => {
      if (value) {
        validateUUID(value, 'knowledgeBaseId');
      }
      return true;
    }),

  body('metadata')
    .optional()
    .isObject()
    .withMessage('metadata 必须是对象格式'),

  // 处理验证结果
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: '数据验证失败',
        errors: errors.array().map(error => ({
          field: error.path,
          message: error.msg,
          value: error.value
        }))
      });
    }
    next();
  }
];

/**
 * FAQ更新输入验证
 */
const validateFAQUpdate = [
  body('question')
    .optional()
    .isLength({ min: 1, max: 1000 })
    .withMessage('问题长度必须在1-1000字符之间')
    .trim(),

  body('answer')
    .optional()
    .isLength({ min: 1, max: 5000 })
    .withMessage('答案长度必须在1-5000字符之间')
    .trim(),

  body('category')
    .optional()
    .isLength({ max: 100 })
    .withMessage('分类名称长度不能超过100字符')
    .trim(),

  body('tags')
    .optional()
    .isArray()
    .withMessage('标签必须是数组格式')
    .custom((tags) => {
      if (tags && tags.length > 0) {
        for (const tag of tags) {
          if (typeof tag !== 'string' || tag.length > 50) {
            throw new Error('每个标签必须是字符串且长度不超过50字符');
          }
        }
      }
      return true;
    }),

  body('priority')
    .optional()
    .isIn(['low', 'medium', 'high'])
    .withMessage('优先级必须是 low、medium 或 high'),

  body('status')
    .optional()
    .isIn(['draft', 'published', 'archived'])
    .withMessage('状态必须是 draft、published 或 archived'),

  body('isPublic')
    .optional()
    .isBoolean()
    .withMessage('isPublic 必须是布尔值'),

  body('knowledgeBaseId')
    .optional()
    .custom((value) => {
      if (value && value !== null) {
        validateUUID(value, 'knowledgeBaseId');
      }
      return true;
    }),

  body('metadata')
    .optional()
    .isObject()
    .withMessage('metadata 必须是对象格式'),

  // 检查至少有一个字段被更新
  (req, res, next) => {
    const updateFields = [
      'question', 'answer', 'category', 'tags', 'priority', 
      'status', 'isPublic', 'knowledgeBaseId', 'metadata'
    ];
    
    const hasUpdate = updateFields.some(field => req.body.hasOwnProperty(field));
    
    if (!hasUpdate) {
      return res.status(400).json({
        success: false,
        message: '至少需要提供一个要更新的字段'
      });
    }
    
    next();
  },

  // 处理验证结果
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: '数据验证失败',
        errors: errors.array().map(error => ({
          field: error.path,
          message: error.msg,
          value: error.value
        }))
      });
    }
    next();
  }
];

/**
 * FAQ搜索参数验证
 */
const validateFAQSearch = [
  body('keyword')
    .notEmpty()
    .withMessage('搜索关键词不能为空')
    .isLength({ min: 1, max: 200 })
    .withMessage('搜索关键词长度必须在1-200字符之间')
    .trim(),

  body('knowledgeBaseId')
    .optional()
    .custom((value) => {
      if (value) {
        validateUUID(value, 'knowledgeBaseId');
      }
      return true;
    }),

  body('category')
    .optional()
    .isLength({ max: 100 })
    .withMessage('分类名称长度不能超过100字符')
    .trim(),

  // 处理验证结果
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: '搜索参数验证失败',
        errors: errors.array().map(error => ({
          field: error.path,
          message: error.msg,
          value: error.value
        }))
      });
    }
    next();
  }
];

/**
 * 批量删除FAQ验证
 */
const validateBulkDelete = [
  body('ids')
    .isArray({ min: 1 })
    .withMessage('必须提供至少一个FAQ ID')
    .custom((ids) => {
      if (ids.length > 100) {
        throw new Error('一次最多只能删除100个FAQ');
      }
      
      for (const id of ids) {
        validateUUID(id, 'FAQ ID');
      }
      
      // 检查是否有重复ID
      const uniqueIds = [...new Set(ids)];
      if (uniqueIds.length !== ids.length) {
        throw new Error('FAQ ID列表中不能有重复项');
      }
      
      return true;
    }),

  // 处理验证结果
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: '批量删除参数验证失败',
        errors: errors.array().map(error => ({
          field: error.path,
          message: error.msg,
          value: error.value
        }))
      });
    }
    next();
  }
];

/**
 * FAQ分类验证
 */
const validateFAQCategory = [
  body('name')
    .notEmpty()
    .withMessage('分类名称不能为空')
    .isLength({ min: 1, max: 100 })
    .withMessage('分类名称长度必须在1-100字符之间')
    .trim()
    .custom((name) => {
      // 检查分类名称是否包含特殊字符
      const specialChars = /[<>\"'&]/;
      if (specialChars.test(name)) {
        throw new Error('分类名称不能包含特殊字符 < > " \' &');
      }
      return true;
    }),

  body('description')
    .optional()
    .isLength({ max: 500 })
    .withMessage('分类描述长度不能超过500字符')
    .trim(),

  // 处理验证结果
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: '分类参数验证失败',
        errors: errors.array().map(error => ({
          field: error.path,
          message: error.msg,
          value: error.value
        }))
      });
    }
    next();
  }
];

/**
 * FAQ标签验证
 */
const validateFAQTags = [
  body('tags')
    .isArray({ min: 1 })
    .withMessage('必须提供至少一个标签')
    .custom((tags) => {
      if (tags.length > 20) {
        throw new Error('最多只能设置20个标签');
      }
      
      for (const tag of tags) {
        if (typeof tag !== 'string') {
          throw new Error('标签必须是字符串');
        }
        
        if (tag.length < 1 || tag.length > 50) {
          throw new Error('每个标签长度必须在1-50字符之间');
        }
        
        // 检查标签是否包含特殊字符
        const specialChars = /[<>\"'&,]/;
        if (specialChars.test(tag)) {
          throw new Error('标签不能包含特殊字符 < > " \' & ,');
        }
      }
      
      // 检查是否有重复标签
      const uniqueTags = [...new Set(tags)];
      if (uniqueTags.length !== tags.length) {
        throw new Error('标签列表中不能有重复项');
      }
      
      return true;
    }),

  // 处理验证结果
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: '标签参数验证失败',
        errors: errors.array().map(error => ({
          field: error.path,
          message: error.msg,
          value: error.value
        }))
      });
    }
    next();
  }
];

/**
 * FAQ反馈验证
 */
const validateFAQFeedback = [
  body('type')
    .isIn(['like', 'dislike'])
    .withMessage('反馈类型必须是 like 或 dislike'),

  body('comment')
    .optional()
    .isLength({ max: 500 })
    .withMessage('评论长度不能超过500字符')
    .trim(),

  // 处理验证结果
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: '反馈参数验证失败',
        errors: errors.array().map(error => ({
          field: error.path,
          message: error.msg,
          value: error.value
        }))
      });
    }
    next();
  }
];

module.exports = {
  validateFAQInput,
  validateFAQUpdate,
  validateFAQSearch,
  validateBulkDelete,
  validateFAQCategory,
  validateFAQTags,
  validateFAQFeedback
}; 