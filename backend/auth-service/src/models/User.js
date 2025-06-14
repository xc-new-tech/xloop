const { DataTypes, Model } = require('sequelize');
const bcrypt = require('bcrypt');
const { sequelize } = require('../config/database');

class User extends Model {
  // 实例方法：验证密码
  async validatePassword(password) {
    return bcrypt.compare(password, this.password_hash);
  }

  // 实例方法：生成用户安全信息（不包含敏感数据）
  toSafeObject() {
    return {
      id: this.id,
      username: this.username,
      email: this.email,
      first_name: this.first_name,
      last_name: this.last_name,
      avatar_url: this.avatar_url,
      role: this.role,
      status: this.status,
      email_verified: this.email_verified,
      last_login_at: this.last_login_at,
      created_at: this.created_at,
      updated_at: this.updated_at,
    };
  }

  // 类方法：加密密码
  static async hashPassword(password) {
    const saltRounds = 12;
    return bcrypt.hash(password, saltRounds);
  }

  // 类方法：通过邮箱查找用户
  static async findByEmail(email) {
    return this.findOne({
      where: { email: email.toLowerCase() }
    });
  }

  // 类方法：通过用户名查找用户
  static async findByUsername(username) {
    return this.findOne({
      where: { username: username.toLowerCase() }
    });
  }
}

// 定义用户表结构
User.init({
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
    comment: '用户唯一标识符'
  },
  username: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true,
    validate: {
      len: [3, 50],
      is: /^[a-zA-Z0-9_-]+$/,  // 允许字母、数字、下划线和连字符
    },
    comment: '用户名（唯一）'
  },
  email: {
    type: DataTypes.STRING(255),
    allowNull: false,
    unique: true,
    validate: {
      isEmail: true,
    },
    set(value) {
      // 邮箱存储为小写
      this.setDataValue('email', value.toLowerCase());
    },
    comment: '邮箱地址（唯一）'
  },
  password_hash: {
    type: DataTypes.STRING(255),
    allowNull: false,
    comment: '加密后的密码'
  },
  first_name: {
    type: DataTypes.STRING(50),
    allowNull: true,
    validate: {
      len: [1, 50],
    },
    comment: '名字'
  },
  last_name: {
    type: DataTypes.STRING(50),
    allowNull: true,
    validate: {
      len: [1, 50],
    },
    comment: '姓氏'
  },
  avatar_url: {
    type: DataTypes.TEXT,
    allowNull: true,
    validate: {
      isUrl: true,
    },
    comment: '头像URL'
  },
  role: {
    type: DataTypes.ENUM('user', 'admin', 'moderator'),
    allowNull: false,
    defaultValue: 'user',
    comment: '用户角色'
  },
  status: {
    type: DataTypes.ENUM('active', 'inactive', 'suspended', 'pending'),
    allowNull: false,
    defaultValue: 'pending',
    comment: '账户状态'
  },
  email_verified: {
    type: DataTypes.BOOLEAN,
    allowNull: false,
    defaultValue: false,
    comment: '邮箱是否已验证'
  },
  email_verification_token: {
    type: DataTypes.STRING(255),
    allowNull: true,
    comment: '邮箱验证令牌'
  },
  email_verification_expires: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: '邮箱验证令牌过期时间'
  },
  password_reset_token: {
    type: DataTypes.STRING(255),
    allowNull: true,
    comment: '密码重置令牌'
  },
  password_reset_expires: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: '密码重置令牌过期时间'
  },
  last_login_at: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: '最后登录时间'
  },
  login_attempts: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
    comment: '失败登录尝试次数'
  },
  locked_until: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: '账户锁定截止时间'
  },
  preferences: {
    type: DataTypes.JSONB,
    allowNull: true,
    defaultValue: {},
    comment: '用户偏好设置'
  },
  metadata: {
    type: DataTypes.JSONB,
    allowNull: true,
    defaultValue: {},
    comment: '扩展元数据'
  }
}, {
  sequelize,
  modelName: 'User',
  tableName: 'users',
  timestamps: true,
  paranoid: true, // 软删除
  underscored: true,
  indexes: [
    {
      unique: true,
      fields: ['email']
    },
    {
      unique: true,
      fields: ['username']
    },
    {
      fields: ['status']
    },
    {
      fields: ['role']
    },
    {
      fields: ['email_verified']
    },
    {
      fields: ['created_at']
    }
  ],
  hooks: {
    // 创建用户前处理
    beforeCreate: async (user) => {
      if (user.username) {
        user.username = user.username.toLowerCase();
      }
    },
    // 更新用户前处理
    beforeUpdate: async (user) => {
      if (user.changed('username') && user.username) {
        user.username = user.username.toLowerCase();
      }
    }
  }
});

module.exports = User; 