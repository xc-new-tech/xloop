/// 路由常量配置
class RouteConstants {
  // 认证相关路由
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String emailVerification = '/email-verification';

  // 主要页面路由
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // 知识库相关路由
  static const String knowledgeBase = '/knowledge-base';
  static const String knowledgeBaseDetail = '/knowledge-base-detail';
  static const String knowledgeBaseCreate = '/knowledge-base-create';
  static const String knowledgeBaseEdit = '/knowledge-base-edit';

  // 文件管理路由
  static const String fileManager = '/file-manager';
  static const String fileUpload = '/file-upload';
  static const String fileDetail = '/file-detail';

  // FAQ管理路由
  static const String faqManager = '/faq-manager';
  static const String faqCreate = '/faq-create';
  static const String faqEdit = '/faq-edit';

  // 对话相关路由
  static const String chat = '/chat';
  static const String chatHistory = '/chat-history';
  static const String chatDetail = '/chat-detail';

  // 调优系统路由
  static const String optimization = '/optimization';
  static const String analyticsReport = '/analytics-report';

  // 系统管理路由
  static const String userManagement = '/user-management';
  static const String systemLogs = '/system-logs';
  static const String systemSettings = '/system-settings';

  // 帮助和支持路由
  static const String help = '/help';
  static const String about = '/about';
  static const String feedback = '/feedback';

  // 错误页面路由
  static const String notFound = '/404';
  static const String serverError = '/500';
  static const String networkError = '/network-error';

  // 闪屏和引导页路由
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  // 路由参数键
  static const String paramId = 'id';
  static const String paramType = 'type';
  static const String paramTitle = 'title';
  static const String paramData = 'data';
  static const String paramRedirect = 'redirect';

  // 路由查询参数键
  static const String queryPage = 'page';
  static const String queryLimit = 'limit';
  static const String querySearch = 'search';
  static const String queryFilter = 'filter';
  static const String querySort = 'sort';

  /// 获取带参数的路由
  static String getRouteWithParams(String route, Map<String, String> params) {
    String routeWithParams = route;
    params.forEach((key, value) {
      routeWithParams = routeWithParams.replaceAll(':$key', value);
    });
    return routeWithParams;
  }

  /// 获取带查询参数的路由
  static String getRouteWithQuery(String route, Map<String, String> query) {
    if (query.isEmpty) return route;
    
    final queryString = query.entries
        .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value)}')
        .join('&');
    
    return '$route?$queryString';
  }
} 