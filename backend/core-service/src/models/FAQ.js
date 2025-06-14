const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const FAQ = sequelize.define('FAQ', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
    allowNull: false,
  },
  question: {
    type: DataTypes.TEXT,
    allowNull: false,
    validate: {
      notEmpty: {
        msg: '问题不能为空'
      },
      len: {
        args: [1, 1000],
        msg: '问题长度必须在1-1000字符之间'
      }
    }
  },
  answer: {
    type: DataTypes.TEXT,
    allowNull: false,
    validate: {
      notEmpty: {
        msg: '答案不能为空'
      },
      len: {
        args: [1, 5000],
        msg: '答案长度必须在1-5000字符之间'
      }
    }
  },
  category: {
    type: DataTypes.STRING(100),
    allowNull: true,
    defaultValue: '未分类',
    validate: {
      len: {
        args: [1, 100],
        msg: '分类名称长度必须在1-100字符之间'
      }
    }
  },
  tags: {
    type: DataTypes.TEXT,
    allowNull: true,
    get() {
      const rawValue = this.getDataValue('tags');
      return rawValue ? JSON.parse(rawValue) : [];
    },
    set(value) {
      this.setDataValue('tags', JSON.stringify(value || []));
    }
  },
  priority: {
    type: DataTypes.ENUM('low', 'medium', 'high'),
    defaultValue: 'medium',
    allowNull: false
  },
  status: {
    type: DataTypes.ENUM('draft', 'published', 'archived'),
    defaultValue: 'draft',
    allowNull: false
  },
  isPublic: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    allowNull: false
  },
  viewCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    allowNull: false,
    validate: {
      min: 0
    }
  },
  likeCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    allowNull: false,
    validate: {
      min: 0
    }
  },
  dislikeCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    allowNull: false,
    validate: {
      min: 0
    }
  },
  knowledgeBaseId: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'KnowledgeBases',
      key: 'id'
    },
    onUpdate: 'CASCADE',
    onDelete: 'SET NULL'
  },
  createdBy: {
    type: DataTypes.UUID,
    allowNull: false,
    comment: '创建者用户ID（来自认证服务）'
    // 注意：不直接引用Users表，因为用户信息在认证服务中
  },
  updatedBy: {
    type: DataTypes.UUID,
    allowNull: true,
    comment: '更新者用户ID（来自认证服务）'
    // 注意：不直接引用Users表，因为用户信息在认证服务中
  },
  metadata: {
    type: DataTypes.TEXT,
    allowNull: true,
    get() {
      const rawValue = this.getDataValue('metadata');
      try {
        return rawValue ? JSON.parse(rawValue) : {};
      } catch (error) {
        return {};
      }
    },
    set(value) {
      this.setDataValue('metadata', JSON.stringify(value || {}));
    }
  },
  searchVector: {
    type: DataTypes.TEXT,
    allowNull: true,
    // 用于全文搜索的向量字段（将来可以接入向量数据库）
  }
}, {
  tableName: 'faqs',
  timestamps: true,
  paranoid: true, // 软删除
  indexes: [
    // 暂时注释掉GIN索引，需要安装pg_trgm扩展后再启用
    // {
    //   name: 'faq_question_search',
    //   fields: ['question'],
    //   using: 'gin',
    //   operator: 'gin_trgm_ops'
    // },
    // {
    //   name: 'faq_answer_search', 
    //   fields: ['answer'],
    //   using: 'gin',
    //   operator: 'gin_trgm_ops'
    // },
    {
      name: 'faq_category_index',
      fields: ['category']
    },
    {
      name: 'faq_status_index',
      fields: ['status']
    },
    {
      name: 'faq_knowledge_base_index',
      fields: ['knowledge_base_id']
    },
    {
      name: 'faq_created_by_index',
      fields: ['created_by']
    },
    {
      name: 'faq_composite_search',
      fields: ['category', 'status', 'is_public']
    }
  ],
  hooks: {
    beforeCreate: (faq) => {
      // 自动生成搜索向量
      faq.searchVector = `${faq.question} ${faq.answer} ${faq.category || ''}`.toLowerCase();
    },
    beforeUpdate: (faq) => {
      // 更新搜索向量
      if (faq.changed('question') || faq.changed('answer') || faq.changed('category')) {
        faq.searchVector = `${faq.question} ${faq.answer} ${faq.category || ''}`.toLowerCase();
      }
    }
  }
});

// 模型关联
FAQ.associate = (models) => {
  // 关联知识库
  FAQ.belongsTo(models.KnowledgeBase, {
    foreignKey: 'knowledgeBaseId',
    as: 'knowledgeBase'
  });

  // 注意：不关联用户模型，因为用户信息在认证服务中
  // 如果需要用户信息，通过API调用认证服务获取
};

// 实例方法
FAQ.prototype.incrementViewCount = function() {
  return this.increment('viewCount');
};

FAQ.prototype.incrementLikeCount = function() {
  return this.increment('likeCount');
};

FAQ.prototype.incrementDislikeCount = function() {
  return this.increment('dislikeCount');
};

FAQ.prototype.toggleStatus = function() {
  const statusMap = {
    'draft': 'published',
    'published': 'archived',
    'archived': 'draft'
  };
  this.status = statusMap[this.status] || 'draft';
  return this.save();
};

// 类方法
FAQ.findByCategory = function(category, options = {}) {
  return this.findAll({
    where: {
      category,
      status: 'published',
      isPublic: true,
      ...options.where
    },
    ...options
  });
};

FAQ.searchByKeyword = function(keyword, options = {}) {
  const { Op } = require('sequelize');
  return this.findAll({
    where: {
      [Op.or]: [
        { question: { [Op.iLike]: `%${keyword}%` } },
        { answer: { [Op.iLike]: `%${keyword}%` } },
        { searchVector: { [Op.iLike]: `%${keyword.toLowerCase()}%` } }
      ],
      status: 'published',
      isPublic: true,
      ...options.where
    },
    ...options
  });
};

FAQ.getCategories = function() {
  return this.findAll({
    attributes: [
      'category',
      [sequelize.fn('COUNT', sequelize.col('id')), 'count']
    ],
    where: {
      status: 'published',
      isPublic: true
    },
    group: ['category'],
    order: [[sequelize.literal('count'), 'DESC']]
  });
};

FAQ.getPopular = function(limit = 10) {
  return this.findAll({
    where: {
      status: 'published',
      isPublic: true
    },
    order: [
      ['viewCount', 'DESC'],
      ['likeCount', 'DESC'],
      ['createdAt', 'DESC']
    ],
    limit
  });
};

module.exports = FAQ; 