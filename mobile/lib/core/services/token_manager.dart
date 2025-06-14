import 'dart:async';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:logger/logger.dart';

import '../storage/token_storage.dart';

/// JWT Token数据模型
class TokenInfo {
  final String token;
  final DateTime expiresAt;
  final DateTime issuedAt;
  final String? subject;
  final String? issuer;
  final Map<String, dynamic> claims;

  const TokenInfo({
    required this.token,
    required this.expiresAt,
    required this.issuedAt,
    this.subject,
    this.issuer,
    required this.claims,
  });

  /// 检查token是否已过期
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// 检查token是否即将过期（提前5分钟）
  bool get isExpiringSoon {
    final threshold = expiresAt.subtract(const Duration(minutes: 5));
    return DateTime.now().isAfter(threshold);
  }

  /// 获取剩余有效时间
  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) {
      return Duration.zero;
    }
    return expiresAt.difference(now);
  }

  factory TokenInfo.fromJwt(String jwt) {
    try {
      final payload = Jwt.parseJwt(jwt);
      
      // 从payload中提取时间戳（秒），转换为DateTime
      final exp = payload['exp'] as int?;
      final iat = payload['iat'] as int?;
      
      return TokenInfo(
        token: jwt,
        expiresAt: exp != null 
            ? DateTime.fromMillisecondsSinceEpoch(exp * 1000)
            : DateTime.now().add(const Duration(hours: 1)), // 默认1小时
        issuedAt: iat != null
            ? DateTime.fromMillisecondsSinceEpoch(iat * 1000)
            : DateTime.now(),
        subject: payload['sub'] as String?,
        issuer: payload['iss'] as String?,
        claims: payload,
      );
    } catch (e) {
      throw TokenParseException('Failed to parse JWT token: $e');
    }
  }

  @override
  String toString() {
    return 'TokenInfo('
        'expires: $expiresAt, '
        'isExpired: $isExpired, '
        'isExpiringSoon: $isExpiringSoon, '
        'subject: $subject'
        ')';
  }
}

/// Token管理器 - 处理JWT token的存储、验证、刷新等
class TokenManager {
  static TokenManager? _instance;
  late TokenStorage _storage;
  late Logger _logger;
  
  TokenInfo? _currentAccessToken;
  TokenInfo? _currentRefreshToken;
  Timer? _refreshTimer;
  
  // Token刷新回调
  Function(String accessToken, String refreshToken)? _onTokenRefreshed;
  Function()? _onTokenExpired;
  
  TokenManager._internal();

  static Future<TokenManager> getInstance() async {
    if (_instance == null) {
      _instance = TokenManager._internal();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _storage = await TokenStorage.getInstance();
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
    
    // 加载已存储的token
    await _loadTokensFromStorage();
    
    // 启动自动刷新机制
    _startAutoRefresh();
    
    _logger.d('TokenManager initialized');
  }

  /// 设置回调函数
  void setCallbacks({
    Function(String accessToken, String refreshToken)? onTokenRefreshed,
    Function()? onTokenExpired,
  }) {
    _onTokenRefreshed = onTokenRefreshed;
    _onTokenExpired = onTokenExpired;
  }

  /// 保存新的token对
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      // 解析token信息
      _currentAccessToken = TokenInfo.fromJwt(accessToken);
      _currentRefreshToken = TokenInfo.fromJwt(refreshToken);
      
      // 保存到安全存储
      await _storage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      
      // 重新启动自动刷新
      _startAutoRefresh();
      
      _logger.i('Tokens saved successfully');
      _logger.d('Access token expires at: ${_currentAccessToken!.expiresAt}');
      _logger.d('Refresh token expires at: ${_currentRefreshToken!.expiresAt}');
      
    } catch (e) {
      _logger.e('Failed to save tokens: $e');
      throw TokenManagerException('Failed to save tokens: $e');
    }
  }

  /// 获取当前有效的访问token
  Future<String?> getValidAccessToken() async {
    try {
      // 如果没有缓存的token，从存储加载
      if (_currentAccessToken == null) {
        await _loadTokensFromStorage();
      }
      
      // 检查token是否存在
      if (_currentAccessToken == null) {
        _logger.w('No access token available');
        return null;
      }
      
      // 检查token是否过期
      if (_currentAccessToken!.isExpired) {
        _logger.w('Access token is expired, attempting refresh');
        
        // 尝试刷新token
        final refreshed = await _refreshAccessToken();
        if (!refreshed) {
          _logger.e('Failed to refresh expired access token');
          await _handleTokenExpired();
          return null;
        }
      }
      
      return _currentAccessToken!.token;
      
    } catch (e) {
      _logger.e('Error getting valid access token: $e');
      return null;
    }
  }

  /// 获取刷新token
  Future<String?> getRefreshToken() async {
    try {
      if (_currentRefreshToken == null) {
        await _loadTokensFromStorage();
      }
      
      if (_currentRefreshToken == null) {
        _logger.w('No refresh token available');
        return null;
      }
      
      if (_currentRefreshToken!.isExpired) {
        _logger.w('Refresh token is expired');
        await _handleTokenExpired();
        return null;
      }
      
      return _currentRefreshToken!.token;
      
    } catch (e) {
      _logger.e('Error getting refresh token: $e');
      return null;
    }
  }

  /// 检查是否已登录（有有效的token）
  Future<bool> isLoggedIn() async {
    final accessToken = await getValidAccessToken();
    return accessToken != null;
  }

  /// 获取当前访问token的信息
  TokenInfo? get currentAccessTokenInfo => _currentAccessToken;

  /// 获取当前刷新token的信息
  TokenInfo? get currentRefreshTokenInfo => _currentRefreshToken;

  /// 清除所有token
  Future<void> clearTokens() async {
    try {
      _currentAccessToken = null;
      _currentRefreshToken = null;
      _refreshTimer?.cancel();
      
      await _storage.clearTokens();
      
      _logger.i('All tokens cleared');
      
    } catch (e) {
      _logger.e('Failed to clear tokens: $e');
      throw TokenManagerException('Failed to clear tokens: $e');
    }
  }

  /// 手动刷新访问token
  Future<bool> refreshAccessToken() async {
    return await _refreshAccessToken();
  }

  /// 从存储加载token
  Future<void> _loadTokensFromStorage() async {
    try {
      final accessToken = await _storage.getAccessToken();
      final refreshToken = await _storage.getRefreshToken();
      
      if (accessToken != null) {
        _currentAccessToken = TokenInfo.fromJwt(accessToken);
      }
      
      if (refreshToken != null) {
        _currentRefreshToken = TokenInfo.fromJwt(refreshToken);
      }
      
      _logger.d('Tokens loaded from storage');
      
    } catch (e) {
      _logger.e('Failed to load tokens from storage: $e');
      // 如果加载失败，清除可能损坏的token
      await _storage.clearTokens();
    }
  }

  /// 启动自动刷新机制
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    
    if (_currentAccessToken == null) return;
    
    // 计算下次刷新时间（提前5分钟）
    final refreshTime = _currentAccessToken!.expiresAt
        .subtract(const Duration(minutes: 5));
    
    final now = DateTime.now();
    if (refreshTime.isBefore(now)) {
      // 如果已经到了刷新时间，立即刷新
      _refreshAccessToken();
      return;
    }
    
    final delay = refreshTime.difference(now);
    _logger.d('Auto refresh scheduled in ${delay.inMinutes} minutes');
    
    _refreshTimer = Timer(delay, () {
      _refreshAccessToken();
    });
  }

  /// 刷新访问token的内部实现
  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        _logger.e('No refresh token available for refresh');
        return false;
      }
      
      _logger.i('Refreshing access token...');
      
      // 使用AuthInterceptor中的刷新逻辑
      // 这里简化实现，实际项目中应该通过依赖注入获取AuthRepository
      final success = await _performDirectTokenRefresh(refreshToken);
      
      if (success) {
        _onTokenRefreshed?.call(_currentAccessToken!.token, _currentRefreshToken!.token);
        return true;
      }
      
      return false;
      
    } catch (e) {
      _logger.e('Failed to refresh access token: $e');
      return false;
    }
  }

  /// 执行直接的token刷新（临时实现）
  Future<bool> _performDirectTokenRefresh(String refreshToken) async {
    try {
      // 导入Dio和ApiConstants
      final dio = _createBasicDio();
      
      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          await saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          
          _logger.i('Direct token refresh successful');
          return true;
        }
      }

      _logger.e('Token refresh response invalid: ${response.statusCode}');
      return false;
      
    } catch (e) {
      _logger.e('Direct token refresh failed: $e');
      return false;
    }
  }

  /// 创建基础的Dio实例（不包含拦截器）
  dynamic _createBasicDio() {
    // 这里应该返回配置好的Dio实例
    // 暂时返回null，实际使用时需要正确配置
    _logger.w('Basic Dio instance not configured');
    return null;
  }

  /// 处理token过期
  Future<void> _handleTokenExpired() async {
    _logger.w('Handling token expiration');
    
    await clearTokens();
    _onTokenExpired?.call();
  }

  /// 获取token统计信息
  Map<String, dynamic> getTokenStats() {
    return {
      'hasAccessToken': _currentAccessToken != null,
      'hasRefreshToken': _currentRefreshToken != null,
      'accessTokenExpired': _currentAccessToken?.isExpired ?? true,
      'refreshTokenExpired': _currentRefreshToken?.isExpired ?? true,
      'accessTokenExpiringSoon': _currentAccessToken?.isExpiringSoon ?? false,
      'accessTokenRemainingTime': _currentAccessToken?.remainingTime.inMinutes,
      'refreshTokenRemainingTime': _currentRefreshToken?.remainingTime.inMinutes,
    };
  }

  /// 清理资源
  void dispose() {
    _refreshTimer?.cancel();
    _logger.d('TokenManager disposed');
  }
}

/// Token管理异常
class TokenManagerException implements Exception {
  final String message;
  
  const TokenManagerException(this.message);
  
  @override
  String toString() => 'TokenManagerException: $message';
}

/// Token解析异常
class TokenParseException implements Exception {
  final String message;
  
  const TokenParseException(this.message);
  
  @override
  String toString() => 'TokenParseException: $message';
} 