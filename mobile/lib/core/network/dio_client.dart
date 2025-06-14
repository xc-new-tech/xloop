import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../storage/token_manager.dart';
import '../constants/api_constants.dart';

/// Dio客户端配置类
class DioClient {
  final Dio _dio;
  final TokenManager _tokenManager;
  final Logger _logger;

  DioClient({
    required TokenManager tokenManager,
    required Logger logger,
  })  : _tokenManager = tokenManager,
        _logger = logger,
        _dio = Dio() {
    _configureDio();
  }

  /// 获取Dio实例
  Dio get dio => _dio;

  /// 配置Dio
  void _configureDio() {
    // 基础配置
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: 15000),
      receiveTimeout: const Duration(milliseconds: 15000),
      sendTimeout: const Duration(milliseconds: 15000),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // 添加拦截器
    _dio.interceptors.addAll([
      _createAuthInterceptor(),
      _createPrettyLoggerInterceptor(),
      _createErrorInterceptor(),
    ]);
  }

  /// 创建认证拦截器
  InterceptorsWrapper _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 如果是登录、注册等不需要Token的请求，直接通过
        if (_isPublicEndpoint(options.path)) {
          return handler.next(options);
        }

        try {
          // 获取访问Token
          final accessToken = await _tokenManager.getAccessToken();
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        } catch (e) {
          _logger.e('获取访问Token失败: $e');
          handler.next(options);
        }
      },
      onError: (error, handler) async {
        // 处理401未授权错误
        if (error.response?.statusCode == 401) {
          try {
            // 尝试刷新Token
            final newToken = await _refreshToken();
            if (newToken != null) {
              // 重新设置请求头
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              
              // 重新发起请求
              final cloneReq = await _dio.request(
                error.requestOptions.path,
                options: Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                ),
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              
              return handler.resolve(cloneReq);
            }
          } catch (e) {
            _logger.e('Token刷新失败: $e');
            // Token刷新失败，清理本地存储
            await _tokenManager.clearTokens();
          }
        }
        
        return handler.next(error);
      },
    );
  }

  /// 创建日志拦截器
  PrettyDioLogger _createPrettyLoggerInterceptor() {
    return PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
      enabled: true, // 在生产环境中应该设置为false
      filter: (options, args) {
        // 过滤敏感信息
        if (options.path.contains('/auth/')) {
          return false;
        }
        return true;
      },
    );
  }

  /// 创建错误处理拦截器
  InterceptorsWrapper _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        _logger.e('网络请求错误: ${error.message}');
        
        // 根据错误类型进行处理
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          _logger.w('网络请求超时');
        } else if (error.type == DioExceptionType.badResponse) {
          _logger.w('服务器响应错误: ${error.response?.statusCode}');
        } else if (error.type == DioExceptionType.cancel) {
          _logger.i('请求被取消');
        } else if (error.type == DioExceptionType.unknown) {
          _logger.e('网络连接错误: ${error.message}');
        }
        
        return handler.next(error);
      },
    );
  }

  /// 刷新Token
  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _tokenManager.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('刷新Token不存在');
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Authorization': null}, // 移除Authorization头
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['data']['accessToken'] as String;
        final newRefreshToken = data['data']['refreshToken'] as String;

        // 保存新的Token
        await _tokenManager.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        return newAccessToken;
      }
    } catch (e) {
      _logger.e('刷新Token失败: $e');
    }
    
    return null;
  }

  /// 判断是否为公开端点
  bool _isPublicEndpoint(String path) {
    final publicPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/forgot-password',
      '/auth/verify-email',
      '/health',
    ];
    
    return publicPaths.any((publicPath) => path.contains(publicPath));
  }

  /// GET请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PUT请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// DELETE请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PATCH请求
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
} 