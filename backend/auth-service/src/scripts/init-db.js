#!/usr/bin/env node

require('dotenv').config();
const { initializeDatabase } = require('../models');

const main = async () => {
  try {
    console.log('🚀 开始初始化认证服务数据库...');
    
    // 从命令行参数获取选项
    const args = process.argv.slice(2);
    const force = args.includes('--force');
    const alter = args.includes('--alter');
    
    const options = {
      force,  // 是否强制重建表（慎用！）
      alter,  // 是否自动调整表结构
    };
    
    if (force) {
      console.log('⚠️  警告: 使用了 --force 参数，将删除并重建所有表！');
      console.log('⏳ 3秒后开始执行...');
      await new Promise(resolve => setTimeout(resolve, 3000));
    }
    
    await initializeDatabase(options);
    
    console.log('🎉 认证服务数据库初始化完成！');
    console.log('');
    console.log('📋 后续步骤:');
    console.log('1. 启动认证服务: npm run dev');
    console.log('2. 测试健康检查: curl http://localhost:3001/health');
    console.log('3. 查看API文档: http://localhost:3001/api');
    
  } catch (error) {
    console.error('❌ 数据库初始化失败:', error);
    process.exit(1);
  }
};

// 运行脚本
if (require.main === module) {
  main();
}

module.exports = { main }; 