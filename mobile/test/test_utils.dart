import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

/// 测试工具类
class TestUtils {
  /// 创建测试Widget包装器
  static Widget createTestApp({
    required Widget child,
    List<BlocProvider>? providers,
    ThemeData? theme,
  }) {
    Widget app = MaterialApp(
      home: child,
      theme: theme ?? ThemeData.light(),
    );

    if (providers != null && providers.isNotEmpty) {
      app = MultiBlocProvider(
        providers: providers,
        child: app,
      );
    }

    return app;
  }

  /// 等待动画完成
  static Future<void> waitForAnimations(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  /// 查找Widget
  static Finder findByType<T extends Widget>() {
    return find.byType(T);
  }

  /// 查找包含文本的Widget
  static Finder findByText(String text) {
    return find.text(text);
  }

  /// 查找包含键的Widget
  static Finder findByKey(Key key) {
    return find.byKey(key);
  }

  /// 点击Widget
  static Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pump();
  }

  /// 输入文本
  static Future<void> enterText(WidgetTester tester, Finder finder, String text) async {
    await tester.enterText(finder, text);
    await tester.pump();
  }

  /// 滚动Widget
  static Future<void> scroll(
    WidgetTester tester,
    Finder finder,
    Offset offset,
  ) async {
    await tester.drag(finder, offset);
    await tester.pump();
  }

  /// 验证Widget存在
  static void expectWidgetExists(Finder finder) {
    expect(finder, findsOneWidget);
  }

  /// 验证Widget不存在
  static void expectWidgetNotExists(Finder finder) {
    expect(finder, findsNothing);
  }

  /// 验证多个Widget存在
  static void expectWidgetsExist(Finder finder, int count) {
    expect(finder, findsNWidgets(count));
  }

  /// 验证文本存在
  static void expectTextExists(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// 验证文本不存在
  static void expectTextNotExists(String text) {
    expect(find.text(text), findsNothing);
  }

  /// 等待Widget出现
  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final end = DateTime.now().add(timeout);
    
    while (DateTime.now().isBefore(end)) {
      await tester.pump();
      
      if (tester.any(finder)) {
        return;
      }
      
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    throw TimeoutException('Widget not found within timeout', timeout);
  }

  /// 等待文本出现
  static Future<void> waitForText(
    WidgetTester tester,
    String text, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await waitForWidget(tester, find.text(text), timeout: timeout);
  }

  /// 创建Mock对象并注册fallback值
  static T createMock<T extends Object>() {
    final mock = MockObject<T>();
    registerFallbackValue(mock);
    return mock as T;
  }

  /// 模拟网络延迟
  static Future<void> simulateNetworkDelay({
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    await Future.delayed(delay);
  }

  /// 生成测试数据
  static Map<String, dynamic> generateTestData({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return {
      'id': id ?? 'test_id_${DateTime.now().millisecondsSinceEpoch}',
      'name': name ?? 'Test Name',
      'email': email ?? 'test@example.com',
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// 创建测试列表数据
  static List<Map<String, dynamic>> generateTestList(int count) {
    return List.generate(count, (index) => generateTestData(
      id: 'test_id_$index',
      name: 'Test Name $index',
      email: 'test$index@example.com',
    ));
  }

  /// 验证JSON结构
  static void expectJsonStructure(
    Map<String, dynamic> json,
    Map<String, Type> expectedStructure,
  ) {
    for (final entry in expectedStructure.entries) {
      expect(json.containsKey(entry.key), isTrue,
          reason: 'Missing key: ${entry.key}');
      expect(json[entry.key], isA<Type>().having((t) => t, 'type', entry.value),
          reason: 'Wrong type for key: ${entry.key}');
    }
  }

  /// 创建测试路由
  static Route<T> createTestRoute<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }
}

/// Mock对象基类
class MockObject<T extends Object> extends Mock {}

/// 超时异常
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  const TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message (timeout: $timeout)';
}

/// 测试常量
class TestConstants {
  static const Duration defaultTimeout = Duration(seconds: 5);
  static const Duration shortTimeout = Duration(seconds: 2);
  static const Duration longTimeout = Duration(seconds: 10);
  
  static const String testUserId = 'test_user_id';
  static const String testUserEmail = 'test@example.com';
  static const String testUserName = 'Test User';
  static const String testToken = 'test_jwt_token';
  
  static const String testKnowledgeBaseId = 'test_kb_id';
  static const String testFileId = 'test_file_id';
  static const String testConversationId = 'test_conversation_id';
}

/// 测试匹配器
class TestMatchers {
  /// 匹配包含特定文本的Widget
  static Matcher containsText(String text) {
    return predicate<Widget>((widget) {
      if (widget is Text) {
        return widget.data?.contains(text) ?? false;
      }
      return false;
    }, 'contains text "$text"');
  }

  /// 匹配特定颜色的Widget
  static Matcher hasColor(Color color) {
    return predicate<Widget>((widget) {
      if (widget is Container && widget.decoration is BoxDecoration) {
        final decoration = widget.decoration as BoxDecoration;
        return decoration.color == color;
      }
      return false;
    }, 'has color $color');
  }

  /// 匹配可见的Widget
  static Matcher isVisible() {
    return predicate<Widget>((widget) {
      return widget is Visibility ? widget.visible : true;
    }, 'is visible');
  }

  /// 匹配不可见的Widget
  static Matcher isHidden() {
    return predicate<Widget>((widget) {
      return widget is Visibility ? !widget.visible : false;
    }, 'is hidden');
  }
} 