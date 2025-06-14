const { Sequelize, DataTypes } = require('sequelize');
const bcrypt = require('bcrypt');

// 为测试创建一个内存SQLite数据库
const sequelize = new Sequelize('sqlite::memory:', {
  logging: false
});

// 重新定义简化的User模型用于测试
const User = sequelize.define('User', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  username: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true
  },
  email: {
    type: DataTypes.STRING(255),
    allowNull: false,
    unique: true
  },
  password_hash: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  role: {
    type: DataTypes.ENUM('user', 'admin', 'moderator'),
    allowNull: false,
    defaultValue: 'user'
  },
  status: {
    type: DataTypes.ENUM('active', 'inactive', 'suspended', 'pending'),
    allowNull: false,
    defaultValue: 'pending'
  },
  email_verified: {
    type: DataTypes.BOOLEAN,
    allowNull: false,
    defaultValue: false
  }
});

// 重新定义简化的UserSession模型用于测试
const UserSession = sequelize.define('UserSession', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: false
  },
  refresh_token: {
    type: DataTypes.STRING(512),
    allowNull: false,
    unique: true
  },
  status: {
    type: DataTypes.ENUM('active', 'expired', 'revoked'),
    allowNull: false,
    defaultValue: 'active'
  },
  expires_at: {
    type: DataTypes.DATE,
    allowNull: false
  }
});

// 定义关联
User.hasMany(UserSession, { foreignKey: 'user_id', as: 'sessions' });
UserSession.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

// 添加User模型方法
User.hashPassword = async function(password) {
  return bcrypt.hash(password, 12);
};

User.prototype.validatePassword = async function(password) {
  return bcrypt.compare(password, this.password_hash);
};

User.findByEmail = async function(email) {
  return this.findOne({ where: { email: email.toLowerCase() } });
};

// 添加UserSession模型方法
UserSession.prototype.isValid = function() {
  return this.status === 'active' && this.expires_at > new Date();
};

describe('数据库模型测试', () => {
  beforeAll(async () => {
    await sequelize.sync({ force: true });
  });

  afterAll(async () => {
    await sequelize.close();
  });

  afterEach(async () => {
    await UserSession.destroy({ where: {}, force: true });
    await User.destroy({ where: {}, force: true });
  });

  describe('User模型测试', () => {
    test('应该能够创建用户', async () => {
      const userData = {
        username: 'testuser',
        email: 'test@example.com',
        password_hash: await User.hashPassword('password123')
      };

      const user = await User.create(userData);

      expect(user.id).toBeDefined();
      expect(user.username).toBe('testuser');
      expect(user.email).toBe('test@example.com');
      expect(user.role).toBe('user');
      expect(user.status).toBe('pending');
      expect(user.email_verified).toBe(false);
    });

    test('应该验证密码', async () => {
      const password = 'testpassword123';
      const user = await User.create({
        username: 'testuser2',
        email: 'test2@example.com',
        password_hash: await User.hashPassword(password)
      });

      const isValid = await user.validatePassword(password);
      expect(isValid).toBe(true);

      const isInvalid = await user.validatePassword('wrongpassword');
      expect(isInvalid).toBe(false);
    });

    test('应该通过邮箱查找用户', async () => {
      await User.create({
        username: 'testuser3',
        email: 'test3@example.com',
        password_hash: await User.hashPassword('password123')
      });

      const foundUser = await User.findByEmail('test3@example.com');
      expect(foundUser).toBeTruthy();
      expect(foundUser.username).toBe('testuser3');

      const notFound = await User.findByEmail('notfound@example.com');
      expect(notFound).toBeNull();
    });
  });

  describe('UserSession模型测试', () => {
    let testUser;

    beforeEach(async () => {
      testUser = await User.create({
        username: 'sessionuser',
        email: 'session@example.com',
        password_hash: await User.hashPassword('password123')
      });
    });

    test('应该能够创建用户会话', async () => {
      const sessionData = {
        user_id: testUser.id,
        refresh_token: 'test-refresh-token-123',
        expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
      };

      const session = await UserSession.create(sessionData);

      expect(session.id).toBeDefined();
      expect(session.user_id).toBe(testUser.id);
      expect(session.refresh_token).toBe('test-refresh-token-123');
      expect(session.status).toBe('active');
    });

    test('应该验证会话有效性', async () => {
      const validSession = await UserSession.create({
        user_id: testUser.id,
        refresh_token: 'valid-token',
        expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
      });

      expect(validSession.isValid()).toBe(true);

      const expiredSession = await UserSession.create({
        user_id: testUser.id,
        refresh_token: 'expired-token',
        expires_at: new Date(Date.now() - 1000)
      });

      expect(expiredSession.isValid()).toBe(false);
    });
  });

  describe('模型关联测试', () => {
    test('用户应该有会话关联', async () => {
      const user = await User.create({
        username: 'relationuser',
        email: 'relation@example.com',
        password_hash: await User.hashPassword('password123')
      });

      await UserSession.create({
        user_id: user.id,
        refresh_token: 'relation-token',
        expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
      });

      const userWithSessions = await User.findByPk(user.id, {
        include: [{ model: UserSession, as: 'sessions' }]
      });

      expect(userWithSessions.sessions).toBeDefined();
      expect(userWithSessions.sessions.length).toBe(1);
      expect(userWithSessions.sessions[0].refresh_token).toBe('relation-token');
    });
  });
}); 