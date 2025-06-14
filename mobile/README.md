# XLoop 知识智能平台

XLoop是一个基于Flutter开发的跨平台知识智能平台，提供智能对话、知识库管理、语义检索、文件解析等核心功能。

## 🚀 项目概述

XLoop采用现代化的技术架构，为用户提供智能化的知识管理和问答体验：

- **Flutter多平台前端**：支持iOS、Android、Web、Desktop
- **Node.js后端服务**：RESTful API设计，微服务架构
- **智能对话系统**：多轮对话，上下文理解
- **语义检索引擎**：基于向量相似度的知识检索
- **文件解析引擎**：支持多种文档格式解析
- **调优分析系统**：对话质量评估和系统优化

## 📱 功能特性

### 核心功能
- 🤖 **智能对话**：支持多轮对话，智能问答
- 📚 **知识库管理**：创建、编辑、管理知识库
- 🔍 **语义检索**：基于AI的智能搜索
- 📄 **文件解析**：PDF、Word、Excel等格式支持
- 💬 **FAQ管理**：问答对管理和维护
- 📊 **数据分析**：对话质量评估和统计分析

### 系统特性
- 🔐 **用户认证**：JWT认证，安全可靠
- 🛡️ **权限管理**：细粒度权限控制
- ⚡ **性能优化**：缓存机制，性能监控
- 📈 **实时监控**：系统健康状态监控
- 🔧 **调优系统**：智能优化建议

## 🏗️ 技术架构

### 前端技术栈
- **Flutter 3.x**：跨平台UI框架
- **Dart 3.x**：编程语言
- **BLoC Pattern**：状态管理
- **Clean Architecture**：项目架构
- **Material Design 3**：UI设计系统

### 核心依赖
```yaml
flutter_bloc: ^8.1.3          # 状态管理
dio: ^5.3.2                   # HTTP客户端
shared_preferences: ^2.2.2    # 本地存储
equatable: ^2.0.5             # 对象比较
get_it: ^7.6.4                # 依赖注入
json_annotation: ^4.8.1       # JSON序列化
```

### 开发工具
```yaml
flutter_lints: ^3.0.0         # 代码规范
build_runner: ^2.4.7          # 代码生成
json_serializable: ^6.7.1     # JSON序列化代码生成
bloc_test: ^9.1.5              # BLoC测试
mocktail: ^1.0.1               # Mock对象
```

## 📁 项目结构

```
mobile/
├── lib/
│   ├── core/                  # 核心模块
│   │   ├── api/              # API配置
│   │   ├── cache/            # 缓存管理
│   │   ├── constants/        # 常量定义
│   │   ├── error/            # 错误处理
│   │   ├── network/          # 网络管理
│   │   ├── performance/      # 性能监控
│   │   ├── theme/            # 主题配置
│   │   └── utils/            # 工具类
│   ├── features/             # 功能模块
│   │   ├── analytics/        # 调优分析
│   │   ├── auth/             # 用户认证
│   │   ├── chat/             # 对话系统
│   │   ├── conversation/     # 对话管理
│   │   ├── data_management/  # 数据管理
│   │   ├── faq/              # FAQ管理
│   │   ├── file/             # 文件管理
│   │   ├── home/             # 首页
│   │   ├── knowledge/        # 知识库
│   │   ├── permission/       # 权限管理
│   │   └── search/           # 语义检索
│   └── main.dart             # 应用入口
├── test/                     # 单元测试
├── integration_test/         # 集成测试
└── pubspec.yaml              # 项目配置
```

### 模块架构（Clean Architecture）

每个功能模块采用分层架构：

```
feature/
├── data/                     # 数据层
│   ├── datasources/         # 数据源
│   ├── models/              # 数据模型
│   └── repositories/        # 存储库实现
├── domain/                   # 领域层
│   ├── entities/            # 实体
│   ├── repositories/        # 存储库接口
│   └── usecases/            # 用例
└── presentation/             # 表示层
    ├── bloc/                # 状态管理
    ├── pages/               # 页面
    └── widgets/             # 组件
```

## 🛠️ 开发环境

### 环境要求
- **Flutter**: 3.16.0+
- **Dart**: 3.2.0+
- **Android Studio/VS Code**
- **Node.js**: 18.0+（后端开发）

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/your-org/xloop.git
cd xloop/mobile
```

2. **安装依赖**
```bash
flutter pub get
```

3. **生成代码**
```bash
flutter pub run build_runner build
```

4. **运行项目**
```bash
flutter run
```

### 开发命令

```bash
# 代码生成
flutter pub run build_runner build --delete-conflicting-outputs

# 运行测试
flutter test

# 集成测试
flutter test integration_test/

# 代码格式化
dart format .

# 代码分析
flutter analyze

# 构建APK
flutter build apk

# 构建iOS
flutter build ios
```

## 🧪 测试

### 测试类型
- **单元测试**：`test/` 目录
- **Widget测试**：组件UI测试
- **集成测试**：`integration_test/` 目录
- **BLoC测试**：状态管理测试

### 运行测试
```bash
# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/features/auth/auth_bloc_test.dart

# 生成覆盖率报告
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📊 性能监控

### 性能指标
- **内存使用率**：实时监控内存占用
- **帧率监控**：UI流畅度检测
- **网络性能**：请求响应时间
- **缓存效率**：缓存命中率统计

### 性能优化
- **图片优化**：压缩和缓存
- **列表优化**：懒加载和虚拟滚动
- **状态优化**：避免不必要的重建
- **网络优化**：请求合并和缓存

## 🔧 配置说明

### 环境配置
```dart
// lib/core/constants/app_config.dart
class AppConfig {
  static const String baseUrl = 'http://localhost:3000/api';
  static const int connectTimeout = 5000;
  static const int receiveTimeout = 10000;
}
```

### 主题配置
```dart
// lib/core/theme/app_theme.dart
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
);
```

## 🚀 部署

### 构建发布版本

**Android**
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS**
```bash
flutter build ios --release
```

**Web**
```bash
flutter build web --release
```

### 环境变量
创建 `.env` 文件配置环境变量：
```
API_BASE_URL=https://api.xloop.com
ENABLE_ANALYTICS=true
LOG_LEVEL=info
```

## 🤝 开发规范

### 代码规范
- 遵循 `flutter_lints` 规范
- 使用 `dart format` 格式化代码
- 组件命名采用PascalCase
- 文件命名采用snake_case

### Git规范
```
feat: 新功能
fix: 修复bug
docs: 文档更新
style: 代码格式
refactor: 代码重构
test: 测试相关
chore: 构建过程或辅助工具的变动
```

### 提交流程
1. 创建功能分支
2. 开发并测试
3. 提交PR
4. 代码审查
5. 合并主分支

## 📚 相关文档

- [Flutter官方文档](https://flutter.dev/docs)
- [BLoC模式指南](https://bloclibrary.dev)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Material Design 3](https://m3.material.io/)

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 👥 贡献者

感谢所有为项目做出贡献的开发者！

## 📞 联系我们

- 项目主页：https://github.com/your-org/xloop
- 问题反馈：https://github.com/your-org/xloop/issues
- 邮箱：contact@xloop.com

---

⭐ 如果这个项目对您有帮助，请给我们一个星标！
