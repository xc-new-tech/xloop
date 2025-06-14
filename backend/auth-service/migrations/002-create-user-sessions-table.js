const { DataTypes } = require('sequelize');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // 创建用户会话表
    await queryInterface.createTable('user_sessions', {
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
      }
    });

    // 创建索引
    await queryInterface.addIndex('user_sessions', ['refresh_token'], { 
      unique: true, 
      name: 'user_sessions_refresh_token_unique' 
    });
    await queryInterface.addIndex('user_sessions', ['user_id'], { 
      name: 'user_sessions_user_id_idx' 
    });
    await queryInterface.addIndex('user_sessions', ['status'], { 
      name: 'user_sessions_status_idx' 
    });
    await queryInterface.addIndex('user_sessions', ['expires_at'], { 
      name: 'user_sessions_expires_at_idx' 
    });
    await queryInterface.addIndex('user_sessions', ['last_activity_at'], { 
      name: 'user_sessions_last_activity_at_idx' 
    });
    await queryInterface.addIndex('user_sessions', ['created_at'], { 
      name: 'user_sessions_created_at_idx' 
    });
    await queryInterface.addIndex('user_sessions', ['ip_address'], { 
      name: 'user_sessions_ip_address_idx' 
    });

    // 创建复合索引
    await queryInterface.addIndex('user_sessions', ['user_id', 'status'], { 
      name: 'user_sessions_user_id_status_idx' 
    });
    await queryInterface.addIndex('user_sessions', ['status', 'expires_at'], { 
      name: 'user_sessions_status_expires_at_idx' 
    });
  },

  down: async (queryInterface, Sequelize) => {
    // 删除索引
    await queryInterface.removeIndex('user_sessions', 'user_sessions_refresh_token_unique');
    await queryInterface.removeIndex('user_sessions', 'user_sessions_user_id_idx');
    await queryInterface.removeIndex('user_sessions', 'user_sessions_status_idx');
    await queryInterface.removeIndex('user_sessions', 'user_sessions_expires_at_idx');
    await queryInterface.removeIndex('user_sessions', 'user_sessions_last_activity_at_idx');
    await queryInterface.removeIndex('user_sessions', 'user_sessions_created_at_idx');
    await queryInterface.removeIndex('user_sessions', 'user_sessions_ip_address_idx');
    await queryInterface.removeIndex('user_sessions', 'user_sessions_user_id_status_idx');
    await queryInterface.removeIndex('user_sessions', 'user_sessions_status_expires_at_idx');
    
    // 删除表
    await queryInterface.dropTable('user_sessions');
  }
}; 