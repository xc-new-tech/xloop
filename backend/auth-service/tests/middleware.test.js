const request = require('supertest');
const { Sequelize, DataTypes } = require('sequelize');
const crypto = require('crypto');

// 模拟模型导出，替换原有的模型
jest.mock('../src/models', () => {
  const { Sequelize, DataTypes } = require('sequelize');
  
  // 创建SQLite内存数据库用于测试
  const sequelize = new Sequelize('sqlite::memory:', {
    logging: false,
  });

  // 重新定义模型用于测试
  const User = sequelize.define('User', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    username: {
      type: DataTypes.STRING(50),
      allowNull: false,
      unique: true,
    },
    email: {
      type: DataTypes.STRING(100),
      allowNull: false,
      unique: true,
    },
    password_hash: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    role: {
      type: DataTypes.ENUM('user', 'admin', 'moderator'),
      defaultValue: 'user',
    },
    status: {
      type: DataTypes.ENUM('pending', 'active', 'disabled'),
      defaultValue: 'pending',
    },
    email_verified: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    profile: {
      type: DataTypes.JSON,
      defaultValue: {},
    },
    preferences: {
      type: DataTypes.JSON,
      defaultValue: {},
    },
    last_login_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    login_count: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
  }, {
    tableName: 'users',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  });

  const UserSession = sequelize.define('UserSession', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: User,
        key: 'id',
      },
      onDelete: 'CASCADE',
    },
    refresh_token_hash: {
      type: DataTypes.STRING(255),
      allowNull: false,
      unique: true,
    },
    token_family: {
      type: DataTypes.STRING(50),
      allowNull: false,
    },
    ip_address: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    user_agent: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    device_info: {
      type: DataTypes.JSON,
      defaultValue: {},
    },
    location_info: {
      type: DataTypes.JSON,
      defaultValue: {},
    },
    status: {
      type: DataTypes.ENUM('active', 'revoked', 'expired'),
      defaultValue: 'active',
    },
    revoked_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    revoke_reason: {
      type: DataTypes.STRING(100),
      allowNull: true,
    },
    last_activity_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    expires_at: {
      type: DataTypes.DATE,
      allowNull: false,
    },
  }, {
    tableName: 'user_sessions',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  });

  // 添加方法到UserSession
  UserSession.prototype.revoke = async function(reason = 'manual') {
    await this.update({
      status: 'revoked',
      revoked_at: new Date(),
      revoke_reason: reason,
    });
    return this;
  };

  // 静态方法
  UserSession.revokeAllUserSessions = async function(userId, reason = 'logout_all') {
    return this.update(
      {
        status: 'revoked',
        revoked_at: new Date(),
        revoke_reason: reason
      },
      {
        where: {
          user_id: userId,
          status: 'active'
        }
      }
    );
  };

  // 定义关联关系
  User.hasMany(UserSession, { 
    foreignKey: 'user_id',
    as: 'sessions',
    onDelete: 'CASCADE'
  });
  UserSession.belongsTo(User, { 
    foreignKey: 'user_id',
    as: 'user'
  });

  return {
    sequelize,
    User,
    UserSession,
  };
});

// 设置测试环境变量
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-jwt-secret-key-for-testing';
process.env.JWT_REFRESH_SECRET = 'test-jwt-refresh-secret-key-for-testing';

const app = require('../src/app');
const { sequelize, User, UserSession } = require('../src/models');
const JWTUtils = require('../src/utils/jwt');
const bcrypt = require('bcrypt');

/**
 * JWT中间件和权限验证测试套件
 */
describe('JWT中间件和权限验证测试', () => {
  let regularUser, adminUser, moderatorUser;
  let regularUserToken, adminUserToken, moderatorUserToken;

  beforeAll(async () => {
    // 同步数据库表
    await sequelize.sync({ force: true });
  });

  afterAll(async () => {
    // 清理数据库连接
    await sequelize.close();
  });

  beforeEach(async () => {
    // 清理数据
    await UserSession.destroy({ where: {} });
    await User.destroy({ where: {} });

    // 创建测试用户
    const passwordHash = await bcrypt.hash('TestPass123!', 12);

    regularUser = await User.create({
      username: 'regularuser',
      email: 'regular@example.com',
      password_hash: passwordHash,
      role: 'user',
      status: 'active',
      email_verified: true,
      login_count: 0,
    });

    adminUser = await User.create({
      username: 'adminuser',
      email: 'admin@example.com',
      password_hash: passwordHash,
      role: 'admin',
      status: 'active',
      email_verified: true,
      login_count: 0,
    });

    moderatorUser = await User.create({
      username: 'moderatoruser',
      email: 'moderator@example.com',
      password_hash: passwordHash,
      role: 'moderator',
      status: 'active',
      email_verified: true,
      login_count: 0,
    });

    // 生成访问令牌
    const sessionInfo = {
      ipAddress: '127.0.0.1',
      userAgent: 'test-agent',
      deviceInfo: { browser: 'test' },
    };

    const regularTokens = await JWTUtils.generateTokenPair(regularUser, sessionInfo);
    const adminTokens = await JWTUtils.generateTokenPair(adminUser, sessionInfo);
    const moderatorTokens = await JWTUtils.generateTokenPair(moderatorUser, sessionInfo);

    regularUserToken = regularTokens.accessToken;
    adminUserToken = adminTokens.accessToken;
    moderatorUserToken = moderatorTokens.accessToken;
  });

  /**
   * JWT认证中间件测试
   */
  describe('JWT认证中间件', () => {
    test('应该允许有效令牌的用户访问受保护资源', async () => {
      const response = await request(app)
        .get('/api/user/profile')
        .set('Authorization', `Bearer ${regularUserToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.user.username).toBe('regularuser');
      expect(response.body.data.user.email).toBe('regular@example.com');
    });

    test('应该拒绝没有令牌的请求', async () => {
      const response = await request(app)
        .get('/api/user/profile')
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('NO_TOKEN');
    });

    test('应该拒绝无效令牌的请求', async () => {
      const response = await request(app)
        .get('/api/user/profile')
        .set('Authorization', 'Bearer invalid-token')
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('INVALID_TOKEN');
    });

    test('应该拒绝已禁用用户的请求', async () => {
      // 禁用用户
      await regularUser.update({ status: 'disabled' });

      const response = await request(app)
        .get('/api/user/profile')
        .set('Authorization', `Bearer ${regularUserToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('ACCOUNT_DISABLED');
    });

    test('应该拒绝未验证邮箱用户的请求', async () => {
      // 设置用户邮箱为未验证
      await regularUser.update({ email_verified: false });

      const response = await request(app)
        .get('/api/user/profile')
        .set('Authorization', `Bearer ${regularUserToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('EMAIL_NOT_VERIFIED');
    });
  });

  /**
   * 角色权限测试
   */
  describe('角色权限验证', () => {
    test('管理员应该能访问管理员专用接口', async () => {
      const response = await request(app)
        .get('/api/user/admin/users')
        .set('Authorization', `Bearer ${adminUserToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.users).toBeDefined();
    });

    test('普通用户应该被拒绝访问管理员专用接口', async () => {
      const response = await request(app)
        .get('/api/user/admin/users')
        .set('Authorization', `Bearer ${regularUserToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('INSUFFICIENT_PERMISSIONS');
    });

    test('版主应该被拒绝访问管理员专用接口', async () => {
      const response = await request(app)
        .get('/api/user/admin/users')
        .set('Authorization', `Bearer ${moderatorUserToken}`)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('INSUFFICIENT_PERMISSIONS');
    });

    test('管理员应该能更新用户状态', async () => {
      const response = await request(app)
        .put(`/api/user/admin/users/${regularUser.id}/status`)
        .set('Authorization', `Bearer ${adminUserToken}`)
        .send({
          status: 'disabled',
          reason: 'test reason',
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toContain('disabled');
    });

    test('普通用户应该被拒绝更新用户状态', async () => {
      const response = await request(app)
        .put(`/api/user/admin/users/${regularUser.id}/status`)
        .set('Authorization', `Bearer ${regularUserToken}`)
        .send({
          status: 'disabled',
          reason: 'test reason',
        })
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('INSUFFICIENT_PERMISSIONS');
    });
  });

  /**
   * 用户资料管理测试
   */
  describe('用户资料管理', () => {
    test('用户应该能获取自己的资料', async () => {
      const response = await request(app)
        .get('/api/user/profile')
        .set('Authorization', `Bearer ${regularUserToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.user.id).toBe(regularUser.id);
      expect(response.body.data.user.username).toBe('regularuser');
    });

    test('用户应该能更新自己的资料', async () => {
      const updateData = {
        profile: {
          displayName: 'New Display Name',
          bio: 'This is my bio',
        },
        preferences: {
          language: 'en-US',
          theme: 'dark',
        },
      };

      const response = await request(app)
        .put('/api/user/profile')
        .set('Authorization', `Bearer ${regularUserToken}`)
        .send(updateData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.user.profile.displayName).toBe('New Display Name');
      expect(response.body.data.user.preferences.language).toBe('en-US');
    });

    test('用户应该能获取自己的会话列表', async () => {
      const response = await request(app)
        .get('/api/user/sessions')
        .set('Authorization', `Bearer ${regularUserToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.sessions).toBeDefined();
      expect(Array.isArray(response.body.data.sessions)).toBe(true);
    });
  });

  /**
   * 会话管理测试
   */
  describe('会话管理', () => {
    test('用户应该能撤销其他会话', async () => {
      // 首先需要获取当前会话ID
      const loginResponse = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'regular@example.com',
          password: 'TestPass123!',
        })
        .expect(200);

      const newToken = loginResponse.body.data.tokens.accessToken;

      const response = await request(app)
        .post('/api/user/sessions/revoke-others')
        .set('Authorization', `Bearer ${newToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toContain('撤销');
    });
  });

  /**
   * 输入验证测试
   */
  describe('输入验证', () => {
    test('更新资料时应该验证无效输入', async () => {
      const invalidData = {
        profile: {
          displayName: '', // 太短
          bio: 'x'.repeat(501), // 太长
          avatar: 'invalid-url', // 无效URL
        },
        preferences: {
          language: 'invalid-lang', // 无效语言
          theme: 'invalid-theme', // 无效主题
        },
      };

      const response = await request(app)
        .put('/api/user/profile')
        .set('Authorization', `Bearer ${regularUserToken}`)
        .send(invalidData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('VALIDATION_ERROR');
      expect(response.body.details).toBeDefined();
    });

    test('管理员更新用户状态时应该验证无效状态', async () => {
      const response = await request(app)
        .put(`/api/user/admin/users/${regularUser.id}/status`)
        .set('Authorization', `Bearer ${adminUserToken}`)
        .send({
          status: 'invalid-status',
        })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('VALIDATION_ERROR');
    });
  });

  /**
   * 错误处理测试
   */
  describe('错误处理', () => {
    test('应该处理不存在的用户ID', async () => {
      const nonExistentId = '00000000-0000-0000-0000-000000000000';

      const response = await request(app)
        .put(`/api/user/admin/users/${nonExistentId}/status`)
        .set('Authorization', `Bearer ${adminUserToken}`)
        .send({
          status: 'disabled',
        })
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('USER_NOT_FOUND');
    });

    test('管理员应该不能禁用自己', async () => {
      const response = await request(app)
        .put(`/api/user/admin/users/${adminUser.id}/status`)
        .set('Authorization', `Bearer ${adminUserToken}`)
        .send({
          status: 'disabled',
        })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('CANNOT_DISABLE_SELF');
    });
  });

  /**
   * 频率限制测试
   */
  describe('频率限制', () => {
    test('应该限制资料更新的频率', async () => {
      const updateData = {
        profile: { displayName: 'Test' },
      };

      // 发送超过限制的请求
      const requests = [];
      for (let i = 0; i < 12; i++) {
        requests.push(
          request(app)
            .put('/api/user/profile')
            .set('Authorization', `Bearer ${regularUserToken}`)
            .send(updateData)
        );
      }

      const responses = await Promise.all(requests);

      // 应该有一些请求被限制
      const limitedResponses = responses.filter(res => res.status === 429);
      expect(limitedResponses.length).toBeGreaterThan(0);

      if (limitedResponses.length > 0) {
        expect(limitedResponses[0].body.error).toBe('RATE_LIMIT_EXCEEDED');
      }
    }, 10000); // 增加超时时间
  });
}); 