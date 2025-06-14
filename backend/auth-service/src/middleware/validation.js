const { validationResult, body } = require('express-validator');

/**
 * 验证中间件
 * 处理express-validator的验证结果
 */
const validationMiddleware = (req, res, next) => {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      error: 'VALIDATION_ERROR',
      message: '输入数据验证失败',
      details: errors.array().map(error => ({
        field: error.path || error.param,
        message: error.msg,
        value: error.value,
      })),
    });
  }

  next();
};

/**
 * 用户注册验证规则
 */
const registerValidation = [
  body('username')
    .isLength({ min: 3, max: 30 })
    .withMessage('用户名必须在3-30个字符之间')
    .matches(/^[a-zA-Z0-9_-]+$/)
    .withMessage('用户名只能包含字母、数字、下划线和连字符'),
  
  body('email')
    .isEmail()
    .withMessage('请输入有效的邮箱地址')
    .normalizeEmail(),
  
  body('password')
    .isLength({ min: 8 })
    .withMessage('密码至少需要8位字符')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .withMessage('密码必须包含至少一个大写字母、一个小写字母、一个数字和一个特殊字符'),

  validationMiddleware,
];

/**
 * 用户登录验证规则
 */
const loginValidation = [
  body('email')
    .isEmail()
    .withMessage('请输入有效的邮箱地址')
    .normalizeEmail(),
  
  body('password')
    .notEmpty()
    .withMessage('密码不能为空'),

  validationMiddleware,
];

/**
 * 邮箱验证规则
 */
const emailVerificationValidation = [
  body('token')
    .notEmpty()
    .withMessage('验证令牌不能为空')
    .isLength({ min: 32, max: 128 })
    .withMessage('验证令牌格式不正确'),

  validationMiddleware,
];

/**
 * 忘记密码验证规则
 */
const forgotPasswordValidation = [
  body('email')
    .isEmail()
    .withMessage('请输入有效的邮箱地址')
    .normalizeEmail(),

  validationMiddleware,
];

/**
 * 重置密码验证规则
 */
const resetPasswordValidation = [
  body('token')
    .notEmpty()
    .withMessage('重置令牌不能为空')
    .isLength({ min: 32, max: 128 })
    .withMessage('重置令牌格式不正确'),
  
  body('newPassword')
    .isLength({ min: 8 })
    .withMessage('新密码至少需要8位字符')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .withMessage('新密码必须包含至少一个大写字母、一个小写字母、一个数字和一个特殊字符'),

  validationMiddleware,
];

/**
 * JWT令牌刷新验证规则
 */
const refreshTokenValidation = [
  body('refreshToken')
    .notEmpty()
    .withMessage('刷新令牌不能为空'),

  validationMiddleware,
];

module.exports = {
  validationMiddleware,
  registerValidation,
  loginValidation,
  emailVerificationValidation,
  forgotPasswordValidation,
  resetPasswordValidation,
  refreshTokenValidation,
}; 