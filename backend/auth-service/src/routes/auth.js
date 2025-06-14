const express = require('express');
const AuthController = require('../controllers/authController');
const { 
  registerValidation, 
  loginValidation, 
  emailVerificationValidation,
  forgotPasswordValidation,
  resetPasswordValidation
} = require('../middleware/validation');

const router = express.Router();

/**
 * 用户注册
 * POST /api/auth/register
 */
router.post('/register', registerValidation, AuthController.register);

/**
 * 用户登录
 * POST /api/auth/login
 */
router.post('/login', loginValidation, AuthController.login);

/**
 * 邮箱验证
 * POST /api/auth/verify-email
 */
router.post('/verify-email', emailVerificationValidation, AuthController.verifyEmail);

/**
 * 忘记密码请求
 * POST /api/auth/forgot-password
 */
router.post('/forgot-password', forgotPasswordValidation, AuthController.forgotPassword);

/**
 * 重置密码
 * POST /api/auth/reset-password
 */
router.post('/reset-password', resetPasswordValidation, AuthController.resetPassword);

module.exports = router; 