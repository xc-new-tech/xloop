const express = require('express');
const router = express.Router();
const faqController = require('../controllers/faqController');
const { authenticateToken, requireAuth } = require('../middleware/auth');
const { validateFAQInput, validateFAQUpdate } = require('../validators/faqValidator');
const rateLimit = require('../middleware/rateLimit');

/**
 * @swagger
 * components:
 *   schemas:
 *     FAQ:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *           description: FAQ的唯一标识符
 *         question:
 *           type: string
 *           description: 问题内容
 *           maxLength: 1000
 *         answer:
 *           type: string
 *           description: 答案内容
 *           maxLength: 5000
 *         category:
 *           type: string
 *           description: FAQ分类
 *           maxLength: 100
 *           default: "未分类"
 *         tags:
 *           type: array
 *           items:
 *             type: string
 *           description: 标签数组
 *         priority:
 *           type: string
 *           enum: [low, medium, high]
 *           description: 优先级
 *           default: medium
 *         status:
 *           type: string
 *           enum: [draft, published, archived]
 *           description: 状态
 *           default: draft
 *         isPublic:
 *           type: boolean
 *           description: 是否公开
 *           default: true
 *         viewCount:
 *           type: integer
 *           description: 查看次数
 *           minimum: 0
 *         likeCount:
 *           type: integer
 *           description: 点赞次数
 *           minimum: 0
 *         dislikeCount:
 *           type: integer
 *           description: 踩次数
 *           minimum: 0
 *         knowledgeBaseId:
 *           type: string
 *           format: uuid
 *           description: 所属知识库ID
 *         createdBy:
 *           type: string
 *           format: uuid
 *           description: 创建者ID
 *         updatedBy:
 *           type: string
 *           format: uuid
 *           description: 更新者ID
 *         metadata:
 *           type: object
 *           description: 扩展元数据
 *         createdAt:
 *           type: string
 *           format: date-time
 *           description: 创建时间
 *         updatedAt:
 *           type: string
 *           format: date-time
 *           description: 更新时间
 *         knowledgeBase:
 *           $ref: '#/components/schemas/KnowledgeBaseRef'
 *         creator:
 *           $ref: '#/components/schemas/UserRef'
 *         updater:
 *           $ref: '#/components/schemas/UserRef'
 *
 *     FAQInput:
 *       type: object
 *       required:
 *         - question
 *         - answer
 *       properties:
 *         question:
 *           type: string
 *           description: 问题内容
 *           minLength: 1
 *           maxLength: 1000
 *         answer:
 *           type: string
 *           description: 答案内容
 *           minLength: 1
 *           maxLength: 5000
 *         category:
 *           type: string
 *           description: FAQ分类
 *           maxLength: 100
 *         tags:
 *           type: array
 *           items:
 *             type: string
 *           description: 标签数组
 *         priority:
 *           type: string
 *           enum: [low, medium, high]
 *           description: 优先级
 *         status:
 *           type: string
 *           enum: [draft, published, archived]
 *           description: 状态
 *         isPublic:
 *           type: boolean
 *           description: 是否公开
 *         knowledgeBaseId:
 *           type: string
 *           format: uuid
 *           description: 所属知识库ID
 *         metadata:
 *           type: object
 *           description: 扩展元数据
 *
 *     FAQList:
 *       type: object
 *       properties:
 *         faqs:
 *           type: array
 *           items:
 *             $ref: '#/components/schemas/FAQ'
 *         pagination:
 *           $ref: '#/components/schemas/Pagination'
 *
 *     FAQSearch:
 *       type: object
 *       properties:
 *         faqs:
 *           type: array
 *           items:
 *             $ref: '#/components/schemas/FAQ'
 *         keyword:
 *           type: string
 *           description: 搜索关键词
 *         pagination:
 *           $ref: '#/components/schemas/Pagination'
 *
 *     FAQCategory:
 *       type: object
 *       properties:
 *         category:
 *           type: string
 *           description: 分类名称
 *         count:
 *           type: integer
 *           description: 该分类下的FAQ数量
 */

/**
 * @swagger
 * tags:
 *   name: FAQ
 *   description: FAQ管理接口
 */

/**
 * @swagger
 * /api/faqs:
 *   get:
 *     summary: 获取FAQ列表
 *     tags: [FAQ]
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
 *         name: search
 *         schema:
 *           type: string
 *         description: 搜索关键词（在问题和答案中搜索）
 *       - in: query
 *         name: category
 *         schema:
 *           type: string
 *         description: 按分类筛选
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [draft, published, archived]
 *         description: 按状态筛选（默认只返回published）
 *       - in: query
 *         name: knowledgeBaseId
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 按知识库筛选
 *       - in: query
 *         name: isPublic
 *         schema:
 *           type: boolean
 *         description: 按公开状态筛选
 *       - in: query
 *         name: sortBy
 *         schema:
 *           type: string
 *           enum: [createdAt, updatedAt, viewCount, likeCount, question, category]
 *           default: createdAt
 *         description: 排序字段
 *       - in: query
 *         name: sortOrder
 *         schema:
 *           type: string
 *           enum: [ASC, DESC]
 *           default: DESC
 *         description: 排序方向
 *       - in: query
 *         name: tags
 *         schema:
 *           type: array
 *           items:
 *             type: string
 *         description: 按标签筛选
 *     responses:
 *       200:
 *         description: 获取FAQ列表成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   $ref: '#/components/schemas/FAQList'
 *       400:
 *         $ref: '#/components/responses/BadRequest'
 *       500:
 *         $ref: '#/components/responses/InternalServerError'
 */
router.get('/', faqController.getFAQs);

/**
 * @swagger
 * /api/faqs/search:
 *   get:
 *     summary: 搜索FAQ
 *     tags: [FAQ]
 *     parameters:
 *       - in: query
 *         name: keyword
 *         required: true
 *         schema:
 *           type: string
 *           minLength: 1
 *         description: 搜索关键词
 *       - in: query
 *         name: knowledgeBaseId
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 限定知识库
 *       - in: query
 *         name: category
 *         schema:
 *           type: string
 *         description: 限定分类
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
 *     responses:
 *       200:
 *         description: 搜索FAQ成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   $ref: '#/components/schemas/FAQSearch'
 *       400:
 *         $ref: '#/components/responses/BadRequest'
 *       500:
 *         $ref: '#/components/responses/InternalServerError'
 */
router.get('/search', faqController.searchFAQs);

/**
 * @swagger
 * /api/faqs/categories:
 *   get:
 *     summary: 获取FAQ分类列表
 *     tags: [FAQ]
 *     parameters:
 *       - in: query
 *         name: knowledgeBaseId
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 限定知识库
 *     responses:
 *       200:
 *         description: 获取分类列表成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     categories:
 *                       type: array
 *                       items:
 *                         $ref: '#/components/schemas/FAQCategory'
 *       500:
 *         $ref: '#/components/responses/InternalServerError'
 */
router.get('/categories', faqController.getCategories);

/**
 * @swagger
 * /api/faqs/popular:
 *   get:
 *     summary: 获取热门FAQ
 *     tags: [FAQ]
 *     parameters:
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 50
 *           default: 10
 *         description: 返回数量
 *       - in: query
 *         name: knowledgeBaseId
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 限定知识库
 *     responses:
 *       200:
 *         description: 获取热门FAQ成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     faqs:
 *                       type: array
 *                       items:
 *                         $ref: '#/components/schemas/FAQ'
 *       500:
 *         $ref: '#/components/responses/InternalServerError'
 */
router.get('/popular', faqController.getPopularFAQs);

/**
 * @swagger
 * /api/faqs/{id}:
 *   get:
 *     summary: 获取FAQ详情
 *     tags: [FAQ]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: FAQ ID
 *     responses:
 *       200:
 *         description: 获取FAQ详情成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     faq:
 *                       $ref: '#/components/schemas/FAQ'
 *       400:
 *         $ref: '#/components/responses/BadRequest'
 *       404:
 *         $ref: '#/components/responses/NotFound'
 *       500:
 *         $ref: '#/components/responses/InternalServerError'
 */
router.get('/:id', faqController.getFAQById);

/**
 * @swagger
 * /api/faqs:
 *   post:
 *     summary: 创建FAQ
 *     tags: [FAQ]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/FAQInput'
 *     responses:
 *       201:
 *         description: FAQ创建成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "FAQ创建成功"
 *                 data:
 *                   type: object
 *                   properties:
 *                     faq:
 *                       $ref: '#/components/schemas/FAQ'
 *       400:
 *         $ref: '#/components/responses/BadRequest'
 *       401:
 *         $ref: '#/components/responses/Unauthorized'
 *       404:
 *         $ref: '#/components/responses/NotFound'
 *       500:
 *         $ref: '#/components/responses/InternalServerError'
 */
router.post('/', requireAuth, validateFAQInput, faqController.createFAQ);

/**
 * @swagger
 * /api/faqs/{id}:
 *   put:
 *     summary: 更新FAQ
 *     tags: [FAQ]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: FAQ ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/FAQInput'
 *     responses:
 *       200:
 *         description: FAQ更新成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "FAQ更新成功"
 *                 data:
 *                   type: object
 *                   properties:
 *                     faq:
 *                       $ref: '#/components/schemas/FAQ'
 *       400:
 *         $ref: '#/components/responses/BadRequest'
 *       401:
 *         $ref: '#/components/responses/Unauthorized'
 *       404:
 *         $ref: '#/components/responses/NotFound'
 *       500:
 *         $ref: '#/components/responses/InternalServerError'
 */
router.put('/:id', requireAuth, validateFAQUpdate, faqController.updateFAQ);

/**
 * @swagger
 * /api/faqs/{id}:
 *   delete:
 *     summary: 删除FAQ
 *     tags: [FAQ]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: FAQ ID
 *     responses:
 *       200:
 *         description: FAQ删除成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "FAQ删除成功"
 *       400:
 *         $ref: '#/components/responses/BadRequest'
 *       401:
 *         $ref: '#/components/responses/Unauthorized'
 *       404:
 *         $ref: '#/components/responses/NotFound'
 *       500:
 *         $ref: '#/components/responses/InternalServerError'
 */
router.delete('/:id', requireAuth, faqController.deleteFAQ);

/**
 * @swagger
 * /api/faqs/bulk/delete:
 *   post:
 *     summary: 批量删除FAQ
 *     tags: [FAQ]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - ids
 *             properties:
 *               ids:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: uuid
 *                 description: 要删除的FAQ ID数组
 *     responses:
 *       200:
 *         description: 批量删除成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "成功删除 3 个FAQ"
 *                 data:
 *                   type: object
 *                   properties:
 *                     deletedCount:
 *                       type: integer
 *                       example: 3
 *       400:
 *         $ref: '#/components/responses/BadRequest'
 *       401:
 *         $ref: '#/components/responses/Unauthorized'
 *       500:
 *         $ref: '#/components/responses/InternalServerError'
 */
router.post('/bulk/delete', requireAuth, faqController.bulkDeleteFAQs);

/**
 * @swagger
 * /api/faqs/{id}/like:
 *   post:
 *     summary: 点赞FAQ
 *     tags: [FAQ]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: FAQ ID
 *     responses:
 *       200:
 *         description: 点赞成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "点赞成功"
 *                 data:
 *                   type: object
 *                   properties:
 *                     likeCount:
 *                       type: integer
 *                       example: 42
 *       400:
 *         $ref: '#/components/responses/BadRequest'
 *       404:
 *         $ref: '#/components/responses/NotFound'
 *       500:
 *         $ref: '#/components/responses/InternalServerError'
 */
router.post('/:id/like', rateLimit({ windowMs: 60000, max: 10 }), faqController.likeFAQ);

/**
 * @swagger
 * /api/faqs/{id}/dislike:
 *   post:
 *     summary: 踩FAQ
 *     tags: [FAQ]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: FAQ ID
 *     responses:
 *       200:
 *         description: 反馈已记录
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "反馈已记录"
 *                 data:
 *                   type: object
 *                   properties:
 *                     dislikeCount:
 *                       type: integer
 *                       example: 5
 *       400:
 *         $ref: '#/components/responses/BadRequest'
 *       404:
 *         $ref: '#/components/responses/NotFound'
 *       500:
 *         $ref: '#/components/responses/InternalServerError'
 */
router.post('/:id/dislike', rateLimit({ windowMs: 60000, max: 10 }), faqController.dislikeFAQ);

/**
 * @swagger
 * /api/faqs/{id}/toggle-status:
 *   post:
 *     summary: 切换FAQ状态
 *     tags: [FAQ]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: FAQ ID
 *     responses:
 *       200:
 *         description: 状态切换成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "状态切换成功"
 *                 data:
 *                   type: object
 *                   properties:
 *                     status:
 *                       type: string
 *                       example: "published"
 *       400:
 *         $ref: '#/components/responses/BadRequest'
 *       401:
 *         $ref: '#/components/responses/Unauthorized'
 *       404:
 *         $ref: '#/components/responses/NotFound'
 *       500:
 *         $ref: '#/components/responses/InternalServerError'
 */
router.post('/:id/toggle-status', requireAuth, faqController.toggleFAQStatus);

module.exports = router; 