const OpenAI = require('openai');
const { Pool } = require('pg');
const Redis = require('redis');

/**
 * 向量数据库服务
 * 提供文本向量化和语义搜索功能
 */
class VectorService {
  constructor() {
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY
    });
    
    this.db = new Pool({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      database: process.env.DB_NAME,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
    });

    this.redis = Redis.createClient({
      host: process.env.REDIS_HOST,
      port: process.env.REDIS_PORT,
    });

    this.redis.connect();
    this.initializeVectorExtension();
  }

  /**
   * 初始化PostgreSQL向量扩展
   */
  async initializeVectorExtension() {
    try {
      await this.db.query('CREATE EXTENSION IF NOT EXISTS vector');
      await this.createVectorTables();
      console.log('Vector extension initialized successfully');
    } catch (error) {
      console.error('Failed to initialize vector extension:', error);
    }
  }

  /**
   * 创建向量存储表
   */
  async createVectorTables() {
    const queries = [
      `CREATE TABLE IF NOT EXISTS document_vectors (
        id UUID PRIMARY KEY,
        document_id UUID NOT NULL,
        content TEXT NOT NULL,
        vector vector(1536),
        metadata JSONB DEFAULT '{}',
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )`,
      
      `CREATE TABLE IF NOT EXISTS faq_vectors (
        id UUID PRIMARY KEY,
        faq_id UUID NOT NULL,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        combined_vector vector(1536),
        question_vector vector(1536),
        answer_vector vector(1536),
        metadata JSONB DEFAULT '{}',
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )`,

      `CREATE INDEX IF NOT EXISTS document_vectors_vector_idx 
       ON document_vectors USING ivfflat (vector vector_cosine_ops) WITH (lists = 100)`,
       
      `CREATE INDEX IF NOT EXISTS faq_vectors_combined_idx 
       ON faq_vectors USING ivfflat (combined_vector vector_cosine_ops) WITH (lists = 100)`,
       
      `CREATE INDEX IF NOT EXISTS faq_vectors_question_idx 
       ON faq_vectors USING ivfflat (question_vector vector_cosine_ops) WITH (lists = 100)`,
    ];

    for (const query of queries) {
      await this.db.query(query);
    }
  }

  /**
   * 生成文本向量
   * @param {string} text - 输入文本
   * @param {string} model - 模型名称，默认使用text-embedding-3-small
   * @returns {Array} 向量数组
   */
  async generateEmbedding(text, model = 'text-embedding-3-small') {
    try {
      // 检查缓存
      const cacheKey = `embedding:${Buffer.from(text).toString('base64')}`;
      const cached = await this.redis.get(cacheKey);
      if (cached) {
        return JSON.parse(cached);
      }

      // 生成新的向量
      const response = await this.openai.embeddings.create({
        model,
        input: text,
        encoding_format: 'float'
      });

      const embedding = response.data[0].embedding;
      
      // 缓存结果（24小时）
      await this.redis.setex(cacheKey, 86400, JSON.stringify(embedding));
      
      return embedding;
    } catch (error) {
      console.error('Failed to generate embedding:', error);
      throw new Error('向量生成失败');
    }
  }

  /**
   * 批量生成文本向量
   * @param {Array} texts - 文本数组
   * @returns {Array} 向量数组
   */
  async batchGenerateEmbeddings(texts) {
    try {
      const response = await this.openai.embeddings.create({
        model: 'text-embedding-3-small',
        input: texts,
        encoding_format: 'float'
      });

      return response.data.map(item => item.embedding);
    } catch (error) {
      console.error('Failed to batch generate embeddings:', error);
      throw new Error('批量向量生成失败');
    }
  }

  /**
   * 存储文档向量
   * @param {string} documentId - 文档ID
   * @param {string} content - 文档内容
   * @param {Object} metadata - 元数据
   */
  async storeDocumentVector(documentId, content, metadata = {}) {
    try {
      const vector = await this.generateEmbedding(content);
      
      const query = `
        INSERT INTO document_vectors (id, document_id, content, vector, metadata)
        VALUES (gen_random_uuid(), $1, $2, $3, $4)
        ON CONFLICT (document_id) 
        DO UPDATE SET 
          content = EXCLUDED.content,
          vector = EXCLUDED.vector,
          metadata = EXCLUDED.metadata,
          updated_at = CURRENT_TIMESTAMP
      `;
      
      await this.db.query(query, [documentId, content, `[${vector.join(',')}]`, metadata]);
      
      console.log(`Document vector stored for ID: ${documentId}`);
    } catch (error) {
      console.error('Failed to store document vector:', error);
      throw error;
    }
  }

  /**
   * 存储FAQ向量
   * @param {string} faqId - FAQ ID
   * @param {string} question - 问题
   * @param {string} answer - 答案
   * @param {Object} metadata - 元数据
   */
  async storeFaqVector(faqId, question, answer, metadata = {}) {
    try {
      const [questionVector, answerVector] = await this.batchGenerateEmbeddings([question, answer]);
      
      // 组合向量：问题和答案的加权平均
      const combinedVector = questionVector.map((val, idx) => 
        (val * 0.7 + answerVector[idx] * 0.3)
      );
      
      const query = `
        INSERT INTO faq_vectors (id, faq_id, question, answer, combined_vector, question_vector, answer_vector, metadata)
        VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, $6, $7)
        ON CONFLICT (faq_id) 
        DO UPDATE SET 
          question = EXCLUDED.question,
          answer = EXCLUDED.answer,
          combined_vector = EXCLUDED.combined_vector,
          question_vector = EXCLUDED.question_vector,
          answer_vector = EXCLUDED.answer_vector,
          metadata = EXCLUDED.metadata,
          updated_at = CURRENT_TIMESTAMP
      `;
      
      await this.db.query(query, [
        faqId, 
        question, 
        answer,
        `[${combinedVector.join(',')}]`,
        `[${questionVector.join(',')}]`,
        `[${answerVector.join(',')}]`,
        metadata
      ]);
      
      console.log(`FAQ vector stored for ID: ${faqId}`);
    } catch (error) {
      console.error('Failed to store FAQ vector:', error);
      throw error;
    }
  }

  /**
   * 语义搜索文档
   * @param {string} query - 搜索查询
   * @param {Object} options - 搜索选项
   * @returns {Array} 搜索结果
   */
  async searchDocuments(query, options = {}) {
    try {
      const {
        limit = 10,
        threshold = 0.7,
        knowledgeBaseId = null,
        includeMetadata = true
      } = options;

      const queryVector = await this.generateEmbedding(query);
      
      let sql = `
        SELECT 
          dv.document_id,
          dv.content,
          dv.metadata,
          d.title,
          d.file_name,
          d.knowledge_base_id,
          1 - (dv.vector <=> $1) as similarity
        FROM document_vectors dv
        JOIN documents d ON dv.document_id = d.id
        WHERE 1 - (dv.vector <=> $1) >= $2
      `;
      
      const params = [`[${queryVector.join(',')}]`, threshold];
      let paramIndex = 3;
      
      if (knowledgeBaseId) {
        sql += ` AND d.knowledge_base_id = $${paramIndex}`;
        params.push(knowledgeBaseId);
        paramIndex++;
      }
      
      sql += ` ORDER BY similarity DESC LIMIT $${paramIndex}`;
      params.push(limit);
      
      const result = await this.db.query(sql, params);
      
      return result.rows.map(row => ({
        documentId: row.document_id,
        title: row.title,
        fileName: row.file_name,
        content: row.content,
        similarity: parseFloat(row.similarity),
        metadata: includeMetadata ? row.metadata : undefined,
        knowledgeBaseId: row.knowledge_base_id
      }));
    } catch (error) {
      console.error('Failed to search documents:', error);
      throw error;
    }
  }

  /**
   * 语义搜索FAQ
   * @param {string} query - 搜索查询
   * @param {Object} options - 搜索选项
   * @returns {Array} 搜索结果
   */
  async searchFaqs(query, options = {}) {
    try {
      const {
        limit = 10,
        threshold = 0.7,
        knowledgeBaseId = null,
        searchType = 'combined', // 'combined', 'question', 'answer'
        includeMetadata = true
      } = options;

      const queryVector = await this.generateEmbedding(query);
      
      let vectorColumn;
      switch (searchType) {
        case 'question':
          vectorColumn = 'question_vector';
          break;
        case 'answer':
          vectorColumn = 'answer_vector';
          break;
        default:
          vectorColumn = 'combined_vector';
      }
      
      let sql = `
        SELECT 
          fv.faq_id,
          fv.question,
          fv.answer,
          fv.metadata,
          f.category,
          f.tags,
          f.priority,
          f.status,
          f.knowledge_base_id,
          1 - (fv.${vectorColumn} <=> $1) as similarity
        FROM faq_vectors fv
        JOIN faqs f ON fv.faq_id = f.id
        WHERE 1 - (fv.${vectorColumn} <=> $1) >= $2
          AND f.status = 'published'
      `;
      
      const params = [`[${queryVector.join(',')}]`, threshold];
      let paramIndex = 3;
      
      if (knowledgeBaseId) {
        sql += ` AND f.knowledge_base_id = $${paramIndex}`;
        params.push(knowledgeBaseId);
        paramIndex++;
      }
      
      sql += ` ORDER BY similarity DESC LIMIT $${paramIndex}`;
      params.push(limit);
      
      const result = await this.db.query(sql, params);
      
      return result.rows.map(row => ({
        faqId: row.faq_id,
        question: row.question,
        answer: row.answer,
        category: row.category,
        tags: row.tags,
        priority: row.priority,
        similarity: parseFloat(row.similarity),
        metadata: includeMetadata ? row.metadata : undefined,
        knowledgeBaseId: row.knowledge_base_id
      }));
    } catch (error) {
      console.error('Failed to search FAQs:', error);
      throw error;
    }
  }

  /**
   * 混合搜索（文档+FAQ）
   * @param {string} query - 搜索查询
   * @param {Object} options - 搜索选项
   * @returns {Object} 包含文档和FAQ结果的对象
   */
  async hybridSearch(query, options = {}) {
    try {
      const {
        documentLimit = 5,
        faqLimit = 5,
        threshold = 0.7,
        knowledgeBaseId = null
      } = options;

      const [documentResults, faqResults] = await Promise.all([
        this.searchDocuments(query, {
          limit: documentLimit,
          threshold,
          knowledgeBaseId
        }),
        this.searchFaqs(query, {
          limit: faqLimit,
          threshold,
          knowledgeBaseId
        })
      ]);

      // 按相似度混合排序
      const allResults = [
        ...documentResults.map(doc => ({ ...doc, type: 'document' })),
        ...faqResults.map(faq => ({ ...faq, type: 'faq' }))
      ].sort((a, b) => b.similarity - a.similarity);

      return {
        documents: documentResults,
        faqs: faqResults,
        mixed: allResults.slice(0, documentLimit + faqLimit),
        total: allResults.length
      };
    } catch (error) {
      console.error('Failed to perform hybrid search:', error);
      throw error;
    }
  }

  /**
   * 相关内容推荐
   * @param {string} contentId - 内容ID
   * @param {string} contentType - 内容类型（'document'或'faq'）
   * @param {Object} options - 推荐选项
   * @returns {Array} 推荐结果
   */
  async getRecommendations(contentId, contentType, options = {}) {
    try {
      const { limit = 5, threshold = 0.6 } = options;
      
      let sourceVector;
      if (contentType === 'document') {
        const result = await this.db.query(
          'SELECT vector FROM document_vectors WHERE document_id = $1',
          [contentId]
        );
        sourceVector = result.rows[0]?.vector;
      } else if (contentType === 'faq') {
        const result = await this.db.query(
          'SELECT combined_vector FROM faq_vectors WHERE faq_id = $1',
          [contentId]
        );
        sourceVector = result.rows[0]?.combined_vector;
      }

      if (!sourceVector) {
        return [];
      }

      // 搜索相似内容，排除自身
      const [docResults, faqResults] = await Promise.all([
        this.db.query(`
          SELECT 
            dv.document_id,
            d.title,
            1 - (dv.vector <=> $1) as similarity
          FROM document_vectors dv
          JOIN documents d ON dv.document_id = d.id
          WHERE dv.document_id != $2
            AND 1 - (dv.vector <=> $1) >= $3
          ORDER BY similarity DESC
          LIMIT $4
        `, [sourceVector, contentType === 'document' ? contentId : null, threshold, limit]),
        
        this.db.query(`
          SELECT 
            fv.faq_id,
            fv.question,
            1 - (fv.combined_vector <=> $1) as similarity
          FROM faq_vectors fv
          JOIN faqs f ON fv.faq_id = f.id
          WHERE fv.faq_id != $2
            AND f.status = 'published'
            AND 1 - (fv.combined_vector <=> $1) >= $3
          ORDER BY similarity DESC
          LIMIT $4
        `, [sourceVector, contentType === 'faq' ? contentId : null, threshold, limit])
      ]);

      return {
        documents: docResults.rows,
        faqs: faqResults.rows
      };
    } catch (error) {
      console.error('Failed to get recommendations:', error);
      throw error;
    }
  }

  /**
   * 获取搜索统计信息
   * @returns {Object} 统计信息
   */
  async getSearchStats() {
    try {
      const stats = await Promise.all([
        this.db.query('SELECT COUNT(*) as document_count FROM document_vectors'),
        this.db.query('SELECT COUNT(*) as faq_count FROM faq_vectors'),
        this.redis.info('memory')
      ]);

      return {
        documentVectors: parseInt(stats[0].rows[0].document_count),
        faqVectors: parseInt(stats[1].rows[0].faq_count),
        cacheInfo: stats[2],
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('Failed to get search stats:', error);
      throw error;
    }
  }

  /**
   * 清理缓存
   * @param {string} pattern - 清理模式，默认清理所有embedding缓存
   */
  async clearCache(pattern = 'embedding:*') {
    try {
      const keys = await this.redis.keys(pattern);
      if (keys.length > 0) {
        await this.redis.del(keys);
      }
      console.log(`Cleared ${keys.length} cache keys`);
    } catch (error) {
      console.error('Failed to clear cache:', error);
      throw error;
    }
  }

  /**
   * 关闭连接
   */
  async close() {
    try {
      await this.db.end();
      await this.redis.disconnect();
      console.log('Vector service connections closed');
    } catch (error) {
      console.error('Failed to close connections:', error);
    }
  }
}

module.exports = VectorService; 