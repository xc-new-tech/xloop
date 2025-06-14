const { DataTypes } = require('sequelize');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // 创建用户表
    await queryInterface.createTable('users', {
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
        comment: '用户名（唯一）'
      },
      email: {
        type: DataTypes.STRING(255),
        allowNull: false,
        unique: true,
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
        comment: '名字'
      },
      last_name: {
        type: DataTypes.STRING(50),
        allowNull: true,
        comment: '姓氏'
      },
      avatar_url: {
        type: DataTypes.TEXT,
        allowNull: true,
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
      },
      created_at: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      updated_at: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      deleted_at: {
        type: DataTypes.DATE,
        allowNull: true,
        comment: '软删除时间'
      }
    });

    // 创建索引
    await queryInterface.addIndex('users', ['email'], { unique: true, name: 'users_email_unique' });
    await queryInterface.addIndex('users', ['username'], { unique: true, name: 'users_username_unique' });
    await queryInterface.addIndex('users', ['status'], { name: 'users_status_idx' });
    await queryInterface.addIndex('users', ['role'], { name: 'users_role_idx' });
    await queryInterface.addIndex('users', ['email_verified'], { name: 'users_email_verified_idx' });
    await queryInterface.addIndex('users', ['created_at'], { name: 'users_created_at_idx' });
    await queryInterface.addIndex('users', ['deleted_at'], { name: 'users_deleted_at_idx' });
  },

  down: async (queryInterface, Sequelize) => {
    // 删除索引
    await queryInterface.removeIndex('users', 'users_email_unique');
    await queryInterface.removeIndex('users', 'users_username_unique');
    await queryInterface.removeIndex('users', 'users_status_idx');
    await queryInterface.removeIndex('users', 'users_role_idx');
    await queryInterface.removeIndex('users', 'users_email_verified_idx');
    await queryInterface.removeIndex('users', 'users_created_at_idx');
    await queryInterface.removeIndex('users', 'users_deleted_at_idx');
    
    // 删除表
    await queryInterface.dropTable('users');
  }
}; 