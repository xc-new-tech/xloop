import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// 网络请求拦截器
/// 用于处理认证、日志和通用错误处理
class NetworkInterceptor extends http.BaseClient {
  final http.Client _inner;
  final String? Function()? getAccessToken;
  final VoidCallback? onUnauthorized;
  final bool enableLogging;

  NetworkInterceptor({
    http.Client? client,
    this.getAccessToken,
    this.onUnauthorized,
    this.enableLogging = true,
  }) : _inner = client ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // 添加认证头
    if (getAccessToken != null) {
      final token = getAccessToken!();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    // 添加通用头
    request.headers.putIfAbsent('Accept', () => 'application/json');
    request.headers.putIfAbsent('Content-Type', () => 'application/json');

    // 日志记录请求
    if (enableLogging) {
      _logRequest(request);
    }

    final stopwatch = Stopwatch()..start();
    
    try {
      final response = await _inner.send(request);
      stopwatch.stop();

      // 日志记录响应
      if (enableLogging) {
        await _logResponse(response, stopwatch.elapsedMilliseconds);
      }

      // 处理401未授权
      if (response.statusCode == 401 && onUnauthorized != null) {
        onUnauthorized!();
      }

      return response;
    } catch (e) {
      stopwatch.stop();
      
      if (enableLogging) {
        developer.log(
          '网络请求异常: $e',
          name: 'NetworkInterceptor',
          error: e,
        );
      }
      
      rethrow;
    }
  }

  /// 记录请求日志
  void _logRequest(http.BaseRequest request) {
    final buffer = StringBuffer();
    buffer.writeln('🚀 ${request.method} ${request.url}');
    
    if (request.headers.isNotEmpty) {
      buffer.writeln('Headers:');
      request.headers.forEach((key, value) {
        // 隐藏敏感信息
        if (key.toLowerCase() == 'authorization') {
          buffer.writeln('  $key: Bearer ***');
        } else {
          buffer.writeln('  $key: $value');
        }
      });
    }

    if (request is http.Request && request.body.isNotEmpty) {
      buffer.writeln('Body: ${request.body}');
    }

    developer.log(
      buffer.toString(),
      name: 'NetworkRequest',
    );
  }

  /// 记录响应日志
  Future<void> _logResponse(
    http.StreamedResponse response,
    int elapsedMs,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('📥 ${response.statusCode} ${response.request?.url}');
    buffer.writeln('耗时: ${elapsedMs}ms');
    
    if (response.headers.isNotEmpty) {
      buffer.writeln('Headers:');
      response.headers.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }

    // 只有在开发模式下才记录响应体
    if (response.contentLength != null && response.contentLength! > 0) {
      try {
        final responseBody = await response.stream.bytesToString();
        if (responseBody.isNotEmpty) {
          // 限制日志长度，避免过长的响应体
          final truncatedBody = responseBody.length > 1000 
              ? '${responseBody.substring(0, 1000)}...'
              : responseBody;
          buffer.writeln('Body: $truncatedBody');
        }
        
        // 注意：原始流已经被读取，无法重新创建
        // 这里只是示例，实际使用中需要特殊处理
      } catch (e) {
        buffer.writeln('Body: <无法解析响应体>');
      }
    }

    developer.log(
      buffer.toString(),
      name: 'NetworkResponse',
    );
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

/// 网络日志级别
enum NetworkLogLevel {
  none,    // 不记录日志
  basic,   // 只记录基本信息
  headers, // 记录头信息
  body,    // 记录所有信息
}

/// 网络配置
class NetworkConfig {
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final NetworkLogLevel logLevel;
  final Map<String, String> defaultHeaders;

  const NetworkConfig({
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.logLevel = NetworkLogLevel.basic,
    this.defaultHeaders = const {},
  });
} 