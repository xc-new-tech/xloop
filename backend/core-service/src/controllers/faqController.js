const { FAQ, KnowledgeBase, User } = require('../models');
const { Op } = require('sequelize');
const logger = require('../config/logger');
const { ApiError } = require('../utils/errors');
const { validateUUID, validatePagination } = require('../validators/common');

/**
 * FAQ控制器
 * 处理FAQ的增删改查、搜索、分类等操作
 */
class FAQController {
  /**
   * 获取FAQ列表
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async getFAQs(req, res) {
    try {
      const {
        page = 1,
        limit = 20,
        search,
        category,
        status,
        knowledgeBaseId,
        isPublic,
        sortBy = 'createdAt',
        sortOrder = 'DESC',
        tags
      } = req.query;

      // 验证分页参数
      const { offset, validatedLimit } = validatePagination(page, limit);

      // 构建查询条件
      const where = {};
      
      if (search) {
        where[Op.or] = [
          { question: { [Op.iLike]: `%${search}%` } },
          { answer: { [Op.iLike]: `%${search}%` } },
          { searchVector: { [Op.iLike]: `%${search.toLowerCase()}%` } }
        ];
      }

      if (category) {
        where.category = category;
      }

      if (status) {
        where.status = status;
      } else {
        // 默认只返回已发布的FAQ
        where.status = 'published';
      }

      if (knowledgeBaseId) {
        validateUUID(knowledgeBaseId, 'knowledgeBaseId');
        where.knowledgeBaseId = knowledgeBaseId;
      }

      if (isPublic !== undefined) {
        where.isPublic = isPublic === 'true';
      }

      if (tags) {
        const tagArray = Array.isArray(tags) ? tags : [tags];
        where.tags = {
          [Op.contains]: tagArray
        };
      }

      // 构建排序
      const validSortFields = ['createdAt', 'updatedAt', 'viewCount', 'likeCount', 'question', 'category'];
      const sortField = validSortFields.includes(sortBy) ? sortBy : 'createdAt';
      const order = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';

      // 查询FAQ
      const { rows: faqs, count: total } = await FAQ.findAndCountAll({
        where,
        include: [
          {
            model: KnowledgeBase,
            as: 'knowledgeBase',
            attributes: ['id', 'name', 'description']
          },
          {
            model: User,
            as: 'creator',
            attributes: ['id', 'username', 'email']
          },
          {
            model: User,
            as: 'updater',
            attributes: ['id', 'username', 'email']
          }
        ],
        order: [[sortField, order]],
        limit: validatedLimit,
        offset,
        distinct: true
      });

      // 计算分页信息
      const totalPages = Math.ceil(total / validatedLimit);
      const hasNext = page < totalPages;
      const hasPrev = page > 1;

      res.json({
        success: true,
        data: {
          faqs,
          pagination: {
            total,
            page: parseInt(page),
            limit: validatedLimit,
            totalPages,
            hasNext,
            hasPrev
          }
        }
      });

    } catch (error) {
      logger.error('获取FAQ列表失败:', error);
      
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
   * 获取单个FAQ详情
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async getFAQById(req, res) {
    try {
      const { id } = req.params;
      validateUUID(id, 'FAQ ID');

      const faq = await FAQ.findByPk(id, {
        include: [
          {
            model: KnowledgeBase,
            as: 'knowledgeBase',
            attributes: ['id', 'name', 'description']
          },
          {
            model: User,
            as: 'creator',
            attributes: ['id', 'username', 'email']
          },
          {
            model: User,
            as: 'updater',
            attributes: ['id', 'username', 'email']
          }
        ]
      });

      if (!faq) {
        return res.status(404).json({
          success: false,
          message: 'FAQ不存在'
        });
      }

      // 增加查看次数
      await faq.incrementViewCount();

      res.json({
        success: true,
        data: { faq }
      });

    } catch (error) {
      logger.error('获取FAQ详情失败:', error);
      
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
   * 创建FAQ
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async createFAQ(req, res) {
    try {
      const {
        question,
        answer,
        category,
        tags = [],
        priority = 'medium',
        status = 'draft',
        isPublic = true,
        knowledgeBaseId,
        metadata = {}
      } = req.body;

      // 验证必填字段
      if (!question || !answer) {
        return res.status(400).json({
          success: false,
          message: '问题和答案不能为空'
        });
      }

      // 验证知识库是否存在
      if (knowledgeBaseId) {
        validateUUID(knowledgeBaseId, 'knowledgeBaseId');
        const knowledgeBase = await KnowledgeBase.findByPk(knowledgeBaseId);
        if (!knowledgeBase) {
          return res.status(404).json({
            success: false,
            message: '指定的知识库不存在'
          });
        }
      }

      // 创建FAQ
      const faq = await FAQ.create({
        question: question.trim(),
        answer: answer.trim(),
        category: category?.trim() || '未分类',
        tags: Array.isArray(tags) ? tags : [],
        priority,
        status,
        isPublic,
        knowledgeBaseId,
        metadata,
        createdBy: req.user.id,
        updatedBy: req.user.id
      });

      // 获取完整的FAQ信息
      const createdFAQ = await FAQ.findByPk(faq.id, {
        include: [
          {
            model: KnowledgeBase,
            as: 'knowledgeBase',
            attributes: ['id', 'name', 'description']
          },
          {
            model: User,
            as: 'creator',
            attributes: ['id', 'username', 'email']
          }
        ]
      });

      logger.info(`用户 ${req.user.id} 创建了FAQ: ${faq.id}`);

      res.status(201).json({
        success: true,
        message: 'FAQ创建成功',
        data: { faq: createdFAQ }
      });

    } catch (error) {
      logger.error('创建FAQ失败:', error);

      if (error.name === 'SequelizeValidationError') {
        return res.status(400).json({
          success: false,
          message: '数据验证失败',
          errors: error.errors.map(err => ({
            field: err.path,
            message: err.message
          }))
        });
      }

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
   * 更新FAQ
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async updateFAQ(req, res) {
    try {
      const { id } = req.params;
      validateUUID(id, 'FAQ ID');

      const {
        question,
        answer,
        category,
        tags,
        priority,
        status,
        isPublic,
        knowledgeBaseId,
        metadata
      } = req.body;

      // 查找FAQ
      const faq = await FAQ.findByPk(id);
      if (!faq) {
        return res.status(404).json({
          success: false,
          message: 'FAQ不存在'
        });
      }

      // 验证知识库是否存在
      if (knowledgeBaseId && knowledgeBaseId !== faq.knowledgeBaseId) {
        validateUUID(knowledgeBaseId, 'knowledgeBaseId');
        const knowledgeBase = await KnowledgeBase.findByPk(knowledgeBaseId);
        if (!knowledgeBase) {
          return res.status(404).json({
            success: false,
            message: '指定的知识库不存在'
          });
        }
      }

      // 更新字段
      const updateFields = {};
      
      if (question !== undefined) updateFields.question = question.trim();
      if (answer !== undefined) updateFields.answer = answer.trim();
      if (category !== undefined) updateFields.category = category?.trim() || '未分类';
      if (tags !== undefined) updateFields.tags = Array.isArray(tags) ? tags : [];
      if (priority !== undefined) updateFields.priority = priority;
      if (status !== undefined) updateFields.status = status;
      if (isPublic !== undefined) updateFields.isPublic = isPublic;
      if (knowledgeBaseId !== undefined) updateFields.knowledgeBaseId = knowledgeBaseId;
      if (metadata !== undefined) updateFields.metadata = metadata;
      
      updateFields.updatedBy = req.user.id;

      // 执行更新
      await faq.update(updateFields);

      // 获取更新后的完整信息
      const updatedFAQ = await FAQ.findByPk(id, {
        include: [
          {
            model: KnowledgeBase,
            as: 'knowledgeBase',
            attributes: ['id', 'name', 'description']
          },
          {
            model: User,
            as: 'creator',
            attributes: ['id', 'username', 'email']
          },
          {
            model: User,
            as: 'updater',
            attributes: ['id', 'username', 'email']
          }
        ]
      });

      logger.info(`用户 ${req.user.id} 更新了FAQ: ${id}`);

      res.json({
        success: true,
        message: 'FAQ更新成功',
        data: { faq: updatedFAQ }
      });

    } catch (error) {
      logger.error('更新FAQ失败:', error);

      if (error.name === 'SequelizeValidationError') {
        return res.status(400).json({
          success: false,
          message: '数据验证失败',
          errors: error.errors.map(err => ({
            field: err.path,
            message: err.message
          }))
        });
      }

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
   * 删除FAQ
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async deleteFAQ(req, res) {
    try {
      const { id } = req.params;
      validateUUID(id, 'FAQ ID');

      const faq = await FAQ.findByPk(id);
      if (!faq) {
        return res.status(404).json({
          success: false,
          message: 'FAQ不存在'
        });
      }

      // 软删除
      await faq.destroy();

      logger.info(`用户 ${req.user.id} 删除了FAQ: ${id}`);

      res.json({
        success: true,
        message: 'FAQ删除成功'
      });

    } catch (error) {
      logger.error('删除FAQ失败:', error);

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
   * 批量删除FAQ
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async bulkDeleteFAQs(req, res) {
    try {
      const { ids } = req.body;

      if (!Array.isArray(ids) || ids.length === 0) {
        return res.status(400).json({
          success: false,
          message: '请提供要删除的FAQ ID数组'
        });
      }

      // 验证所有ID
      ids.forEach(id => validateUUID(id, 'FAQ ID'));

      // 批量软删除
      const deletedCount = await FAQ.destroy({
        where: {
          id: { [Op.in]: ids }
        }
      });

      logger.info(`用户 ${req.user.id} 批量删除了 ${deletedCount} 个FAQ`);

      res.json({
        success: true,
        message: `成功删除 ${deletedCount} 个FAQ`,
        data: { deletedCount }
      });

    } catch (error) {
      logger.error('批量删除FAQ失败:', error);

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
   * 搜索FAQ
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async searchFAQs(req, res) {
    try {
      const {
        keyword,
        knowledgeBaseId,
        category,
        page = 1,
        limit = 20
      } = req.query;

      if (!keyword || keyword.trim().length === 0) {
        return res.status(400).json({
          success: false,
          message: '搜索关键词不能为空'
        });
      }

      const { offset, validatedLimit } = validatePagination(page, limit);

      // 使用模型的搜索方法
      const options = {
        where: {
          status: 'published',
          isPublic: true
        },
        include: [
          {
            model: KnowledgeBase,
            as: 'knowledgeBase',
            attributes: ['id', 'name', 'description']
          }
        ],
        limit: validatedLimit,
        offset,
        order: [['viewCount', 'DESC'], ['likeCount', 'DESC']]
      };

      if (knowledgeBaseId) {
        validateUUID(knowledgeBaseId, 'knowledgeBaseId');
        options.where.knowledgeBaseId = knowledgeBaseId;
      }

      if (category) {
        options.where.category = category;
      }

      const faqs = await FAQ.searchByKeyword(keyword.trim(), options);
      const total = await FAQ.count({
        where: {
          ...options.where,
          [Op.or]: [
            { question: { [Op.iLike]: `%${keyword}%` } },
            { answer: { [Op.iLike]: `%${keyword}%` } },
            { searchVector: { [Op.iLike]: `%${keyword.toLowerCase()}%` } }
          ]
        }
      });

      const totalPages = Math.ceil(total / validatedLimit);

      res.json({
        success: true,
        data: {
          faqs,
          keyword: keyword.trim(),
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
      logger.error('搜索FAQ失败:', error);

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
   * 获取FAQ分类列表
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async getCategories(req, res) {
    try {
      const { knowledgeBaseId } = req.query;

      let where = {
        status: 'published',
        isPublic: true
      };

      if (knowledgeBaseId) {
        validateUUID(knowledgeBaseId, 'knowledgeBaseId');
        where.knowledgeBaseId = knowledgeBaseId;
      }

      const categories = await FAQ.getCategories();

      res.json({
        success: true,
        data: { categories }
      });

    } catch (error) {
      logger.error('获取FAQ分类失败:', error);

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
   * 获取热门FAQ
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async getPopularFAQs(req, res) {
    try {
      const { limit = 10, knowledgeBaseId } = req.query;

      const options = {
        include: [
          {
            model: KnowledgeBase,
            as: 'knowledgeBase',
            attributes: ['id', 'name', 'description']
          }
        ]
      };

      if (knowledgeBaseId) {
        validateUUID(knowledgeBaseId, 'knowledgeBaseId');
        options.where = { knowledgeBaseId };
      }

      const faqs = await FAQ.getPopular(parseInt(limit));

      res.json({
        success: true,
        data: { faqs }
      });

    } catch (error) {
      logger.error('获取热门FAQ失败:', error);

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
   * 点赞FAQ
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async likeFAQ(req, res) {
    try {
      const { id } = req.params;
      validateUUID(id, 'FAQ ID');

      const faq = await FAQ.findByPk(id);
      if (!faq) {
        return res.status(404).json({
          success: false,
          message: 'FAQ不存在'
        });
      }

      await faq.incrementLikeCount();

      res.json({
        success: true,
        message: '点赞成功',
        data: {
          likeCount: faq.likeCount + 1
        }
      });

    } catch (error) {
      logger.error('点赞FAQ失败:', error);

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
   * 踩FAQ
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async dislikeFAQ(req, res) {
    try {
      const { id } = req.params;
      validateUUID(id, 'FAQ ID');

      const faq = await FAQ.findByPk(id);
      if (!faq) {
        return res.status(404).json({
          success: false,
          message: 'FAQ不存在'
        });
      }

      await faq.incrementDislikeCount();

      res.json({
        success: true,
        message: '反馈已记录',
        data: {
          dislikeCount: faq.dislikeCount + 1
        }
      });

    } catch (error) {
      logger.error('踩FAQ失败:', error);

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
   * 切换FAQ状态
   * @param {Object} req - 请求对象
   * @param {Object} res - 响应对象
   */
  async toggleFAQStatus(req, res) {
    try {
      const { id } = req.params;
      validateUUID(id, 'FAQ ID');

      const faq = await FAQ.findByPk(id);
      if (!faq) {
        return res.status(404).json({
          success: false,
          message: 'FAQ不存在'
        });
      }

      await faq.toggleStatus();

      logger.info(`用户 ${req.user.id} 切换了FAQ ${id} 的状态为: ${faq.status}`);

      res.json({
        success: true,
        message: '状态切换成功',
        data: {
          status: faq.status
        }
      });

    } catch (error) {
      logger.error('切换FAQ状态失败:', error);

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

module.exports = new FAQController(); 