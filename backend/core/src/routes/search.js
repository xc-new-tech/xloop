const express = require('express');
const { SearchController, validators } = require('../controllers/searchController');
const { authenticateJWT } = require('../middleware/auth');

const router = express.Router();
const searchController = new SearchController();

/**
 * 语义搜索路由
 * 提供各种语义搜索API接口
 */

// 健康检查（无需认证）
router.get('/health', searchController.healthCheck.bind(searchController));

// 以下路由需要认证
router.use(authenticateJWT);

/**
 * @route GET /api/search
 * @desc 通用语义搜索（混合搜索）
 * @access Private
 * @param {string} q - 搜索查询 (必需)
 * @param {string} type - 搜索类型: documents|faqs|hybrid (可选，默认hybrid)
 * @param {number} limit - 结果数量限制 (可选，默认10，最大50)
 * @param {number} threshold - 相似度阈值 (可选，默认0.7，范围0-1)
 * @param {string} knowledge_base_id - 知识库ID (可选)
 * @param {boolean} include_metadata - 是否包含元数据 (可选，默认true)
 * @example GET /api/search?q=如何使用Flutter&type=hybrid&limit=10
 */
router.get('/', validators.search, searchController.search.bind(searchController));

/**
 * @route GET /api/search/documents
 * @desc 文档语义搜索
 * @access Private
 * @param {string} q - 搜索查询 (必需)
 * @param {number} limit - 结果数量限制 (可选，默认10，最大50)
 * @param {number} threshold - 相似度阈值 (可选，默认0.7，范围0-1)
 * @param {string} knowledge_base_id - 知识库ID (可选)
 * @param {boolean} include_metadata - 是否包含元数据 (可选，默认true)
 * @example GET /api/search/documents?q=Flutter架构设计&limit=5
 */
router.get('/documents', validators.searchDocuments, searchController.searchDocuments.bind(searchController));

/**
 * @route GET /api/search/faqs
 * @desc FAQ语义搜索
 * @access Private
 * @param {string} q - 搜索查询 (必需)
 * @param {string} search_type - 搜索类型: combined|question|answer (可选，默认combined)
 * @param {number} limit - 结果数量限制 (可选，默认10，最大50)
 * @param {number} threshold - 相似度阈值 (可选，默认0.7，范围0-1)
 * @param {string} knowledge_base_id - 知识库ID (可选)
 * @param {boolean} include_metadata - 是否包含元数据 (可选，默认true)
 * @example GET /api/search/faqs?q=如何登录&search_type=question&limit=5
 */
router.get('/faqs', validators.searchFaqs, searchController.searchFaqs.bind(searchController));

/**
 * @route GET /api/search/recommendations
 * @desc 获取内容推荐
 * @access Private
 * @param {string} content_id - 内容ID (必需)
 * @param {string} content_type - 内容类型: document|faq (必需)
 * @param {number} limit - 推荐数量限制 (可选，默认5，最大20)
 * @param {number} threshold - 相似度阈值 (可选，默认0.6，范围0-1)
 * @example GET /api/search/recommendations?content_id=123e4567-e89b-12d3-a456-426614174000&content_type=document
 */
router.get('/recommendations', validators.getRecommendations, searchController.getRecommendations.bind(searchController));

/**
 * @route POST /api/search/vectorize/document
 * @desc 向量化文档内容
 * @access Private
 * @body {string} document_id - 文档ID (必需)
 * @body {string} content - 文档内容 (必需，10-50000字符)
 * @body {object} metadata - 元数据 (可选)
 * @example POST /api/search/vectorize/document
 * {
 *   "document_id": "123e4567-e89b-12d3-a456-426614174000",
 *   "content": "这是一篇关于Flutter开发的文档...",
 *   "metadata": {"author": "张三", "category": "技术文档"}
 * }
 */
router.post('/vectorize/document', validators.vectorizeDocument, searchController.vectorizeDocument.bind(searchController));

/**
 * @route POST /api/search/vectorize/faq
 * @desc 向量化FAQ内容
 * @access Private
 * @body {string} faq_id - FAQ ID (必需)
 * @body {string} question - 问题 (必需，5-1000字符)
 * @body {string} answer - 答案 (必需，10-10000字符)
 * @body {object} metadata - 元数据 (可选)
 * @example POST /api/search/vectorize/faq
 * {
 *   "faq_id": "123e4567-e89b-12d3-a456-426614174000",
 *   "question": "如何在Flutter中实现路由？",
 *   "answer": "在Flutter中可以使用Navigator和Router...",
 *   "metadata": {"category": "开发", "difficulty": "中级"}
 * }
 */
router.post('/vectorize/faq', validators.vectorizeFaq, searchController.vectorizeFaq.bind(searchController));

/**
 * @route POST /api/search/vectorize/batch
 * @desc 批量向量化内容
 * @access Private
 * @body {string} type - 类型: document|faq (必需)
 * @body {array} items - 项目数组 (必需，1-100个项目)
 * @example POST /api/search/vectorize/batch
 * {
 *   "type": "document",
 *   "items": [
 *     {
 *       "document_id": "123e4567-e89b-12d3-a456-426614174000",
 *       "content": "文档内容1...",
 *       "metadata": {}
 *     },
 *     {
 *       "document_id": "123e4567-e89b-12d3-a456-426614174001",
 *       "content": "文档内容2...",
 *       "metadata": {}
 *     }
 *   ]
 * }
 */
router.post('/vectorize/batch', validators.batchVectorize, searchController.batchVectorize.bind(searchController));

/**
 * @route GET /api/search/stats
 * @desc 获取搜索统计信息
 * @access Private
 * @returns {object} 包含向量数量、缓存信息等统计数据
 * @example GET /api/search/stats
 */
router.get('/stats', searchController.getStats.bind(searchController));

/**
 * @route POST /api/search/cache/clear
 * @desc 清理缓存
 * @access Private
 * @body {string} pattern - 清理模式 (可选，默认'embedding:*')
 * @example POST /api/search/cache/clear
 * {
 *   "pattern": "embedding:*"
 * }
 */
router.post('/cache/clear', searchController.clearCache.bind(searchController));

module.exports = router; 