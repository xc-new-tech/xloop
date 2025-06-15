import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import '../constants/api_constants.dart';
import '../error/exceptions.dart';

/// API客户端类
/// 提供统一的HTTP请求接口
class ApiClient {
  static const String _baseUrl = ApiConstants.baseUrl;
  static const Duration _timeoutDuration = Duration(seconds: 30);

  final http.Client _client;
  String? _accessToken;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// 设置访问令牌
  void setAccessToken(String token) {
    _accessToken = token;
  }

  /// 清除访问令牌
  void clearAccessToken() {
    _accessToken = null;
  }

  /// 获取请求头
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  /// GET请求
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(_timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('网络连接失败');
    } on HttpException {
      throw NetworkException('HTTP请求失败');
    } on FormatException {
      throw ServerException('服务器响应格式错误');
    }
  }

  /// POST请求
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final jsonBody = body != null ? jsonEncode(body) : null;

      final response = await _client
          .post(uri, headers: _headers, body: jsonBody)
          .timeout(_timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('网络连接失败');
    } on HttpException {
      throw NetworkException('HTTP请求失败');
    } on FormatException {
      throw ServerException('服务器响应格式错误');
    }
  }

  /// PUT请求
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final jsonBody = body != null ? jsonEncode(body) : null;

      final response = await _client
          .put(uri, headers: _headers, body: jsonBody)
          .timeout(_timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('网络连接失败');
    } on HttpException {
      throw NetworkException('HTTP请求失败');
    } on FormatException {
      throw ServerException('服务器响应格式错误');
    }
  }

  /// DELETE请求
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);

      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(_timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('网络连接失败');
    } on HttpException {
      throw NetworkException('HTTP请求失败');
    } on FormatException {
      throw ServerException('服务器响应格式错误');
    }
  }

  /// PATCH请求
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final jsonBody = body != null ? jsonEncode(body) : null;

      final response = await _client
          .patch(uri, headers: _headers, body: jsonBody)
          .timeout(_timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('网络连接失败');
    } on HttpException {
      throw NetworkException('HTTP请求失败');
    } on FormatException {
      throw ServerException('服务器响应格式错误');
    }
  }

  /// 文件上传
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath,
    String fieldName, {
    Map<String, String>? fields,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final request = http.MultipartRequest('POST', uri);

      // 添加headers
      request.headers.addAll(_headers);
      request.headers.remove('Content-Type'); // 让http包自动设置

      // 添加文件
      final file = await http.MultipartFile.fromPath(fieldName, filePath);
      request.files.add(file);

      // 添加其他字段
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send().timeout(_timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('网络连接失败');
    } on HttpException {
      throw NetworkException('HTTP请求失败');
    } on FormatException {
      throw ServerException('服务器响应格式错误');
    }
  }

  /// PlatformFile上传（支持Web和移动端）
  Future<Map<String, dynamic>> uploadPlatformFile(
    String endpoint,
    PlatformFile platformFile,
    String fieldName, {
    Map<String, String>? fields,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final request = http.MultipartRequest('POST', uri);

      // 添加headers
      request.headers.addAll(_headers);
      request.headers.remove('Content-Type'); // 让http包自动设置

      // 添加文件
      http.MultipartFile file;
      if (platformFile.bytes != null) {
        // Web平台使用bytes
        file = http.MultipartFile.fromBytes(
          fieldName,
          platformFile.bytes!,
          filename: platformFile.name,
        );
      } else if (platformFile.path != null) {
        // 移动端使用path
        file = await http.MultipartFile.fromPath(
          fieldName,
          platformFile.path!,
          filename: platformFile.name,
        );
      } else {
        throw ServerException('文件数据无效');
      }
      
      request.files.add(file);

      // 添加其他字段
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send().timeout(_timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('网络连接失败');
    } on HttpException {
      throw NetworkException('HTTP请求失败');
    } on FormatException {
      throw ServerException('服务器响应格式错误');
    }
  }

  /// 构建URI
  Uri _buildUri(String endpoint, [Map<String, String>? queryParameters]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final url = '$_baseUrl/$cleanEndpoint';
    
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return Uri.parse(url).replace(queryParameters: queryParameters);
    }
    
    return Uri.parse(url);
  }

  /// 处理响应
  Map<String, dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
        if (response.body.isEmpty) {
          return <String, dynamic>{};
        }
        return jsonDecode(response.body) as Map<String, dynamic>;
      
      case 204:
        return <String, dynamic>{};
      
      case 400:
        throw ClientException('请求参数错误: ${response.body}');
      
      case 401:
        throw UnauthorizedException('未授权访问');
      
      case 403:
        throw ForbiddenException('访问被禁止');
      
      case 404:
        throw NotFoundException('资源不存在');
      
      case 422:
        throw ValidationException('数据验证失败: ${response.body}');
      
      case 429:
        throw RateLimitException('请求频率过高');
      
      case 500:
      case 502:
      case 503:
      case 504:
        throw ServerException('服务器错误: ${response.statusCode}');
      
      default:
        throw ServerException('未知错误: ${response.statusCode}');
    }
  }

  /// 释放资源
  void dispose() {
    _client.close();
  }
} 