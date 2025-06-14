const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

// 导入配置和模型
const { testConnection: testDbConnection, healthCheck: dbHealthCheck } = require('./config/database');
const { connectRedis, healthCheck: redisHealthCheck } = require('./config/redis');
const { initializeDatabase, getDatabaseStats } = require('./models');

const app = express();
const PORT = process.env.PORT || 3002;

// 中间件配置
app.use(helmet());
app.use(compression());
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true,
}));

// 速率限制
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW) || 15 * 60 * 1000, // 15分钟
  max: parseInt(process.env.RATE_LIMIT_MAX) || 100, // 限制每个IP 100次请求
  message: {
    error: '请求过于频繁，请稍后再试',
    code: 'RATE_LIMIT_EXCEEDED'
  }
});
app.use('/api/', limiter);

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// 导入路由
const apiRoutes = require('./routes');

// 注册API路由
app.use('/api', apiRoutes);

// 健康检查端点
app.get('/health', async (req, res) => {
  try {
    const [dbHealth, redisHealth] = await Promise.all([
      dbHealthCheck(),
      redisHealthCheck(),
    ]);

    const health = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      service: 'xloop-core-service',
      version: '1.0.0',
      checks: {
        database: dbHealth,
        redis: redisHealth,
      }
    };

    // 如果任何服务不健康，返回503状态
    const isHealthy = dbHealth.status === 'healthy' && redisHealth.status === 'healthy';
    
    res.status(isHealthy ? 200 : 503).json(health);
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      service: 'xloop-core-service',
      error: error.message,
    });
  }
});

// 数据库统计端点
app.get('/api/stats', async (req, res) => {
  try {
    const stats = await getDatabaseStats();
    res.json({
      success: true,
      data: stats,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('获取统计信息失败:', error);
    res.status(500).json({
      success: false,
      error: '获取统计信息失败',
      message: error.message,
    });
  }
});

// 基础信息端点
app.get('/api/info', (req, res) => {
  res.json({
    service: 'XLoop Core Service',
    description: 'XLoop知识智能平台核心服务',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString(),
    endpoints: {
      health: '/health',
      stats: '/api/stats',
      info: '/api/info',
    }
  });
});

// 404处理
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    error: '接口不存在',
    path: req.originalUrl,
    method: req.method,
  });
});

// 全局错误处理
app.use((error, req, res, next) => {
  console.error('全局错误:', error);
  
  res.status(error.status || 500).json({
    success: false,
    error: process.env.NODE_ENV === 'production' ? '服务器内部错误' : error.message,
    ...(process.env.NODE_ENV !== 'production' && { stack: error.stack }),
  });
});

// 启动服务器
const startServer = async () => {
  try {
    console.log('🚀 启动XLoop核心服务...');
    
    // 测试数据库连接
    await testDbConnection();
    
    // 连接Redis
    try {
      await connectRedis();
    } catch (error) {
      console.warn('⚠️  Redis连接失败，将在无缓存模式下运行:', error.message);
    }
    
    // 初始化数据库
    await initializeDatabase();
    
    // 启动HTTP服务器
    const server = app.listen(PORT, () => {
      console.log(`✅ XLoop核心服务已启动`);
      console.log(`   - 端口: ${PORT}`);
      console.log(`   - 环境: ${process.env.NODE_ENV || 'development'}`);
      console.log(`   - 健康检查: http://localhost:${PORT}/health`);
      console.log(`   - API信息: http://localhost:${PORT}/api/info`);
      console.log(`   - 数据统计: http://localhost:${PORT}/api/stats`);
    });

    // 优雅关闭处理
    const gracefulShutdown = (signal) => {
      console.log(`\n📡 收到${signal}信号，开始优雅关闭...`);
      
      server.close(async () => {
        console.log('🔌 HTTP服务器已关闭');
        
        try {
          // 关闭数据库连接
          const { sequelize } = require('./config/database');
          await sequelize.close();
          console.log('🔌 数据库连接已关闭');
          
          // 关闭Redis连接
          const { client } = require('./config/redis');
          if (client.isOpen) {
            await client.quit();
            console.log('🔌 Redis连接已关闭');
          }
          
          console.log('✅ 服务已完全关闭');
          process.exit(0);
        } catch (error) {
          console.error('❌ 关闭过程中出现错误:', error);
          process.exit(1);
        }
      });
    };

    // 监听关闭信号
    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));
    
    return server;
  } catch (error) {
    console.error('❌ 启动服务失败:', error);
    process.exit(1);
  }
};

// 如果直接运行此文件，则启动服务器
if (require.main === module) {
  startServer();
}

module.exports = { app, startServer }; 