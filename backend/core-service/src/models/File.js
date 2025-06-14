const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const File = sequelize.define('File', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
    comment: '文件唯一标识符'
  },
  originalName: {
    type: DataTypes.STRING(255),
    allowNull: false,
    comment: '原始文件名'
  },
  filename: {
    type: DataTypes.STRING(255),
    allowNull: false,
    comment: '存储文件名'
  },
  mimetype: {
    type: DataTypes.STRING(100),
    allowNull: false,
    comment: '文件MIME类型'
  },
  size: {
    type: DataTypes.BIGINT,
    allowNull: false,
    comment: '文件大小（字节）'
  },
  hash: {
    type: DataTypes.STRING(64),
    allowNull: false,
    unique: true,
    comment: '文件SHA256哈希值'
  },
  path: {
    type: DataTypes.STRING(500),
    allowNull: false,
    comment: '文件存储相对路径'
  },
  userId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'Users',
      key: 'id'
    },
    comment: '上传用户ID'
  },
  knowledgeBaseId: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'KnowledgeBases',
      key: 'id'
    },
    comment: '所属知识库ID'
  },
  category: {
    type: DataTypes.ENUM('document', 'image', 'audio', 'video', 'other'),
    allowNull: false,
    defaultValue: 'document',
    comment: '文件分类'
  },
  tags: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: [],
    comment: '文件标签'
  },
  contentType: {
    type: DataTypes.STRING(50),
    allowNull: true,
    comment: '解析后的内容类型'
  },
  extractedText: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '提取的文本内容'
  },
  metadata: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: {},
    comment: '文件元数据'
  },
  chunks: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: [],
    comment: '文档切片数据'
  },
  status: {
    type: DataTypes.ENUM('uploading', 'processing', 'processed', 'failed'),
    allowNull: false,
    defaultValue: 'uploading',
    comment: '处理状态'
  },
  processingErrors: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: [],
    comment: '处理错误信息'
  },
  downloadCount: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
    comment: '下载次数'
  },
  lastAccessedAt: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: '最后访问时间'
  }
}, {
  tableName: 'files',
  timestamps: true,
  paranoid: true, // 软删除
  indexes: [
    {
      fields: ['userId']
    },
    {
      fields: ['knowledgeBaseId']
    },
    {
      fields: ['hash']
    },
    {
      fields: ['category']
    },
    {
      fields: ['contentType']
    },
    {
      fields: ['status']
    },
    {
      fields: ['createdAt']
    },
    {
      name: 'files_search_idx',
      type: 'GIN',
      fields: [sequelize.fn('to_tsvector', 'english', sequelize.col('originalName'))]
    }
  ],
  comment: '文件信息表'
});

// 实例方法
File.prototype.toJSON = function() {
  const values = Object.assign({}, this.get());
  
  // 在列表视图中隐藏大字段
  if (this.dataValues.hideContent) {
    delete values.extractedText;
    delete values.chunks;
  }
  
  return values;
};

// 类方法
File.associate = function(models) {
  // 与用户的关联
  File.belongsTo(models.User, {
    foreignKey: 'userId',
    as: 'user'
  });
  
  // 与知识库的关联
  File.belongsTo(models.KnowledgeBase, {
    foreignKey: 'knowledgeBaseId',
    as: 'knowledgeBase'
  });
};

// 钩子函数
File.addHook('beforeCreate', (file, options) => {
  // 可以在这里添加文件创建前的处理逻辑
});

File.addHook('beforeUpdate', (file, options) => {
  // 可以在这里添加文件更新前的处理逻辑
});

File.addHook('beforeDestroy', async (file, options) => {
  // 文件删除前的清理逻辑
  const FileStorageService = require('../services/FileStorageService');
  try {
    await FileStorageService.delete(file.path);
  } catch (error) {
    console.warn('删除物理文件失败:', error.message);
  }
});

module.exports = File; 