/// API相关常量定义
class ApiConstants {
  ApiConstants._();

  // 基础URL配置
  static const String baseUrl = 'http://localhost:3000/api/v1';
  static const String apiVersion = '/api';
  
  // 认证相关端点
  static const String authBaseUrl = '$apiVersion/auth';
  static const String userBaseUrl = '$apiVersion/user';
  
  // 认证端点
  static const String register = '$authBaseUrl/register';
  static const String login = '$authBaseUrl/login';
  static const String verifyEmail = '$authBaseUrl/verify-email';
  static const String forgotPassword = '$authBaseUrl/forgot-password';
  static const String resetPassword = '$authBaseUrl/reset-password';
  static const String refreshToken = '$authBaseUrl/refresh';
  static const String logout = '$authBaseUrl/logout';
  
  // 用户端点
  static const String profile = '$userBaseUrl/profile';
  static const String sessions = '$userBaseUrl/sessions';
  static const String revokeOtherSessions = '$userBaseUrl/sessions/revoke-others';
  
  // 管理员端点
  static const String adminUsers = '$userBaseUrl/admin/users';
  
  // 知识库相关端点
  static const String knowledgeBases = '$apiVersion/knowledge-bases';
  static String knowledgeBase(String id) => '$knowledgeBases/$id';
  static String knowledgeBaseDocuments(String id) => '$knowledgeBases/$id/documents';
  static String document(String id) => '/documents/$id';
  
  // 文件相关端点
  static const String files = '$apiVersion/files';
  static String file(String id) => '$files/$id';
  static const String upload = '$files/upload';
  static const String download = '$files/download';
  
  // 对话相关端点
  static const String conversations = '$apiVersion/conversations';
  static String conversation(String id) => '$conversations/$id';
  static String conversationMessages(String id) => '$conversations/$id/messages';
  static const String chat = '/chat';
  
  // 搜索相关端点
  static const String search = '$apiVersion/search';
  static const String semanticSearch = '$search/semantic';
  static const String keywordSearch = '$search/keyword';
  
  // 超时配置
  static const int connectTimeoutMs = 30000; // 30秒
  static const int receiveTimeoutMs = 30000; // 30秒
  static const int sendTimeoutMs = 30000; // 30秒
  
  // 响应状态码
  static const int success = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int tooManyRequests = 429;
  static const int internalServerError = 500;
  
  // 请求头
  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String applicationJson = 'application/json';
  static const String bearerPrefix = 'Bearer ';
}

/// 存储相关常量
class StorageConstants {
  StorageConstants._();
  
  // 安全存储键（用于敏感信息）
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userCredentials = 'user_credentials';
  static const String userData = 'user_data';
  static const String tokenExpiry = 'token_expiry';
  
  // 普通存储键
  static const String userPreferences = 'user_preferences';
  static const String isFirstLaunch = 'is_first_launch';
  static const String languageCode = 'language_code';
  static const String themeMode = 'theme_mode';
}

/// 路由名称常量
class RouteConstants {
  RouteConstants._();
  
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyEmail = '/verify-email';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

/// 应用常量
class AppConstants {
  AppConstants._();
  
  static const String appName = 'XLoop';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@xloop.com';
  
  // 验证规则
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  
  // 正则表达式
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String passwordRegex = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]';
  static const String usernameRegex = r'^[a-zA-Z0-9_-]+$';
}

/// 用户相关常量
class UserConstants {
  UserConstants._();
  
  static const String users = '/users';
  static String user(String id) => '/users/$id';
  static const String userProfile = '/users/profile';
  static const String userPreferences = '/users/preferences';
}

/// 权限相关常量
class PermissionConstants {
  PermissionConstants._();
  
  static const String permissions = '/permissions';
  static const String roles = '/roles';
  static String userPermissions(String userId) => '/users/$userId/permissions';
}

/// 分析相关常量
class AnalyticsConstants {
  AnalyticsConstants._();
  
  static const String analytics = '/analytics';
  static const String qualityAnalysis = '/analytics/quality';
  static const String performanceMetrics = '/analytics/performance';
  static const String optimization = '/analytics/optimization';
}

/// 数据管理相关常量
class DataManagementConstants {
  DataManagementConstants._();
  
  static const String dataManagement = '/data-management';
  static const String backup = '/data-management/backup';
  static const String restore = '/data-management/restore';
  static const String sync = '/data-management/sync';
}

/// API管理相关常量
class ApiManagementConstants {
  ApiManagementConstants._();
  
  static const String apiManagement = '/api-management';
  static const String apiDocs = '/api-management/docs';
  static const String apiStatus = '/api-management/status';
}

/// 系统相关常量
class SystemConstants {
  SystemConstants._();
  
  static const String health = '/health';
  static const String version = '/version';
  static const String config = '/config';
}

/// FAQ相关常量
class FaqConstants {
  FaqConstants._();
  
  static const String faqs = '/faqs';
  static String faq(String id) => '/faqs/$id';
  static const String faqCategories = '/faq-categories';
} 