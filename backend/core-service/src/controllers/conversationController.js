const { Conversation, KnowledgeBase, User } = require('../models');
const { Op } = require('sequelize');
const logger = require('../utils/logger');
const { ApiError } = require('../utils/errors');
const { validateUUID, validatePagination } = require('../validators/common');
const { v4: uuidv4 } = require('uuid');
const { generateResponse } = require('../services/aiService');
const { searchKnowledge } = require('../services/vectorService');

/**
 * 对话控制器
 * 处理对话的创建、管理、消息发送等操作
 */
class ConversationController {
  /**
   * 创建新对话
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async createConversation(req, res) {
    try {
      const {
        knowledgeBaseId,
        title,
        type = 'chat',
        settings = {},
        tags = []
      } = req.body;

      const userId = req.user?.id;
      const sessionId = uuidv4();

      // 验证知识库ID（如果提供）
      if (knowledgeBaseId) {
        validateUUID(knowledgeBaseId, 'knowledgeBaseId');
        
        const knowledgeBase = await KnowledgeBase.findByPk(knowledgeBaseId);
        if (!knowledgeBase) {
          return res.status(404).json({
            success: false,
            message: '知识库不存在'
          });
        }
      }

      // 创建对话
      const conversation = await Conversation.create({
        sessionId,
        userId,
        knowledgeBaseId,
        title: title || `对话 ${new Date().toLocaleString()}`,
        type,
        settings,
        tags,
        clientInfo: {
          userAgent: req.get('User-Agent'),
          language: req.get('Accept-Language'),
        },
        ipAddress: req.ip
      });

      res.status(201).json({
        success: true,
        data: { conversation }
      });

    } catch (error) {
      logger.error('创建对话失败:', error);
      
      if (error instanceof ApiError) {
        return res.status(error.statusCode).json({
          success: false,
          message: error.message
        });
      }

      res.status(500).json({
        success: false,
        message: '服务器内部错误'
      });
    }
  }

  /**
   * 获取对话列表
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async getConversations(req, res) {
    try {
      const {
        page = 1,
        limit = 20,
        type,
        status,
        knowledgeBaseId,
        search,
        sortBy = 'lastMessageAt',
        sortOrder = 'DESC'
      } = req.query;

      const userId = req.user?.id;

      // 验证分页参数
      const { offset, validatedLimit } = validatePagination(page, limit);

      // 构建查询条件
      const where = {};
      
      if (userId) {
        where.userId = userId;
      }

      if (type) {
        where.type = type;
      }

      if (status) {
        where.status = status;
      } else {
        // 默认不返回已归档的对话
        where.status = { [Op.ne]: 'archived' };
      }

      if (knowledgeBaseId) {
        validateUUID(knowledgeBaseId, 'knowledgeBaseId');
        where.knowledgeBaseId = knowledgeBaseId;
      }

      if (search) {
        where[Op.or] = [
          { title: { [Op.iLike]: `%${search}%` } },
          { tags: { [Op.contains]: [search] } }
        ];
      }

      // 构建排序
      const validSortFields = ['createdAt', 'updatedAt', 'lastMessageAt', 'messageCount', 'title'];
      const sortField = validSortFields.includes(sortBy) ? sortBy : 'lastMessageAt';
      const order = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';

      // 查询对话
      const { rows: conversations, count: total } = await Conversation.findAndCountAll({
        where,
        include: [
          {
            model: KnowledgeBase,
            as: 'knowledgeBase',
            attributes: ['id', 'name', 'description']
          }
        ],
        order: [[sortField, order]],
        limit: validatedLimit,
        offset,
        distinct: true
      });

      // 计算分页信息
      const totalPages = Math.ceil(total / validatedLimit);

      res.json({
        success: true,
        data: {
          conversations,
          pagination: {
            total,
            page: parseInt(page),
            limit: validatedLimit,
            totalPages,
            hasNext: page < totalPages,
            hasPrev: page > 1
          }
        }
      });

    } catch (error) {
      logger.error('获取对话列表失败:', error);
      
      if (error instanceof ApiError) {
        return res.status(error.statusCode).json({
          success: false,
          message: error.message
        });
      }

      res.status(500).json({
        success: false,
        message: '服务器内部错误'
      });
    }
  }

  /**
   * 获取对话详情
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async getConversationById(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user?.id;

      validateUUID(id, 'conversation ID');

      const where = { id };
      if (userId) {
        where.userId = userId;
      }

      const conversation = await Conversation.findOne({
        where,
        include: [
          {
            model: KnowledgeBase,
            as: 'knowledgeBase',
            attributes: ['id', 'name', 'description']
          }
        ]
      });

      if (!conversation) {
        return res.status(404).json({
          success: false,
          message: '对话不存在或无权访问'
        });
      }

      res.json({
        success: true,
        data: { conversation }
      });

    } catch (error) {
      logger.error('获取对话详情失败:', error);
      
      if (error instanceof ApiError) {
        return res.status(error.statusCode).json({
          success: false,
          message: error.message
        });
      }

      res.status(500).json({
        success: false,
        message: '服务器内部错误'
      });
    }
  }

  /**
   * 发送消息
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async sendMessage(req, res) {
    try {
      const { id } = req.params;
      const { content, contentType = 'text', metadata = {} } = req.body;
      const userId = req.user?.id;

      validateUUID(id, 'conversation ID');

      if (!content || content.trim() === '') {
        return res.status(400).json({
          success: false,
          message: '消息内容不能为空'
        });
      }

      const where = { id };
      if (userId) {
        where.userId = userId;
      }

      const conversation = await Conversation.findOne({
        where,
        include: [
          {
            model: KnowledgeBase,
            as: 'knowledgeBase'
          }
        ]
      });

      if (!conversation) {
        return res.status(404).json({
          success: false,
          message: '对话不存在或无权访问'
        });
      }

      if (conversation.status === 'ended') {
        return res.status(400).json({
          success: false,
          message: '对话已结束，无法发送消息'
        });
      }

      const startTime = Date.now();

      // 创建用户消息
      const userMessage = {
        id: uuidv4(),
        role: 'user',
        content: content.trim(),
        contentType,
        timestamp: new Date().toISOString(),
        metadata
      };

      // 添加用户消息到对话
      const messages = [...conversation.messages, userMessage];

      // 搜索相关知识
      let sources = [];
      let assistantResponse = '';

      try {
        // 如果有关联的知识库，进行知识检索
        if (conversation.knowledgeBaseId) {
          const searchResults = await searchKnowledge({
            query: content,
            knowledgeBaseId: conversation.knowledgeBaseId,
            limit: 5,
            threshold: 0.7
          });

          sources = searchResults.documents.map(doc => ({
            type: 'document',
            id: doc.id,
            title: doc.title,
            content: doc.content.substring(0, 200),
            similarity: doc.similarity
          }));
        }

        // 生成AI回复
        const aiResponse = await generateResponse({
          messages: messages.slice(-10), // 只取最近10条消息作为上下文
          knowledgeBase: conversation.knowledgeBase,
          sources,
          settings: conversation.settings
        });

        assistantResponse = aiResponse.content;

      } catch (aiError) {
        logger.error('生成AI回复失败:', aiError);
        assistantResponse = '抱歉，我遇到了一些问题，暂时无法回复您。请稍后再试。';
      }

      const processingTime = Date.now() - startTime;

      // 创建助手消息
      const assistantMessage = {
        id: uuidv4(),
        role: 'assistant',
        content: assistantResponse,
        contentType: 'text',
        timestamp: new Date().toISOString(),
        metadata: {
          sources,
          processingTime,
          model: 'gpt-3.5-turbo' // 实际使用的模型
        }
      };

      // 更新对话
      const updatedMessages = [...messages, assistantMessage];
      await conversation.update({
        messages: updatedMessages,
        messageCount: updatedMessages.length,
        lastMessageAt: new Date(),
        context: {
          ...conversation.context,
          lastQuery: content,
          lastSources: sources
        }
      });

      res.json({
        success: true,
        data: {
          userMessage,
          assistantMessage,
          sources,
          processingTime
        }
      });

    } catch (error) {
      logger.error('发送消息失败:', error);
      
      if (error instanceof ApiError) {
        return res.status(error.statusCode).json({
          success: false,
          message: error.message
        });
      }

      res.status(500).json({
        success: false,
        message: '服务器内部错误'
      });
    }
  }

  /**
   * 更新对话
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async updateConversation(req, res) {
    try {
      const { id } = req.params;
      const { title, tags, settings, status } = req.body;
      const userId = req.user?.id;

      validateUUID(id, 'conversation ID');

      const where = { id };
      if (userId) {
        where.userId = userId;
      }

      const conversation = await Conversation.findOne({ where });

      if (!conversation) {
        return res.status(404).json({
          success: false,
          message: '对话不存在或无权访问'
        });
      }

      // 准备更新数据
      const updateData = {};
      
      if (title !== undefined) {
        updateData.title = title;
      }
      
      if (tags !== undefined) {
        updateData.tags = tags;
      }
      
      if (settings !== undefined) {
        updateData.settings = { ...conversation.settings, ...settings };
      }
      
      if (status !== undefined) {
        updateData.status = status;
        if (status === 'ended') {
          updateData.endedAt = new Date();
        }
      }

      // 更新对话
      await conversation.update(updateData);

      res.json({
        success: true,
        data: { conversation }
      });

    } catch (error) {
      logger.error('更新对话失败:', error);
      
      if (error instanceof ApiError) {
        return res.status(error.statusCode).json({
          success: false,
          message: error.message
        });
      }

      res.status(500).json({
        success: false,
        message: '服务器内部错误'
      });
    }
  }

  /**
   * 删除对话
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async deleteConversation(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user?.id;

      validateUUID(id, 'conversation ID');

      const where = { id };
      if (userId) {
        where.userId = userId;
      }

      const conversation = await Conversation.findOne({ where });

      if (!conversation) {
        return res.status(404).json({
          success: false,
          message: '对话不存在或无权访问'
        });
      }

      await conversation.destroy();

      res.json({
        success: true,
        message: '对话已删除'
      });

    } catch (error) {
      logger.error('删除对话失败:', error);
      
      if (error instanceof ApiError) {
        return res.status(error.statusCode).json({
          success: false,
          message: error.message
        });
      }

      res.status(500).json({
        success: false,
        message: '服务器内部错误'
      });
    }
  }

  /**
   * 批量删除对话
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async bulkDeleteConversations(req, res) {
    try {
      const { ids } = req.body;
      const userId = req.user?.id;

      if (!Array.isArray(ids) || ids.length === 0) {
        return res.status(400).json({
          success: false,
          message: '请提供要删除的对话ID列表'
        });
      }

      // 验证所有ID
      ids.forEach(id => validateUUID(id, 'conversation ID'));

      const where = { id: { [Op.in]: ids } };
      if (userId) {
        where.userId = userId;
      }

      const deletedCount = await Conversation.destroy({ where });

      res.json({
        success: true,
        data: { deletedCount },
        message: `成功删除 ${deletedCount} 个对话`
      });

    } catch (error) {
      logger.error('批量删除对话失败:', error);
      
      if (error instanceof ApiError) {
        return res.status(error.statusCode).json({
          success: false,
          message: error.message
        });
      }

      res.status(500).json({
        success: false,
        message: '服务器内部错误'
      });
    }
  }

  /**
   * 对话评分
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async rateConversation(req, res) {
    try {
      const { id } = req.params;
      const { rating, feedback } = req.body;
      const userId = req.user?.id;

      validateUUID(id, 'conversation ID');

      if (!rating || rating < 1 || rating > 5) {
        return res.status(400).json({
          success: false,
          message: '评分必须是1-5之间的数字'
        });
      }

      const where = { id };
      if (userId) {
        where.userId = userId;
      }

      const conversation = await Conversation.findOne({ where });

      if (!conversation) {
        return res.status(404).json({
          success: false,
          message: '对话不存在或无权访问'
        });
      }

      await conversation.update({
        rating: parseInt(rating),
        feedback: feedback || null
      });

      res.json({
        success: true,
        message: '评分成功',
        data: {
          rating: conversation.rating,
          feedback: conversation.feedback
        }
      });

    } catch (error) {
      logger.error('对话评分失败:', error);
      
      if (error instanceof ApiError) {
        return res.status(error.statusCode).json({
          success: false,
          message: error.message
        });
      }

      res.status(500).json({
        success: false,
        message: '服务器内部错误'
      });
    }
  }

  /**
   * 获取对话统计信息
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async getConversationStats(req, res) {
    try {
      const userId = req.user?.id;
      const { startDate, endDate, knowledgeBaseId } = req.query;

      const where = {};
      if (userId) {
        where.userId = userId;
      }

      if (knowledgeBaseId) {
        validateUUID(knowledgeBaseId, 'knowledgeBaseId');
        where.knowledgeBaseId = knowledgeBaseId;
      }

      if (startDate || endDate) {
        where.createdAt = {};
        if (startDate) {
          where.createdAt[Op.gte] = new Date(startDate);
        }
        if (endDate) {
          where.createdAt[Op.lte] = new Date(endDate);
        }
      }

      // 基础统计
      const totalConversations = await Conversation.count({ where });
      
      const activeConversations = await Conversation.count({
        where: { ...where, status: 'active' }
      });

      const avgRating = await Conversation.findOne({
        where: { ...where, rating: { [Op.ne]: null } },
        attributes: [
          [sequelize.fn('AVG', sequelize.col('rating')), 'avgRating'],
          [sequelize.fn('COUNT', sequelize.col('rating')), 'ratedCount']
        ],
        raw: true
      });

      const totalMessages = await Conversation.findOne({
        where,
        attributes: [[sequelize.fn('SUM', sequelize.col('message_count')), 'totalMessages']],
        raw: true
      });

      // 按类型统计
      const conversationsByType = await Conversation.findAll({
        where,
        attributes: [
          'type',
          [sequelize.fn('COUNT', sequelize.col('id')), 'count']
        ],
        group: ['type'],
        raw: true
      });

      // 按状态统计
      const conversationsByStatus = await Conversation.findAll({
        where,
        attributes: [
          'status',
          [sequelize.fn('COUNT', sequelize.col('id')), 'count']
        ],
        group: ['status'],
        raw: true
      });

      res.json({
        success: true,
        data: {
          overview: {
            totalConversations,
            activeConversations,
            avgRating: avgRating?.avgRating ? parseFloat(avgRating.avgRating).toFixed(2) : 0,
            ratedCount: avgRating?.ratedCount || 0,
            totalMessages: totalMessages?.totalMessages || 0
          },
          breakdowns: {
            byType: conversationsByType,
            byStatus: conversationsByStatus
          }
        }
      });

    } catch (error) {
      logger.error('获取对话统计失败:', error);
      
      if (error instanceof ApiError) {
        return res.status(error.statusCode).json({
          success: false,
          message: error.message
        });
      }

      res.status(500).json({
        success: false,
        message: '服务器内部错误'
      });
    }
  }
}

module.exports = new ConversationController(); 