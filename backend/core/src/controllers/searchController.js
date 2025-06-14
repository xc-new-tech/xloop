const VectorService = require('../services/vectorService');
const { body, query, validationResult } = require('express-validator');

/**
 * 语义搜索控制器
 * 处理各种语义搜索请求
 */
class SearchController {
  constructor() {
    this.vectorService = new VectorService();
  }

  /**
   * 通用搜索（文档+FAQ混合搜索）
   */
  async search(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: '请求参数验证失败',
          errors: errors.array()
        });
      }

      const {
        q: query,
        knowledge_base_id: knowledgeBaseId,
        type = 'hybrid',
        limit = 10,
        threshold = 0.7,
        include_metadata = true
      } = req.query;

      let results;

      switch (type) {
        case 'documents':
          results = await this.vectorService.searchDocuments(query, {
            limit: parseInt(limit),
            threshold: parseFloat(threshold),
            knowledgeBaseId,
            includeMetadata: include_metadata === 'true'
          });
          break;

        case 'faqs':
          results = await this.vectorService.searchFaqs(query, {
            limit: parseInt(limit),
            threshold: parseFloat(threshold),
            knowledgeBaseId,
            includeMetadata: include_metadata === 'true'
          });
          break;

        case 'hybrid':
        default:
          const documentLimit = Math.ceil(parseInt(limit) / 2);
          const faqLimit = parseInt(limit) - documentLimit;
          
          results = await this.vectorService.hybridSearch(query, {
            documentLimit,
            faqLimit,
            threshold: parseFloat(threshold),
            knowledgeBaseId
          });
          break;
      }

      res.json({
        success: true,
        data: results,
        meta: {
          query,
          type,
          limit: parseInt(limit),
          threshold: parseFloat(threshold),
          knowledgeBaseId,
          timestamp: new Date().toISOString()
        }
      });

    } catch (error) {
      console.error('Search error:', error);
      res.status(500).json({
        success: false,
        message: '搜索失败',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }

  /**
   * 文档搜索
   */
  async searchDocuments(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: '请求参数验证失败',
          errors: errors.array()
        });
      }

      const {
        q: query,
        knowledge_base_id: knowledgeBaseId,
        limit = 10,
        threshold = 0.7,
        include_metadata = true
      } = req.query;

      const results = await this.vectorService.searchDocuments(query, {
        limit: parseInt(limit),
        threshold: parseFloat(threshold),
        knowledgeBaseId,
        includeMetadata: include_metadata === 'true'
      });

      res.json({
        success: true,
        data: results,
        meta: {
          query,
          type: 'documents',
          count: results.length,
          limit: parseInt(limit),
          threshold: parseFloat(threshold),
          timestamp: new Date().toISOString()
        }
      });

    } catch (error) {
      console.error('Document search error:', error);
      res.status(500).json({
        success: false,
        message: '文档搜索失败',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }

  /**
   * FAQ搜索
   */
  async searchFaqs(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: '请求参数验证失败',
          errors: errors.array()
        });
      }

      const {
        q: query,
        knowledge_base_id: knowledgeBaseId,
        search_type: searchType = 'combined',
        limit = 10,
        threshold = 0.7,
        include_metadata = true
      } = req.query;

      const results = await this.vectorService.searchFaqs(query, {
        limit: parseInt(limit),
        threshold: parseFloat(threshold),
        knowledgeBaseId,
        searchType,
        includeMetadata: include_metadata === 'true'
      });

      res.json({
        success: true,
        data: results,
        meta: {
          query,
          type: 'faqs',
          searchType,
          count: results.length,
          limit: parseInt(limit),
          threshold: parseFloat(threshold),
          timestamp: new Date().toISOString()
        }
      });

    } catch (error) {
      console.error('FAQ search error:', error);
      res.status(500).json({
        success: false,
        message: 'FAQ搜索失败',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }

  /**
   * 获取内容推荐
   */
  async getRecommendations(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: '请求参数验证失败',
          errors: errors.array()
        });
      }

      const {
        content_id: contentId,
        content_type: contentType,
        limit = 5,
        threshold = 0.6
      } = req.query;

      const results = await this.vectorService.getRecommendations(
        contentId,
        contentType,
        {
          limit: parseInt(limit),
          threshold: parseFloat(threshold)
        }
      );

      res.json({
        success: true,
        data: results,
        meta: {
          contentId,
          contentType,
          limit: parseInt(limit),
          threshold: parseFloat(threshold),
          timestamp: new Date().toISOString()
        }
      });

    } catch (error) {
      console.error('Recommendations error:', error);
      res.status(500).json({
        success: false,
        message: '推荐内容获取失败',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }

  /**
   * 向量化文档内容
   */
  async vectorizeDocument(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: '请求参数验证失败',
          errors: errors.array()
        });
      }

      const { document_id, content, metadata = {} } = req.body;

      await this.vectorService.storeDocumentVector(document_id, content, metadata);

      res.json({
        success: true,
        message: '文档向量化成功',
        data: {
          documentId: document_id,
          timestamp: new Date().toISOString()
        }
      });

    } catch (error) {
      console.error('Document vectorization error:', error);
      res.status(500).json({
        success: false,
        message: '文档向量化失败',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }

  /**
   * 向量化FAQ内容
   */
  async vectorizeFaq(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: '请求参数验证失败',
          errors: errors.array()
        });
      }

      const { faq_id, question, answer, metadata = {} } = req.body;

      await this.vectorService.storeFaqVector(faq_id, question, answer, metadata);

      res.json({
        success: true,
        message: 'FAQ向量化成功',
        data: {
          faqId: faq_id,
          timestamp: new Date().toISOString()
        }
      });

    } catch (error) {
      console.error('FAQ vectorization error:', error);
      res.status(500).json({
        success: false,
        message: 'FAQ向量化失败',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }

  /**
   * 批量向量化
   */
  async batchVectorize(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: '请求参数验证失败',
          errors: errors.array()
        });
      }

      const { type, items } = req.body;

      const results = [];
      const errors_arr = [];

      for (const item of items) {
        try {
          if (type === 'document') {
            await this.vectorService.storeDocumentVector(
              item.document_id,
              item.content,
              item.metadata || {}
            );
            results.push({ id: item.document_id, status: 'success' });
          } else if (type === 'faq') {
            await this.vectorService.storeFaqVector(
              item.faq_id,
              item.question,
              item.answer,
              item.metadata || {}
            );
            results.push({ id: item.faq_id, status: 'success' });
          }
        } catch (error) {
          console.error(`Batch vectorization error for ${item.id}:`, error);
          errors_arr.push({
            id: item.id,
            error: error.message
          });
        }
      }

      res.json({
        success: true,
        message: `批量向量化完成`,
        data: {
          successful: results.length,
          failed: errors_arr.length,
          results,
          errors: errors_arr,
          timestamp: new Date().toISOString()
        }
      });

    } catch (error) {
      console.error('Batch vectorization error:', error);
      res.status(500).json({
        success: false,
        message: '批量向量化失败',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }

  /**
   * 获取搜索统计信息
   */
  async getStats(req, res) {
    try {
      const stats = await this.vectorService.getSearchStats();

      res.json({
        success: true,
        data: stats
      });

    } catch (error) {
      console.error('Get stats error:', error);
      res.status(500).json({
        success: false,
        message: '获取统计信息失败',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }

  /**
   * 清理缓存
   */
  async clearCache(req, res) {
    try {
      const { pattern = 'embedding:*' } = req.body;

      await this.vectorService.clearCache(pattern);

      res.json({
        success: true,
        message: '缓存清理成功',
        data: {
          pattern,
          timestamp: new Date().toISOString()
        }
      });

    } catch (error) {
      console.error('Clear cache error:', error);
      res.status(500).json({
        success: false,
        message: '缓存清理失败',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }

  /**
   * 健康检查
   */
  async healthCheck(req, res) {
    try {
      const stats = await this.vectorService.getSearchStats();
      
      res.json({
        success: true,
        message: '语义搜索服务运行正常',
        data: {
          service: 'semantic-search',
          status: 'healthy',
          stats,
          timestamp: new Date().toISOString()
        }
      });

    } catch (error) {
      console.error('Health check error:', error);
      res.status(503).json({
        success: false,
        message: '语义搜索服务异常',
        data: {
          service: 'semantic-search',
          status: 'unhealthy',
          error: error.message,
          timestamp: new Date().toISOString()
        }
      });
    }
  }
}

// 验证器
const validators = {
  search: [
    query('q').notEmpty().withMessage('搜索查询不能为空').isLength({ min: 1, max: 500 }).withMessage('查询长度应在1-500字符之间'),
    query('type').optional().isIn(['documents', 'faqs', 'hybrid']).withMessage('搜索类型必须是documents、faqs或hybrid'),
    query('limit').optional().isInt({ min: 1, max: 50 }).withMessage('限制数量必须是1-50之间的整数'),
    query('threshold').optional().isFloat({ min: 0, max: 1 }).withMessage('相似度阈值必须是0-1之间的浮点数'),
    query('knowledge_base_id').optional().isUUID().withMessage('知识库ID必须是有效的UUID')
  ],

  searchDocuments: [
    query('q').notEmpty().withMessage('搜索查询不能为空').isLength({ min: 1, max: 500 }).withMessage('查询长度应在1-500字符之间'),
    query('limit').optional().isInt({ min: 1, max: 50 }).withMessage('限制数量必须是1-50之间的整数'),
    query('threshold').optional().isFloat({ min: 0, max: 1 }).withMessage('相似度阈值必须是0-1之间的浮点数'),
    query('knowledge_base_id').optional().isUUID().withMessage('知识库ID必须是有效的UUID')
  ],

  searchFaqs: [
    query('q').notEmpty().withMessage('搜索查询不能为空').isLength({ min: 1, max: 500 }).withMessage('查询长度应在1-500字符之间'),
    query('search_type').optional().isIn(['combined', 'question', 'answer']).withMessage('搜索类型必须是combined、question或answer'),
    query('limit').optional().isInt({ min: 1, max: 50 }).withMessage('限制数量必须是1-50之间的整数'),
    query('threshold').optional().isFloat({ min: 0, max: 1 }).withMessage('相似度阈值必须是0-1之间的浮点数'),
    query('knowledge_base_id').optional().isUUID().withMessage('知识库ID必须是有效的UUID')
  ],

  getRecommendations: [
    query('content_id').notEmpty().withMessage('内容ID不能为空').isUUID().withMessage('内容ID必须是有效的UUID'),
    query('content_type').notEmpty().withMessage('内容类型不能为空').isIn(['document', 'faq']).withMessage('内容类型必须是document或faq'),
    query('limit').optional().isInt({ min: 1, max: 20 }).withMessage('限制数量必须是1-20之间的整数'),
    query('threshold').optional().isFloat({ min: 0, max: 1 }).withMessage('相似度阈值必须是0-1之间的浮点数')
  ],

  vectorizeDocument: [
    body('document_id').notEmpty().withMessage('文档ID不能为空').isUUID().withMessage('文档ID必须是有效的UUID'),
    body('content').notEmpty().withMessage('文档内容不能为空').isLength({ min: 10, max: 50000 }).withMessage('文档内容长度应在10-50000字符之间'),
    body('metadata').optional().isObject().withMessage('元数据必须是对象')
  ],

  vectorizeFaq: [
    body('faq_id').notEmpty().withMessage('FAQ ID不能为空').isUUID().withMessage('FAQ ID必须是有效的UUID'),
    body('question').notEmpty().withMessage('问题不能为空').isLength({ min: 5, max: 1000 }).withMessage('问题长度应在5-1000字符之间'),
    body('answer').notEmpty().withMessage('答案不能为空').isLength({ min: 10, max: 10000 }).withMessage('答案长度应在10-10000字符之间'),
    body('metadata').optional().isObject().withMessage('元数据必须是对象')
  ],

  batchVectorize: [
    body('type').notEmpty().withMessage('类型不能为空').isIn(['document', 'faq']).withMessage('类型必须是document或faq'),
    body('items').isArray({ min: 1, max: 100 }).withMessage('项目数组必须包含1-100个项目')
  ]
};

module.exports = {
  SearchController,
  validators
}; 