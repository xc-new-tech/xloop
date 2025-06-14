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
    email_verification_token: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    email_verification_expires: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    password_reset_token: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    password_reset_expires: {
      type: DataTypes.DATE,
      allowNull: true,
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

  // 添加revoke方法到UserSession
  UserSession.prototype.revoke = async function(reason = 'manual') {
    await this.update({
      status: 'revoked',
      revoked_at: new Date(),
      revoke_reason: reason,
    });
    return this;
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

// 模拟邮件服务
jest.mock('../src/services/emailService');

// 模拟邮件配置以避免邮件发送错误
jest.mock('../src/config/email', () => ({
  createTransporter: () => ({
    sendMail: jest.fn().mockResolvedValue({ messageId: 'test-message-id' }),
    verify: jest.fn().mockResolvedValue(true),
  }),
  emailTemplates: {
    verification: {
      subject: '测试邮件验证',
      getHtml: (link, username) => `测试邮件内容 ${link} ${username}`,
    },
  },
}));

// 设置测试环境变量
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-jwt-secret-key-for-testing';
process.env.JWT_REFRESH_SECRET = 'test-jwt-refresh-secret-key-for-testing';

const app = require('../src/app');
const { sequelize, User, UserSession } = require('../src/models');
const EmailService = require('../src/services/emailService');
const bcrypt = require('bcrypt');

/**
 * 认证系统完整测试套件
 * 涵盖注册、登录、邮箱验证、密码重置等功能
 */
describe('认证系统测试', () => {
  beforeAll(async () => {
    // 同步数据库表
    await sequelize.sync({ force: true });
  });

  afterAll(async () => {
    // 清理数据库连接
    await sequelize.close();
  });

  beforeEach(async () => {
    // 每次测试前清理数据
    await UserSession.destroy({ where: {} });
    await User.destroy({ where: {} });
    
    // 重置邮件服务mock
    EmailService.mockClear();
    EmailService.prototype.sendVerificationEmail = jest.fn().mockResolvedValue({ messageId: 'test-message-id' });
    EmailService.prototype.sendPasswordResetEmail = jest.fn().mockResolvedValue({ messageId: 'test-message-id' });
    EmailService.prototype.sendPasswordResetConfirmation = jest.fn().mockResolvedValue({ messageId: 'test-message-id' });
  });

  /**
   * 用户注册测试
   */
  describe('POST /api/auth/register', () => {
    test('应该成功注册新用户', async () => {
      const userData = {
        username: 'testuser',
        email: 'test@example.com',
        password: 'TestPass123!',
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('注册成功，请检查您的邮箱激活账户');
      expect(response.body.data.user.username).toBe(userData.username);
      expect(response.body.data.user.email).toBe(userData.email);
      expect(response.body.data.user.status).toBe('pending');
      expect(response.body.data.user.emailVerified).toBe(false);

      // 验证邮件服务被调用
      expect(EmailService.prototype.sendVerificationEmail).toHaveBeenCalledWith(
        userData.email,
        userData.username,
        expect.any(String)
      );

      // 验证用户已保存到数据库
      const user = await User.findOne({ where: { email: userData.email } });
      expect(user).toBeTruthy();
      expect(user.username).toBe(userData.username);
    });

    test('用户名已存在时应该返回错误', async () => {
      // 先创建一个用户
      await User.create({
        username: 'existinguser',
        email: 'existing@example.com',
        password_hash: 'hashedpassword',
        status: 'active',
        email_verified: true,
      });

      const userData = {
        username: 'existinguser',
        email: 'newemail@example.com',
        password: 'TestPass123!',
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(409);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('USERNAME_EXISTS');
    });

    test('邮箱已存在时应该返回错误', async () => {
      // 先创建一个用户
      await User.create({
        username: 'existinguser',
        email: 'existing@example.com',
        password_hash: 'hashedpassword',
        status: 'active',
        email_verified: true,
      });

      const userData = {
        username: 'newuser',
        email: 'existing@example.com',
        password: 'TestPass123!',
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(409);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('EMAIL_EXISTS');
    });

    test('无效输入应该返回验证错误', async () => {
      const invalidData = {
        username: 'ab', // 太短
        email: 'invalid-email',
        password: '123', // 太短且不符合要求
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(invalidData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('VALIDATION_ERROR');
      expect(response.body.details).toBeDefined();
    });
  });

  /**
   * 用户登录测试
   */
  describe('POST /api/auth/login', () => {
    let testUser;

    beforeEach(async () => {
      const passwordHash = await bcrypt.hash('TestPass123!', 12);

      testUser = await User.create({
        username: 'testuser',
        email: 'test@example.com',
        password_hash: passwordHash,
        status: 'active',
        email_verified: true,
        login_count: 0,
      });
    });

    test('应该成功登录', async () => {
      const loginData = {
        email: 'test@example.com',
        password: 'TestPass123!',
      };

      const response = await request(app)
        .post('/api/auth/login')
        .send(loginData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('登录成功');
      expect(response.body.data.user.username).toBe(testUser.username);
      expect(response.body.data.tokens.accessToken).toBeDefined();
      expect(response.body.data.tokens.refreshToken).toBeDefined();
    });

    test('错误密码应该返回401', async () => {
      const loginData = {
        email: 'test@example.com',
        password: 'wrongpassword',
      };

      const response = await request(app)
        .post('/api/auth/login')
        .send(loginData)
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('INVALID_CREDENTIALS');
    });

    test('不存在的用户应该返回401', async () => {
      const loginData = {
        email: 'nonexistent@example.com',
        password: 'TestPass123!',
      };

      const response = await request(app)
        .post('/api/auth/login')
        .send(loginData)
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('INVALID_CREDENTIALS');
    });

    test('未验证邮箱的用户应该返回403', async () => {
      // 创建未验证邮箱的用户
      const passwordHash = await bcrypt.hash('TestPass123!', 12);

      await User.create({
        username: 'unverified',
        email: 'unverified@example.com',
        password_hash: passwordHash,
        status: 'pending',
        email_verified: false,
        login_count: 0,
      });

      const loginData = {
        email: 'unverified@example.com',
        password: 'TestPass123!',
      };

      const response = await request(app)
        .post('/api/auth/login')
        .send(loginData)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('EMAIL_NOT_VERIFIED');
    });

    test('被禁用的账户应该返回403', async () => {
      // 禁用用户账户
      await testUser.update({ status: 'disabled' });

      const loginData = {
        email: 'test@example.com',
        password: 'TestPass123!',
      };

      const response = await request(app)
        .post('/api/auth/login')
        .send(loginData)
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('ACCOUNT_DISABLED');
    });
  });

  /**
   * 邮箱验证测试
   */
  describe('POST /api/auth/verify-email', () => {
    let testUser;
    let verificationToken;

    beforeEach(async () => {
      verificationToken = crypto.randomBytes(32).toString('hex');
      const verificationExpires = new Date(Date.now() + 24 * 60 * 60 * 1000);

      testUser = await User.create({
        username: 'testuser',
        email: 'test@example.com',
        password_hash: 'hashedpassword',
        status: 'pending',
        email_verified: false,
        email_verification_token: verificationToken,
        email_verification_expires: verificationExpires,
        login_count: 0,
      });
    });

    test('应该成功验证邮箱', async () => {
      const response = await request(app)
        .post('/api/auth/verify-email')
        .send({ token: verificationToken })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('邮箱验证成功，账户已激活');
      expect(response.body.data.user.emailVerified).toBe(true);
      expect(response.body.data.user.status).toBe('active');

      // 验证数据库中的用户状态已更新
      await testUser.reload();
      expect(testUser.email_verified).toBe(true);
      expect(testUser.status).toBe('active');
      expect(testUser.email_verification_token).toBeNull();
    });

    test('无效令牌应该返回400', async () => {
      const response = await request(app)
        .post('/api/auth/verify-email')
        .send({ token: 'invalid-token-but-long-enough-to-pass-length-validation-12345678901234567890' })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('INVALID_TOKEN');
    });

    test('过期令牌应该返回400', async () => {
      // 设置令牌为已过期
      await testUser.update({
        email_verification_expires: new Date(Date.now() - 1000),
      });

      const response = await request(app)
        .post('/api/auth/verify-email')
        .send({ token: verificationToken })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('INVALID_TOKEN');
    });
  });

  /**
   * 忘记密码测试
   */
  describe('POST /api/auth/forgot-password', () => {
    let testUser;

    beforeEach(async () => {
      testUser = await User.create({
        username: 'testuser',
        email: 'test@example.com',
        password_hash: 'hashedpassword',
        status: 'active',
        email_verified: true,
        login_count: 0,
      });
    });

    test('应该成功发送密码重置邮件', async () => {
      const response = await request(app)
        .post('/api/auth/forgot-password')
        .send({ email: 'test@example.com' })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('密码重置邮件已发送，请检查您的邮箱');

      // 验证邮件服务被调用
      expect(EmailService.prototype.sendPasswordResetEmail).toHaveBeenCalledWith(
        'test@example.com',
        'testuser',
        expect.any(String)
      );

      // 验证重置令牌已保存到数据库
      await testUser.reload();
      expect(testUser.password_reset_token).toBeTruthy();
      expect(testUser.password_reset_expires).toBeTruthy();
    });

    test('不存在的邮箱应该返回成功消息（防止邮箱枚举）', async () => {
      const response = await request(app)
        .post('/api/auth/forgot-password')
        .send({ email: 'nonexistent@example.com' })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('如果该邮箱已注册，您将收到密码重置邮件');

      // 验证邮件服务未被调用
      expect(EmailService.prototype.sendPasswordResetEmail).not.toHaveBeenCalled();
    });

    test('被禁用的账户应该返回403', async () => {
      await testUser.update({ status: 'disabled' });

      const response = await request(app)
        .post('/api/auth/forgot-password')
        .send({ email: 'test@example.com' })
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('ACCOUNT_DISABLED');
    });

    test('无效邮箱格式应该返回验证错误', async () => {
      const response = await request(app)
        .post('/api/auth/forgot-password')
        .send({ email: 'invalid-email' })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('VALIDATION_ERROR');
    });
  });

  /**
   * 重置密码测试
   */
  describe('POST /api/auth/reset-password', () => {
    let testUser;
    let resetToken;

    beforeEach(async () => {
      resetToken = crypto.randomBytes(32).toString('hex');
      const resetExpires = new Date(Date.now() + 60 * 60 * 1000); // 1小时后过期

      testUser = await User.create({
        username: 'testuser',
        email: 'test@example.com',
        password_hash: 'old-hashed-password',
        status: 'active',
        email_verified: true,
        password_reset_token: resetToken,
        password_reset_expires: resetExpires,
        login_count: 0,
      });
    });

    test('应该成功重置密码', async () => {
      const response = await request(app)
        .post('/api/auth/reset-password')
        .send({
          token: resetToken,
          newPassword: 'NewPass123!',
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('密码重置成功，请使用新密码登录');

      // 验证确认邮件被发送
      expect(EmailService.prototype.sendPasswordResetConfirmation).toHaveBeenCalledWith(
        'test@example.com',
        'testuser'
      );

      // 验证数据库中的密码已更新且重置令牌已清除
      await testUser.reload();
      expect(testUser.password_hash).not.toBe('old-hashed-password');
      expect(testUser.password_reset_token).toBeNull();
      expect(testUser.password_reset_expires).toBeNull();

      // 验证可以使用新密码登录
      const loginResponse = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'test@example.com',
          password: 'NewPass123!',
        })
        .expect(200);

      expect(loginResponse.body.success).toBe(true);
    });

    test('无效重置令牌应该返回400', async () => {
      const response = await request(app)
        .post('/api/auth/reset-password')
        .send({
          token: 'invalid-reset-token-but-long-enough-to-pass-validation-12345678901234567890',
          newPassword: 'NewPass123!',
        })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('INVALID_TOKEN');
    });

    test('过期重置令牌应该返回400', async () => {
      // 设置令牌为已过期
      await testUser.update({
        password_reset_expires: new Date(Date.now() - 1000),
      });

      const response = await request(app)
        .post('/api/auth/reset-password')
        .send({
          token: resetToken,
          newPassword: 'NewPass123!',
        })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('TOKEN_EXPIRED');
    });

    test('被禁用的账户应该返回403', async () => {
      await testUser.update({ status: 'disabled' });

      const response = await request(app)
        .post('/api/auth/reset-password')
        .send({
          token: resetToken,
          newPassword: 'NewPass123!',
        })
        .expect(403);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('ACCOUNT_DISABLED');
    });

    test('无效新密码应该返回验证错误', async () => {
      const response = await request(app)
        .post('/api/auth/reset-password')
        .send({
          token: resetToken,
          newPassword: '123', // 太短且不符合要求
        })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('VALIDATION_ERROR');
    });
  });

  /**
   * 输入验证测试
   */
  describe('输入验证测试', () => {
    test('注册时缺少必需字段应该返回验证错误', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({})
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('VALIDATION_ERROR');
    });

    test('登录时缺少必需字段应该返回验证错误', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({})
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('VALIDATION_ERROR');
    });

    test('邮箱验证时缺少令牌应该返回验证错误', async () => {
      const response = await request(app)
        .post('/api/auth/verify-email')
        .send({})
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('VALIDATION_ERROR');
    });

    test('忘记密码时缺少邮箱应该返回验证错误', async () => {
      const response = await request(app)
        .post('/api/auth/forgot-password')
        .send({})
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('VALIDATION_ERROR');
    });

    test('重置密码时缺少必需字段应该返回验证错误', async () => {
      const response = await request(app)
        .post('/api/auth/reset-password')
        .send({})
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('VALIDATION_ERROR');
    });
  });
}); 