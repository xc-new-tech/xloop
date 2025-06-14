const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

/**
 * 权限模型
 * 定义系统中的各种权限
 */
const Permission = sequelize.define('Permission', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
    allowNull: false,
    comment: '权限ID'
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true,
    comment: '权限名称，如：read_users, create_knowledge_base'
  },
  displayName: {
    type: DataTypes.STRING(200),
    allowNull: false,
    comment: '权限显示名称，如：读取用户列表, 创建知识库'
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '权限描述'
  },
  resource: {
    type: DataTypes.STRING(100),
    allowNull: false,
    comment: '权限对应的资源，如：users, knowledge_bases, documents'
  },
  action: {
    type: DataTypes.STRING(50),
    allowNull: false,
    comment: '权限对应的操作，如：read, create, update, delete'
  },
  module: {
    type: DataTypes.STRING(100),
    allowNull: false,
    comment: '权限所属模块，如：auth, knowledge, conversation'
  },
  isSystem: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    comment: '是否为系统权限，系统权限不可删除'
  },
  priority: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: '权限优先级，数字越大优先级越高'
  },
  conditions: {
    type: DataTypes.JSONB,
    allowNull: true,
    comment: '权限条件，支持复杂的权限控制逻辑'
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    comment: '权限是否启用'
  },
  createdAt: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
    comment: '创建时间'
  },
  updatedAt: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
    comment: '更新时间'
  }
}, {
  tableName: 'permissions',
  timestamps: true,
  indexes: [
    {
      fields: ['name'],
      unique: true
    },
    {
      fields: ['resource', 'action']
    },
    {
      fields: ['module']
    },
    {
      fields: ['isActive']
    },
    {
      name: 'idx_permission_resource_action',
      fields: ['resource', 'action'],
      unique: true
    }
  ],
  comment: '系统权限表'
});

/**
 * 模型方法
 */

// 根据资源和操作查找权限
Permission.findByResourceAction = async function(resource, action) {
  return await this.findOne({
    where: {
      resource,
      action,
      isActive: true
    }
  });
};

// 根据模块获取权限列表
Permission.getByModule = async function(module) {
  return await this.findAll({
    where: {
      module,
      isActive: true
    },
    order: [['priority', 'DESC'], ['name', 'ASC']]
  });
};

// 获取系统权限
Permission.getSystemPermissions = async function() {
  return await this.findAll({
    where: {
      isSystem: true,
      isActive: true
    },
    order: [['module', 'ASC'], ['priority', 'DESC']]
  });
};

// 权限名称格式验证
Permission.prototype.validateName = function() {
  const namePattern = /^[a-z][a-z0-9_]*$/;
  return namePattern.test(this.name);
};

// 权限全名（模块.资源.操作）
Permission.prototype.getFullName = function() {
  return `${this.module}.${this.resource}.${this.action}`;
};

module.exports = Permission; 