const express = require('express');
const FileController = require('../controllers/fileController');
const { authenticate } = require('../middleware/auth');
const { body, param, query } = require('express-validator');
const { validateRequest } = require('../middleware/validation');

const router = express.Router();

/**
 * @swagger
 * components:
 *   schemas:
 *     File:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *           description: 文件唯一标识符
 *         originalName:
 *           type: string
 *           description: 原始文件名
 *         filename:
 *           type: string
 *           description: 存储文件名
 *         mimetype:
 *           type: string
 *           description: 文件MIME类型
 *         size:
 *           type: integer
 *           description: 文件大小（字节）
 *         hash:
 *           type: string
 *           description: 文件SHA256哈希值
 *         path:
 *           type: string
 *           description: 文件存储路径
 *         userId:
 *           type: string
 *           format: uuid
 *           description: 上传用户ID
 *         knowledgeBaseId:
 *           type: string
 *           format: uuid
 *           description: 所属知识库ID
 *         category:
 *           type: string
 *           enum: [document, image, audio, video, other]
 *           description: 文件分类
 *         tags:
 *           type: array
 *           items:
 *             type: string
 *           description: 文件标签
 *         contentType:
 *           type: string
 *           description: 解析后的内容类型
 *         extractedText:
 *           type: string
 *           description: 提取的文本内容
 *         metadata:
 *           type: object
 *           description: 文件元数据
 *         chunks:
 *           type: array
 *           items:
 *             type: object
 *           description: 文档切片
 *         status:
 *           type: string
 *           enum: [uploading, processing, processed, failed]
 *           description: 处理状态
 *         processingErrors:
 *           type: array
 *           items:
 *             type: string
 *           description: 处理错误信息
 *         createdAt:
 *           type: string
 *           format: date-time
 *         updatedAt:
 *           type: string
 *           format: date-time
 *     FileUploadResponse:
 *       type: object
 *       properties:
 *         success:
 *           type: boolean
 *         message:
 *           type: string
 *         data:
 *           $ref: '#/components/schemas/File'
 *     MultipleFileUploadResponse:
 *       type: object
 *       properties:
 *         success:
 *           type: boolean
 *         message:
 *           type: string
 *         data:
 *           type: object
 *           properties:
 *             successful:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/File'
 *             failed:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   filename:
 *                     type: string
 *                   error:
 *                     type: string
 *             summary:
 *               type: object
 *               properties:
 *                 total:
 *                   type: integer
 *                 successful:
 *                   type: integer
 *                 failed:
 *                   type: integer
 */

/**
 * @swagger
 * /api/files/upload:
 *   post:
 *     summary: 上传单个文件
 *     tags: [Files]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *                 description: 要上传的文件
 *               knowledgeBaseId:
 *                 type: string
 *                 format: uuid
 *                 description: 所属知识库ID
 *               category:
 *                 type: string
 *                 enum: [document, image, audio, video, other]
 *                 default: document
 *                 description: 文件分类
 *               tags:
 *                 type: string
 *                 description: 文件标签JSON数组字符串
 *             required:
 *               - file
 *     responses:
 *       201:
 *         description: 文件上传成功
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/FileUploadResponse'
 *       400:
 *         description: 请求错误
 *       401:
 *         description: 未授权
 *       413:
 *         description: 文件过大
 *       415:
 *         description: 不支持的文件类型
 *       500:
 *         description: 服务器错误
 */
router.post('/upload', 
  authenticate,
  FileController.uploadSingle,
  FileController.handleSingleUpload
);

/**
 * @swagger
 * /api/files/upload-multiple:
 *   post:
 *     summary: 上传多个文件
 *     tags: [Files]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               files:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *                 description: 要上传的文件数组（最多10个）
 *               knowledgeBaseId:
 *                 type: string
 *                 format: uuid
 *                 description: 所属知识库ID
 *               category:
 *                 type: string
 *                 enum: [document, image, audio, video, other]
 *                 default: document
 *                 description: 文件分类
 *               tags:
 *                 type: string
 *                 description: 文件标签JSON数组字符串
 *             required:
 *               - files
 *     responses:
 *       201:
 *         description: 文件上传结果
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MultipleFileUploadResponse'
 *       400:
 *         description: 请求错误
 *       401:
 *         description: 未授权
 *       413:
 *         description: 文件过大
 *       415:
 *         description: 不支持的文件类型
 *       500:
 *         description: 服务器错误
 */
router.post('/upload-multiple',
  authenticate,
  FileController.uploadMultiple,
  FileController.handleMultipleUpload
);

/**
 * @swagger
 * /api/files:
 *   get:
 *     summary: 获取文件列表
 *     tags: [Files]
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
 *         name: knowledgeBaseId
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 筛选指定知识库的文件
 *       - in: query
 *         name: category
 *         schema:
 *           type: string
 *           enum: [document, image, audio, video, other]
 *         description: 筛选文件分类
 *       - in: query
 *         name: mimetype
 *         schema:
 *           type: string
 *         description: 筛选MIME类型
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: 搜索文件名或内容
 *     responses:
 *       200:
 *         description: 文件列表
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
 *                     files:
 *                       type: array
 *                       items:
 *                         $ref: '#/components/schemas/File'
 *                     pagination:
 *                       type: object
 *                       properties:
 *                         total:
 *                           type: integer
 *                         page:
 *                           type: integer
 *                         limit:
 *                           type: integer
 *                         pages:
 *                           type: integer
 *       401:
 *         description: 未授权
 *       500:
 *         description: 服务器错误
 */
router.get('/',
  authenticate,
  [
    query('page').optional().isInt({ min: 1 }),
    query('limit').optional().isInt({ min: 1, max: 100 }),
    query('knowledgeBaseId').optional().isUUID(),
    query('category').optional().isIn(['document', 'image', 'audio', 'video', 'other']),
    query('search').optional().isLength({ min: 1, max: 100 })
  ],
  validateRequest,
  FileController.getFiles
);

/**
 * @swagger
 * /api/files/{id}:
 *   get:
 *     summary: 获取文件详情
 *     tags: [Files]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 文件ID
 *     responses:
 *       200:
 *         description: 文件详情
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   $ref: '#/components/schemas/File'
 *       404:
 *         description: 文件不存在
 *       401:
 *         description: 未授权
 *       500:
 *         description: 服务器错误
 */
router.get('/:id',
  authenticate,
  [
    param('id').isUUID().withMessage('文件ID格式无效')
  ],
  validateRequest,
  FileController.getFileById
);

/**
 * @swagger
 * /api/files/{id}/download:
 *   get:
 *     summary: 下载文件
 *     tags: [Files]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 文件ID
 *     responses:
 *       200:
 *         description: 文件下载
 *         content:
 *           application/octet-stream:
 *             schema:
 *               type: string
 *               format: binary
 *       404:
 *         description: 文件不存在
 *       401:
 *         description: 未授权
 *       500:
 *         description: 服务器错误
 */
router.get('/:id/download',
  authenticate,
  [
    param('id').isUUID().withMessage('文件ID格式无效')
  ],
  validateRequest,
  FileController.downloadFile
);

/**
 * @swagger
 * /api/files/{id}/reparse:
 *   post:
 *     summary: 重新解析文件
 *     tags: [Files]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 文件ID
 *     responses:
 *       200:
 *         description: 重新解析成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *                 data:
 *                   $ref: '#/components/schemas/File'
 *       404:
 *         description: 文件不存在
 *       401:
 *         description: 未授权
 *       500:
 *         description: 服务器错误
 */
router.post('/:id/reparse',
  authenticate,
  [
    param('id').isUUID().withMessage('文件ID格式无效')
  ],
  validateRequest,
  FileController.reparseFile
);

/**
 * @swagger
 * /api/files/{id}:
 *   delete:
 *     summary: 删除文件
 *     tags: [Files]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: 文件ID
 *     responses:
 *       200:
 *         description: 文件删除成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *       404:
 *         description: 文件不存在
 *       401:
 *         description: 未授权
 *       500:
 *         description: 服务器错误
 */
router.delete('/:id',
  authenticate,
  [
    param('id').isUUID().withMessage('文件ID格式无效')
  ],
  validateRequest,
  FileController.deleteFile
);

module.exports = router; 