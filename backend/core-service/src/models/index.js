const { sequelize } = require('../config/database');

// 导入所有模型
const KnowledgeBase = require('./KnowledgeBase');
const Document = require('./Document');
const FAQ = require('./FAQ');
const Conversation = require('./Conversation');
const File = require('./File');

// 定义模型关系
const defineAssociations = () => {
  // KnowledgeBase 和 Document 的关系
  KnowledgeBase.hasMany(Document, {
    foreignKey: 'knowledge_base_id',
    as: 'documents',
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE'
  });

  Document.belongsTo(KnowledgeBase, {
    foreignKey: 'knowledge_base_id',
    as: 'knowledgeBase',
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE'
  });

  // KnowledgeBase 和 FAQ 的关系
  KnowledgeBase.hasMany(FAQ, {
    foreignKey: 'knowledge_base_id',
    as: 'faqs',
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE'
  });

  FAQ.belongsTo(KnowledgeBase, {
    foreignKey: 'knowledge_base_id',
    as: 'knowledgeBase',
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE'
  });

  // KnowledgeBase 和 Conversation 的关系
  KnowledgeBase.hasMany(Conversation, {
    foreignKey: 'knowledge_base_id',
    as: 'conversations',
    onDelete: 'SET NULL',
    onUpdate: 'CASCADE'
  });

  Conversation.belongsTo(KnowledgeBase, {
    foreignKey: 'knowledge_base_id',
    as: 'knowledgeBase',
    onDelete: 'SET NULL',
    onUpdate: 'CASCADE'
  });

  // Document 和 FAQ 的关系（FAQ可以来源于Document）
  Document.hasMany(FAQ, {
    foreignKey: 'source_document_id',
    as: 'generatedFaqs',
    onDelete: 'SET NULL',
    onUpdate: 'CASCADE'
  });

  FAQ.belongsTo(Document, {
    foreignKey: 'source_document_id',
    as: 'sourceDocument',
    onDelete: 'SET NULL',
    onUpdate: 'CASCADE'
  });

  // Document 版本控制关系（自关联）
  Document.hasMany(Document, {
    foreignKey: 'parent_id',
    as: 'versions',
    onDelete: 'SET NULL',
    onUpdate: 'CASCADE'
  });

  Document.belongsTo(Document, {
    foreignKey: 'parent_id',
    as: 'parent',
    onDelete: 'SET NULL',
    onUpdate: 'CASCADE'
  });

  // KnowledgeBase 和 File 的关系
  KnowledgeBase.hasMany(File, {
    foreignKey: 'knowledgeBaseId',
    as: 'files',
    onDelete: 'SET NULL',
    onUpdate: 'CASCADE'
  });

  File.belongsTo(KnowledgeBase, {
    foreignKey: 'knowledgeBaseId',
    as: 'knowledgeBase',
    onDelete: 'SET NULL',
    onUpdate: 'CASCADE'
  });

  console.log('✅ 数据库模型关系定义完成');
};

// 同步数据库
const syncDatabase = async (options = {}) => {
  try {
    console.log('🔄 开始同步核心服务数据库...');
    
    // 默认配置
    const syncOptions = {
      force: false, // 生产环境应该设为false
      alter: false, // 生产环境应该设为false
      logging: process.env.NODE_ENV === 'development' ? console.log : false,
      ...options
    };

    await sequelize.sync(syncOptions);
    console.log('✅ 核心服务数据库同步完成');
    
    return true;
  } catch (error) {
    console.error('❌ 核心服务数据库同步失败:', error);
    throw error;
  }
};

// 创建示例数据
const createSampleData = async () => {
  try {
    console.log('🔄 开始创建示例数据...');

    // 检查是否已有数据
    const kbCount = await KnowledgeBase.count();
    if (kbCount > 0) {
      console.log('ℹ️  示例数据已存在，跳过创建');
      return;
    }

    // 创建示例知识库
    const sampleKB = await KnowledgeBase.create({
      name: 'XLoop平台使用指南',
      description: 'XLoop知识智能平台的使用说明和常见问题解答',
      owner_id: '00000000-0000-0000-0000-000000000001', // 示例用户ID
      type: 'public',
      status: 'active',
      tags: ['使用指南', '帮助文档', '新手教程'],
      settings: {
        allowPublicAccess: true,
        enableAI: true,
        enableSearch: true
      },
      created_by: '00000000-0000-0000-0000-000000000001',
    });

    // 创建示例文档
    const sampleDoc = await Document.create({
      knowledge_base_id: sampleKB.id,
      title: 'XLoop平台快速入门指南',
      content: `# XLoop平台快速入门指南

## 什么是XLoop？

XLoop是一个智能知识管理平台，帮助您：
- 管理和组织知识文档
- 快速搜索和查找信息
- 通过AI助手获得智能问答
- 构建团队知识库

## 主要功能

### 1. 知识库管理
- 创建个人或团队知识库
- 上传各种格式的文档
- 自动内容提取和索引

### 2. 智能搜索
- 全文搜索功能
- 语义搜索支持
- 标签和分类筛选

### 3. AI问答助手
- 基于知识库内容的智能问答
- 上下文理解和对话记忆
- 多轮对话支持

## 快速开始

1. 注册并登录XLoop平台
2. 创建您的第一个知识库
3. 上传文档或添加内容
4. 开始搜索和提问

更多详细信息请参考完整用户手册。`,
      content_markdown: `# XLoop平台快速入门指南...`,
      type: 'markdown',
      status: 'active',
      language: 'zh-CN',
      tags: ['入门', '指南', '教程'],
      search_keywords: ['XLoop', '平台', '入门', '指南', '知识库', 'AI', '搜索'],
      uploaded_by: '00000000-0000-0000-0000-000000000001',
      indexing_status: 'completed',
    });

    // 创建示例FAQ
    const sampleFAQs = [
      {
        knowledge_base_id: sampleKB.id,
        question: '如何创建新的知识库？',
        answer: '登录后点击"创建知识库"按钮，填写知识库名称和描述，选择类型（个人/团队/公开），然后点击确认即可创建。',
        category: '基础操作',
        status: 'published',
        priority: 'high',
        is_featured: true,
        keywords: ['创建', '知识库', '新建'],
        created_by: '00000000-0000-0000-0000-000000000001',
      },
      {
        knowledge_base_id: sampleKB.id,
        question: '支持哪些文件格式？',
        answer: 'XLoop支持多种文件格式，包括：PDF、Word文档(.doc/.docx)、Excel表格(.xls/.xlsx)、PowerPoint演示文稿(.ppt/.pptx)、纯文本(.txt)、Markdown(.md)等。',
        category: '文件管理',
        status: 'published',
        priority: 'medium',
        keywords: ['文件格式', '支持', '上传', 'PDF', 'Word', 'Excel'],
        created_by: '00000000-0000-0000-0000-000000000001',
      },
      {
        knowledge_base_id: sampleKB.id,
        question: 'AI助手如何工作？',
        answer: 'AI助手基于您知识库中的内容进行问答。它会理解您的问题，搜索相关文档，并生成准确的回答。支持多轮对话和上下文理解。',
        category: 'AI功能',
        status: 'published',
        priority: 'high',
        is_featured: true,
        keywords: ['AI', '助手', '问答', '对话', '智能'],
        created_by: '00000000-0000-0000-0000-000000000001',
      }
    ];

    await FAQ.bulkCreate(sampleFAQs);

    // 创建示例对话
    const sampleConversation = await Conversation.create({
      session_id: 'sample_session_001',
      user_id: '00000000-0000-0000-0000-000000000001',
      knowledge_base_id: sampleKB.id,
      title: '关于XLoop平台的咨询',
      type: 'qa',
      status: 'ended',
      messages: [
        {
          id: '00000000-0000-0000-0000-000000000001',
          role: 'user',
          content: '你好，我想了解XLoop平台的主要功能',
          content_type: 'text',
          timestamp: new Date().toISOString(),
        },
        {
          id: '00000000-0000-0000-0000-000000000002',
          role: 'assistant',
          content: '您好！XLoop是一个智能知识管理平台，主要功能包括：\n\n1. **知识库管理** - 创建和管理个人或团队知识库\n2. **文档上传** - 支持多种格式文档的上传和内容提取\n3. **智能搜索** - 全文搜索和语义搜索功能\n4. **AI问答** - 基于知识库内容的智能问答助手\n\n您想了解哪个功能的详细信息呢？',
          content_type: 'text',
          timestamp: new Date().toISOString(),
          sources: [sampleDoc.id],
        }
      ],
      message_count: 2,
      rating: 5,
      feedback: '回答很详细，很有帮助！',
      last_message_at: new Date(),
      ended_at: new Date(),
    });

    console.log('✅ 示例数据创建完成');
    console.log(`   - 知识库: ${sampleKB.name}`);
    console.log(`   - 文档: ${sampleDoc.title}`);
    console.log(`   - FAQ: ${sampleFAQs.length}条`);
    console.log(`   - 对话: ${sampleConversation.title}`);

    return {
      knowledgeBase: sampleKB,
      document: sampleDoc,
      faqs: sampleFAQs,
      conversation: sampleConversation,
    };
  } catch (error) {
    console.error('❌ 创建示例数据失败:', error);
    throw error;
  }
};

// 初始化数据库
const initializeDatabase = async (options = {}) => {
  try {
    console.log('🚀 开始初始化核心服务数据库...');
    
    // 测试连接
    await sequelize.authenticate();
    console.log('✅ 核心服务数据库连接测试成功');
    
    // 定义关系
    defineAssociations();
    
    // 同步模型
    await syncDatabase(options);
    
    // 创建示例数据（仅在开发环境）
    if (process.env.NODE_ENV === 'development' || process.env.CREATE_SAMPLE_DATA === 'true') {
      await createSampleData();
    }
    
    console.log('🎉 核心服务数据库初始化完成');
    return true;
  } catch (error) {
    console.error('❌ 核心服务数据库初始化失败:', error);
    throw error;
  }
};

// 延迟初始化关系（只在需要时调用）
let associationsInitialized = false;
const ensureAssociations = () => {
  if (!associationsInitialized) {
    defineAssociations();
    associationsInitialized = true;
  }
};

// 获取数据库统计信息
const getDatabaseStats = async () => {
  try {
    const stats = {
      knowledgeBases: await KnowledgeBase.count(),
      documents: await Document.count(),
      faqs: await FAQ.count(),
      conversations: await Conversation.count(),
      activeKnowledgeBases: await KnowledgeBase.count({ where: { status: 'active' } }),
      activeDocuments: await Document.count({ where: { status: 'active' } }),
      activeFaqs: await FAQ.count({ where: { status: 'active' } }),
      activeConversations: await Conversation.count({ where: { status: 'active' } }),
    };
    
    return stats;
  } catch (error) {
    console.error('❌ 获取数据库统计信息失败:', error);
    throw error;
  }
};

module.exports = {
  sequelize,
  
  // 模型
  KnowledgeBase,
  Document,
  FAQ,
  Conversation,
  File,
  
  // 方法
  defineAssociations,
  syncDatabase,
  createSampleData,
  initializeDatabase,
  ensureAssociations,
  getDatabaseStats,
  
  // 导出所有模型（便于其他地方导入）
  models: {
    KnowledgeBase,
    Document,
    FAQ,
    Conversation,
    File,
  }
}; 