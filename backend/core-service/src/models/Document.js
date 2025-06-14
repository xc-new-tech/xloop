const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Document = sequelize.define('Document', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  knowledge_base_id: {
    type: DataTypes.UUID,
    allowNull: false,
    comment: '所属知识库ID',
  },
  title: {
    type: DataTypes.STRING(500),
    allowNull: false,
    comment: '文档标题',
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '文档内容（纯文本）',
  },
  content_html: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '文档内容（HTML格式）',
  },
  content_markdown: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '文档内容（Markdown格式）',
  },
  file_path: {
    type: DataTypes.STRING(1000),
    allowNull: true,
    comment: '文件存储路径',
  },
  file_name: {
    type: DataTypes.STRING(255),
    allowNull: true,
    comment: '原文件名',
  },
  file_size: {
    type: DataTypes.BIGINT,
    allowNull: true,
    comment: '文件大小（字节）',
  },
  file_type: {
    type: DataTypes.STRING(50),
    allowNull: true,
    comment: '文件类型',
  },
  mime_type: {
    type: DataTypes.STRING(100),
    allowNull: true,
    comment: 'MIME类型',
  },
  checksum: {
    type: DataTypes.STRING(64),
    allowNull: true,
    comment: '文件校验和',
  },
  type: {
    type: DataTypes.ENUM('text', 'pdf', 'doc', 'docx', 'excel', 'ppt', 'image', 'markdown', 'html', 'other'),
    defaultValue: 'text',
    allowNull: false,
    comment: '文档类型',
  },
  status: {
    type: DataTypes.ENUM('draft', 'processing', 'active', 'archived', 'failed'),
    defaultValue: 'draft',
    allowNull: false,
    comment: '文档状态',
  },
  language: {
    type: DataTypes.STRING(10),
    defaultValue: 'zh-CN',
    comment: '文档语言',
  },
  tags: {
    type: DataTypes.ARRAY(DataTypes.STRING),
    defaultValue: [],
    comment: '标签数组',
  },
  metadata: {
    type: DataTypes.JSONB,
    defaultValue: {},
    comment: '文档元数据（JSON格式）',
  },
  extraction_result: {
    type: DataTypes.JSONB,
    allowNull: true,
    comment: '内容提取结果',
  },
  indexing_status: {
    type: DataTypes.ENUM('pending', 'processing', 'completed', 'failed'),
    defaultValue: 'pending',
    comment: '索引状态',
  },
  vector_id: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: '向量存储ID',
  },
  search_keywords: {
    type: DataTypes.ARRAY(DataTypes.STRING),
    defaultValue: [],
    comment: '搜索关键词',
  },
  word_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: '字数统计',
  },
  reading_time: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: '预估阅读时间（分钟）',
  },
  version: {
    type: DataTypes.INTEGER,
    defaultValue: 1,
    comment: '文档版本号',
  },
  parent_id: {
    type: DataTypes.UUID,
    allowNull: true,
    comment: '父文档ID（用于版本控制）',
  },
  uploaded_by: {
    type: DataTypes.UUID,
    allowNull: false,
    comment: '上传者用户ID',
  },
  processed_at: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: '处理完成时间',
  },
  last_accessed: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: '最后访问时间',
  },
  access_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: '访问次数',
  },
}, {
  tableName: 'documents',
  timestamps: true,
  underscored: true,
  indexes: [
    {
      fields: ['knowledge_base_id'],
      name: 'idx_documents_knowledge_base_id',
    },
    {
      fields: ['type'],
      name: 'idx_documents_type',
    },
    {
      fields: ['status'],
      name: 'idx_documents_status',
    },
    {
      fields: ['uploaded_by'],
      name: 'idx_documents_uploaded_by',
    },
    {
      fields: ['created_at'],
      name: 'idx_documents_created_at',
    },
    {
      fields: ['tags'],
      using: 'gin',
      name: 'idx_documents_tags',
    },
    {
      fields: ['search_keywords'],
      using: 'gin',
      name: 'idx_documents_search_keywords',
    },
    {
      fields: ['title'],
      name: 'idx_documents_title',
    },
    {
      fields: ['checksum'],
      name: 'idx_documents_checksum',
    },
    {
      fields: ['indexing_status'],
      name: 'idx_documents_indexing_status',
    },
    // 全文搜索索引 - 需要PostgreSQL的pg_trgm扩展或使用btree索引
    // 暂时注释掉，稍后可以通过SQL手动创建tsvector索引
    // {
    //   fields: ['title', 'content'],
    //   using: 'gin',
    //   name: 'idx_documents_fulltext',
    // },
  ],
  hooks: {
    beforeCreate: (document) => {
      if (document.content) {
        // 计算字数
        document.word_count = document.content.replace(/\s+/g, '').length;
        // 估算阅读时间（每分钟300字）
        document.reading_time = Math.ceil(document.word_count / 300);
      }
    },
    beforeUpdate: (document) => {
      if (document.changed('content') && document.content) {
        document.word_count = document.content.replace(/\s+/g, '').length;
        document.reading_time = Math.ceil(document.word_count / 300);
      }
    },
  },
});

// 实例方法
Document.prototype.toJSON = function() {
  const values = { ...this.dataValues };
  
  // 格式化日期
  ['created_at', 'updated_at', 'processed_at', 'last_accessed'].forEach(field => {
    if (values[field]) {
      values[field] = values[field].toISOString();
    }
  });
  
  return values;
};

Document.prototype.updateAccessStats = async function() {
  this.access_count += 1;
  this.last_accessed = new Date();
  await this.save();
};

// 静态方法
Document.findByKnowledgeBase = function(knowledgeBaseId, options = {}) {
  return this.findAll({
    where: { knowledge_base_id: knowledgeBaseId },
    order: [['created_at', 'DESC']],
    ...options,
  });
};

Document.searchByContent = function(query, knowledgeBaseId = null, options = {}) {
  const { Op } = require('sequelize');
  const where = {
    [Op.or]: [
      {
        title: {
          [Op.iLike]: `%${query}%`
        }
      },
      {
        content: {
          [Op.iLike]: `%${query}%`
        }
      },
      {
        search_keywords: {
          [Op.contains]: [query]
        }
      }
    ],
    status: 'active'
  };

  if (knowledgeBaseId) {
    where.knowledge_base_id = knowledgeBaseId;
  }

  return this.findAll({
    where,
    order: [['updated_at', 'DESC']],
    ...options,
  });
};

Document.findPendingIndexing = function(options = {}) {
  return this.findAll({
    where: { 
      indexing_status: 'pending',
      status: 'active'
    },
    order: [['created_at', 'ASC']],
    ...options,
  });
};

Document.findByUploader = function(uploaderId, options = {}) {
  return this.findAll({
    where: { uploaded_by: uploaderId },
    order: [['created_at', 'DESC']],
    ...options,
  });
};

module.exports = Document; 