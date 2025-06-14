const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Conversation = sequelize.define('Conversation', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  session_id: {
    type: DataTypes.STRING(64),
    allowNull: false,
    comment: '会话ID',
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: true,
    comment: '用户ID（可为空，支持匿名会话）',
  },
  knowledge_base_id: {
    type: DataTypes.UUID,
    allowNull: true,
    comment: '使用的知识库ID',
  },
  title: {
    type: DataTypes.STRING(500),
    allowNull: true,
    comment: '对话标题',
  },
  type: {
    type: DataTypes.ENUM('chat', 'search', 'qa', 'support'),
    defaultValue: 'chat',
    allowNull: false,
    comment: '对话类型',
  },
  status: {
    type: DataTypes.ENUM('active', 'ended', 'archived'),
    defaultValue: 'active',
    allowNull: false,
    comment: '对话状态',
  },
  messages: {
    type: DataTypes.JSONB,
    defaultValue: [],
    comment: '消息列表',
  },
  context: {
    type: DataTypes.JSONB,
    defaultValue: {},
    comment: '对话上下文',
  },
  metadata: {
    type: DataTypes.JSONB,
    defaultValue: {},
    comment: '扩展元数据',
  },
  settings: {
    type: DataTypes.JSONB,
    defaultValue: {},
    comment: '对话设置',
  },
  tags: {
    type: DataTypes.ARRAY(DataTypes.STRING),
    defaultValue: [],
    comment: '标签数组',
  },
  rating: {
    type: DataTypes.INTEGER,
    allowNull: true,
    comment: '用户评分（1-5）',
  },
  feedback: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: '用户反馈',
  },
  message_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: '消息数量',
  },
  last_message_at: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: '最后消息时间',
  },
  started_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
    comment: '对话开始时间',
  },
  ended_at: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: '对话结束时间',
  },
  client_info: {
    type: DataTypes.JSONB,
    defaultValue: {},
    comment: '客户端信息',
  },
  ip_address: {
    type: DataTypes.STRING(45),
    allowNull: true,
    comment: 'IP地址',
  },
  user_agent: {
    type: DataTypes.STRING(1000),
    allowNull: true,
    comment: '用户代理',
  },
}, {
  tableName: 'conversations',
  timestamps: true,
  underscored: true,
  indexes: [
    {
      fields: ['session_id'],
      unique: true,
      name: 'idx_conversations_session_id',
    },
    {
      fields: ['user_id'],
      name: 'idx_conversations_user_id',
    },
    {
      fields: ['knowledge_base_id'],
      name: 'idx_conversations_knowledge_base_id',
    },
    {
      fields: ['type'],
      name: 'idx_conversations_type',
    },
    {
      fields: ['status'],
      name: 'idx_conversations_status',
    },
    {
      fields: ['started_at'],
      name: 'idx_conversations_started_at',
    },
    {
      fields: ['last_message_at'],
      name: 'idx_conversations_last_message_at',
    },
    {
      fields: ['tags'],
      using: 'gin',
      name: 'idx_conversations_tags',
    },
    {
      fields: ['rating'],
      name: 'idx_conversations_rating',
    },
  ],
  hooks: {
    beforeCreate: (conversation) => {
      if (!conversation.title && conversation.messages.length > 0) {
        // 自动生成标题（使用第一条用户消息的前50个字符）
        const firstUserMessage = conversation.messages.find(msg => msg.role === 'user');
        if (firstUserMessage) {
          conversation.title = firstUserMessage.content.substring(0, 50) + 
            (firstUserMessage.content.length > 50 ? '...' : '');
        }
      }
    },
    beforeUpdate: (conversation) => {
      if (conversation.changed('messages')) {
        conversation.message_count = conversation.messages.length;
        if (conversation.messages.length > 0) {
          const lastMessage = conversation.messages[conversation.messages.length - 1];
          conversation.last_message_at = new Date(lastMessage.timestamp);
        }
      }
    },
  },
});

// 消息模型（嵌套在对话中）
const MessageSchema = {
  id: 'string', // UUID
  role: 'string', // 'user', 'assistant', 'system'
  content: 'string', // 消息内容
  content_type: 'string', // 'text', 'image', 'file', 'audio'
  timestamp: 'string', // ISO日期字符串
  metadata: 'object', // 扩展数据
  sources: 'array', // 来源文档
  tokens: 'object', // token使用统计
  processing_time: 'number', // 处理时间（毫秒）
  error: 'object', // 错误信息（如果有）
};

// 实例方法
Conversation.prototype.toJSON = function() {
  const values = { ...this.dataValues };
  
  // 格式化日期
  ['created_at', 'updated_at', 'started_at', 'ended_at', 'last_message_at'].forEach(field => {
    if (values[field]) {
      values[field] = values[field].toISOString();
    }
  });
  
  return values;
};

Conversation.prototype.addMessage = async function(message) {
  const messageWithId = {
    id: require('uuid').v4(),
    timestamp: new Date().toISOString(),
    ...message,
  };
  
  this.messages = [...this.messages, messageWithId];
  this.message_count = this.messages.length;
  this.last_message_at = new Date();
  
  await this.save();
  return messageWithId;
};

Conversation.prototype.updateLastMessage = async function(updates) {
  if (this.messages.length === 0) {
    throw new Error('No messages to update');
  }
  
  const lastMessageIndex = this.messages.length - 1;
  this.messages[lastMessageIndex] = {
    ...this.messages[lastMessageIndex],
    ...updates,
  };
  
  await this.save();
  return this.messages[lastMessageIndex];
};

Conversation.prototype.endConversation = async function(rating = null, feedback = null) {
  this.status = 'ended';
  this.ended_at = new Date();
  
  if (rating !== null) {
    this.rating = rating;
  }
  
  if (feedback !== null) {
    this.feedback = feedback;
  }
  
  await this.save();
};

Conversation.prototype.getMessages = function(limit = null, offset = 0) {
  const messages = this.messages || [];
  
  if (limit === null) {
    return messages.slice(offset);
  }
  
  return messages.slice(offset, offset + limit);
};

Conversation.prototype.getLastMessages = function(count = 10) {
  const messages = this.messages || [];
  return messages.slice(-count);
};

// 静态方法
Conversation.findBySessionId = function(sessionId) {
  return this.findOne({
    where: { session_id: sessionId },
  });
};

Conversation.findByUser = function(userId, options = {}) {
  return this.findAll({
    where: { user_id: userId },
    order: [['last_message_at', 'DESC']],
    ...options,
  });
};

Conversation.findActiveByUser = function(userId, options = {}) {
  return this.findAll({
    where: { 
      user_id: userId,
      status: 'active'
    },
    order: [['last_message_at', 'DESC']],
    ...options,
  });
};

Conversation.findByKnowledgeBase = function(knowledgeBaseId, options = {}) {
  return this.findAll({
    where: { knowledge_base_id: knowledgeBaseId },
    order: [['started_at', 'DESC']],
    ...options,
  });
};

Conversation.getStatsByPeriod = async function(startDate, endDate, knowledgeBaseId = null) {
  const { QueryTypes } = require('sequelize');
  
  let whereClause = 'WHERE started_at BETWEEN :startDate AND :endDate';
  const replacements = { startDate, endDate };
  
  if (knowledgeBaseId) {
    whereClause += ' AND knowledge_base_id = :knowledgeBaseId';
    replacements.knowledgeBaseId = knowledgeBaseId;
  }
  
  const query = `
    SELECT 
      COUNT(*) as total_conversations,
      AVG(message_count) as avg_message_count,
      AVG(rating) as avg_rating,
      COUNT(CASE WHEN status = 'ended' THEN 1 END) as completed_conversations,
      COUNT(CASE WHEN rating IS NOT NULL THEN 1 END) as rated_conversations
    FROM conversations 
    ${whereClause}
  `;
  
  const result = await sequelize.query(query, {
    replacements,
    type: QueryTypes.SELECT,
  });
  
  return result[0];
};

Conversation.findPopularTopics = async function(knowledgeBaseId = null, limit = 10) {
  const { QueryTypes } = require('sequelize');
  
  let whereClause = 'WHERE status = \'ended\' AND title IS NOT NULL';
  const replacements = { limit };
  
  if (knowledgeBaseId) {
    whereClause += ' AND knowledge_base_id = :knowledgeBaseId';
    replacements.knowledgeBaseId = knowledgeBaseId;
  }
  
  const query = `
    SELECT 
      title, 
      COUNT(*) as count,
      AVG(rating) as avg_rating,
      AVG(message_count) as avg_messages
    FROM conversations 
    ${whereClause}
    GROUP BY title
    ORDER BY count DESC
    LIMIT :limit
  `;
  
  return await sequelize.query(query, {
    replacements,
    type: QueryTypes.SELECT,
  });
};

module.exports = Conversation; 