const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const { testConnection } = require('./config/database');
const { configurePassport } = require('./config/passport');
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/user');

// 创建Express应用
const app = express();

// 安全中间件
app.use(helmet());

// CORS配置
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || [
    'http://localhost:3000',  // Flutter Web开发服务器
    'http://localhost:8080',  // 可能的其他前端端口
  ],
  credentials: true,
}));

// 请求限制（测试环境中禁用）
if (process.env.NODE_ENV !== 'test') {
  const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15分钟
    max: 100, // 每个IP最多100个请求
    message: {
      error: '请求过于频繁，请稍后再试',
      retryAfter: 15 * 60,
    },
  });
  app.use('/api/', limiter);

  // 更严格的认证请求限制
  const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15分钟
    max: 10, // 每个IP最多10个认证请求
    message: {
      error: '认证请求过于频繁，请稍后再试',
      retryAfter: 15 * 60,
    },
  });
  app.use('/api/auth/', authLimiter);
}

// 请求解析中间件
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// 配置Passport
configurePassport(app);

// 健康检查端点
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    service: 'xloop-auth-service',
    version: process.env.npm_package_version || '1.0.0',
  });
});

// API路由（稍后添加）
app.get('/api', (req, res) => {
  res.json({
    message: 'XLoop 认证服务 API',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      auth: '/api/auth',
    },
  });
});

// 认证路由
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);

// 404处理
app.use((req, res) => {
  res.status(404).json({
    error: '接口不存在',
    path: req.path,
    method: req.method,
  });
});

// 错误处理中间件
app.use((err, req, res, next) => {
  console.error('服务器错误:', err);
  
  // 开发环境显示详细错误信息
  const isDev = process.env.NODE_ENV === 'development';
  
  res.status(err.status || 500).json({
    error: isDev ? err.message : '服务器内部错误',
    ...(isDev && { stack: err.stack }),
  });
});

// 启动服务器
const PORT = process.env.PORT || 3001;

const startServer = async () => {
  try {
    // 测试数据库连接
    await testConnection();
    
    app.listen(PORT, () => {
      console.log(`🚀 XLoop认证服务启动成功`);
      console.log(`📍 服务地址: http://localhost:${PORT}`);
      console.log(`🌍 环境: ${process.env.NODE_ENV || 'development'}`);
      console.log(`📋 API文档: http://localhost:${PORT}/api`);
    });
  } catch (error) {
    console.error('❌ 服务启动失败:', error);
    process.exit(1);
  }
};

// 优雅关闭
process.on('SIGTERM', () => {
  console.log('📥 收到SIGTERM信号，正在关闭服务...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('📥 收到SIGINT信号，正在关闭服务...');
  process.exit(0);
});

if (require.main === module) {
  startServer();
}

module.exports = app; 