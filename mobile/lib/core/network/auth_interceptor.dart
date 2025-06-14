import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../services/token_manager.dart';
import '../constants/api_constants.dart';

/// 认证拦截器 - 自动添加token到请求头，处理token过期
class AuthInterceptor extends Interceptor {
  late TokenManager _tokenManager;
  late Logger _logger;
  
  // 用于防止并发刷新token的锁
  Completer<bool>? _refreshCompleter;

  AuthInterceptor() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
    _initTokenManager();
  }

  Future<void> _initTokenManager() async {
    _tokenManager = await TokenManager.getInstance();
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // 确保TokenManager已初始化
      await _initTokenManager();

      // 跳过不需要认证的请求
      if (_shouldSkipAuth(options)) {
        handler.next(options);
        return;
      }

      // 获取有效的访问token
      final accessToken = await _tokenManager.getValidAccessToken();
      
      if (accessToken != null) {
        // 添加Authorization头
        options.headers['Authorization'] = 'Bearer $accessToken';
        _logger.d('Added Authorization header to ${options.method} ${options.path}');
      } else {
        _logger.w('No valid access token available for ${options.method} ${options.path}');
      }

      handler.next(options);
      
    } catch (e) {
      _logger.e('Error in auth interceptor onRequest: $e');
      handler.next(options);
    }
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 处理401未授权错误
    if (err.response?.statusCode == 401) {
      _logger.w('Received 401 Unauthorized, attempting token refresh');
      
      try {
        // 尝试刷新token并重试请求
        final success = await _handleTokenRefresh(err, handler);
        if (success) {
          return; // 请求已被重试，不继续处理错误
        }
      } catch (e) {
        _logger.e('Error handling token refresh: $e');
      }
    }

    // 继续处理其他错误
    handler.next(err);
  }

  /// 判断是否应该跳过认证
  bool _shouldSkipAuth(RequestOptions options) {
    final path = options.path.toLowerCase();
    
    // 跳过认证相关的接口
    final authPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/auth/forgot-password',
      '/auth/reset-password',
      '/auth/verify-email',
    ];
    
    return authPaths.any((authPath) => path.contains(authPath));
  }

  /// 处理token刷新和请求重试
  Future<bool> _handleTokenRefresh(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      // 如果已经有刷新在进行，等待结果
      if (_refreshCompleter != null) {
        _logger.d('Token refresh already in progress, waiting...');
        final success = await _refreshCompleter!.future;
        if (success) {
          return await _retryRequest(err, handler);
        }
        return false;
      }

      // 开始新的token刷新
      _refreshCompleter = Completer<bool>();
      
      _logger.i('Starting token refresh...');
      
      final refreshToken = await _tokenManager.getRefreshToken();
      if (refreshToken == null) {
        _logger.e('No refresh token available');
        _refreshCompleter!.complete(false);
        _refreshCompleter = null;
        return false;
      }

      // 执行token刷新
      final success = await _performTokenRefresh(refreshToken);
      
      _refreshCompleter!.complete(success);
      _refreshCompleter = null;
      
      if (success) {
        return await _retryRequest(err, handler);
      }
      
      return false;
      
    } catch (e) {
      _logger.e('Token refresh failed: $e');
      _refreshCompleter?.complete(false);
      _refreshCompleter = null;
      return false;
    }
  }

  /// 执行实际的token刷新
  Future<bool> _performTokenRefresh(String refreshToken) async {
    try {
      // 创建一个新的Dio实例来避免拦截器循环
      final dio = Dio();
      
      final response = await dio.post(
        '${ApiConstants.baseUrl}/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          await _tokenManager.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          
          _logger.i('Token refresh successful');
          return true;
        }
      }

      _logger.e('Token refresh response invalid: ${response.statusCode}');
      return false;
      
    } catch (e) {
      _logger.e('Token refresh request failed: $e');
      return false;
    }
  }

  /// 重试原始请求
  Future<bool> _retryRequest(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      _logger.d('Retrying original request after token refresh');
      
      final requestOptions = err.requestOptions;
      
      // 获取新的访问token
      final newAccessToken = await _tokenManager.getValidAccessToken();
      if (newAccessToken == null) {
        _logger.e('No valid access token after refresh');
        return false;
      }

      // 更新Authorization头
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

      // 创建新的Dio实例重试请求
      final dio = Dio();
      final response = await dio.fetch(requestOptions);

      // 返回成功响应
      handler.resolve(response);
      return true;
      
    } catch (e) {
      _logger.e('Failed to retry request: $e');
      return false;
    }
  }

  /// 清理资源
  void dispose() {
    _refreshCompleter?.complete(false);
    _refreshCompleter = null;
    _logger.d('AuthInterceptor disposed');
  }
}

/// 认证相关的网络错误
class AuthNetworkException implements Exception {
  final String message;
  final int? statusCode;
  
  const AuthNetworkException(this.message, {this.statusCode});
  
  @override
  String toString() => 'AuthNetworkException($statusCode): $message';
} 