const multer = require('multer');
const path = require('path');
const fs = require('fs').promises;
const crypto = require('crypto');
const { body, validationResult } = require('express-validator');
const { File } = require('../models');
const FileParseService = require('../services/FileParseService');
const FileStorageService = require('../services/FileStorageService');
const logger = require('../config/logger');

// 配置multer存储
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadPath = path.join(__dirname, '../uploads/temp');
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const fileExtension = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + fileExtension);
  }
});

// 文件过滤器
const fileFilter = (req, file, cb) => {
  const allowedTypes = [
    'application/pdf',
    'text/plain',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'text/csv',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'audio/mpeg',
    'audio/wav',
    'audio/mp3',
    'image/jpeg',
    'image/png',
    'image/gif'
  ];

  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error(`不支持的文件类型: ${file.mimetype}`), false);
  }
};

// 配置multer
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 50 * 1024 * 1024, // 50MB
    files: 10 // 最多10个文件
  }
});

class FileController {
  /**
   * 上传单个文件
   */
  static uploadSingle = upload.single('file');

  /**
   * 上传多个文件
   */
  static uploadMultiple = upload.array('files', 10);

  /**
   * 处理单文件上传
   */
  static async handleSingleUpload(req, res) {
    try {
      logger.info('开始处理单文件上传', { userId: req.user?.id });

      const { knowledgeBaseId, category = 'document', tags = [] } = req.body;
      
      if (!req.file) {
        return res.status(400).json({
          success: false,
          message: '没有上传文件'
        });
      }

      const result = await FileController.processUploadedFile(
        req.file,
        req.user.id,
        knowledgeBaseId,
        category,
        Array.isArray(tags) ? tags : JSON.parse(tags || '[]')
      );

      res.status(201).json({
        success: true,
        message: '文件上传成功',
        data: result
      });

    } catch (error) {
      logger.error('单文件上传失败', { error: error.message, stack: error.stack });
      
      // 清理临时文件
      if (req.file && req.file.path) {
        try {
          await fs.unlink(req.file.path);
        } catch (cleanupError) {
          logger.error('清理临时文件失败', { path: req.file.path, error: cleanupError.message });
        }
      }

      res.status(500).json({
        success: false,
        message: error.message || '文件上传失败'
      });
    }
  }

  /**
   * 处理多文件上传
   */
  static async handleMultipleUpload(req, res) {
    try {
      logger.info('开始处理多文件上传', { 
        userId: req.user?.id, 
        fileCount: req.files?.length 
      });

      const { knowledgeBaseId, category = 'document', tags = [] } = req.body;
      
      if (!req.files || req.files.length === 0) {
        return res.status(400).json({
          success: false,
          message: '没有上传文件'
        });
      }

      const results = [];
      const errors = [];

      for (const file of req.files) {
        try {
          const result = await FileController.processUploadedFile(
            file,
            req.user.id,
            knowledgeBaseId,
            category,
            Array.isArray(tags) ? tags : JSON.parse(tags || '[]')
          );
          results.push(result);
        } catch (error) {
          logger.error('处理文件失败', { 
            filename: file.originalname, 
            error: error.message 
          });
          errors.push({
            filename: file.originalname,
            error: error.message
          });
          
          // 清理失败的临时文件
          try {
            await fs.unlink(file.path);
          } catch (cleanupError) {
            logger.error('清理临时文件失败', { 
              path: file.path, 
              error: cleanupError.message 
            });
          }
        }
      }

      const response = {
        success: true,
        message: `成功上传 ${results.length} 个文件`,
        data: {
          successful: results,
          failed: errors,
          summary: {
            total: req.files.length,
            successful: results.length,
            failed: errors.length
          }
        }
      };

      res.status(201).json(response);

    } catch (error) {
      logger.error('多文件上传失败', { error: error.message, stack: error.stack });

      // 清理所有临时文件
      if (req.files) {
        for (const file of req.files) {
          try {
            await fs.unlink(file.path);
          } catch (cleanupError) {
            logger.error('清理临时文件失败', { 
              path: file.path, 
              error: cleanupError.message 
            });
          }
        }
      }

      res.status(500).json({
        success: false,
        message: error.message || '文件上传失败'
      });
    }
  }

  /**
   * 处理上传的文件
   */
  static async processUploadedFile(file, userId, knowledgeBaseId, category, tags) {
    try {
      // 1. 生成文件唯一标识符
      const fileId = crypto.randomUUID();
      const fileHash = await FileController.calculateFileHash(file.path);

      // 2. 检查文件是否已存在
      const existingFile = await File.findOne({ where: { hash: fileHash } });
      if (existingFile) {
        // 文件已存在，直接返回现有记录
        await fs.unlink(file.path); // 删除临时文件
        return existingFile;
      }

      // 3. 存储文件到永久位置
      const storedFilePath = await FileStorageService.store(file, fileId);

      // 4. 解析文件内容
      const parseResult = await FileParseService.parseFile(file.path, file.mimetype);

      // 5. 创建文件记录
      const fileRecord = await File.create({
        id: fileId,
        originalName: file.originalname,
        filename: file.filename,
        mimetype: file.mimetype,
        size: file.size,
        hash: fileHash,
        path: storedFilePath,
        userId: userId,
        knowledgeBaseId: knowledgeBaseId,
        category: category,
        tags: tags,
        contentType: parseResult.contentType,
        extractedText: parseResult.text,
        metadata: parseResult.metadata,
        chunks: parseResult.chunks || [],
        status: 'processed',
        processingErrors: parseResult.errors || []
      });

      // 6. 清理临时文件
      try {
        await fs.unlink(file.path);
      } catch (cleanupError) {
        logger.warn('清理临时文件失败', { 
          path: file.path, 
          error: cleanupError.message 
        });
      }

      logger.info('文件处理完成', { 
        fileId: fileId, 
        originalName: file.originalname,
        size: file.size,
        textLength: parseResult.text?.length || 0,
        chunksCount: parseResult.chunks?.length || 0
      });

      return fileRecord;

    } catch (error) {
      logger.error('文件处理失败', { 
        filename: file.originalname, 
        error: error.message,
        stack: error.stack
      });
      throw error;
    }
  }

  /**
   * 计算文件哈希值
   */
  static async calculateFileHash(filePath) {
    const fileBuffer = await fs.readFile(filePath);
    return crypto.createHash('sha256').update(fileBuffer).digest('hex');
  }

  /**
   * 获取文件列表
   */
  static async getFiles(req, res) {
    try {
      const {
        page = 1,
        limit = 20,
        knowledgeBaseId,
        category,
        mimetype,
        search
      } = req.query;

      const offset = (page - 1) * limit;
      const where = { userId: req.user.id };

      if (knowledgeBaseId) {
        where.knowledgeBaseId = knowledgeBaseId;
      }

      if (category) {
        where.category = category;
      }

      if (mimetype) {
        where.mimetype = mimetype;
      }

      if (search) {
        const { Op } = require('sequelize');
        where[Op.or] = [
          { originalName: { [Op.iLike]: `%${search}%` } },
          { extractedText: { [Op.iLike]: `%${search}%` } }
        ];
      }

      const { count, rows } = await File.findAndCountAll({
        where,
        limit: parseInt(limit),
        offset: parseInt(offset),
        order: [['createdAt', 'DESC']],
        attributes: {
          exclude: ['extractedText', 'chunks'] // 列表中不返回大字段
        }
      });

      res.json({
        success: true,
        data: {
          files: rows,
          pagination: {
            total: count,
            page: parseInt(page),
            limit: parseInt(limit),
            pages: Math.ceil(count / limit)
          }
        }
      });

    } catch (error) {
      logger.error('获取文件列表失败', { error: error.message, stack: error.stack });
      res.status(500).json({
        success: false,
        message: '获取文件列表失败'
      });
    }
  }

  /**
   * 获取文件详情
   */
  static async getFileById(req, res) {
    try {
      const { id } = req.params;
      
      const file = await File.findOne({
        where: { 
          id: id,
          userId: req.user.id 
        }
      });

      if (!file) {
        return res.status(404).json({
          success: false,
          message: '文件不存在'
        });
      }

      res.json({
        success: true,
        data: file
      });

    } catch (error) {
      logger.error('获取文件详情失败', { error: error.message, stack: error.stack });
      res.status(500).json({
        success: false,
        message: '获取文件详情失败'
      });
    }
  }

  /**
   * 下载文件
   */
  static async downloadFile(req, res) {
    try {
      const { id } = req.params;
      
      const file = await File.findOne({
        where: { 
          id: id,
          userId: req.user.id 
        }
      });

      if (!file) {
        return res.status(404).json({
          success: false,
          message: '文件不存在'
        });
      }

      const filePath = await FileStorageService.getFilePath(file.path);
      
      // 检查文件是否存在
      try {
        await fs.access(filePath);
      } catch (error) {
        return res.status(404).json({
          success: false,
          message: '文件已被删除或移动'
        });
      }

      res.download(filePath, file.originalName);

    } catch (error) {
      logger.error('文件下载失败', { error: error.message, stack: error.stack });
      res.status(500).json({
        success: false,
        message: '文件下载失败'
      });
    }
  }

  /**
   * 删除文件
   */
  static async deleteFile(req, res) {
    try {
      const { id } = req.params;
      
      const file = await File.findOne({
        where: { 
          id: id,
          userId: req.user.id 
        }
      });

      if (!file) {
        return res.status(404).json({
          success: false,
          message: '文件不存在'
        });
      }

      // 删除物理文件
      try {
        await FileStorageService.delete(file.path);
      } catch (error) {
        logger.warn('删除物理文件失败', { 
          path: file.path, 
          error: error.message 
        });
      }

      // 删除数据库记录
      await file.destroy();

      res.json({
        success: true,
        message: '文件删除成功'
      });

    } catch (error) {
      logger.error('文件删除失败', { error: error.message, stack: error.stack });
      res.status(500).json({
        success: false,
        message: '文件删除失败'
      });
    }
  }

  /**
   * 重新解析文件
   */
  static async reparseFile(req, res) {
    try {
      const { id } = req.params;
      
      const file = await File.findOne({
        where: { 
          id: id,
          userId: req.user.id 
        }
      });

      if (!file) {
        return res.status(404).json({
          success: false,
          message: '文件不存在'
        });
      }

      const filePath = await FileStorageService.getFilePath(file.path);
      
      // 检查文件是否存在
      try {
        await fs.access(filePath);
      } catch (error) {
        return res.status(404).json({
          success: false,
          message: '文件已被删除或移动'
        });
      }

      // 重新解析文件
      const parseResult = await FileParseService.parseFile(filePath, file.mimetype);

      // 更新文件记录
      await file.update({
        extractedText: parseResult.text,
        metadata: parseResult.metadata,
        chunks: parseResult.chunks || [],
        status: 'processed',
        processingErrors: parseResult.errors || [],
        updatedAt: new Date()
      });

      res.json({
        success: true,
        message: '文件重新解析成功',
        data: file
      });

    } catch (error) {
      logger.error('文件重新解析失败', { error: error.message, stack: error.stack });
      res.status(500).json({
        success: false,
        message: '文件重新解析失败'
      });
    }
  }
}

module.exports = FileController; 