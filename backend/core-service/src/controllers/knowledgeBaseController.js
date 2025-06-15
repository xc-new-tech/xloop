const KnowledgeBase = require('../models/KnowledgeBase');
const { Op } = require('sequelize');
const Joi = require('joi');

// 验证模式
const createKnowledgeBaseSchema = Joi.object({
  name: Joi.string().min(1).max(255).required().messages({
    'string.empty': '知识库名称不能为空',
    'string.max': '知识库名称不能超过255个字符',
    'any.required': '知识库名称是必填项'
  }),
  description: Joi.string().max(1000).allow('').optional().messages({
    'string.max': '知识库描述不能超过1000个字符'
  }),
  type: Joi.string().valid('personal', 'team', 'public').default('personal').messages({
    'any.only': '知识库类型必须是personal、team或public'
  }),
  tags: Joi.array().items(Joi.string().max(50)).max(20).default([]).messages({
    'array.max': '标签数量不能超过20个',
    'string.max': '单个标签不能超过50个字符'
  }),
  settings: Joi.object().default({}),
  indexing_enabled: Joi.boolean().default(true),
  search_enabled: Joi.boolean().default(true),
  ai_enabled: Joi.boolean().default(true)
});

const updateKnowledgeBaseSchema = Joi.object({
  name: Joi.string().min(1).max(255).optional().messages({
    'string.empty': '知识库名称不能为空',
    'string.max': '知识库名称不能超过255个字符'
  }),
  description: Joi.string().max(1000).allow('').optional().messages({
    'string.max': '知识库描述不能超过1000个字符'
  }),
  type: Joi.string().valid('personal', 'team', 'public').optional().messages({
    'any.only': '知识库类型必须是personal、team或public'
  }),
  status: Joi.string().valid('active', 'archived', 'disabled').optional().messages({
    'any.only': '知识库状态必须是active、archived或disabled'
  }),
  tags: Joi.array().items(Joi.string().max(50)).max(20).optional().messages({
    'array.max': '标签数量不能超过20个',
    'string.max': '单个标签不能超过50个字符'
  }),
  settings: Joi.object().optional(),
  indexing_enabled: Joi.boolean().optional(),
  search_enabled: Joi.boolean().optional(),
  ai_enabled: Joi.boolean().optional()
});

const querySchema = Joi.object({
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
  search: Joi.string().max(255).optional(),
  type: Joi.string().valid('personal', 'team', 'public').optional(),
  status: Joi.string().valid('active', 'archived', 'disabled').optional(),
  tags: Joi.alternatives().try(
    Joi.string(),
    Joi.array().items(Joi.string())
  ).optional(),
  sort: Joi.string().valid('name', 'created_at', 'updated_at', 'last_activity', 'document_count').default('last_activity'),
  order: Joi.string().valid('ASC', 'DESC').default('DESC')
});

/**
 * 创建知识库
 */
const createKnowledgeBase = async (req, res) => {
  try {
    // 验证请求数据
    const { error, value } = createKnowledgeBaseSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        error: '请求数据验证失败',
        details: error.details.map(d => d.message)
      });
    }

    // TODO: 从JWT token中获取用户ID，这里暂时使用模拟UUID
    const userId = req.user?.id || '00000000-0000-0000-0000-000000000001';

    // 创建知识库
    const knowledgeBase = await KnowledgeBase.create({
      ...value,
      owner_id: userId,
      created_by: userId,
      updated_by: userId
    });

    res.status(201).json({
      success: true,
      message: '知识库创建成功',
      data: knowledgeBase.toJSON()
    });
  } catch (error) {
    console.error('创建知识库失败:', error);
    res.status(500).json({
      success: false,
      error: '创建知识库失败',
      message: error.message
    });
  }
};

/**
 * 获取知识库列表
 */
const getKnowledgeBases = async (req, res) => {
  try {
    // 验证查询参数
    const { error, value } = querySchema.validate(req.query);
    if (error) {
      return res.status(400).json({
        success: false,
        error: '查询参数验证失败',
        details: error.details.map(d => d.message)
      });
    }

    const { page, limit, search, type, status, tags, sort, order } = value;
    const offset = (page - 1) * limit;

    // 构建查询条件
    const whereConditions = {};

    // TODO: 根据用户权限过滤数据，这里暂时返回所有数据
    // if (req.user) {
    //   whereConditions[Op.or] = [
    //     { owner_id: req.user.id },
    //     { type: 'public' }
    //   ];
    // } else {
    //   whereConditions.type = 'public';
    // }

    if (search) {
      whereConditions[Op.or] = [
        { name: { [Op.iLike]: `%${search}%` } },
        { description: { [Op.iLike]: `%${search}%` } }
      ];
    }

    if (type) {
      whereConditions.type = type;
    }

    if (status) {
      whereConditions.status = status;
    }

    if (tags) {
      const tagArray = Array.isArray(tags) ? tags : [tags];
      whereConditions.tags = {
        [Op.overlap]: tagArray
      };
    }

    // 执行查询
    const { count, rows } = await KnowledgeBase.findAndCountAll({
      where: whereConditions,
      order: [[sort, order]],
      limit,
      offset,
      attributes: [
        'id', 'name', 'description', 'type', 'status', 'tags',
        'indexing_enabled', 'search_enabled', 'ai_enabled',
        'document_count', 'total_size', 'last_activity',
        'created_at', 'updated_at'
      ]
    });

    res.json({
      success: true,
      data: {
        knowledgeBases: rows.map(kb => kb.toJSON()),
        pagination: {
          current_page: page,
          total_pages: Math.ceil(count / limit),
          total_count: count,
          per_page: limit,
          has_next: page < Math.ceil(count / limit),
          has_prev: page > 1
        }
      }
    });
  } catch (error) {
    console.error('获取知识库列表失败:', error);
    res.status(500).json({
      success: false,
      error: '获取知识库列表失败',
      message: error.message
    });
  }
};

/**
 * 获取单个知识库详情
 */
const getKnowledgeBase = async (req, res) => {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({
        success: false,
        error: '知识库ID是必填项'
      });
    }

    const knowledgeBase = await KnowledgeBase.findByPk(id);

    if (!knowledgeBase) {
      return res.status(404).json({
        success: false,
        error: '知识库不存在'
      });
    }

    // TODO: 检查用户权限
    // if (knowledgeBase.type !== 'public' && knowledgeBase.owner_id !== req.user?.id) {
    //   return res.status(403).json({
    //     success: false,
    //     error: '没有访问权限'
    //   });
    // }

    res.json({
      success: true,
      data: knowledgeBase.toJSON()
    });
  } catch (error) {
    console.error('获取知识库详情失败:', error);
    res.status(500).json({
      success: false,
      error: '获取知识库详情失败',
      message: error.message
    });
  }
};

/**
 * 更新知识库
 */
const updateKnowledgeBase = async (req, res) => {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({
        success: false,
        error: '知识库ID是必填项'
      });
    }

    // 验证请求数据
    const { error, value } = updateKnowledgeBaseSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        error: '请求数据验证失败',
        details: error.details.map(d => d.message)
      });
    }

    // 查找知识库
    const knowledgeBase = await KnowledgeBase.findByPk(id);

    if (!knowledgeBase) {
      return res.status(404).json({
        success: false,
        error: '知识库不存在'
      });
    }

    // TODO: 检查用户权限
    // if (knowledgeBase.owner_id !== req.user?.id) {
    //   return res.status(403).json({
    //     success: false,
    //     error: '没有修改权限'
    //   });
    // }

    // 更新知识库
    const userId = req.user?.id || 'mock-user-id';
    await knowledgeBase.update({
      ...value,
      updated_by: userId
    });

    res.json({
      success: true,
      message: '知识库更新成功',
      data: knowledgeBase.toJSON()
    });
  } catch (error) {
    console.error('更新知识库失败:', error);
    res.status(500).json({
      success: false,
      error: '更新知识库失败',
      message: error.message
    });
  }
};

/**
 * 删除知识库
 */
const deleteKnowledgeBase = async (req, res) => {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({
        success: false,
        error: '知识库ID是必填项'
      });
    }

    // 查找知识库
    const knowledgeBase = await KnowledgeBase.findByPk(id);

    if (!knowledgeBase) {
      return res.status(404).json({
        success: false,
        error: '知识库不存在'
      });
    }

    // TODO: 检查用户权限
    // if (knowledgeBase.owner_id !== req.user?.id) {
    //   return res.status(403).json({
    //     success: false,
    //     error: '没有删除权限'
    //   });
    // }

    // 删除知识库（这会级联删除相关的文档和FAQ）
    await knowledgeBase.destroy();

    res.json({
      success: true,
      message: '知识库删除成功'
    });
  } catch (error) {
    console.error('删除知识库失败:', error);
    res.status(500).json({
      success: false,
      error: '删除知识库失败',
      message: error.message
    });
  }
};

/**
 * 获取用户的知识库
 */
const getMyKnowledgeBases = async (req, res) => {
  try {
    // TODO: 从JWT token中获取用户ID
    const userId = req.user?.id || 'mock-user-id';

    // 验证查询参数
    const { error, value } = querySchema.validate(req.query);
    if (error) {
      return res.status(400).json({
        success: false,
        error: '查询参数验证失败',
        details: error.details.map(d => d.message)
      });
    }

    const { page, limit, search, status, tags, sort, order } = value;
    const offset = (page - 1) * limit;

    // 构建查询条件
    const whereConditions = { owner_id: userId };

    if (search) {
      whereConditions[Op.or] = [
        { name: { [Op.iLike]: `%${search}%` } },
        { description: { [Op.iLike]: `%${search}%` } }
      ];
    }

    if (status) {
      whereConditions.status = status;
    }

    if (tags) {
      const tagArray = Array.isArray(tags) ? tags : [tags];
      whereConditions.tags = {
        [Op.overlap]: tagArray
      };
    }

    // 执行查询
    const { count, rows } = await KnowledgeBase.findAndCountAll({
      where: whereConditions,
      order: [[sort, order]],
      limit,
      offset
    });

    res.json({
      success: true,
      data: {
        knowledgeBases: rows.map(kb => kb.toJSON()),
        pagination: {
          current_page: page,
          total_pages: Math.ceil(count / limit),
          total_count: count,
          per_page: limit,
          has_next: page < Math.ceil(count / limit),
          has_prev: page > 1
        }
      }
    });
  } catch (error) {
    console.error('获取我的知识库失败:', error);
    res.status(500).json({
      success: false,
      error: '获取我的知识库失败',
      message: error.message
    });
  }
};

/**
 * 获取公开知识库
 */
const getPublicKnowledgeBases = async (req, res) => {
  try {
    // 验证查询参数
    const { error, value } = querySchema.validate(req.query);
    if (error) {
      return res.status(400).json({
        success: false,
        error: '查询参数验证失败',
        details: error.details.map(d => d.message)
      });
    }

    const { page, limit, search, tags, sort, order } = value;
    const offset = (page - 1) * limit;

    // 构建查询条件
    const whereConditions = { 
      type: 'public',
      status: 'active'
    };

    if (search) {
      whereConditions[Op.or] = [
        { name: { [Op.iLike]: `%${search}%` } },
        { description: { [Op.iLike]: `%${search}%` } }
      ];
    }

    if (tags) {
      const tagArray = Array.isArray(tags) ? tags : [tags];
      whereConditions.tags = {
        [Op.overlap]: tagArray
      };
    }

    // 执行查询
    const { count, rows } = await KnowledgeBase.findAndCountAll({
      where: whereConditions,
      order: [[sort, order]],
      limit,
      offset,
      attributes: [
        'id', 'name', 'description', 'tags',
        'document_count', 'last_activity',
        'created_at'
      ]
    });

    res.json({
      success: true,
      data: {
        knowledgeBases: rows.map(kb => kb.toJSON()),
        pagination: {
          current_page: page,
          total_pages: Math.ceil(count / limit),
          total_count: count,
          per_page: limit,
          has_next: page < Math.ceil(count / limit),
          has_prev: page > 1
        }
      }
    });
  } catch (error) {
    console.error('获取公开知识库失败:', error);
    res.status(500).json({
      success: false,
      error: '获取公开知识库失败',
      message: error.message
    });
  }
};

module.exports = {
  createKnowledgeBase,
  getKnowledgeBases,
  getKnowledgeBase,
  updateKnowledgeBase,
  deleteKnowledgeBase,
  getMyKnowledgeBases,
  getPublicKnowledgeBases
}; 