import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import 'package:mobile/core/storage/token_storage.dart';
import 'package:mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

import 'test_helpers.mocks.dart';

/// 生成Mock类的注解
@GenerateMocks([
  Dio,
  TokenStorage,
  AuthRemoteDataSource,
  AuthRepository,
  Logger,
])
void main() {}

/// 测试辅助工具类
class TestHelpers {
  static final GetIt _testGetIt = GetIt.instance;

  /// 初始化测试环境
  static Future<void> setupTestEnvironment() async {
    // 重置GetIt实例
    if (_testGetIt.isRegistered<TokenStorage>()) {
      await _testGetIt.reset();
    }

    // 创建Mock对象
    final mockDio = MockDio();
    final mockTokenStorage = MockTokenStorage();
    final mockAuthDataSource = MockAuthRemoteDataSource();
    final mockAuthRepository = MockAuthRepository();
    final mockLogger = MockLogger();

    // 注册Mock对象到测试GetIt实例
    _testGetIt.registerSingleton<Dio>(mockDio);
    _testGetIt.registerSingleton<TokenStorage>(mockTokenStorage);
    _testGetIt.registerSingleton<AuthRemoteDataSource>(mockAuthDataSource);
    _testGetIt.registerSingleton<AuthRepository>(mockAuthRepository);
    _testGetIt.registerSingleton<Logger>(mockLogger);

    // 配置默认的Mock行为
    _setupDefaultMockBehavior(
      mockTokenStorage,
      mockAuthDataSource,
      mockAuthRepository,
    );
  }

  /// 清理测试环境
  static Future<void> tearDownTestEnvironment() async {
    await _testGetIt.reset();
  }

  /// 配置默认的Mock行为
  static void _setupDefaultMockBehavior(
    MockTokenStorage mockTokenStorage,
    MockAuthRemoteDataSource mockAuthDataSource,
    MockAuthRepository mockAuthRepository,
  ) {
    // TokenStorage默认行为
    when(mockTokenStorage.saveTokens(
      accessToken: anyNamed('accessToken'),
      refreshToken: anyNamed('refreshToken'),
    )).thenAnswer((_) async {});

    when(mockTokenStorage.getAccessToken())
        .thenAnswer((_) async => 'mock_access_token');

    when(mockTokenStorage.getRefreshToken())
        .thenAnswer((_) async => 'mock_refresh_token');

    when(mockTokenStorage.isLoggedIn())
        .thenAnswer((_) async => true);

    when(mockTokenStorage.clearTokens())
        .thenAnswer((_) async {});
  }

  /// 获取Mock对象
  static T getMock<T extends Object>() {
    return _testGetIt.get<T>();
  }

  /// 验证Mock调用
  static void verifyMockCalls(List<Function> verifications) {
    for (final verification in verifications) {
      verification();
    }
  }
}

/// 测试数据工厂
class TestDataFactory {
  /// 创建测试用的JWT Token
  static String createTestJwtToken({
    String subject = 'test_user',
    String issuer = 'xloop_test',
    Duration validFor = const Duration(hours: 1),
  }) {
    // 这是一个简化的JWT结构，实际测试中可能需要使用真实的JWT库
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
        'eyJzdWIiOiIkc3ViamVjdCIsImlzcyI6IiRpc3N1ZXIiLCJleHAiOjE2ODg5MTUyMDAsImlhdCI6MTY4ODkxMTYwMH0.'
        'test_signature';
  }

  /// 创建测试用的用户登录请求
  static Map<String, dynamic> createLoginRequest({
    String email = 'test@xloop.com',
    String password = 'Test123!',
    bool rememberMe = false,
  }) {
    return {
      'email': email,
      'password': password,
      'rememberMe': rememberMe,
    };
  }

  /// 创建测试用的用户注册请求
  static Map<String, dynamic> createRegisterRequest({
    String email = 'test@xloop.com',
    String password = 'Test123!',
    String confirmPassword = 'Test123!',
    String name = 'Test User',
  }) {
    return {
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'name': name,
    };
  }

  /// 创建测试用的认证响应
  static Map<String, dynamic> createAuthResponse({
    String? accessToken,
    String? refreshToken,
    Map<String, dynamic>? user,
  }) {
    return {
      'success': true,
      'message': 'Authentication successful',
      'data': {
        'accessToken': accessToken ?? createTestJwtToken(),
        'refreshToken': refreshToken ?? createTestJwtToken(validFor: const Duration(days: 30)),
        'user': user ?? {
          'id': '1',
          'email': 'test@xloop.com',
          'name': 'Test User',
          'isEmailVerified': true,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      },
    };
  }

  /// 创建测试用的错误响应
  static Map<String, dynamic> createErrorResponse({
    String message = 'Test error',
    int code = 400,
    Map<String, dynamic>? errors,
  }) {
    return {
      'success': false,
      'message': message,
      'code': code,
      'errors': errors,
    };
  }

  /// 创建测试用的Dio响应
  static Response<T> createDioResponse<T>({
    required T data,
    int statusCode = 200,
    String statusMessage = 'OK',
    Map<String, List<String>>? headers,
  }) {
    return Response<T>(
      data: data,
      statusCode: statusCode,
      statusMessage: statusMessage,
      headers: Headers.fromMap(headers ?? {}),
      requestOptions: RequestOptions(path: '/test'),
    );
  }

  /// 创建测试用的Dio错误
  static DioException createDioError({
    int statusCode = 400,
    String message = 'Test error',
    Map<String, dynamic>? responseData,
  }) {
    return DioException(
      requestOptions: RequestOptions(path: '/test'),
      response: Response(
        statusCode: statusCode,
        statusMessage: message,
        data: responseData ?? createErrorResponse(message: message, code: statusCode),
        requestOptions: RequestOptions(path: '/test'),
      ),
      type: DioExceptionType.badResponse,
      message: message,
    );
  }
}

/// 测试断言工具
class TestAssertions {
  /// 断言异步操作成功
  static Future<void> assertAsyncSuccess<T>(
    Future<T> future, {
    void Function(T result)? onSuccess,
  }) async {
    try {
      final result = await future;
      onSuccess?.call(result);
    } catch (e) {
      throw AssertionError('Expected success but got error: $e');
    }
  }

  /// 断言异步操作失败
  static Future<void> assertAsyncFailure<T>(
    Future<T> future, {
    Type? expectedErrorType,
    String? expectedMessage,
  }) async {
    try {
      await future;
      throw AssertionError('Expected failure but operation succeeded');
    } catch (e) {
      if (expectedErrorType != null && e.runtimeType != expectedErrorType) {
        throw AssertionError(
          'Expected error type $expectedErrorType but got ${e.runtimeType}',
        );
      }
      if (expectedMessage != null && !e.toString().contains(expectedMessage)) {
        throw AssertionError(
          'Expected error message to contain "$expectedMessage" but got: $e',
        );
      }
    }
  }

  /// 断言Mock被调用
  static void assertMockCalled(
    dynamic mock,
    String methodName, {
    int times = 1,
  }) {
    verify(mock).called(times);
  }

  /// 断言Mock未被调用
  static void assertMockNotCalled(dynamic mock) {
    verifyNever(mock);
  }
} 