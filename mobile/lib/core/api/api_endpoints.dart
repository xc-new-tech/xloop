/// API端点常量类
class ApiEndpoints {
  ApiEndpoints._();

  // 基础URL
  static const String baseUrl = 'http://localhost:3002/api';
  
  // 认证相关
  static const String authBaseUrl = '$baseUrl/auth';
  static const String login = '$authBaseUrl/login';
  static const String register = '$authBaseUrl/register';
  static const String logout = '$authBaseUrl/logout';
  static const String refreshToken = '$authBaseUrl/refresh-token';
  static const String forgotPassword = '$authBaseUrl/forgot-password';
  static const String resetPassword = '$authBaseUrl/reset-password';
  
  // 用户相关
  static const String userBaseUrl = '$baseUrl/users';
  static const String profile = '$userBaseUrl/profile';
  static const String updateProfile = '$userBaseUrl/profile';
  static const String changePassword = '$userBaseUrl/change-password';
  
  // 知识库相关
  static const String knowledgeBases = '$baseUrl/knowledge-bases';
  static const String myKnowledgeBases = '$knowledgeBases/my';
  static const String publicKnowledgeBases = '$knowledgeBases/public';
  
  // 知识库动态端点方法
  static String knowledgeBaseDetail(String id) => '$knowledgeBases/$id';
  static String knowledgeBaseFiles(String id) => '$knowledgeBases/$id/files';
  static String knowledgeBaseImport(String id) => '$knowledgeBases/$id/import';
  static String knowledgeBaseExport(String id) => '$knowledgeBases/$id/export';
  static String knowledgeBaseStatus(String id) => '$knowledgeBases/$id/status';
  
  // 文件相关
  static const String files = '$baseUrl/files';
  static const String getFiles = '$files'; // 获取文件列表
  static const String upload = '$files/upload';
  static const String uploadMultiple = '$files/upload-multiple';
  
  // FAQ相关
  static const String faqs = '$baseUrl/faqs';
  static const String faqCategories = '$baseUrl/faq-categories';
  static const String faqSearch = '$faqs/search';
  static const String faqPopular = '$faqs/popular';
  static const String faqBulkDelete = '$faqs/bulk-delete';
  
  // FAQ动态端点方法
  static String faqDetail(String id) => '$faqs/$id';
  static String faqLike(String id) => '$faqs/$id/like';
  static String faqDislike(String id) => '$faqs/$id/dislike';
  static String faqToggleStatus(String id) => '$faqs/$id/toggle-status';
  
  // 对话相关
  static const String conversations = '$baseUrl/conversations';
  static const String messages = '$baseUrl/messages';
  
  // 搜索相关
  static const String search = '$baseUrl/search';
  static const String semanticSearch = '$search/semantic';
  static const String keywordSearch = '$search/keyword';
  static const String hybridSearch = '$search/hybrid';
  
  // 分析相关
  static const String analytics = '$baseUrl/analytics';
  static const String qualityAssessments = '$analytics/quality-assessments';
  static const String optimizations = '$analytics/optimizations';
  static const String reports = '$analytics/reports';
  
  // 权限相关
  static const String permissions = '$baseUrl/permissions';
  static const String roles = '$baseUrl/roles';
  static const String userPermissions = '$baseUrl/user-permissions';
  
  // 数据管理相关
  static const String dataManagement = '$baseUrl/data-management';
  static const String backups = '$dataManagement/backups';
  static const String sync = '$dataManagement/sync';
  static const String logs = '$dataManagement/logs';
  
  // API管理相关
  static const String apiManagement = '$baseUrl/api-management';
  static const String apiStats = '$apiManagement/stats';
  static const String apiDocs = '$apiManagement/docs';
  
  // 通用路径构建方法
  static String getById(String baseEndpoint, String id) => '$baseEndpoint/$id';
  static String getByUserId(String baseEndpoint, String userId) => '$baseEndpoint/user/$userId';
  static String getWithQuery(String baseEndpoint, Map<String, String> params) {
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$baseEndpoint?$query';
  }
} 