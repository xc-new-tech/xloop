const express = require('express');
const router = express.Router();

// 导入各模块路由
const knowledgeBaseRoutes = require('./knowledgeBase');
const fileRoutes = require('./file');
const faqRoutes = require('./faq');

/**
 * API路由集成
 * Base path: /api
 */

// 知识库管理路由
router.use('/knowledge-bases', knowledgeBaseRoutes);

// 文件管理路由
router.use('/files', fileRoutes);

// FAQ管理路由
router.use('/faqs', faqRoutes);

// API根路径信息
router.get('/', (req, res) => {
  res.json({
    service: 'XLoop Core Service API',
    version: '1.0.0',
    description: 'XLoop知识智能平台核心服务API',
    timestamp: new Date().toISOString(),
    endpoints: {
      knowledgeBases: '/api/knowledge-bases',
      files: '/api/files',
      // TODO: 添加其他模块的端点
      documents: '/api/documents',
      faqs: '/api/faqs',
      conversations: '/api/conversations',
    },
    documentation: {
      swagger: '/api-docs',
      postman: '/api/postman'
    }
  });
});

// 健康检查（API级别）
router.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'XLoop Core API',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    version: '1.0.0'
  });
});

module.exports = router; 