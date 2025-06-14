const redis = require('redis');
require('dotenv').config();

// Redis客户端配置
const redisConfig = {
  host: process.env.REDIS_HOST || 'localhost',
  port: process.env.REDIS_PORT || 6379,
  password: process.env.REDIS_PASSWORD || undefined,
  db: process.env.REDIS_DB || 0,
  retryDelayOnFailover: 100,
  enableReadyCheck: true,
  maxRetriesPerRequest: 3,
};

// 创建Redis客户端
const client = redis.createClient({
  url: `redis://${redisConfig.host}:${redisConfig.port}/${redisConfig.db}`,
  password: redisConfig.password,
  retry_strategy: (options) => {
    if (options.error && options.error.code === 'ECONNREFUSED') {
      console.error('❌ Redis服务器拒绝连接');
    }
    if (options.total_retry_time > 1000 * 60 * 60) {
      console.error('❌ Redis重试时间超过1小时，停止重试');
      return new Error('重试时间超限');
    }
    if (options.attempt > 10) {
      console.error('❌ Redis重试次数超过10次，停止重试');
      return undefined;
    }
    // 每次重试间隔递增
    return Math.min(options.attempt * 100, 3000);
  }
});

// Redis事件监听
client.on('connect', () => {
  console.log('🔄 Redis客户端正在连接...');
});

client.on('ready', () => {
  console.log('✅ Redis连接就绪');
});

client.on('error', (err) => {
  console.error('❌ Redis连接错误:', err);
});

client.on('end', () => {
  console.log('🔌 Redis连接已断开');
});

// 连接Redis
const connectRedis = async () => {
  try {
    await client.connect();
    console.log('✅ Redis连接成功');
    return true;
  } catch (error) {
    console.error('❌ Redis连接失败:', error);
    throw error;
  }
};

// Redis健康检查
const healthCheck = async () => {
  try {
    const start = Date.now();
    await client.ping();
    const duration = Date.now() - start;
    
    return {
      status: 'healthy',
      responseTime: `${duration}ms`,
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    return {
      status: 'unhealthy',
      error: error.message,
      timestamp: new Date().toISOString()
    };
  }
};

// 缓存操作工具类
class CacheManager {
  // 设置缓存
  static async set(key, value, ttl = 3600) {
    try {
      const serializedValue = JSON.stringify(value);
      if (ttl > 0) {
        await client.setEx(key, ttl, serializedValue);
      } else {
        await client.set(key, serializedValue);
      }
      return true;
    } catch (error) {
      console.error('❌ Redis设置失败:', error);
      return false;
    }
  }

  // 获取缓存
  static async get(key) {
    try {
      const value = await client.get(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      console.error('❌ Redis获取失败:', error);
      return null;
    }
  }

  // 删除缓存
  static async del(key) {
    try {
      await client.del(key);
      return true;
    } catch (error) {
      console.error('❌ Redis删除失败:', error);
      return false;
    }
  }

  // 检查键是否存在
  static async exists(key) {
    try {
      const result = await client.exists(key);
      return result === 1;
    } catch (error) {
      console.error('❌ Redis检查存在失败:', error);
      return false;
    }
  }

  // 设置过期时间
  static async expire(key, ttl) {
    try {
      await client.expire(key, ttl);
      return true;
    } catch (error) {
      console.error('❌ Redis设置过期时间失败:', error);
      return false;
    }
  }

  // 获取匹配的键
  static async keys(pattern) {
    try {
      return await client.keys(pattern);
    } catch (error) {
      console.error('❌ Redis获取键失败:', error);
      return [];
    }
  }

  // 清空所有缓存
  static async flushAll() {
    try {
      await client.flushAll();
      return true;
    } catch (error) {
      console.error('❌ Redis清空失败:', error);
      return false;
    }
  }
}

module.exports = {
  client,
  connectRedis,
  healthCheck,
  CacheManager,
}; 