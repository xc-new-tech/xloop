import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xloop_mobile/core/constants/app_routes.dart';
import 'package:xloop_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:xloop_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:xloop_mobile/features/home/presentation/pages/home_page.dart';
import 'package:xloop_mobile/features/knowledge/presentation/pages/knowledge_base_page.dart';
import 'package:xloop_mobile/features/chat/presentation/pages/chat_page.dart';
import 'package:xloop_mobile/features/optimization/presentation/pages/optimization_dashboard_page.dart';
import 'package:xloop_mobile/features/permissions/presentation/pages/permissions_management_page.dart';
import 'package:xloop_mobile/features/faq/presentation/pages/faq_management_page.dart';
import 'package:xloop_mobile/features/search/presentation/pages/semantic_search_simple.dart';
import 'package:xloop_mobile/features/data_management/presentation/pages/data_management_page.dart';
import 'package:xloop_mobile/features/api/presentation/pages/api_management_page.dart';
import 'package:xloop_mobile/features/performance/presentation/pages/performance_monitoring_page.dart';
import 'package:xloop_mobile/features/workflow/presentation/pages/workflow_management_page.dart';
import 'package:xloop_mobile/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:xloop_mobile/features/settings/presentation/pages/system_settings_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.knowledgeBase,
        name: 'knowledge-base',
        builder: (context, state) => const KnowledgeBasePage(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        builder: (context, state) => const ChatPage(),
      ),
      GoRoute(
        path: AppRoutes.optimization,
        name: 'optimization',
        builder: (context, state) => const OptimizationDashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.permissions,
        name: 'permissions',
        builder: (context, state) => const PermissionsManagementPage(),
      ),
      GoRoute(
        path: AppRoutes.faq,
        name: 'faq',
        builder: (context, state) => const FaqManagementPage(),
      ),
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'] ?? '';
          return SemanticSearchPage(initialQuery: query);
        },
      ),
      GoRoute(
        path: AppRoutes.dataManagement,
        name: 'data-management',
        builder: (context, state) => const DataManagementPage(),
      ),
      GoRoute(
        path: AppRoutes.apiManagement,
        name: 'api-management',
        builder: (context, state) => const ApiManagementPage(),
      ),
      GoRoute(
        path: AppRoutes.performance,
        name: 'performance',
        builder: (context, state) => const PerformanceMonitoringPage(),
      ),
      GoRoute(
        path: AppRoutes.workflow,
        name: 'workflow',
        builder: (context, state) => const WorkflowManagementPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SystemSettingsPage(),
      ),
    ],
  );
} 