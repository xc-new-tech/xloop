import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../features/auth/presentation/blocs/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/knowledge/presentation/pages/knowledge_base_page.dart';
import '../../features/knowledge/presentation/pages/knowledge_base_form_page.dart';
import '../../features/files/presentation/pages/file_management_page.dart';
import '../../features/faq/presentation/pages/faq_management_simple.dart';
import '../../features/faq/presentation/pages/faq_detail_page.dart';
import '../../features/faq/presentation/pages/faq_form_page.dart';
import '../../features/faq/presentation/pages/faq_list_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/search/presentation/pages/semantic_search_simple.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/analytics/presentation/pages/analytics_dashboard_page.dart';
import '../../features/permissions/presentation/pages/permission_management_page.dart';
import '../../features/data/presentation/pages/data_management_page.dart';
import '../../features/api/presentation/pages/api_management_page.dart';
import '../../features/performance/presentation/pages/performance_monitoring_page.dart';
import '../../features/workflow/presentation/pages/workflow_management_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../shared/presentation/pages/splash_page.dart';
import '../../shared/presentation/pages/not_found_page.dart';

/// 应用路由配置类
class AppRouter {
  AppRouter._();

  /// 路由路径常量
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String knowledgeBase = '/knowledge-base';
  static const String knowledgeBaseDetail = '/knowledge-base/:id';
  static const String files = '/files';
  static const String faq = '/faq';
  static const String chat = '/chat';
  static const String chatDetail = '/chat/:id';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String analytics = '/analytics';
  static const String permissions = '/permissions';
  static const String dataManagement = '/data-management';
  static const String apiManagement = '/api-management';
  static const String performance = '/performance';
  static const String workflow = '/workflow';
  static const String dashboard = '/dashboard';

  /// 路由配置
  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    
    // 路由重定向逻辑
    redirect: (BuildContext context, GoRouterState state) {
      final authBloc = context.read<AuthBloc>();
      final isAuthenticated = authBloc.state is AuthAuthenticated;
      final isLoading = authBloc.state is AuthLoading;
      
      final isGoingToLogin = state.matchedLocation == login ||
          state.matchedLocation == '/login/register' ||
          state.matchedLocation == '/login/forgot-password';
      
      final isGoingToSplash = state.matchedLocation == splash;
      
      // 如果正在加载，保持在splash页面
      if (isLoading && !isGoingToSplash) {
        return splash;
      }
      
      // 如果已认证但访问登录相关页面，重定向到首页
      if (isAuthenticated && isGoingToLogin) {
        return home;
      }
      
      // 如果未认证但访问需要认证的页面，重定向到登录页
      if (!isAuthenticated && !isGoingToLogin && !isGoingToSplash) {
        return login;
      }
      
      return null; // 不需要重定向
    },
    
    // 路由定义
    routes: [
      // 启动页
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      
      // 认证相关路由
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
        routes: [
          // 注册页面作为登录页的子路由
          GoRoute(
            path: 'register',
            name: 'register',
            builder: (context, state) => const RegisterPage(),
          ),
          // 忘记密码页面
          GoRoute(
            path: 'forgot-password',
            name: 'forgot-password',
            builder: (context, state) => const ForgotPasswordPage(),
          ),
        ],
      ),
      
      // 主要功能路由（需要认证）
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: _buildBottomNavigationBar(context, state),
          );
        },
        routes: [
          // 首页
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          
          // 知识库
          GoRoute(
            path: knowledgeBase,
            name: 'knowledge-base',
            builder: (context, state) => const KnowledgeBasePage(),
            routes: [
              // 知识库详情
              GoRoute(
                path: ':id',
                name: 'knowledge-base-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return KnowledgeBaseDetailPage(knowledgeBaseId: id);
                },
              ),
              // 创建/编辑知识库
              GoRoute(
                path: '/new',
                name: 'knowledge-base-new',
                builder: (context, state) => const KnowledgeBaseFormPage(),
              ),
              GoRoute(
                path: '/edit/:id',
                name: 'knowledge-base-edit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  // 这里需要根据id获取知识库对象，暂时用默认参数
                  return const KnowledgeBaseFormPage(isEditing: true);
                },
              ),
            ],
          ),
          
          // 文件管理
          GoRoute(
            path: files,
            name: 'files',
            builder: (context, state) {
              final knowledgeBaseId = state.uri.queryParameters['knowledgeBaseId'];
              return FileManagementPage(knowledgeBaseId: knowledgeBaseId);
            },
          ),
          
          // FAQ管理
                      GoRoute(
              path: faq,
              name: 'faq',
              builder: (context, state) {
                final knowledgeBaseId = state.uri.queryParameters['knowledgeBaseId'];
                return FaqManagementSimplePage(knowledgeBaseId: knowledgeBaseId);
              },
              routes: [
                // FAQ列表页面
                GoRoute(
                  path: 'list',
                  name: 'faq_list',
                  builder: (context, state) {
                    final categoryId = state.uri.queryParameters['categoryId'];
                    final knowledgeBaseId = state.uri.queryParameters['knowledgeBaseId'];
                    return FaqListPage(
                      categoryId: categoryId,
                      knowledgeBaseId: knowledgeBaseId,
                    );
                  },
                ),
                // FAQ详情页面
                GoRoute(
                  path: ':faqId',
                  name: 'faq_detail',
                  builder: (context, state) {
                    final faqId = state.pathParameters['faqId']!;
                    return FaqDetailPage(faqId: faqId);
                  },
                ),
                // FAQ创建页面
                GoRoute(
                  path: 'create',
                  name: 'faq_create',
                  builder: (context, state) {
                    final knowledgeBaseId = state.uri.queryParameters['knowledgeBaseId'];
                    return FaqFormPage(initialKnowledgeBaseId: knowledgeBaseId);
                  },
                ),
                // FAQ编辑页面
                GoRoute(
                  path: 'edit/:faqId',
                  name: 'faq_edit',
                  builder: (context, state) {
                    final faqId = state.pathParameters['faqId']!;
                    return FaqFormPage(faqId: faqId);
                  },
                ),
              ],
            ),
          
          // 聊天
          GoRoute(
            path: chat,
            name: 'chat',
            builder: (context, state) => const ChatPage(),
            routes: [
              // 聊天详情
              GoRoute(
                path: ':id',
                name: 'chat-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ChatDetailPage(chatId: id);
                },
              ),
            ],
          ),
          
          // 语义搜索
          GoRoute(
            path: search,
            name: 'search',
            builder: (context, state) {
              final initialQuery = state.uri.queryParameters['query'];
              final knowledgeBaseId = state.uri.queryParameters['knowledgeBaseId'];
              return SemanticSearchSimplePage(
                initialQuery: initialQuery,
                knowledgeBaseId: knowledgeBaseId,
              );
            },
          ),
          
          // 个人资料
          GoRoute(
            path: profile,
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
          
          // 设置
          GoRoute(
            path: settings,
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          
          // 分析仪表板
          GoRoute(
            path: analytics,
            name: 'analytics',
            builder: (context, state) => const AnalyticsDashboardPage(),
          ),
          
          // 权限管理
          GoRoute(
            path: permissions,
            name: 'permissions',
            builder: (context, state) => const PermissionManagementPage(),
          ),
          
          // 数据管理
          GoRoute(
            path: dataManagement,
            name: 'data-management',
            builder: (context, state) => const DataManagementPage(),
          ),
          
          // API管理
          GoRoute(
            path: apiManagement,
            name: 'api-management',
            builder: (context, state) => const ApiManagementPage(),
          ),
          
          // 性能监控
          GoRoute(
            path: performance,
            name: 'performance',
            builder: (context, state) => const PerformanceMonitoringPage(),
          ),
          
          // 工作流管理
          GoRoute(
            path: workflow,
            name: 'workflow',
            builder: (context, state) => const WorkflowManagementPage(),
          ),
          
          // 仪表板
          GoRoute(
            path: dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
        ],
      ),
    ],
    
    // 错误处理
    errorBuilder: (context, state) => NotFoundPage(
      error: state.error.toString(),
    ),
  );

  /// 构建底部导航栏
  static Widget _buildBottomNavigationBar(BuildContext context, GoRouterState state) {
    final currentPath = state.matchedLocation;
    
    // 计算当前选中的索引
    int currentIndex = 0;
    if (currentPath.startsWith(home)) {
      currentIndex = 0;
    } else if (currentPath.startsWith(knowledgeBase)) {
      currentIndex = 1;
    } else if (currentPath.startsWith(search)) {
      currentIndex = 2;
    } else if (currentPath.startsWith(chat)) {
      currentIndex = 3;
    } else if (currentPath.startsWith(faq)) {
      currentIndex = 4;
    } else if (currentPath.startsWith(profile)) {
      currentIndex = 5;
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go(home);
            break;
          case 1:
            context.go(knowledgeBase);
            break;
          case 2:
            context.go(search);
            break;
          case 3:
            context.go(chat);
            break;
          case 4:
            context.go(faq);
            break;
          case 5:
            context.go(profile);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '首页',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books),
          label: '知识库',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology),
          label: '搜索',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: '聊天',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.quiz_outlined),
          label: 'FAQ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '我的',
        ),
      ],
    );
  }
}

/// 知识库详情页面（临时实现）
class KnowledgeBaseDetailPage extends StatelessWidget {
  final String knowledgeBaseId;

  const KnowledgeBaseDetailPage({
    super.key,
    required this.knowledgeBaseId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('知识库详情 $knowledgeBaseId'),
      ),
      body: Center(
        child: Text('知识库详情页面 - ID: $knowledgeBaseId'),
      ),
    );
  }
}

/// 聊天详情页面（临时实现）
class ChatDetailPage extends StatelessWidget {
  final String chatId;

  const ChatDetailPage({
    super.key,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('聊天详情 $chatId'),
      ),
      body: Center(
        child: Text('聊天详情页面 - ID: $chatId'),
      ),
    );
  }
} 