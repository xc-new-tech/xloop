const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

/**
 * 角色模型
 * 定义系统中的各种角色
 */
const Role = sequelize.define('Role', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
    allowNull: false,
    comment: '角色ID'
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true,
    comment: '角色名称，如：admin, editor, viewer'
  },
  displayName: {
    type: DataTypes.STRING(200),
    allowNull: false,
    comment: '角色显示名称，如：系统管理员, 编辑者, 查看者'
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '角色描述'
  },
  type: {
    type: DataTypes.ENUM('system', 'custom', 'organization'),
    defaultValue: 'custom',
    comment: '角色类型：system-系统角色, custom-自定义角色, organization-组织角色'
  },
  level: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: '角色等级，数字越大权限越高，用于角色继承'
  },
  parentRoleId: {
    type: DataTypes.UUID,
    allowNull: true,
    comment: '父角色ID，支持角色继承'
  },
  isSystem: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    comment: '是否为系统角色，系统角色不可删除'
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    comment: '角色是否启用'
  },
  settings: {
    type: DataTypes.JSONB,
    allowNull: true,
    comment: '角色设置，存储角色相关的配置信息'
  },
  createdBy: {
    type: DataTypes.UUID,
    allowNull: true,
    comment: '创建者ID'
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
  tableName: 'roles',
  timestamps: true,
  indexes: [
    {
      fields: ['name'],
      unique: true
    },
    {
      fields: ['type']
    },
    {
      fields: ['level']
    },
    {
      fields: ['parentRoleId']
    },
    {
      fields: ['isActive']
    }
  ],
  comment: '系统角色表'
});

/**
 * 模型方法
 */

// 根据类型获取角色
Role.getByType = async function(type, includeInactive = false) {
  const where = { type };
  if (!includeInactive) {
    where.isActive = true;
  }
  
  return await this.findAll({
    where,
    order: [['level', 'DESC'], ['name', 'ASC']]
  });
};

// 获取系统角色
Role.getSystemRoles = async function() {
  return await this.findAll({
    where: {
      isSystem: true,
      isActive: true
    },
    order: [['level', 'DESC'], ['name', 'ASC']]
  });
};

// 角色名称格式验证
Role.prototype.validateName = function() {
  const namePattern = /^[a-z][a-z0-9_]*$/;
  return namePattern.test(this.name);
};

module.exports = Role;
const sequelize = require('../config/database');

/**
 * 角色模型
 * 定义系统中的各种角色
 */
const Role = sequelize.define('Role', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
    allowNull: false,
    comment: '角色ID'
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true,
    comment: '角色名称，如：admin, editor, viewer'
  },
  displayName: {
    type: DataTypes.STRING(200),
    allowNull: false,
    comment: '角色显示名称，如：系统管理员, 编辑者, 查看者'
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '角色描述'
  },
  type: {
    type: DataTypes.ENUM('system', 'custom', 'organization'),
    defaultValue: 'custom',
    comment: '角色类型：system-系统角色, custom-自定义角色, organization-组织角色'
  },
  level: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: '角色等级，数字越大权限越高，用于角色继承'
  },
  parentRoleId: {
    type: DataTypes.UUID,
    allowNull: true,
    comment: '父角色ID，支持角色继承'
  },
  isSystem: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    comment: '是否为系统角色，系统角色不可删除'
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    comment: '角色是否启用'
  },
  settings: {
    type: DataTypes.JSONB,
    allowNull: true,
    comment: '角色设置，存储角色相关的配置信息'
  },
  createdBy: {
    type: DataTypes.UUID,
    allowNull: true,
    comment: '创建者ID'
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
  tableName: 'roles',
  timestamps: true,
  indexes: [
    {
      fields: ['name'],
      unique: true
    },
    {
      fields: ['type']
    },
    {
      fields: ['level']
    },
    {
      fields: ['parentRoleId']
    },
    {
      fields: ['isActive']
    }
  ],
  comment: '系统角色表'
});

/**
 * 模型方法
 */

// 根据类型获取角色
Role.getByType = async function(type, includeInactive = false) {
  const where = { type };
  if (!includeInactive) {
    where.isActive = true;
  }
  
  return await this.findAll({
    where,
    order: [['level', 'DESC'], ['name', 'ASC']]
  });
};

// 获取系统角色
Role.getSystemRoles = async function() {
  return await this.findAll({
    where: {
      isSystem: true,
      isActive: true
    },
    order: [['level', 'DESC'], ['name', 'ASC']]
  });
};

// 角色名称格式验证
Role.prototype.validateName = function() {
  const namePattern = /^[a-z][a-z0-9_]*$/;
  return namePattern.test(this.name);
};

module.exports = Role;
