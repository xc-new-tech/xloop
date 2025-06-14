const { DataTypes, Model } = require('sequelize');
const { sequelize } = require('../config/database');

class UserSession extends Model {
  // 实例方法：检查会话是否有效
  isValid() {
    const now = new Date();
    return this.status === 'active' && 
           this.expires_at > now && 
           (!this.last_activity_at || 
            (now - this.last_activity_at) < (30 * 24 * 60 * 60 * 1000)); // 30天无活动限制
  }

  // 实例方法：更新最后活动时间
  async updateActivity() {
    this.last_activity_at = new Date();
    await this.save();
  }

  // 实例方法：撤销会话
  async revoke(reason = 'manual') {
    this.status = 'revoked';
    this.revoked_at = new Date();
    this.revoke_reason = reason;
    await this.save();
  }

  // 类方法：清理过期会话
  static async cleanupExpiredSessions() {
    const now = new Date();
    return this.update(
      { 
        status: 'expired',
        revoked_at: now,
        revoke_reason: 'expired'
      },
      {
        where: {
          status: 'active',
          expires_at: { [sequelize.Sequelize.Op.lt]: now }
        }
      }
    );
  }

  // 类方法：撤销用户的所有会话
  static async revokeAllUserSessions(userId, reason = 'logout_all') {
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
  }

  // 类方法：通过刷新令牌查找有效会话
  static async findValidByRefreshToken(refreshToken) {
    const session = await this.findOne({
      where: {
        refresh_token: refreshToken,
        status: 'active'
      }
    });

    return session && session.isValid() ? session : null;
  }
}

// 定义用户会话表结构
UserSession.init({
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
    comment: '会话唯一标识符'
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'users',
      key: 'id'
    },
    onUpdate: 'CASCADE',
    onDelete: 'CASCADE',
    comment: '关联的用户ID'
  },
  refresh_token: {
    type: DataTypes.STRING(512),
    allowNull: false,
    unique: true,
    comment: 'JWT刷新令牌'
  },
  device_info: {
    type: DataTypes.JSONB,
    allowNull: true,
    defaultValue: {},
    comment: '设备信息（浏览器、操作系统等）'
  },
  ip_address: {
    type: DataTypes.INET,
    allowNull: true,
    comment: '客户端IP地址'
  },
  user_agent: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '用户代理字符串'
  },
  status: {
    type: DataTypes.ENUM('active', 'expired', 'revoked'),
    allowNull: false,
    defaultValue: 'active',
    comment: '会话状态'
  },
  expires_at: {
    type: DataTypes.DATE,
    allowNull: false,
    comment: '会话过期时间'
  },
  last_activity_at: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: '最后活动时间'
  },
  revoked_at: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: '会话撤销时间'
  },
  revoke_reason: {
    type: DataTypes.STRING(100),
    allowNull: true,
    comment: '撤销原因'
  },
  location_info: {
    type: DataTypes.JSONB,
    allowNull: true,
    defaultValue: {},
    comment: '地理位置信息'
  }
}, {
  sequelize,
  modelName: 'UserSession',
  tableName: 'user_sessions',
  timestamps: true,
  underscored: true,
  indexes: [
    {
      unique: true,
      fields: ['refresh_token']
    },
    {
      fields: ['user_id']
    },
    {
      fields: ['status']
    },
    {
      fields: ['expires_at']
    },
    {
      fields: ['last_activity_at']
    },
    {
      fields: ['created_at']
    },
    {
      fields: ['ip_address']
    }
  ],
  hooks: {
    // 创建会话前自动清理过期会话
    beforeCreate: async () => {
      await UserSession.cleanupExpiredSessions();
    }
  }
});

module.exports = UserSession; 