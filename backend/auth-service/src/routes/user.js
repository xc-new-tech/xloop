const express = require('express');
const { User, UserSession } = require('../models');
const { 
  authenticateJWT, 
  requireOwnership, 
  requireAdmin,
  requireValidSession,
  createRateLimit
} = require('../middleware/auth');
const { body, validationResult } = require('express-validator');

const router = express.Router();

/**
 * 获取当前用户信息
 * GET /api/user/profile
 */
router.get('/profile', authenticateJWT, async (req, res) => {
  try {
    const user = await User.findByPk(req.user.id, {
      attributes: ['id', 'username', 'email', 'role', 'status', 'email_verified', 'profile', 'preferences', 'last_login_at', 'login_count', 'created_at']
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
      data: {
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          role: user.role,
          status: user.status,
          emailVerified: user.email_verified,
          profile: user.profile || {},
          preferences: user.preferences || {},
          lastLoginAt: user.last_login_at,
          loginCount: user.login_count,
          createdAt: user.created_at,
        },
      },
    });
  } catch (error) {
    console.error('获取用户信息失败:', error);
    res.status(500).json({
      success: false,
      error: 'INTERNAL_ERROR',
      message: '服务器内部错误',
    });
  }
});

/**
 * 更新用户资料
 * PUT /api/user/profile
 */
router.put('/profile', 
  authenticateJWT,
  createRateLimit({ maxRequests: 10, windowMs: 60 * 1000 }), // 每分钟最多10次
  [
    body('profile.displayName')
      .optional()
      .isLength({ min: 1, max: 50 })
      .withMessage('显示名称长度应在1-50个字符之间'),
    body('profile.bio')
      .optional()
      .isLength({ max: 500 })
      .withMessage('个人简介不能超过500个字符'),
    body('profile.avatar')
      .optional()
      .isURL()
      .withMessage('头像必须是有效的URL'),
    body('preferences.language')
      .optional()
      .isIn(['zh-CN', 'en-US'])
      .withMessage('语言设置无效'),
    body('preferences.theme')
      .optional()
      .isIn(['light', 'dark', 'auto'])
      .withMessage('主题设置无效'),
  ],
  async (req, res) => {
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

      const { profile, preferences } = req.body;
      
      const user = await User.findByPk(req.user.id);
      if (!user) {
        return res.status(404).json({
          success: false,
          error: 'USER_NOT_FOUND',
          message: '用户不存在',
        });
      }

      // 更新用户资料
      const updateData = {};
      if (profile) {
        updateData.profile = { ...user.profile, ...profile };
      }
      if (preferences) {
        updateData.preferences = { ...user.preferences, ...preferences };
      }

      await user.update(updateData);

      res.json({
        success: true,
        message: '用户资料更新成功',
        data: {
          user: {
            id: user.id,
            username: user.username,
            email: user.email,
            profile: user.profile,
            preferences: user.preferences,
          },
        },
      });
    } catch (error) {
      console.error('更新用户资料失败:', error);
      res.status(500).json({
        success: false,
        error: 'INTERNAL_ERROR',
        message: '服务器内部错误',
      });
    }
  }
);

/**
 * 获取用户会话列表
 * GET /api/user/sessions
 */
router.get('/sessions', authenticateJWT, async (req, res) => {
  try {
    const sessions = await UserSession.findAll({
      where: { user_id: req.user.id },
      order: [['last_activity_at', 'DESC']],
      attributes: ['id', 'device_info', 'ip_address', 'user_agent', 'status', 'created_at', 'last_activity_at', 'expires_at', 'location_info'],
    });

    res.json({
      success: true,
      data: {
        sessions: sessions.map(session => ({
          id: session.id,
          deviceInfo: session.device_info || {},
          ipAddress: session.ip_address,
          userAgent: session.user_agent,
          status: session.status,
          createdAt: session.created_at,
          lastActivityAt: session.last_activity_at,
          expiresAt: session.expires_at,
          locationInfo: session.location_info || {},
          isCurrent: req.session && req.session.id === session.id,
        })),
      },
    });
  } catch (error) {
    console.error('获取用户会话失败:', error);
    res.status(500).json({
      success: false,
      error: 'INTERNAL_ERROR',
      message: '服务器内部错误',
    });
  }
});

/**
 * 撤销指定会话
 * DELETE /api/user/sessions/:sessionId
 */
router.delete('/sessions/:sessionId', 
  authenticateJWT,
  requireValidSession,
  async (req, res) => {
    try {
      const { sessionId } = req.params;

      const session = await UserSession.findOne({
        where: {
          id: sessionId,
          user_id: req.user.id,
        },
      });

      if (!session) {
        return res.status(404).json({
          success: false,
          error: 'SESSION_NOT_FOUND',
          message: '会话不存在',
        });
      }

      if (session.status !== 'active') {
        return res.status(400).json({
          success: false,
          error: 'SESSION_ALREADY_REVOKED',
          message: '会话已被撤销',
        });
      }

      await session.revoke('user_action');

      res.json({
        success: true,
        message: '会话已成功撤销',
      });
    } catch (error) {
      console.error('撤销会话失败:', error);
      res.status(500).json({
        success: false,
        error: 'INTERNAL_ERROR',
        message: '服务器内部错误',
      });
    }
  }
);

/**
 * 撤销所有其他会话（保留当前会话）
 * POST /api/user/sessions/revoke-others
 */
router.post('/sessions/revoke-others',
  authenticateJWT,
  requireValidSession,
  async (req, res) => {
    try {
      const result = await UserSession.update(
        {
          status: 'revoked',
          revoked_at: new Date(),
          revoke_reason: 'revoke_others',
        },
        {
          where: {
            user_id: req.user.id,
            status: 'active',
            id: { [require('sequelize').Op.ne]: req.session.id },
          },
        }
      );

      const revokedCount = Array.isArray(result) ? result[0] : result;

      res.json({
        success: true,
        message: `已撤销 ${revokedCount} 个其他会话`,
        data: {
          revokedCount,
        },
      });
    } catch (error) {
      console.error('撤销其他会话失败:', error);
      res.status(500).json({
        success: false,
        error: 'INTERNAL_ERROR',
        message: '服务器内部错误',
      });
    }
  }
);

/**
 * 管理员：获取所有用户列表
 * GET /api/user/admin/users
 */
router.get('/admin/users',
  authenticateJWT,
  requireAdmin,
  createRateLimit({ maxRequests: 50, windowMs: 60 * 1000 }),
  async (req, res) => {
    try {
      const { page = 1, limit = 20, status, role, search } = req.query;
      const offset = (page - 1) * limit;

      const whereConditions = {};

      if (status) {
        whereConditions.status = status;
      }

      if (role) {
        whereConditions.role = role;
      }

      if (search) {
        whereConditions[require('sequelize').Op.or] = [
          { username: { [require('sequelize').Op.iLike]: `%${search}%` } },
          { email: { [require('sequelize').Op.iLike]: `%${search}%` } },
        ];
      }

      const { rows: users, count: total } = await User.findAndCountAll({
        where: whereConditions,
        attributes: ['id', 'username', 'email', 'role', 'status', 'email_verified', 'last_login_at', 'login_count', 'created_at'],
        order: [['created_at', 'DESC']],
        limit: parseInt(limit),
        offset: parseInt(offset),
      });

      res.json({
        success: true,
        data: {
          users: users.map(user => ({
            id: user.id,
            username: user.username,
            email: user.email,
            role: user.role,
            status: user.status,
            emailVerified: user.email_verified,
            lastLoginAt: user.last_login_at,
            loginCount: user.login_count,
            createdAt: user.created_at,
          })),
          pagination: {
            page: parseInt(page),
            limit: parseInt(limit),
            total,
            pages: Math.ceil(total / limit),
          },
        },
      });
    } catch (error) {
      console.error('获取用户列表失败:', error);
      res.status(500).json({
        success: false,
        error: 'INTERNAL_ERROR',
        message: '服务器内部错误',
      });
    }
  }
);

/**
 * 管理员：更新用户状态
 * PUT /api/user/admin/users/:userId/status
 */
router.put('/admin/users/:userId/status',
  authenticateJWT,
  requireAdmin,
  [
    body('status')
      .isIn(['active', 'disabled', 'pending'])
      .withMessage('无效的用户状态'),
    body('reason')
      .optional()
      .isLength({ min: 1, max: 200 })
      .withMessage('原因说明长度应在1-200个字符之间'),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          error: 'VALIDATION_ERROR',
          message: '输入数据验证失败',
          details: errors.array(),
        });
      }

      const { userId } = req.params;
      const { status, reason } = req.body;

      const user = await User.findByPk(userId);
      if (!user) {
        return res.status(404).json({
          success: false,
          error: 'USER_NOT_FOUND',
          message: '用户不存在',
        });
      }

      // 防止管理员禁用自己
      if (user.id === req.user.id && status === 'disabled') {
        return res.status(400).json({
          success: false,
          error: 'CANNOT_DISABLE_SELF',
          message: '不能禁用自己的账户',
        });
      }

      await user.update({ status });

      // 如果禁用用户，撤销所有活跃会话
      if (status === 'disabled') {
        await UserSession.update(
          {
            status: 'revoked',
            revoked_at: new Date(),
            revoke_reason: 'account_disabled',
          },
          {
            where: {
              user_id: userId,
              status: 'active',
            },
          }
        );
      }

      res.json({
        success: true,
        message: `用户状态已更新为 ${status}`,
        data: {
          user: {
            id: user.id,
            username: user.username,
            email: user.email,
            status: user.status,
          },
          reason: reason || null,
        },
      });
    } catch (error) {
      console.error('更新用户状态失败:', error);
      res.status(500).json({
        success: false,
        error: 'INTERNAL_ERROR',
        message: '服务器内部错误',
      });
    }
  }
);

module.exports = router; 