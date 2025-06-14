# XLoop 知识智能平台

<div align="center">
  <img src="images/xloop-logo.png" alt="XLoop Logo" width="200" height="200" />
  
  **端到端的企业级知识智能管理平台**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.24.0-blue.svg)](https://flutter.dev/)
  [![Node.js](https://img.shields.io/badge/Node.js-18.x-green.svg)](https://nodejs.org/)
  [![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15.x-blue.svg)](https://postgresql.org/)
  [![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
</div>

## 📋 项目概述

XLoop 是一款端到端的知识智能平台，旨在帮助企业建立、管理并智能调用其知识库。平台核心功能包括知识上传、FAQ管理、语义召回优化和多端接入。

### 🎯 核心功能

- **📁 知识库管理**: 支持多种文件格式（CSV、PPT、PDF、MP3）的知识解析和归档
- **❓ FAQ 问答系统**: 智能问答编辑与召回策略调整
- **🔍 语义搜索**: 基于语义匹配的高效知识检索
- **👥 多端支持**: 客户端和工作端的统一用户管理
- **📊 数据分析**: 对话日志查询和知识调优分析

## 🏗️ 技术架构

### 前端 (Mobile App)
- **框架**: Flutter 3.24.0
- **状态管理**: BLoC Pattern
- **网络请求**: Dio + Retrofit
- **本地存储**: SharedPreferences + Hive
- **UI组件**: Material Design 3

### 后端 (Microservices)
- **认证服务**: Node.js + Express + JWT
- **核心服务**: Node.js + Express
- **数据库**: PostgreSQL 15.x
- **API文档**: 自动生成的OpenAPI规范

### 基础设施
- **容器化**: Docker + Docker Compose
- **版本控制**: Git + GitHub
- **CI/CD**: GitHub Actions (计划中)

## 📁 项目结构

```
xloop/
├── mobile/                 # Flutter移动应用
│   ├── lib/
│   │   ├── core/          # 核心功能和配置
│   │   ├── features/      # 功能模块
│   │   │   ├── auth/      # 认证模块
│   │   │   ├── chat/      # 聊天模块
│   │   │   └── knowledge/ # 知识库模块
│   │   └── shared/        # 共享组件
│   ├── test/              # 测试文件
│   └── pubspec.yaml       # Flutter依赖配置
├── backend/               # 后端服务
│   ├── auth-service/      # 认证服务
│   │   ├── src/
│   │   │   ├── controllers/
│   │   │   ├── models/
│   │   │   ├── routes/
│   │   │   └── utils/
│   │   └── package.json
│   ├── core-service/      # 核心业务服务
│   └── core/              # 共享核心模块
├── docs/                  # 项目文档
├── .taskmaster/           # 任务管理配置
└── README.md              # 项目说明文档
```

## 🚀 快速开始

### 环境要求

- **Flutter**: 3.24.0 或更高版本
- **Node.js**: 18.x 或更高版本
- **PostgreSQL**: 15.x 或更高版本
- **Git**: 最新版本

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/your-username/xloop.git
   cd xloop
   ```

2. **设置数据库**
   ```bash
   # 创建PostgreSQL数据库
   createdb xloop_dev
   
   # 运行数据库迁移
   cd backend/auth-service
   npm run migrate
   ```

3. **配置环境变量**
   ```bash
   # 复制环境变量模板
   cp backend/auth-service/.env.example backend/auth-service/.env
   
   # 编辑环境变量文件，设置数据库连接和JWT密钥
   ```

4. **启动后端服务**
   ```bash
   # 启动认证服务
   cd backend/auth-service
   npm install
   npm run dev
   
   # 启动核心服务 (新终端)
   cd backend/core-service
   npm install
   npm run dev
   ```

5. **启动前端应用**
   ```bash
   cd mobile
   flutter pub get
   flutter run
   ```

## 🔧 开发指南

### 后端开发

#### 认证服务 (端口: 3001)
- **登录**: `POST /api/auth/login`
- **注册**: `POST /api/auth/register`
- **刷新令牌**: `POST /api/auth/refresh`
- **登出**: `POST /api/auth/logout`

#### 核心服务 (端口: 3002)
- **知识库管理**: `/api/knowledge/*`
- **FAQ管理**: `/api/faq/*`
- **对话管理**: `/api/conversations/*`

### 前端开发

#### 主要功能模块
- **认证模块** (`lib/features/auth/`): 用户登录、注册、令牌管理
- **聊天模块** (`lib/features/chat/`): 对话界面、消息管理
- **知识库模块** (`lib/features/knowledge/`): 知识库管理、文件上传

#### 状态管理
使用BLoC模式进行状态管理，每个功能模块包含：
- `bloc/`: 业务逻辑层
- `data/`: 数据访问层
- `domain/`: 领域模型层
- `presentation/`: 表现层

## 🧪 测试

### 后端测试
```bash
cd backend/auth-service
npm test
```

### 前端测试
```bash
cd mobile
flutter test
```

## 📊 当前开发状态

### ✅ 已完成功能
- [x] 用户认证系统 (登录/注册/JWT令牌管理)
- [x] 数据库设计和迁移
- [x] Flutter应用基础架构
- [x] BLoC状态管理集成
- [x] API客户端集成
- [x] 基础UI组件库

### 🚧 开发中功能
- [ ] 知识库文件上传和解析
- [ ] FAQ问答系统
- [ ] 语义搜索功能
- [ ] 对话界面优化

### 📋 计划功能
- [ ] 多文件格式支持 (PDF, PPT, MP3)
- [ ] 高级语义分析
- [ ] 数据分析仪表板
- [ ] 移动端优化
- [ ] API文档自动生成

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📝 更新日志

### v0.1.0 (2025-01-14)
- ✨ 初始项目架构搭建
- ✨ 用户认证系统实现
- ✨ Flutter应用基础框架
- 🐛 修复登录响应格式不匹配问题
- 🐛 修复JSON序列化字段映射问题

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

- **项目维护者**: Daniel Tang
- **邮箱**: tdfdjx@gmail.com
- **GitHub**: [https://github.com/your-username/xloop](https://github.com/your-username/xloop)

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者和设计师。

---

<div align="center">
  Made with ❤️ by the XLoop Team
</div> 