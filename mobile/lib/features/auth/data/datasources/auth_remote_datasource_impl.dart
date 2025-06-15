import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

/// 认证远程数据源实现
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  final Logger _logger = Logger();

  AuthRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      _logger.d('发送登录请求: ${request.email}');

      final response = await _dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      if (response.statusCode == ApiConstants.success) {
        final authResponse = AuthResponse.fromJson(response.data);
        _logger.d('登录请求成功: ${authResponse.user.username}');
        return authResponse;
      } else {
        throw ServerException(message: '登录失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, '登录');
      rethrow;
    } catch (e) {
      _logger.e('登录请求异常: $e');
      throw ServerException(message: '登录请求失败: $e');
    }
  }

  @override
  Future<ApiResponse<String>> register(RegisterRequest request) async {
    try {
      _logger.d('发送注册请求: ${request.email}');
      _logger.d('请求URL: ${_dio.options.baseUrl}${ApiConstants.register}');
      _logger.d('请求数据: ${request.toJson()}');

      final response = await _dio.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      if (response.statusCode == ApiConstants.created) {
        final data = response.data as Map<String, dynamic>;
        final message = data['message'] as String? ?? '注册成功';
        
        final apiResponse = ApiResponse<String>(
          success: data['success'] as bool? ?? true,
          message: message,
          data: message,
        );
        
        _logger.d('注册请求成功');
        return apiResponse;
      } else {
        throw ServerException(message: '注册失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, '注册');
      rethrow;
    } catch (e) {
      _logger.e('注册请求异常: $e');
      throw ServerException(message: '注册请求失败: $e');
    }
  }

  @override
  Future<ApiResponse<String>> logout(LogoutRequest request) async {
    try {
      _logger.d('发送登出请求');

      final response = await _dio.post(
        '${ApiConstants.authBaseUrl}/logout',
        data: request.toJson(),
      );

      if (response.statusCode == ApiConstants.success) {
        final apiResponse = ApiResponse<String>.fromJson(
          response.data,
          (json) => json as String,
        );
        _logger.d('登出请求成功');
        return apiResponse;
      } else {
        throw ServerException(message: '登出失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, '登出');
      rethrow;
    } catch (e) {
      _logger.e('登出请求异常: $e');
      throw ServerException(message: '登出请求失败: $e');
    }
  }

  @override
  Future<RefreshTokenResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      _logger.d('发送Token刷新请求');

      final response = await _dio.post(
        '${ApiConstants.authBaseUrl}/refresh-token',
        data: request.toJson(),
      );

      if (response.statusCode == ApiConstants.success) {
        final refreshResponse = RefreshTokenResponse.fromJson(response.data);
        _logger.d('Token刷新成功');
        return refreshResponse;
      } else {
        throw AuthException(message: 'Token刷新失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'Token刷新');
      rethrow;
    } catch (e) {
      _logger.e('Token刷新异常: $e');
      throw AuthException(message: 'Token刷新失败: $e');
    }
  }

  @override
  Future<ApiResponse<String>> forgotPassword(ForgotPasswordRequest request) async {
    try {
      _logger.d('发送忘记密码请求: ${request.email}');

      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: request.toJson(),
      );

      if (response.statusCode == ApiConstants.success) {
        final apiResponse = ApiResponse<String>.fromJson(
          response.data,
          (json) => json as String,
        );
        _logger.d('忘记密码请求成功');
        return apiResponse;
      } else {
        throw ServerException(message: '忘记密码请求失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, '忘记密码');
      rethrow;
    } catch (e) {
      _logger.e('忘记密码请求异常: $e');
      throw ServerException(message: '忘记密码请求失败: $e');
    }
  }

  @override
  Future<ApiResponse<String>> resetPassword(ResetPasswordRequest request) async {
    try {
      _logger.d('发送重置密码请求');

      final response = await _dio.post(
        ApiConstants.resetPassword,
        data: request.toJson(),
      );

      if (response.statusCode == ApiConstants.success) {
        final apiResponse = ApiResponse<String>.fromJson(
          response.data,
          (json) => json as String,
        );
        _logger.d('重置密码请求成功');
        return apiResponse;
      } else {
        throw ServerException(message: '重置密码失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, '重置密码');
      rethrow;
    } catch (e) {
      _logger.e('重置密码请求异常: $e');
      throw ServerException(message: '重置密码请求失败: $e');
    }
  }

  @override
  Future<ApiResponse<String>> changePassword(ChangePasswordRequest request) async {
    try {
      _logger.d('发送更改密码请求');

      final response = await _dio.put(
        '${ApiConstants.userBaseUrl}/password',
        data: request.toJson(),
      );

      if (response.statusCode == ApiConstants.success) {
        final apiResponse = ApiResponse<String>.fromJson(
          response.data,
          (json) => json as String,
        );
        _logger.d('更改密码请求成功');
        return apiResponse;
      } else {
        throw ServerException(message: '更改密码失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, '更改密码');
      rethrow;
    } catch (e) {
      _logger.e('更改密码请求异常: $e');
      throw ServerException(message: '更改密码请求失败: $e');
    }
  }

  @override
  Future<ApiResponse<String>> sendEmailVerification(EmailVerificationRequest request) async {
    try {
      _logger.d('发送邮箱验证请求: ${request.email}');

      final response = await _dio.post(
        '${ApiConstants.authBaseUrl}/send-verification',
        data: request.toJson(),
      );

      if (response.statusCode == ApiConstants.success) {
        final apiResponse = ApiResponse<String>.fromJson(
          response.data,
          (json) => json as String,
        );
        _logger.d('邮箱验证发送成功');
        return apiResponse;
      } else {
        throw ServerException(message: '发送邮箱验证失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, '邮箱验证发送');
      rethrow;
    } catch (e) {
      _logger.e('邮箱验证发送异常: $e');
      throw ServerException(message: '邮箱验证发送失败: $e');
    }
  }

  @override
  Future<ApiResponse<String>> verifyEmailToken(VerifyEmailTokenRequest request) async {
    try {
      _logger.d('发送邮箱Token验证请求');

      final response = await _dio.post(
        ApiConstants.verifyEmail,
        data: request.toJson(),
      );

      if (response.statusCode == ApiConstants.success) {
        final apiResponse = ApiResponse<String>.fromJson(
          response.data,
          (json) => json as String,
        );
        _logger.d('邮箱Token验证成功');
        return apiResponse;
      } else {
        throw ValidationException(message: '邮箱验证失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, '邮箱Token验证');
      rethrow;
    } catch (e) {
      _logger.e('邮箱Token验证异常: $e');
      throw ValidationException(message: '邮箱验证失败: $e');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      _logger.d('获取当前用户信息');

      final response = await _dio.get(ApiConstants.profile);

      if (response.statusCode == ApiConstants.success) {
        final userModel = UserModel.fromJson(response.data['data']);
        _logger.d('获取用户信息成功: ${userModel.username}');
        return userModel;
      } else {
        throw ServerException(message: '获取用户信息失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, '获取用户信息');
      rethrow;
    } catch (e) {
      _logger.e('获取用户信息异常: $e');
      throw ServerException(message: '获取用户信息失败: $e');
    }
  }

  @override
  Future<UserModel> updateUser(UpdateUserRequest request) async {
    try {
      _logger.d('更新用户信息');

      final response = await _dio.put(
        ApiConstants.profile,
        data: request.toJson(),
      );

      if (response.statusCode == ApiConstants.success) {
        final userModel = UserModel.fromJson(response.data['data']);
        _logger.d('更新用户信息成功: ${userModel.username}');
        return userModel;
      } else {
        throw ServerException(message: '更新用户信息失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, '更新用户信息');
      rethrow;
    } catch (e) {
      _logger.e('更新用户信息异常: $e');
      throw ServerException(message: '更新用户信息失败: $e');
    }
  }

  @override
  Future<ApiResponse<String>> deleteAccount(DeleteAccountRequest request) async {
    try {
      _logger.d('发送删除账户请求');

      final response = await _dio.delete(
        ApiConstants.profile,
        data: request.toJson(),
      );

      if (response.statusCode == ApiConstants.success) {
        final apiResponse = ApiResponse<String>.fromJson(
          response.data,
          (json) => json as String,
        );
        _logger.d('删除账户成功');
        return apiResponse;
      } else {
        throw ServerException(message: '删除账户失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, '删除账户');
      rethrow;
    } catch (e) {
      _logger.e('删除账户异常: $e');
      throw ServerException(message: '删除账户失败: $e');
    }
  }

  @override
  Future<ApiResponse<String>> validateToken() async {
    try {
      _logger.d('验证Token有效性');

      final response = await _dio.get('${ApiConstants.authBaseUrl}/validate');

      if (response.statusCode == ApiConstants.success) {
        final apiResponse = ApiResponse<String>.fromJson(
          response.data,
          (json) => json as String,
        );
        _logger.d('Token验证成功');
        return apiResponse;
      } else {
        throw AuthException(message: 'Token验证失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, 'Token验证');
      rethrow;
    } catch (e) {
      _logger.e('Token验证异常: $e');
      throw AuthException(message: 'Token验证失败: $e');
    }
  }

  @override
  Future<ApiResponse<String>> resendVerificationEmail() async {
    try {
      _logger.d('重新发送验证邮件');

      final response = await _dio.post('${ApiConstants.authBaseUrl}/resend-verification');

      if (response.statusCode == ApiConstants.success) {
        final apiResponse = ApiResponse<String>.fromJson(
          response.data,
          (json) => json as String,
        );
        _logger.d('重新发送验证邮件成功');
        return apiResponse;
      } else {
        throw ServerException(message: '重新发送验证邮件失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, '重新发送验证邮件');
      rethrow;
    } catch (e) {
      _logger.e('重新发送验证邮件异常: $e');
      throw ServerException(message: '重新发送验证邮件失败: $e');
    }
  }

  @override
  Future<ApiResponse<String>> verifyEmail(VerifyEmailRequest request) async {
    try {
      _logger.d('验证邮件');

      final response = await _dio.post(
        '${ApiConstants.authBaseUrl}/verify-email',
        data: request.toJson(),
      );

      if (response.statusCode == ApiConstants.success) {
        final apiResponse = ApiResponse<String>.fromJson(
          response.data,
          (json) => json as String,
        );
        _logger.d('邮件验证成功');
        return apiResponse;
      } else {
        throw ValidationException(message: '邮件验证失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, '邮件验证');
      rethrow;
    } catch (e) {
      _logger.e('邮件验证异常: $e');
      throw ValidationException(message: '邮件验证失败: $e');
    }
  }

  @override
  Future<UserModel> updateProfile(UpdateProfileRequest request) async {
    try {
      _logger.d('更新个人资料');

      final response = await _dio.put(
        '${ApiConstants.userBaseUrl}/profile',
        data: request.toJson(),
      );

      if (response.statusCode == ApiConstants.success) {
        final userModel = UserModel.fromJson(response.data['data']);
        _logger.d('更新个人资料成功: ${userModel.username}');
        return userModel;
      } else {
        throw ServerException(message: '更新个人资料失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioException(e, '更新个人资料');
      rethrow;
    } catch (e) {
      _logger.e('更新个人资料异常: $e');
      throw ServerException(message: '更新个人资料失败: $e');
    }
  }

  /// 处理Dio异常
  void _handleDioException(DioException e, String operation) {
    _logger.e('$operation Dio异常: ${e.type} - ${e.message}');
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException(message: '网络连接超时，请检查网络设置');
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        
        // 安全地提取错误消息
        String _extractMessage(dynamic data, String defaultMessage) {
          try {
            if (data is Map<String, dynamic>) {
              final message = data['message'];
              if (message is String) {
                return message;
              }
            }
            return defaultMessage;
          } catch (e) {
            return defaultMessage;
          }
        }
        
        switch (statusCode) {
          case ApiConstants.badRequest:
            final message = _extractMessage(data, '请求参数错误');
            throw ValidationException(message: message);
          
          case ApiConstants.unauthorized:
            final message = _extractMessage(data, '未授权访问');
            throw AuthException(message: message);
          
          case ApiConstants.forbidden:
            final message = _extractMessage(data, '禁止访问');
            throw AuthException(message: message);
          
          case ApiConstants.notFound:
            final message = _extractMessage(data, '请求的资源不存在');
            throw ServerException(message: message);
          
          case ApiConstants.conflict:
            final message = _extractMessage(data, '数据冲突');
            throw ValidationException(message: message);
          
          case ApiConstants.tooManyRequests:
            final message = _extractMessage(data, '请求过于频繁，请稍后重试');
            throw NetworkException(message: message);
          
          case ApiConstants.internalServerError:
          default:
            final message = _extractMessage(data, '服务器内部错误');
            throw ServerException(message: message);
        }
      
      case DioExceptionType.connectionError:
        throw NetworkException(message: '网络连接失败，请检查网络设置');
      
      case DioExceptionType.badCertificate:
        throw NetworkException(message: 'SSL证书验证失败');
      
      case DioExceptionType.cancel:
        throw NetworkException(message: '请求已取消');
      
      case DioExceptionType.unknown:
        throw NetworkException(message: '网络请求失败: ${e.message}');
    }
  }
} 