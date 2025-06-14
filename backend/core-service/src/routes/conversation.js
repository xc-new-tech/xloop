const express = require('express');
const router = express.Router();
const conversationController = require('../controllers/conversationController');
const { authenticateToken } = require('../middleware/auth');
const { rateLimiter } = require('../middleware/rateLimiter');
const { body, param, query } = require('express-validator');
const { validateRequest } = require('../middleware/validation');

/**
 * @swagger
 * components:
 *   schemas:
 *     Conversation:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *           description: 对话唯一标识符
 *         sessionId:
 *           type: string
 *           description: 会话ID
 *         userId:
 *           type: string
 *           format: uuid
 *           description: 用户ID
 *         knowledgeBaseId:
 *           type: string
 *           format: uuid
 *           description: 关联知识库ID
 *         title:
 *           type: string
 *           description: 对话标题
 *         type:
 *           type: string
 *           enum: [chat, search, qa, support]
 *           description: 对话类型
 *         status:
 *           type: string
 *           enum: [active, ended, archived]
 *           description: 对话状态
 *         messages:
 *           type: array
 *           description: 消息列表
 *           items:
 *             type: object
 *             properties:
 *               id:
 *                 type: string
 *               role:
 *                 type: string
 *                 enum: [user, assistant, system]
 *               content:
 *                 type: string
 *               contentType:
 *                 type: string
 *               timestamp:
 *                 type: string
 *                 format: date-time
 *               metadata:
 *                 type: object
 *         context:
 *           type: object
 *           description: 对话上下文
 *         settings:
 *           type: object
 *           description: 对话设置
 *         tags:
 *           type: array
 *           items:
 *             type: string
 *           description: 标签列表
 *         rating:
 *           type: integer
 *           minimum: 1
 *           maximum: 5
 *           description: 用户评分
 *         feedback:
 *           type: string
 *           description: 用户反馈
 *         messageCount:
 *           type: integer
 *           description: 消息数量
 *         lastMessageAt:
 *           type: string
 *           format: date-time
 *           description: 最后消息时间
 *         createdAt:
 *           type: string
 *           format: date-time
 *         updatedAt:
 *           type: string
 *           format: date-time
 *     
 *     Message:
 *       type: object
 *       properties:
 *         content:
 *           type: string
 *           description: 消息内容
 *         contentType:
 *           type: string
 *           default: text
 *           description: 内容类型
 *         metadata:
 *           type: object
 *           description: 消息元数据
 *       required:
 *         - content
 */

// 应用认证中间件到所有路由
router.use(authenticateToken);

/**
 * @swagger
 * /api/conversations:
 *   post:
 *     summary: 创建新对话
 *     tags: [Conversations]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               knowledgeBaseId:
 *                 type: string
 *                 format: uuid
 *                 description: 关联知识库ID（可选）
 *               title:
 *                 type: string
 *                 description: 对话标题（可选）
 *               type:
 *                 type: string
 *                 enum: [chat, search, qa, support]
 *                 default: chat
 *                 description: 对话类型
 *               settings:
 *                 type: object
 *                 description: 对话设置
 *               tags:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: 标签列表
 *     responses:
 *       201:
 *         description: 对话创建成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     conversation:
 *                       $ref: '#/components/schemas/Conversation'
 *       400:
 *         description: 请求参数错误
 *       401:
 *         description: 未授权
 *       404:
 *         description: 知识库不存在
 */
router.post('/',
  rateLimiter({ windowMs: 15 * 60 * 1000, max: 100 }), // 15分钟内最多100次请求
  [
    body('knowledgeBaseId').optional().isUUID().withMessage('知识库ID格式无效'),
    body('title').optional().isLength({ min: 1, max: 500 }).withMessage('标题长度应在1-500字符之间'),
    body('type').optional().isIn(['chat', 'search', 'qa', 'support']).withMessage('对话类型无效'),
    body('settings').optional().isObject().withMessage('设置必须是对象'),
    body('tags').optional().isArray().withMessage('标签必须是数组'),
  ],
  validateRequest,
  conversationController.createConversation
);

/**
 * @swagger
 * /api/conversations:
 *   get:
 *     summary: 获取对话列表
 *     tags: [Conversations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           minimum: 1
 *           default: 1
 *         description: 页码
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 100
 *           default: 20
 *         description: 每页数量
 *       - in: query
 *         name: type
 *         schema:
 *           type: string
 *           enum: [chat, search, qa, support]
 *         description: 对话类型筛选
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [active, ended, archived]
 *         description: 对话状态筛选
 *       - in: query
 *         name: knowledgeBaseId
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 知识库ID筛选
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: 搜索关键词
 *       - in: query
 *         name: sortBy
 *         schema:
 *           type: string
 *           enum: [createdAt, updatedAt, lastMessageAt, messageCount, title]
 *           default: lastMessageAt
 *         description: 排序字段
 *       - in: query
 *         name: sortOrder
 *         schema:
 *           type: string
 *           enum: [ASC, DESC]
 *           default: DESC
 *         description: 排序顺序
 *     responses:
 *       200:
 *         description: 获取成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     conversations:
 *                       type: array
 *                       items:
 *                         $ref: '#/components/schemas/Conversation'
 *                     pagination:
 *                       type: object
 *                       properties:
 *                         total:
 *                           type: integer
 *                         page:
 *                           type: integer
 *                         limit:
 *                           type: integer
 *                         totalPages:
 *                           type: integer
 *                         hasNext:
 *                           type: boolean
 *                         hasPrev:
 *                           type: boolean
 *       401:
 *         description: 未授权
 */
router.get('/',
  [
    query('page').optional().isInt({ min: 1 }).withMessage('页码必须是正整数'),
    query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('每页数量必须在1-100之间'),
    query('type').optional().isIn(['chat', 'search', 'qa', 'support']).withMessage('对话类型无效'),
    query('status').optional().isIn(['active', 'ended', 'archived']).withMessage('对话状态无效'),
    query('knowledgeBaseId').optional().isUUID().withMessage('知识库ID格式无效'),
    query('sortBy').optional().isIn(['createdAt', 'updatedAt', 'lastMessageAt', 'messageCount', 'title']).withMessage('排序字段无效'),
    query('sortOrder').optional().isIn(['ASC', 'DESC']).withMessage('排序顺序无效'),
  ],
  validateRequest,
  conversationController.getConversations
);

/**
 * @swagger
 * /api/conversations/{id}:
 *   get:
 *     summary: 获取对话详情
 *     tags: [Conversations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 对话ID
 *     responses:
 *       200:
 *         description: 获取成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     conversation:
 *                       $ref: '#/components/schemas/Conversation'
 *       401:
 *         description: 未授权
 *       404:
 *         description: 对话不存在
 */
router.get('/:id',
  [
    param('id').isUUID().withMessage('对话ID格式无效'),
  ],
  validateRequest,
  conversationController.getConversationById
);

/**
 * @swagger
 * /api/conversations/{id}/messages:
 *   post:
 *     summary: 发送消息
 *     tags: [Conversations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 对话ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Message'
 *     responses:
 *       200:
 *         description: 消息发送成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     userMessage:
 *                       type: object
 *                     assistantMessage:
 *                       type: object
 *                     sources:
 *                       type: array
 *                     processingTime:
 *                       type: number
 *       400:
 *         description: 请求参数错误
 *       401:
 *         description: 未授权
 *       404:
 *         description: 对话不存在
 */
router.post('/:id/messages',
  rateLimiter({ windowMs: 60 * 1000, max: 30 }), // 1分钟内最多30条消息
  [
    param('id').isUUID().withMessage('对话ID格式无效'),
    body('content').notEmpty().isLength({ min: 1, max: 10000 }).withMessage('消息内容长度应在1-10000字符之间'),
    body('contentType').optional().isIn(['text', 'image', 'file', 'audio']).withMessage('内容类型无效'),
    body('metadata').optional().isObject().withMessage('元数据必须是对象'),
  ],
  validateRequest,
  conversationController.sendMessage
);

/**
 * @swagger
 * /api/conversations/{id}:
 *   put:
 *     summary: 更新对话
 *     tags: [Conversations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 对话ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *                 description: 对话标题
 *               tags:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: 标签列表
 *               settings:
 *                 type: object
 *                 description: 对话设置
 *               status:
 *                 type: string
 *                 enum: [active, ended, archived]
 *                 description: 对话状态
 *     responses:
 *       200:
 *         description: 更新成功
 *       400:
 *         description: 请求参数错误
 *       401:
 *         description: 未授权
 *       404:
 *         description: 对话不存在
 */
router.put('/:id',
  [
    param('id').isUUID().withMessage('对话ID格式无效'),
    body('title').optional().isLength({ min: 1, max: 500 }).withMessage('标题长度应在1-500字符之间'),
    body('tags').optional().isArray().withMessage('标签必须是数组'),
    body('settings').optional().isObject().withMessage('设置必须是对象'),
    body('status').optional().isIn(['active', 'ended', 'archived']).withMessage('状态无效'),
  ],
  validateRequest,
  conversationController.updateConversation
);

/**
 * @swagger
 * /api/conversations/{id}:
 *   delete:
 *     summary: 删除对话
 *     tags: [Conversations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 对话ID
 *     responses:
 *       200:
 *         description: 删除成功
 *       401:
 *         description: 未授权
 *       404:
 *         description: 对话不存在
 */
router.delete('/:id',
  [
    param('id').isUUID().withMessage('对话ID格式无效'),
  ],
  validateRequest,
  conversationController.deleteConversation
);

/**
 * @swagger
 * /api/conversations/bulk/delete:
 *   post:
 *     summary: 批量删除对话
 *     tags: [Conversations]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               ids:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: uuid
 *                 description: 对话ID列表
 *             required:
 *               - ids
 *     responses:
 *       200:
 *         description: 删除成功
 *       400:
 *         description: 请求参数错误
 *       401:
 *         description: 未授权
 */
router.post('/bulk/delete',
  [
    body('ids').isArray({ min: 1 }).withMessage('请提供要删除的对话ID列表'),
    body('ids.*').isUUID().withMessage('对话ID格式无效'),
  ],
  validateRequest,
  conversationController.bulkDeleteConversations
);

/**
 * @swagger
 * /api/conversations/{id}/rate:
 *   post:
 *     summary: 对话评分
 *     tags: [Conversations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 对话ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               rating:
 *                 type: integer
 *                 minimum: 1
 *                 maximum: 5
 *                 description: 评分（1-5）
 *               feedback:
 *                 type: string
 *                 description: 反馈内容（可选）
 *             required:
 *               - rating
 *     responses:
 *       200:
 *         description: 评分成功
 *       400:
 *         description: 请求参数错误
 *       401:
 *         description: 未授权
 *       404:
 *         description: 对话不存在
 */
router.post('/:id/rate',
  [
    param('id').isUUID().withMessage('对话ID格式无效'),
    body('rating').isInt({ min: 1, max: 5 }).withMessage('评分必须是1-5之间的整数'),
    body('feedback').optional().isLength({ max: 1000 }).withMessage('反馈内容不能超过1000字符'),
  ],
  validateRequest,
  conversationController.rateConversation
);

/**
 * @swagger
 * /api/conversations/stats:
 *   get:
 *     summary: 获取对话统计信息
 *     tags: [Conversations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: startDate
 *         schema:
 *           type: string
 *           format: date
 *         description: 开始日期
 *       - in: query
 *         name: endDate
 *         schema:
 *           type: string
 *           format: date
 *         description: 结束日期
 *       - in: query
 *         name: knowledgeBaseId
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 知识库ID筛选
 *     responses:
 *       200:
 *         description: 获取成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     overview:
 *                       type: object
 *                       properties:
 *                         totalConversations:
 *                           type: integer
 *                         activeConversations:
 *                           type: integer
 *                         avgRating:
 *                           type: string
 *                         ratedCount:
 *                           type: integer
 *                         totalMessages:
 *                           type: integer
 *                     breakdowns:
 *                       type: object
 *                       properties:
 *                         byType:
 *                           type: array
 *                         byStatus:
 *                           type: array
 *       401:
 *         description: 未授权
 */
router.get('/stats',
  [
    query('startDate').optional().isISO8601().withMessage('开始日期格式无效'),
    query('endDate').optional().isISO8601().withMessage('结束日期格式无效'),
    query('knowledgeBaseId').optional().isUUID().withMessage('知识库ID格式无效'),
  ],
  validateRequest,
  conversationController.getConversationStats
);

module.exports = router; 