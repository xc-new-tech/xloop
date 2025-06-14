import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/app_preferences.dart';
import 'core/utils/logger_utils.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/auth/presentation/blocs/auth_state.dart';
import 'features/auth/presentation/blocs/auth_event.dart';
import 'generated/l10n/app_localizations.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 设置系统UI样式
  await _setupSystemUI();

  // 初始化Hydrated BLoC
  await _initializeHydratedBloc();

  // 初始化依赖注入
  await initializeDependencies();

  // 启动应用
  runApp(const XLoopApp());
}

/// 设置系统UI样式
Future<void> _setupSystemUI() async {
  // 设置系统状态栏和导航栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 设置支持的屏幕方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

/// 初始化Hydrated BLoC
Future<void> _initializeHydratedBloc() async {
  try {
    final storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory(),
    );
    HydratedBloc.storage = storage;
    LoggerUtils.i('HydratedBloc 初始化成功');
  } catch (e) {
    LoggerUtils.e('HydratedBloc 初始化失败', e);
  }
}

/// XLoop应用主类
class XLoopApp extends StatelessWidget {
  const XLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 认证BLoC
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // iPhone X 设计尺寸
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return _AppWithPreferences();
        },
      ),
    );
  }
}

/// 带偏好设置的应用组件
class _AppWithPreferences extends StatefulWidget {
  @override
  State<_AppWithPreferences> createState() => _AppWithPreferencesState();
}

class _AppWithPreferencesState extends State<_AppWithPreferences> {
  late AppPreferences _appPreferences;
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('zh');

  @override
  void initState() {
    super.initState();
    _appPreferences = sl<AppPreferences>();
    _loadPreferences();
  }

  /// 加载偏好设置
  void _loadPreferences() {
    final themeMode = _appPreferences.getThemeMode();
    final language = _appPreferences.getLanguage();

    setState(() {
      _themeMode = ThemeMode.values[themeMode];
      _locale = Locale(language);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'XLoop知识智能平台',
      
      // 路由配置
      routerConfig: AppRouter.router,
      
      // 主题配置
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      
      // 国际化配置
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      
      // 调试配置
      debugShowCheckedModeBanner: false,
      
      // 构建器
      builder: (context, child) {
        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // 监听认证状态变化
            if (state is AuthUnauthenticated) {
              LoggerUtils.i('用户未认证');
            } else if (state is AuthAuthenticated) {
              LoggerUtils.i('用户已认证: ${state.user.email}');
            } else if (state is AuthError) {
              LoggerUtils.e('认证错误: ${state.message}');
              // 显示错误消息
              if (context.mounted) {
                _showErrorSnackBar(context, state.message);
              }
            }
          },
          child: MediaQuery(
            // 禁用系统字体缩放
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  /// 显示错误提示
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '关闭',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

/// 启动页面
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 模拟应用初始化过程
    await Future.delayed(const Duration(seconds: 2));
    
    // 检查登录状态
    // final tokenStorage = getIt<TokenStorage>();
    // final isLoggedIn = await tokenStorage.isLoggedIn();
    
    // 导航到相应页面
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo占位符
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Icon(
                Icons.psychology,
                size: 60.sp,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'XLoop',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '知识智能平台',
                             style: TextStyle(
                 fontSize: 16.sp,
                 color: AppTheme.white.withValues(alpha: 0.8),
               ),
            ),
            SizedBox(height: 48.h),
                         SizedBox(
               width: 120.w,
               child: LinearProgressIndicator(
                 backgroundColor: AppTheme.white.withValues(alpha: 0.3),
                 valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.white),
               ),
             ),
          ],
        ),
      ),
    );
  }
}

/// 欢迎页面（临时）
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('欢迎使用 XLoop'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 100.sp,
              color: AppTheme.success,
            ),
            SizedBox(height: 24.h),
            Text(
              'Flutter 认证模块初始化完成!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              '基础架构搭建成功，包括：\n• 项目结构\n• 依赖配置\n• 主题系统\n• 网络层\n• 存储层',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () {
                // 这里将导航到登录页面
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('认证模块架构已准备就绪，下一步将开发登录页面'),
                  ),
                );
              },
              child: const Text('开始体验'),
            ),
          ],
        ),
      ),
    );
  }
}
