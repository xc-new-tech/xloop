import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';

import 'token_manager.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/models/user_model.dart';

/// 用户会话状态
enum SessionState {
  unknown,          // 未知状态
  unauthenticated,  // 未认证
  authenticated,    // 已认证
  expired,          // 会话过期
}

/// 会话管理器 - 管理用户登录状态和会话信息
class SessionManager {
  static SessionManager? _instance;
  late TokenManager _tokenManager;
  late TokenStorage _tokenStorage;
  late Logger _logger;

  // 当前用户信息
  UserModel? _currentUser;
  SessionState _sessionState = SessionState.unknown;

  // 状态变化流
  final StreamController<SessionState> _stateController = 
      StreamController<SessionState>.broadcast();
  final StreamController<UserModel?> _userController = 
      StreamController<UserModel?>.broadcast();

  SessionManager._internal();

  static Future<SessionManager> getInstance() async {
    if (_instance == null) {
      _instance = SessionManager._internal();
      await _instance!._init();
    }
    return _instance!;
  }

  /// 会话状态流
  Stream<SessionState> get sessionStateStream => _stateController.stream;

  /// 用户信息流
  Stream<UserModel?> get userStream => _userController.stream;

  /// 当前会话状态
  SessionState get sessionState => _sessionState;

  /// 当前用户
  UserModel? get currentUser => _currentUser;

  /// 是否已登录
  bool get isLoggedIn => _sessionState == SessionState.authenticated;

  Future<void> _init() async {
    _tokenManager = await TokenManager.getInstance();
    _tokenStorage = await TokenStorage.getInstance();
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

    // 设置Token管理器的回调
    _tokenManager.setCallbacks(
      onTokenRefreshed: _onTokenRefreshed,
      onTokenExpired: _onTokenExpired,
    );

    // 检查现有会话
    await _checkExistingSession();

    _logger.d('SessionManager initialized');
  }

  /// 用户登录
  Future<void> login({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
    bool rememberMe = false,
  }) async {
    try {
      _logger.i('Starting user login session');

      // 保存tokens
      await _tokenManager.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      // 保存用户信息
      await _saveUserData(user);

      // 如果选择记住我，保存凭据
      if (rememberMe) {
        // 这里应该保存加密的凭据，实际应用中需要更安全的处理
        _logger.d('Remember me enabled for user: ${user.email}');
      }

      // 更新状态
      _currentUser = user;
      _updateSessionState(SessionState.authenticated);

      _logger.i('User login session established for: ${user.email}');

    } catch (e) {
      _logger.e('Failed to establish login session: $e');
      throw SessionManagerException('Login session failed: $e');
    }
  }

  /// 用户登出
  Future<void> logout({bool clearRememberedCredentials = false}) async {
    try {
      _logger.i('Starting user logout');

      // 清除tokens
      await _tokenManager.clearTokens();

      // 清除用户数据
      await _clearUserData();

      // 如果需要，清除记住的凭据
      if (clearRememberedCredentials) {
        await _tokenStorage.clearUserCredentials();
        _logger.d('Cleared remembered credentials');
      }

      // 更新状态
      _currentUser = null;
      _updateSessionState(SessionState.unauthenticated);

      _logger.i('User logout completed');

    } catch (e) {
      _logger.e('Failed to logout: $e');
      throw SessionManagerException('Logout failed: $e');
    }
  }

  /// 更新用户信息
  Future<void> updateUser(UserModel user) async {
    try {
      await _saveUserData(user);
      _currentUser = user;
      _userController.add(_currentUser);
      _logger.d('User data updated');
    } catch (e) {
      _logger.e('Failed to update user data: $e');
      throw SessionManagerException('Update user failed: $e');
    }
  }

  /// 刷新用户信息（从服务器获取最新数据）
  Future<UserModel?> refreshUserInfo() async {
    try {
      if (!isLoggedIn) {
        _logger.w('Cannot refresh user info: not logged in');
        return null;
      }

      // TODO: 这里应该调用API获取最新用户信息
      // final userResult = await _authRepository.getUserInfo();
      // if (userResult.isRight()) {
      //   final user = userResult.getOrElse(() => throw Exception());
      //   await updateUser(user);
      //   return user;
      // }

      _logger.w('User info refresh not implemented yet');
      return _currentUser;

    } catch (e) {
      _logger.e('Failed to refresh user info: $e');
      return null;
    }
  }

  /// 检查现有会话
  Future<void> _checkExistingSession() async {
    try {
      _logger.d('Checking existing session...');

      // 检查是否有有效的token
      final isLoggedIn = await _tokenManager.isLoggedIn();
      
      if (isLoggedIn) {
        // 尝试加载用户数据
        final userData = await _loadUserData();
        
        if (userData != null) {
          _currentUser = userData;
          _updateSessionState(SessionState.authenticated);
          _logger.i('Existing session restored for: ${userData.email}');
        } else {
          _logger.w('Valid token found but no user data, clearing session');
          await _tokenManager.clearTokens();
          _updateSessionState(SessionState.unauthenticated);
        }
      } else {
        _updateSessionState(SessionState.unauthenticated);
        _logger.d('No existing session found');
      }

    } catch (e) {
      _logger.e('Error checking existing session: $e');
      _updateSessionState(SessionState.unauthenticated);
    }
  }

  /// 保存用户数据
  Future<void> _saveUserData(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _tokenStorage.saveUserData(userJson);
    } catch (e) {
      _logger.e('Failed to save user data: $e');
      throw SessionManagerException('Save user data failed: $e');
    }
  }

  /// 加载用户数据
  Future<UserModel?> _loadUserData() async {
    try {
      final userJson = await _tokenStorage.getUserData();
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      _logger.e('Failed to load user data: $e');
      return null;
    }
  }

  /// 清除用户数据
  Future<void> _clearUserData() async {
    try {
      await _tokenStorage.clearUserData();
    } catch (e) {
      _logger.e('Failed to clear user data: $e');
    }
  }

  /// 更新会话状态
  void _updateSessionState(SessionState newState) {
    if (_sessionState != newState) {
      _sessionState = newState;
      _stateController.add(_sessionState);
      _logger.d('Session state changed to: $newState');
    }
  }

  /// Token刷新回调
  void _onTokenRefreshed(String accessToken, String refreshToken) {
    _logger.d('Tokens refreshed automatically');
    // 保持会话状态为已认证
    if (_sessionState != SessionState.authenticated) {
      _updateSessionState(SessionState.authenticated);
    }
  }

  /// Token过期回调
  void _onTokenExpired() {
    _logger.w('Token expired, ending session');
    _currentUser = null;
    _updateSessionState(SessionState.expired);
    _userController.add(null);
  }

  /// 检查是否可以自动登录
  Future<bool> canAutoLogin() async {
    try {
      final credentials = await _tokenStorage.getUserCredentials();
      return credentials != null;
    } catch (e) {
      _logger.e('Error checking auto login capability: $e');
      return false;
    }
  }

  /// 获取记住的凭据
  Future<Map<String, String>?> getRememberedCredentials() async {
    try {
      return await _tokenStorage.getUserCredentials();
    } catch (e) {
      _logger.e('Error getting remembered credentials: $e');
      return null;
    }
  }

  /// 清除记住的凭据
  Future<void> clearRememberedCredentials() async {
    try {
      await _tokenStorage.clearUserCredentials();
      _logger.d('Remembered credentials cleared');
    } catch (e) {
      _logger.e('Error clearing remembered credentials: $e');
    }
  }

  /// 获取会话统计信息
  Map<String, dynamic> getSessionStats() {
    final tokenStats = _tokenManager.getTokenStats();
    
    return {
      'sessionState': _sessionState.toString(),
      'hasUser': _currentUser != null,
      'userId': _currentUser?.id,
      'userEmail': _currentUser?.email,
      'tokenStats': tokenStats,
    };
  }

  /// 强制刷新会话
  Future<void> forceRefreshSession() async {
    _logger.i('Force refreshing session...');
    await _checkExistingSession();
  }

  /// 清理资源
  void dispose() {
    _stateController.close();
    _userController.close();
    _logger.d('SessionManager disposed');
  }
}

/// 会话管理异常
class SessionManagerException implements Exception {
  final String message;
  
  const SessionManagerException(this.message);
  
  @override
  String toString() => 'SessionManagerException: $message';
} 