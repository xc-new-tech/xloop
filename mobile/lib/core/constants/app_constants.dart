/// 应用常量配置
class AppConstants {
  // 应用信息
  static const String appName = 'XLoop';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'XLoop知识智能平台';

  // 密码规则
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  // 验证规则
  static const int maxUsernameLength = 50;
  static const int maxEmailLength = 255;

  // 文件上传限制
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const List<String> supportedFileTypes = [
    'pdf',
    'txt',
    'docx',
    'doc',
    'csv',
    'xlsx',
    'xls',
    'ppt',
    'pptx',
    'mp3',
    'wav',
    'mp4',
    'avi',
  ];

  // 网络请求超时
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // 分页设置
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // 缓存设置
  static const Duration cacheExpiry = Duration(hours: 24);
  static const Duration shortCacheExpiry = Duration(minutes: 30);

  // UI设置
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;

  // 动画时长
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);

  // 防抖时长
  static const Duration debounceDuration = Duration(milliseconds: 500);

  // Token刷新阈值（提前5分钟刷新）
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  // 重试配置
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // 日志配置
  static const bool enableLogging = true;
  static const bool enableNetworkLogging = true;

  // 环境标识
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // 是否为生产环境
  static bool get isProduction => environment == 'production';

  // 是否为开发环境
  static bool get isDevelopment => environment == 'development';

  // 是否为测试环境
  static bool get isTesting => environment == 'testing';
} 