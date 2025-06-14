const express = require('express');
const router = express.Router();
const {
  createKnowledgeBase,
  getKnowledgeBases,
  getKnowledgeBase,
  updateKnowledgeBase,
  deleteKnowledgeBase,
  getMyKnowledgeBases,
  getPublicKnowledgeBases
} = require('../controllers/knowledgeBaseController');

/**
 * 知识库路由
 * @swagger
 * tags:
 *   name: KnowledgeBase
 *   description: 知识库管理API
 */

/**
 * @swagger
 * /api/knowledge-bases:
 *   get:
 *     summary: 获取知识库列表
 *     tags: [KnowledgeBase]
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
 *         description: 搜索关键词
 *       - in: query
 *         name: type
 *         schema:
 *           type: string
 *           enum: [personal, team, public]
 *         description: 知识库类型
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [active, archived, disabled]
 *         description: 知识库状态
 *       - in: query
 *         name: tags
 *         schema:
 *           type: array
 *           items:
 *             type: string
 *         description: 标签筛选
 *       - in: query
 *         name: sort
 *         schema:
 *           type: string
 *           enum: [name, created_at, updated_at, last_activity, document_count]
 *           default: last_activity
 *         description: 排序字段
 *       - in: query
 *         name: order
 *         schema:
 *           type: string
 *           enum: [ASC, DESC]
 *           default: DESC
 *         description: 排序方向
 *     responses:
 *       200:
 *         description: 获取成功
 *       400:
 *         description: 请求参数错误
 *       500:
 *         description: 服务器错误
 */
router.get('/', getKnowledgeBases);

/**
 * @swagger
 * /api/knowledge-bases:
 *   post:
 *     summary: 创建知识库
 *     tags: [KnowledgeBase]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *             properties:
 *               name:
 *                 type: string
 *                 maxLength: 255
 *                 description: 知识库名称
 *               description:
 *                 type: string
 *                 maxLength: 1000
 *                 description: 知识库描述
 *               type:
 *                 type: string
 *                 enum: [personal, team, public]
 *                 default: personal
 *                 description: 知识库类型
 *               tags:
 *                 type: array
 *                 items:
 *                   type: string
 *                   maxLength: 50
 *                 maxItems: 20
 *                 description: 标签数组
 *               settings:
 *                 type: object
 *                 description: 知识库设置
 *               indexing_enabled:
 *                 type: boolean
 *                 default: true
 *                 description: 是否启用索引
 *               search_enabled:
 *                 type: boolean
 *                 default: true
 *                 description: 是否启用搜索
 *               ai_enabled:
 *                 type: boolean
 *                 default: true
 *                 description: 是否启用AI功能
 *     responses:
 *       201:
 *         description: 创建成功
 *       400:
 *         description: 请求数据错误
 *       500:
 *         description: 服务器错误
 */
router.post('/', createKnowledgeBase);

/**
 * @swagger
 * /api/knowledge-bases/my:
 *   get:
 *     summary: 获取我的知识库
 *     tags: [KnowledgeBase]
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           minimum: 1
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 100
 *           default: 20
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [active, archived, disabled]
 *       - in: query
 *         name: tags
 *         schema:
 *           type: array
 *           items:
 *             type: string
 *       - in: query
 *         name: sort
 *         schema:
 *           type: string
 *           enum: [name, created_at, updated_at, last_activity, document_count]
 *           default: last_activity
 *       - in: query
 *         name: order
 *         schema:
 *           type: string
 *           enum: [ASC, DESC]
 *           default: DESC
 *     responses:
 *       200:
 *         description: 获取成功
 *       401:
 *         description: 未授权
 *       500:
 *         description: 服务器错误
 */
router.get('/my', getMyKnowledgeBases);

/**
 * @swagger
 * /api/knowledge-bases/public:
 *   get:
 *     summary: 获取公开知识库
 *     tags: [KnowledgeBase]
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           minimum: 1
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 100
 *           default: 20
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *       - in: query
 *         name: tags
 *         schema:
 *           type: array
 *           items:
 *             type: string
 *       - in: query
 *         name: sort
 *         schema:
 *           type: string
 *           enum: [name, created_at, updated_at, last_activity, document_count]
 *           default: last_activity
 *       - in: query
 *         name: order
 *         schema:
 *           type: string
 *           enum: [ASC, DESC]
 *           default: DESC
 *     responses:
 *       200:
 *         description: 获取成功
 *       500:
 *         description: 服务器错误
 */
router.get('/public', getPublicKnowledgeBases);

/**
 * @swagger
 * /api/knowledge-bases/{id}:
 *   get:
 *     summary: 获取知识库详情
 *     tags: [KnowledgeBase]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 知识库ID
 *     responses:
 *       200:
 *         description: 获取成功
 *       404:
 *         description: 知识库不存在
 *       403:
 *         description: 没有访问权限
 *       500:
 *         description: 服务器错误
 */
router.get('/:id', getKnowledgeBase);

/**
 * @swagger
 * /api/knowledge-bases/{id}:
 *   put:
 *     summary: 更新知识库
 *     tags: [KnowledgeBase]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 知识库ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 maxLength: 255
 *               description:
 *                 type: string
 *                 maxLength: 1000
 *               type:
 *                 type: string
 *                 enum: [personal, team, public]
 *               status:
 *                 type: string
 *                 enum: [active, archived, disabled]
 *               tags:
 *                 type: array
 *                 items:
 *                   type: string
 *                   maxLength: 50
 *                 maxItems: 20
 *               settings:
 *                 type: object
 *               indexing_enabled:
 *                 type: boolean
 *               search_enabled:
 *                 type: boolean
 *               ai_enabled:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: 更新成功
 *       400:
 *         description: 请求数据错误
 *       404:
 *         description: 知识库不存在
 *       403:
 *         description: 没有修改权限
 *       500:
 *         description: 服务器错误
 */
router.put('/:id', updateKnowledgeBase);

/**
 * @swagger
 * /api/knowledge-bases/{id}:
 *   delete:
 *     summary: 删除知识库
 *     tags: [KnowledgeBase]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 知识库ID
 *     responses:
 *       200:
 *         description: 删除成功
 *       404:
 *         description: 知识库不存在
 *       403:
 *         description: 没有删除权限
 *       500:
 *         description: 服务器错误
 */
router.delete('/:id', deleteKnowledgeBase);

module.exports = router; 