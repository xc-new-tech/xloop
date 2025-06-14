/// API端点配置类
class ApiEndpoints {
  // 基础路径
  static const String baseUrl = 'http://localhost:3001';
  static const String apiVersion = '/api/v1';
  static const String basePath = '$baseUrl$apiVersion';

  // 认证相关端点
  static const String auth = '/auth';
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String logout = '$auth/logout';
  static const String refreshToken = '$auth/refresh';
  static const String forgotPassword = '$auth/forgot-password';
  static const String resetPassword = '$auth/reset-password';
  static const String verifyEmail = '$auth/verify-email';

  // 用户相关端点
  static const String users = '/users';
  static const String profile = '$users/profile';
  static const String updateProfile = '$users/profile';
  static const String changePassword = '$users/change-password';

  // 知识库相关端点
  static const String knowledgeBases = '/knowledge-bases';
  static String knowledgeBase(String id) => '$knowledgeBases/$id';
  static String knowledgeBaseDocuments(String id) => '$knowledgeBases/$id/documents';
  static String knowledgeBaseFaqs(String id) => '$knowledgeBases/$id/faqs';
  static String knowledgeBaseSearch(String id) => '$knowledgeBases/$id/search';
  static String knowledgeBaseStats(String id) => '$knowledgeBases/$id/stats';
  static String duplicateKnowledgeBase(String id) => '$knowledgeBases/$id/duplicate';
  static String shareKnowledgeBase(String id) => '$knowledgeBases/$id/share';
  static String exportKnowledgeBase(String id) => '$knowledgeBases/$id/export';
  static const String importKnowledgeBase = '$knowledgeBases/import';
  static const String knowledgeBaseTags = '$knowledgeBases/tags';
  static const String searchKnowledgeBases = '$knowledgeBases/search';

  // 文件相关端点
  static const String files = '/files';
  static String file(String id) => '$files/$id';
  static const String uploadFiles = '$files/upload';
  static String downloadFile(String id) => '$files/$id/download';
  static const String batchDelete = '$files/batch-delete';
  static const String batchDownload = '$files/batch-download';

  // 文档相关端点
  static const String documents = '/documents';
  static String document(String id) => '$documents/$id';
  static String documentChunks(String id) => '$documents/$id/chunks';

  // FAQ相关端点
  static const String faqs = '/faqs';
  static String faq(String id) => '$faqs/$id';
  static String faqDetail(String id) => '$faqs/$id';
  static const String faqCategories = '$faqs/categories';
  static const String faqSearch = '$faqs/search';
  static const String searchFaqs = '$faqs/search';
  static const String faqBulkDelete = '$faqs/bulk-delete';
  static const String faqPopular = '$faqs/popular';
  static String faqLike(String id) => '$faqs/$id/like';
  static String faqDislike(String id) => '$faqs/$id/dislike';
  static String faqToggleStatus(String id) => '$faqs/$id/toggle-status';

  // 对话相关端点
  static const String conversations = '/conversations';
  static String conversation(String id) => '$conversations/$id';
  static String conversationMessages(String id) => '$conversations/$id/messages';
  static const String chat = '/chat';
  static const String chatStream = '$chat/stream';

  // 搜索相关端点
  static const String search = '/search';
  static const String searchDocuments = '$search/documents';
  static const String searchFaqsEndpoint = '$search/faqs';
  static const String searchHybrid = '$search/hybrid';
  static const String searchRecommendations = '$search/recommendations';
  static const String searchStats = '$search/stats';
  static const String vectorize = '$search/vectorize';
  static const String vectorizeDocument = '$search/vectorize/document';
  static const String vectorizeFaq = '$search/vectorize/faq';
  static const String batchVectorize = '$search/vectorize/batch';
  static const String clearCache = '$search/cache/clear';
  static const String searchHealth = '$search/health';

  // 权限管理相关端点
  static const String permissions = '/permissions';
  static String permission(String id) => '$permissions/$id';
  static const String roles = '/roles';
  static String role(String id) => '$roles/$id';
  static const String userPermissions = '/users/{userId}/permissions';
  static const String currentUserPermissions = '$auth/permissions';
  static const String checkPermission = '$auth/check-permission';
  static const String checkAnyPermissions = '$auth/check-any-permissions';
  static const String checkAllPermissions = '$auth/check-all-permissions';
  static const String checkRole = '$auth/check-role';
  static String assignPermissionsToRole(String roleId) => '$roles/$roleId/permissions';
  static String assignRolesToUser(String userId) => '/users/$userId/roles';
  static const String refreshPermissions = '$auth/refresh-permissions';

  // 系统相关端点
  static const String health = '/health';
  static const String stats = '/stats';
} 