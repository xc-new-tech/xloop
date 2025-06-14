const { sequelize } = require('../config/database');

// 直接导入模型
const User = require('./User');
const UserSession = require('./UserSession');

// 定义模型关系
const defineAssociations = () => {
  // User 和 UserSession 的关系
  User.hasMany(UserSession, {
    foreignKey: 'user_id',
    as: 'sessions',
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE'
  });

  UserSession.belongsTo(User, {
    foreignKey: 'user_id',
    as: 'user',
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE'
  });
};

// 同步数据库（开发环境）
const syncDatabase = async (options = {}) => {
  try {
    console.log('🔄 开始同步数据库...');
    
    // 默认配置
    const syncOptions = {
      force: false, // 生产环境应该设为false
      alter: false, // 生产环境应该设为false
      logging: process.env.NODE_ENV === 'development' ? console.log : false,
      ...options
    };

    await sequelize.sync(syncOptions);
    console.log('✅ 数据库同步完成');
    
    return true;
  } catch (error) {
    console.error('❌ 数据库同步失败:', error);
    throw error;
  }
};

// 创建初始管理员用户（如果不存在）
const createDefaultAdmin = async () => {
  try {
    const adminExists = await User.findOne({
      where: { role: 'admin' }
    });

    if (!adminExists) {
      const hashedPassword = await User.hashPassword(
        process.env.DEFAULT_ADMIN_PASSWORD || 'admin123456'
      );

      const admin = await User.create({
        username: 'admin',
        email: process.env.DEFAULT_ADMIN_EMAIL || 'admin@xloop.local',
        password_hash: hashedPassword,
        first_name: 'System',
        last_name: 'Administrator',
        role: 'admin',
        status: 'active',
        email_verified: true
      });

      console.log('✅ 默认管理员账户创建成功:', admin.email);
      return admin;
    } else {
      console.log('ℹ️  管理员账户已存在，跳过创建');
      return adminExists;
    }
  } catch (error) {
    console.error('❌ 创建默认管理员失败:', error);
    throw error;
  }
};

// 初始化数据库
const initializeDatabase = async (options = {}) => {
  try {
    console.log('🚀 开始初始化数据库...');
    
    // 测试连接
    await sequelize.authenticate();
    console.log('✅ 数据库连接测试成功');
    
    // 定义关系
    defineAssociations();
    
    // 同步模型
    await syncDatabase(options);
    
    // 创建默认管理员（仅在开发环境）
    if (process.env.NODE_ENV === 'development' || process.env.CREATE_DEFAULT_ADMIN === 'true') {
      await createDefaultAdmin();
    }
    
    console.log('🎉 数据库初始化完成');
    return true;
  } catch (error) {
    console.error('❌ 数据库初始化失败:', error);
    throw error;
  }
};

// 延迟初始化关系（只在需要时调用）
let associationsInitialized = false;
const ensureAssociations = () => {
  if (!associationsInitialized) {
    defineAssociations();
    associationsInitialized = true;
  }
};

module.exports = {
  sequelize,
  User,
  UserSession,
  defineAssociations,
  syncDatabase,
  createDefaultAdmin,
  initializeDatabase,
  ensureAssociations,
  
  // 导出所有模型（便于其他地方导入）
  models: {
    User,
    UserSession
  }
}; 