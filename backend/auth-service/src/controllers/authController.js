const JWTUtils = require('../utils/jwt');
const { User, UserSession } = require('../models');
const EmailService = require('../services/emailService');
const bcrypt = require('bcrypt');
const crypto = require('crypto');
const { body, validationResult } = require('express-validator');

/**
 * 认证控制器
 * 处理用户认证相关功能
 */
class AuthController {
  /**
   * 用户注册
   * POST /api/auth/register
   */
  static async register(req, res) {
    try {
      // 验证输入数据
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          error: 'VALIDATION_ERROR',
          message: '输入数据验证失败',
          details: errors.array(),
        });
      }

      const { username, email, password } = req.body;

      // 检查用户名是否已存在
      const existingUserByUsername = await User.findOne({ where: { username } });
      if (existingUserByUsername) {
        return res.status(409).json({
          success: false,
          error: 'USERNAME_EXISTS',
          message: '用户名已存在',
        });
      }

      // 检查邮箱是否已存在
      const existingUserByEmail = await User.findOne({ where: { email } });
      if (existingUserByEmail) {
        return res.status(409).json({
          success: false,
          error: 'EMAIL_EXISTS',
          message: '邮箱已存在',
        });
      }

      // 密码加密
      const saltRounds = 12;
      const passwordHash = await bcrypt.hash(password, saltRounds);

      // 生成邮箱验证令牌
      const verificationToken = crypto.randomBytes(32).toString('hex');
      const verificationExpires = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24小时后过期

      // 创建用户
      const user = await User.create({
        username,
        email,
        password_hash: passwordHash,
        status: 'active',  // 直接设置为活跃状态，跳过邮箱验证
        email_verified: true,  // 直接设置为已验证
      });

      // 跳过邮件发送步骤
      // 注释掉邮件发送逻辑
      /*
      try {
        const emailService = new EmailService();
        await emailService.sendVerificationEmail(email, username, verificationToken);
      } catch (emailError) {
        console.error('发送验证邮件失败:', emailError);
        // 邮件发送失败不影响注册成功，但需要通知用户
      }
      */

      // 返回成功响应（不包含敏感信息）
      res.status(201).json({
        success: true,
        message: '注册成功，您现在可以登录了',
        data: {
          user: {
            id: user.id,
            username: user.username,
            email: user.email,
            status: user.status,
            emailVerified: user.email_verified,
            createdAt: user.created_at,
          },
        },
      });

    } catch (error) {
      console.error('用户注册失败:', error);
      res.status(500).json({
        success: false,
        error: 'REGISTRATION_ERROR',
        message: '注册失败，请稍后重试',
      });
    }
  }

  /**
   * 用户登录
   * POST /api/auth/login
   */
  static async login(req, res) {
    try {
      console.log('🔍 开始登录流程...');
      
      // 验证输入数据
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        console.log('❌ 输入验证失败:', errors.array());
        return res.status(400).json({
          success: false,
          error: 'VALIDATION_ERROR',
          message: '输入数据验证失败',
          details: errors.array(),
        });
      }

      const { email, password } = req.body;
      console.log('📧 登录邮箱:', email);

      // 查找用户
      console.log('🔍 查找用户...');
      const user = await User.findOne({ where: { email } });
      if (!user) {
        console.log('❌ 用户不存在:', email);
        return res.status(401).json({
          success: false,
          error: 'INVALID_CREDENTIALS',
          message: '邮箱或密码错误',
        });
      }
      console.log('✅ 找到用户:', user.username);

      // 验证密码
      console.log('🔐 验证密码...');
      const isPasswordValid = await bcrypt.compare(password, user.password_hash);
      if (!isPasswordValid) {
        console.log('❌ 密码错误');
        return res.status(401).json({
          success: false,
          error: 'INVALID_CREDENTIALS',
          message: '邮箱或密码错误',
        });
      }
      console.log('✅ 密码验证成功');

      // 检查账户状态
      console.log('📋 检查账户状态:', user.status);
      if (user.status === 'disabled') {
        return res.status(403).json({
          success: false,
          error: 'ACCOUNT_DISABLED',
          message: '账户已被禁用，请联系管理员',
        });
      }

      if (!user.email_verified) {
        console.log('❌ 邮箱未验证');
        return res.status(403).json({
          success: false,
          error: 'EMAIL_NOT_VERIFIED',
          message: '请先验证您的邮箱地址',
        });
      }
      console.log('✅ 账户状态正常');

      // 收集会话信息
      console.log('📱 收集会话信息...');
      const sessionInfo = {
        ipAddress: req.ip || req.connection.remoteAddress,
        userAgent: req.get('User-Agent'),
        deviceInfo: {
          platform: req.get('User-Agent'),
          timestamp: new Date(),
        },
      };
      console.log('📱 会话信息:', sessionInfo);

      // 生成JWT令牌对
      console.log('🔑 生成JWT令牌...');
      const tokens = await JWTUtils.generateTokenPair(user, sessionInfo);
      console.log('✅ JWT令牌生成成功');

      // 更新用户登录信息
      console.log('📊 更新用户登录信息...');
      await user.update({
        last_login_at: new Date(),
        login_count: user.login_count + 1,
      });
      console.log('✅ 用户信息更新成功');

      console.log('🎉 登录成功!');
      res.status(200).json({
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          avatar: user.avatar_url,
          role: user.role,
          status: user.status,
          email_verified: user.email_verified,
          created_at: user.created_at,
          updated_at: user.updated_at,
        },
        access_token: tokens.accessToken,
        refresh_token: tokens.refreshToken,
        expires_in: tokens.expiresIn,
        token_type: tokens.tokenType,
        message: '登录成功',
      });

    } catch (error) {
      console.error('💥 用户登录失败 - 详细错误:', error);
      console.error('💥 错误堆栈:', error.stack);
      res.status(500).json({
        success: false,
        error: 'LOGIN_ERROR',
        message: '登录失败，请稍后重试',
      });
    }
  }

  /**
   * 邮箱验证
   * POST /api/auth/verify-email
   */
  static async verifyEmail(req, res) {
    try {
      // 验证输入数据
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          error: 'VALIDATION_ERROR',
          message: '输入数据验证失败',
          details: errors.array(),
        });
      }

      const { token } = req.body;

      // 查找待验证的用户
      const user = await User.findOne({
        where: {
          email_verification_token: token,
          email_verified: false,
        },
      });

      if (!user) {
        return res.status(400).json({
          success: false,
          error: 'INVALID_TOKEN',
          message: '无效的验证令牌',
        });
      }

      // 检查令牌是否过期
      if (user.email_verification_expires && new Date() > user.email_verification_expires) {
        return res.status(400).json({
          success: false,
          error: 'INVALID_TOKEN',
          message: '验证令牌已过期，请重新注册',
        });
      }

      // 激活用户账户
      await user.update({
        email_verified: true,
        status: 'active',
        email_verification_token: null,
        email_verification_expires: null,
      });

      res.status(200).json({
        success: true,
        message: '邮箱验证成功，账户已激活',
        data: {
          user: {
            id: user.id,
            username: user.username,
            email: user.email,
            status: user.status,
            emailVerified: user.email_verified,
          },
        },
      });

    } catch (error) {
      console.error('邮箱验证失败:', error);
      res.status(500).json({
        success: false,
        error: 'VERIFICATION_ERROR',
        message: '验证失败，请稍后重试',
      });
    }
  }

  /**
   * 忘记密码请求
   * POST /api/auth/forgot-password
   */
  static async forgotPassword(req, res) {
    try {
      // 验证输入数据
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          error: 'VALIDATION_ERROR',
          message: '输入数据验证失败',
          details: errors.array(),
        });
      }

      const { email } = req.body;

      // 查找用户
      const user = await User.findOne({ where: { email } });
      
      // 为了安全起见，即使用户不存在也返回成功消息
      // 这样可以防止邮箱枚举攻击
      if (!user) {
        return res.status(200).json({
          success: true,
          message: '如果该邮箱已注册，您将收到密码重置邮件',
        });
      }

      // 检查账户状态
      if (user.status === 'disabled') {
        return res.status(403).json({
          success: false,
          error: 'ACCOUNT_DISABLED',
          message: '账户已被禁用，请联系管理员',
        });
      }

      // 生成密码重置令牌
      const resetToken = crypto.randomBytes(32).toString('hex');
      const resetExpires = new Date(Date.now() + 60 * 60 * 1000); // 1小时后过期

      // 保存重置令牌
      await user.update({
        password_reset_token: resetToken,
        password_reset_expires: resetExpires,
      });

      // 发送密码重置邮件
      try {
        const emailService = new EmailService();
        await emailService.sendPasswordResetEmail(email, user.username, resetToken);
      } catch (emailError) {
        console.error('发送密码重置邮件失败:', emailError);
        return res.status(500).json({
          success: false,
          error: 'EMAIL_SEND_ERROR',
          message: '邮件发送失败，请稍后重试',
        });
      }

      res.status(200).json({
        success: true,
        message: '密码重置邮件已发送，请检查您的邮箱',
      });

    } catch (error) {
      console.error('忘记密码请求失败:', error);
      res.status(500).json({
        success: false,
        error: 'FORGOT_PASSWORD_ERROR',
        message: '请求失败，请稍后重试',
      });
    }
  }

  /**
   * 重置密码
   * POST /api/auth/reset-password
   */
  static async resetPassword(req, res) {
    try {
      // 验证输入数据
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          error: 'VALIDATION_ERROR',
          message: '输入数据验证失败',
          details: errors.array(),
        });
      }

      const { token, newPassword } = req.body;

      // 查找用户
      const user = await User.findOne({
        where: {
          password_reset_token: token,
        },
      });

      if (!user) {
        return res.status(400).json({
          success: false,
          error: 'INVALID_TOKEN',
          message: '无效的重置令牌',
        });
      }

      // 检查令牌是否过期
      if (user.password_reset_expires && new Date() > user.password_reset_expires) {
        return res.status(400).json({
          success: false,
          error: 'TOKEN_EXPIRED',
          message: '重置令牌已过期，请重新申请密码重置',
        });
      }

      // 检查账户状态
      if (user.status === 'disabled') {
        return res.status(403).json({
          success: false,
          error: 'ACCOUNT_DISABLED',
          message: '账户已被禁用，请联系管理员',
        });
      }

      // 加密新密码
      const saltRounds = 12;
      const newPasswordHash = await bcrypt.hash(newPassword, saltRounds);

      // 更新密码并清除重置令牌
      await user.update({
        password_hash: newPasswordHash,
        password_reset_token: null,
        password_reset_expires: null,
      });

      // 撤销所有用户会话（强制重新登录）
      try {
        await JWTUtils.revokeAllUserTokens(user.id, 'password_reset');
      } catch (revokeError) {
        console.error('撤销用户会话失败:', revokeError);
        // 继续执行，不影响密码重置成功
      }

      // 发送密码重置确认邮件
      try {
        const emailService = new EmailService();
        await emailService.sendPasswordResetConfirmation(user.email, user.username);
      } catch (emailError) {
        console.error('发送密码重置确认邮件失败:', emailError);
        // 邮件发送失败不影响密码重置成功
      }

      res.status(200).json({
        success: true,
        message: '密码重置成功，请使用新密码登录',
        data: {
          user: {
            id: user.id,
            username: user.username,
            email: user.email,
          },
        },
      });

    } catch (error) {
      console.error('密码重置失败:', error);
      res.status(500).json({
        success: false,
        error: 'RESET_PASSWORD_ERROR',
        message: '密码重置失败，请稍后重试',
      });
    }
  }

  /**
   * 刷新访问令牌
   * POST /api/auth/refresh-token
   */
  static async refreshToken(req, res) {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        return res.status(400).json({
          success: false,
          error: 'MISSING_REFRESH_TOKEN',
          message: '缺少刷新令牌',
        });
      }

      // 获取会话信息
      const sessionInfo = {
        ipAddress: req.ip || req.connection.remoteAddress,
        userAgent: req.get('User-Agent'),
        deviceInfo: req.body.deviceInfo || {},
        locationInfo: req.body.locationInfo || {},
      };

      // 刷新令牌
      const tokenData = await JWTUtils.refreshAccessToken(refreshToken, sessionInfo);

      res.json({
        success: true,
        message: '令牌刷新成功',
        data: tokenData,
      });

    } catch (error) {
      console.error('刷新令牌失败:', error);

      if (error.message.includes('无效') || error.message.includes('过期')) {
        return res.status(401).json({
          success: false,
          error: 'INVALID_REFRESH_TOKEN',
          message: '无效或过期的刷新令牌',
        });
      }

      res.status(500).json({
        success: false,
        error: 'REFRESH_TOKEN_ERROR',
        message: '刷新令牌失败',
      });
    }
  }

  /**
   * 用户登出
   * POST /api/auth/logout
   */
  static async logout(req, res) {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        return res.status(400).json({
          success: false,
          error: 'MISSING_REFRESH_TOKEN',
          message: '缺少刷新令牌',
        });
      }

      // 撤销刷新令牌
      const revoked = await JWTUtils.revokeRefreshToken(refreshToken, 'logout');

      if (revoked) {
        res.json({
          success: true,
          message: '登出成功',
        });
      } else {
        res.status(400).json({
          success: false,
          error: 'INVALID_REFRESH_TOKEN',
          message: '无效的刷新令牌',
        });
      }

    } catch (error) {
      console.error('登出失败:', error);
      res.status(500).json({
        success: false,
        error: 'LOGOUT_ERROR',
        message: '登出失败',
      });
    }
  }

  /**
   * 全部登出（撤销用户所有会话）
   * POST /api/auth/logout-all
   */
  static async logoutAll(req, res) {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: 'AUTHENTICATION_REQUIRED',
          message: '需要认证才能执行此操作',
        });
      }

      // 撤销用户的所有令牌
      const revokedCount = await JWTUtils.revokeAllUserTokens(req.user.id, 'logout_all');

      res.json({
        success: true,
        message: '已登出所有设备',
        data: {
          revokedSessions: revokedCount,
        },
      });

    } catch (error) {
      console.error('全部登出失败:', error);
      res.status(500).json({
        success: false,
        error: 'LOGOUT_ALL_ERROR',
        message: '全部登出失败',
      });
    }
  }

  /**
   * 验证令牌有效性
   * GET /api/auth/verify-token
   */
  static async verifyToken(req, res) {
    try {
      // 如果到达这里，说明中间件已验证了令牌
      const user = req.user;
      const token = req.token;

      res.json({
        success: true,
        message: '令牌有效',
        data: {
          user: {
            id: user.id,
            username: user.username,
            email: user.email,
            role: user.role,
            status: user.status,
            emailVerified: user.email_verified,
            createdAt: user.created_at,
          },
          token: {
            type: token.type,
            issuedAt: new Date(token.iat * 1000),
            expiresAt: new Date(token.exp * 1000),
          },
        },
      });

    } catch (error) {
      console.error('验证令牌失败:', error);
      res.status(500).json({
        success: false,
        error: 'TOKEN_VERIFICATION_ERROR',
        message: '验证令牌失败',
      });
    }
  }

  /**
   * 获取用户会话列表
   * GET /api/auth/sessions
   */
  static async getUserSessions(req, res) {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: 'AUTHENTICATION_REQUIRED',
          message: '需要认证才能执行此操作',
        });
      }

      const sessions = await UserSession.findAll({
        where: {
          user_id: req.user.id,
          status: 'active',
        },
        attributes: [
          'id',
          'ip_address',
          'user_agent', 
          'device_info',
          'location_info',
          'created_at',
          'updated_at',
          'last_activity_at',
          'expires_at'
        ],
        order: [['created_at', 'DESC']],
      });

      // 处理会话数据，隐藏敏感信息
      const sessionData = sessions.map(session => ({
        id: session.id,
        ipAddress: session.ip_address,
        userAgent: session.user_agent,
        deviceInfo: session.device_info,
        locationInfo: session.location_info,
        createdAt: session.created_at,
        lastActivityAt: session.last_activity_at,
        expiresAt: session.expires_at,
        isCurrentSession: req.session?.id === session.id, // 如果有当前会话信息
      }));

      res.json({
        success: true,
        message: '获取会话列表成功',
        data: {
          sessions: sessionData,
          total: sessionData.length,
        },
      });

    } catch (error) {
      console.error('获取用户会话失败:', error);
      res.status(500).json({
        success: false,
        error: 'GET_SESSIONS_ERROR',
        message: '获取会话列表失败',
      });
    }
  }

  /**
   * 撤销特定会话
   * DELETE /api/auth/sessions/:sessionId
   */
  static async revokeSession(req, res) {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: 'AUTHENTICATION_REQUIRED',
          message: '需要认证才能执行此操作',
        });
      }

      const { sessionId } = req.params;

      // 查找会话
      const session = await UserSession.findOne({
        where: {
          id: sessionId,
          user_id: req.user.id,
          status: 'active',
        },
      });

      if (!session) {
        return res.status(404).json({
          success: false,
          error: 'SESSION_NOT_FOUND',
          message: '会话不存在或已失效',
        });
      }

      // 撤销会话
      await session.revoke('user_revoked');

      res.json({
        success: true,
        message: '会话已撤销',
      });

    } catch (error) {
      console.error('撤销会话失败:', error);
      res.status(500).json({
        success: false,
        error: 'REVOKE_SESSION_ERROR',
        message: '撤销会话失败',
      });
    }
  }

  /**
   * 清理过期会话（管理员功能）
   * POST /api/auth/cleanup-sessions
   */
  static async cleanupExpiredSessions(req, res) {
    try {
      if (!req.user || req.user.role !== 'admin') {
        return res.status(403).json({
          success: false,
          error: 'INSUFFICIENT_PRIVILEGES',
          message: '权限不足',
        });
      }

      const cleanedCount = await JWTUtils.cleanupExpiredSessions();

      res.json({
        success: true,
        message: '过期会话清理完成',
        data: {
          cleanedSessions: cleanedCount,
        },
      });

    } catch (error) {
      console.error('清理过期会话失败:', error);
      res.status(500).json({
        success: false,
        error: 'CLEANUP_SESSIONS_ERROR',
        message: '清理过期会话失败',
      });
    }
  }

  /**
   * 获取当前用户信息
   * GET /api/auth/me
   */
  static async getCurrentUser(req, res) {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: 'AUTHENTICATION_REQUIRED',
          message: '需要认证才能执行此操作',
        });
      }

      // 从数据库重新获取最新的用户信息
      const user = await User.findByPk(req.user.id, {
        attributes: ['id', 'username', 'email', 'role', 'status', 'email_verified', 'profile', 'preferences', 'created_at', 'updated_at']
      });

      if (!user) {
        return res.status(404).json({
          success: false,
          error: 'USER_NOT_FOUND',
          message: '用户不存在',
        });
      }

      res.json({
        success: true,
        message: '获取用户信息成功',
        data: {
          user: {
            id: user.id,
            username: user.username,
            email: user.email,
            role: user.role,
            status: user.status,
            emailVerified: user.email_verified,
            profile: user.profile,
            preferences: user.preferences,
            createdAt: user.created_at,
            updatedAt: user.updated_at,
          },
        },
      });

    } catch (error) {
      console.error('获取当前用户信息失败:', error);
      res.status(500).json({
        success: false,
        error: 'GET_USER_ERROR',
        message: '获取用户信息失败',
      });
    }
  }
}

module.exports = AuthController; 