const request = require('supertest');
const { Sequelize } = require('sequelize');
const app = require('../src/app');
const { User, UserSession } = require('../src/models');
const JWTUtils = require('../src/utils/jwt');

// 测试数据库配置
const testDb = new Sequelize({
  dialect: 'sqlite',
  storage: ':memory:',
  logging: false
});

describe('JWT功能测试', () => {
  let testUser;
  let accessToken;
  let refreshToken;

  beforeAll(async () => {
    // 定义模型
    const { DataTypes } = require('sequelize');
    
    // 重新定义User模型
    const TestUser = testDb.define('User', {
      id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true
      },
      username: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true
      },
      email: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true
      },
      password_hash: {
        type: DataTypes.STRING,
        allowNull: false
      },
      role: {
        type: DataTypes.ENUM('user', 'admin'),
        defaultValue: 'user'
      },
      status: {
        type: DataTypes.ENUM('active', 'inactive', 'pending'),
        defaultValue: 'active'
      },
      email_verified: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
      },
      profile: {
        type: DataTypes.JSON,
        defaultValue: {}
      },
      preferences: {
        type: DataTypes.JSON,
        defaultValue: {}
      }
    }, {
      tableName: 'users',
      underscored: true
    });

    // 重新定义UserSession模型
    const TestUserSession = testDb.define('UserSession', {
      id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true
      },
      user_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
          model: 'users',
          key: 'id'
        }
      },
      refresh_token: {
        type: DataTypes.TEXT,
        allowNull: false
      },
      expires_at: {
        type: DataTypes.DATE,
        allowNull: false
      },
      status: {
        type: DataTypes.ENUM('active', 'revoked', 'expired'),
        defaultValue: 'active'
      },
      ip_address: DataTypes.STRING,
      user_agent: DataTypes.TEXT,
      device_info: {
        type: DataTypes.JSON,
        defaultValue: {}
      },
      location_info: {
        type: DataTypes.JSON,
        defaultValue: {}
      },
      last_activity_at: DataTypes.DATE,
      revoked_at: DataTypes.DATE,
      revoked_reason: DataTypes.STRING
    }, {
      tableName: 'user_sessions',
      underscored: true
    });

    // 设置关联
    TestUser.hasMany(TestUserSession, { foreignKey: 'user_id', as: 'sessions' });
    TestUserSession.belongsTo(TestUser, { foreignKey: 'user_id', as: 'user' });

    // 为测试模型添加必要的方法
    TestUserSession.prototype.isValid = function() {
      return this.status === 'active' && new Date() < this.expires_at;
    };

    TestUserSession.prototype.revoke = async function(reason = 'manual') {
      this.status = 'revoked';
      this.revoked_at = new Date();
      this.revoked_reason = reason;
      await this.save();
    };

    TestUserSession.prototype.updateActivity = async function() {
      this.last_activity_at = new Date();
      await this.save();
    };

    TestUserSession.revokeAllUserSessions = async function(userId, reason = 'logout_all') {
      const [affectedCount] = await this.update(
        {
          status: 'revoked',
          revoked_at: new Date(),
          revoked_reason: reason
        },
        {
          where: {
            user_id: userId,
            status: 'active'
          }
        }
      );
      return affectedCount;
    };

    TestUserSession.cleanupExpiredSessions = async function() {
      const [affectedCount] = await this.update(
        {
          status: 'expired'
        },
        {
          where: {
            expires_at: {
              [require('sequelize').Op.lt]: new Date()
            },
            status: 'active'
          }
        }
      );
      return affectedCount;
    };

    // 重新导出模型供JWT utils使用
    User.init = () => TestUser;
    UserSession.init = () => TestUserSession;
    User.findByPk = TestUser.findByPk.bind(TestUser);
    UserSession.findOne = TestUserSession.findOne.bind(TestUserSession);
    UserSession.findAll = TestUserSession.findAll.bind(TestUserSession);
    UserSession.create = TestUserSession.create.bind(TestUserSession);
    UserSession.revokeAllUserSessions = TestUserSession.revokeAllUserSessions.bind(TestUserSession);
    UserSession.cleanupExpiredSessions = TestUserSession.cleanupExpiredSessions.bind(TestUserSession);

    // 同步数据库
    await testDb.sync({ force: true });

    // 创建测试用户
    testUser = await TestUser.create({
      username: 'jwttest',
      email: 'jwttest@example.com',
      password_hash: await require('bcrypt').hash('password123', 10),
      status: 'active',
      email_verified: true,
    });
  });

  afterAll(async () => {
    await testDb.close();
  });

  afterEach(async () => {
    // 清理会话数据
    try {
      await testDb.models.UserSession.destroy({ where: {} });
    } catch (error) {
      // 忽略清理错误
    }
  });

  describe('JWT工具类测试', () => {
    test('应该能生成访问令牌', () => {
      const payload = {
        userId: testUser.id,
        email: testUser.email,
        role: testUser.role,
      };

      const token = JWTUtils.generateAccessToken(payload);
      expect(token).toBeTruthy();
      expect(typeof token).toBe('string');
    });

    test('应该能验证访问令牌', () => {
      const payload = {
        userId: testUser.id,
        email: testUser.email,
        role: testUser.role,
      };

      const token = JWTUtils.generateAccessToken(payload);
      const decoded = JWTUtils.verifyAccessToken(token);

      expect(decoded).toBeTruthy();
      expect(decoded.userId).toBe(testUser.id);
      expect(decoded.email).toBe(testUser.email);
      expect(decoded.type).toBe('access');
    });

    test('应该能生成刷新令牌', () => {
      const payload = { userId: testUser.id };
      const token = JWTUtils.generateRefreshToken(payload);
      
      expect(token).toBeTruthy();
      expect(typeof token).toBe('string');
    });

    test('应该能验证刷新令牌', () => {
      const payload = { userId: testUser.id };
      const token = JWTUtils.generateRefreshToken(payload);
      const decoded = JWTUtils.verifyRefreshToken(token);

      expect(decoded).toBeTruthy();
      expect(decoded.userId).toBe(testUser.id);
      expect(decoded.type).toBe('refresh');
      expect(decoded.jti).toBeTruthy(); // JWT ID应该存在
    });

    test('应该能生成令牌对', async () => {
      const sessionInfo = {
        ipAddress: '127.0.0.1',
        userAgent: 'Test-Agent',
      };

      const tokenPair = await JWTUtils.generateTokenPair(testUser, sessionInfo);

      expect(tokenPair).toBeTruthy();
      expect(tokenPair.accessToken).toBeTruthy();
      expect(tokenPair.refreshToken).toBeTruthy();
      expect(tokenPair.tokenType).toBe('Bearer');
      expect(typeof tokenPair.expiresIn).toBe('number');

      // 验证会话已保存到数据库
      const session = await UserSession.findOne({
        where: { refresh_token: tokenPair.refreshToken }
      });
      expect(session).toBeTruthy();
      expect(session.user_id).toBe(testUser.id);
      expect(session.ip_address).toBe('127.0.0.1');
    });

    test('应该能刷新访问令牌', async () => {
      // 先生成初始令牌对
      const initialTokens = await JWTUtils.generateTokenPair(testUser, {
        ipAddress: '127.0.0.1',
        userAgent: 'Test-Agent',
      });

      // 刷新令牌
      const newTokens = await JWTUtils.refreshAccessToken(
        initialTokens.refreshToken,
        { ipAddress: '127.0.0.1' }
      );

      expect(newTokens).toBeTruthy();
      expect(newTokens.accessToken).toBeTruthy();
      expect(newTokens.refreshToken).toBeTruthy();
      expect(newTokens.accessToken).not.toBe(initialTokens.accessToken);
      expect(newTokens.refreshToken).not.toBe(initialTokens.refreshToken);
    });

    test('应该能撤销刷新令牌', async () => {
      const tokenPair = await JWTUtils.generateTokenPair(testUser, {
        ipAddress: '127.0.0.1',
      });

      const revoked = await JWTUtils.revokeRefreshToken(tokenPair.refreshToken);
      expect(revoked).toBe(true);

      // 验证会话状态已更新
      const session = await UserSession.findOne({
        where: { refresh_token: tokenPair.refreshToken }
      });
      expect(session.status).toBe('revoked');
    });

    test('应该能处理过期时间字符串', () => {
      expect(JWTUtils.parseExpiresIn('15m')).toBe(15 * 60 * 1000);
      expect(JWTUtils.parseExpiresIn('1h')).toBe(60 * 60 * 1000);
      expect(JWTUtils.parseExpiresIn('7d')).toBe(7 * 24 * 60 * 60 * 1000);
      expect(JWTUtils.parseExpiresIn(3600)).toBe(3600 * 1000);
    });

    test('应该能提取Bearer令牌', () => {
      const token = 'test-token-123';
      const authHeader = `Bearer ${token}`;
      
      const extracted = JWTUtils.extractBearerToken(authHeader);
      expect(extracted).toBe(token);

      expect(JWTUtils.extractBearerToken('Invalid header')).toBeNull();
      expect(JWTUtils.extractBearerToken('')).toBeNull();
      expect(JWTUtils.extractBearerToken(null)).toBeNull();
    });
  });

  describe('认证API测试', () => {
    beforeEach(async () => {
      // 为每个测试生成新的令牌
      const tokenPair = await JWTUtils.generateTokenPair(testUser, {
        ipAddress: '127.0.0.1',
        userAgent: 'Test-Agent',
      });
      accessToken = tokenPair.accessToken;
      refreshToken = tokenPair.refreshToken;
    });

    describe('POST /api/auth/refresh-token', () => {
      test('应该能刷新令牌', async () => {
        const response = await request(app)
          .post('/api/auth/refresh-token')
          .send({ refreshToken })
          .expect(200);

        expect(response.body.success).toBe(true);
        expect(response.body.data.accessToken).toBeTruthy();
        expect(response.body.data.refreshToken).toBeTruthy();
        expect(response.body.data.tokenType).toBe('Bearer');
      });

      test('无效刷新令牌应该返回401', async () => {
        await request(app)
          .post('/api/auth/refresh-token')
          .send({ refreshToken: 'invalid-token' })
          .expect(401);
      });

      test('缺少刷新令牌应该返回400', async () => {
        await request(app)
          .post('/api/auth/refresh-token')
          .send({})
          .expect(400);
      });
    });

    describe('POST /api/auth/logout', () => {
      test('应该能登出用户', async () => {
        const response = await request(app)
          .post('/api/auth/logout')
          .send({ refreshToken })
          .expect(200);

        expect(response.body.success).toBe(true);
        expect(response.body.message).toBe('登出成功');
      });

      test('无效刷新令牌应该返回400', async () => {
        await request(app)
          .post('/api/auth/logout')
          .send({ refreshToken: 'invalid-token' })
          .expect(400);
      });
    });

    describe('GET /api/auth/verify-token', () => {
      test('有效令牌应该返回用户信息', async () => {
        const response = await request(app)
          .get('/api/auth/verify-token')
          .set('Authorization', `Bearer ${accessToken}`)
          .expect(200);

        expect(response.body.success).toBe(true);
        expect(response.body.data.user.id).toBe(testUser.id);
        expect(response.body.data.user.email).toBe(testUser.email);
        expect(response.body.data.token.type).toBe('access');
      });

      test('无效令牌应该返回401', async () => {
        await request(app)
          .get('/api/auth/verify-token')
          .set('Authorization', 'Bearer invalid-token')
          .expect(401);
      });

      test('缺少令牌应该返回401', async () => {
        await request(app)
          .get('/api/auth/verify-token')
          .expect(401);
      });
    });

    describe('GET /api/auth/me', () => {
      test('应该返回当前用户信息', async () => {
        const response = await request(app)
          .get('/api/auth/me')
          .set('Authorization', `Bearer ${accessToken}`)
          .expect(200);

        expect(response.body.success).toBe(true);
        expect(response.body.data.user.id).toBe(testUser.id);
        expect(response.body.data.user.username).toBe(testUser.username);
        expect(response.body.data.user.email).toBe(testUser.email);
      });
    });

    describe('GET /api/auth/sessions', () => {
      test('应该返回用户会话列表', async () => {
        const response = await request(app)
          .get('/api/auth/sessions')
          .set('Authorization', `Bearer ${accessToken}`)
          .expect(200);

        expect(response.body.success).toBe(true);
        expect(response.body.data.sessions).toBeInstanceOf(Array);
        expect(response.body.data.total).toBeGreaterThan(0);
      });
    });

    describe('POST /api/auth/logout-all', () => {
      test('应该能登出所有设备', async () => {
        const response = await request(app)
          .post('/api/auth/logout-all')
          .set('Authorization', `Bearer ${accessToken}`)
          .expect(200);

        expect(response.body.success).toBe(true);
        expect(response.body.message).toBe('已登出所有设备');
        expect(response.body.data.revokedSessions).toBeGreaterThan(0);
      });
    });
  });

  describe('认证中间件测试', () => {
    test('有效令牌应该通过认证', async () => {
      const response = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
    });

    test('无效令牌应该被拒绝', async () => {
      await request(app)
        .get('/api/auth/me')
        .set('Authorization', 'Bearer invalid-token')
        .expect(401);
    });

    test('禁用用户应该被拒绝', async () => {
      // 禁用用户
      await testUser.update({ status: 'inactive' });

      await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(401);

      // 恢复用户状态
      await testUser.update({ status: 'active' });
    });
  });
}); 