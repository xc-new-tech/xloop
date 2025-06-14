const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const KnowledgeBase = sequelize.define('KnowledgeBase', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  name: {
    type: DataTypes.STRING(255),
    allowNull: false,
    comment: '知识库名称',
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '知识库描述',
  },
  owner_id: {
    type: DataTypes.UUID,
    allowNull: false,
    comment: '所有者用户ID',
  },
  type: {
    type: DataTypes.ENUM('personal', 'team', 'public'),
    defaultValue: 'personal',
    allowNull: false,
    comment: '知识库类型：个人/团队/公开',
  },
  status: {
    type: DataTypes.ENUM('active', 'archived', 'disabled'),
    defaultValue: 'active',
    allowNull: false,
    comment: '知识库状态',
  },
  settings: {
    type: DataTypes.JSONB,
    defaultValue: {},
    comment: '知识库设置（JSON格式）',
  },
  tags: {
    type: DataTypes.ARRAY(DataTypes.STRING),
    defaultValue: [],
    comment: '标签数组',
  },
  indexing_enabled: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    comment: '是否启用索引',
  },
  search_enabled: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    comment: '是否启用搜索',
  },
  ai_enabled: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    comment: '是否启用AI功能',
  },
  vector_store_id: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: '向量存储ID',
  },
  document_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: '文档数量',
  },
  total_size: {
    type: DataTypes.BIGINT,
    defaultValue: 0,
    comment: '总文件大小（字节）',
  },
  last_activity: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
    comment: '最后活动时间',
  },
  created_by: {
    type: DataTypes.UUID,
    allowNull: false,
    comment: '创建者ID',
  },
  updated_by: {
    type: DataTypes.UUID,
    allowNull: true,
    comment: '更新者ID',
  },
}, {
  tableName: 'knowledge_bases',
  timestamps: true,
  underscored: true,
  indexes: [
    {
      fields: ['owner_id'],
      name: 'idx_knowledge_bases_owner_id',
    },
    {
      fields: ['type'],
      name: 'idx_knowledge_bases_type',
    },
    {
      fields: ['status'],
      name: 'idx_knowledge_bases_status',
    },
    {
      fields: ['created_at'],
      name: 'idx_knowledge_bases_created_at',
    },
    {
      fields: ['tags'],
      using: 'gin',
      name: 'idx_knowledge_bases_tags',
    },
    {
      fields: ['name'],
      name: 'idx_knowledge_bases_name',
    },
  ],
  hooks: {
    beforeCreate: (knowledgeBase) => {
      knowledgeBase.last_activity = new Date();
    },
    beforeUpdate: (knowledgeBase) => {
      knowledgeBase.last_activity = new Date();
    },
  },
});

// 实例方法
KnowledgeBase.prototype.toJSON = function() {
  const values = { ...this.dataValues };
  
  // 格式化日期
  if (values.created_at) {
    values.created_at = values.created_at.toISOString();
  }
  if (values.updated_at) {
    values.updated_at = values.updated_at.toISOString();
  }
  if (values.last_activity) {
    values.last_activity = values.last_activity.toISOString();
  }
  
  return values;
};

// 静态方法
KnowledgeBase.findByOwner = function(ownerId, options = {}) {
  return this.findAll({
    where: { owner_id: ownerId },
    order: [['last_activity', 'DESC']],
    ...options,
  });
};

KnowledgeBase.findPublic = function(options = {}) {
  return this.findAll({
    where: { 
      type: 'public',
      status: 'active'
    },
    order: [['last_activity', 'DESC']],
    ...options,
  });
};

KnowledgeBase.searchByName = function(query, options = {}) {
  const { Op } = require('sequelize');
  return this.findAll({
    where: {
      name: {
        [Op.iLike]: `%${query}%`
      },
      status: 'active'
    },
    order: [['last_activity', 'DESC']],
    ...options,
  });
};

module.exports = KnowledgeBase; 