/// 安全配置类 - 定义应用的安全相关设置
class SecurityConfig {
  // Token相关配置
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const Duration maxTokenAge = Duration(hours: 24);
  static const Duration refreshTokenMaxAge = Duration(days: 30);
  
  // 存储安全配置
  static const String keyAlias = 'XLoopSecureStorage';
  static const bool requireAuthentication = true;
  static const bool requireBiometrics = false;
  
  // 会话配置
  static const Duration sessionTimeout = Duration(hours: 8);
  static const Duration inactivityTimeout = Duration(minutes: 30);
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  
  // 密码策略
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const bool requireUppercase = true;
  static const bool requireLowercase = true;
  static const bool requireNumbers = true;
  static const bool requireSpecialChars = true;
  
  // 网络安全
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const bool enableCertificatePinning = false; // 生产环境应启用
  
  // 调试和日志
  static const bool enableSecurityLogs = true;
  static const bool enableNetworkLogs = false; // 生产环境应禁用
  static const bool enableTokenLogs = false; // 生产环境应禁用
  
  // 加密配置
  static const String encryptionAlgorithm = 'AES-256-GCM';
  static const int keyDerivationIterations = 10000;
  static const int saltLength = 32;
  
  /// 获取安全存储选项
  static Map<String, String> getSecureStorageOptions() {
    return {
      'encryptedSharedPreferences': 'true',
      'keyCipherAlgorithm': 'RSA/ECB/PKCS1Padding',
      'storageCipherAlgorithm': 'AES/GCM/NoPadding',
      'keySize': '256',
      'requireAuthentication': requireAuthentication.toString(),
    };
  }
  
  /// 获取网络安全配置
  static Map<String, dynamic> getNetworkSecurityConfig() {
    return {
      'connectTimeout': connectTimeout.inMilliseconds,
      'receiveTimeout': receiveTimeout.inMilliseconds,
      'sendTimeout': networkTimeout.inMilliseconds,
      'enableCertificatePinning': enableCertificatePinning,
      'validateCertificate': true,
      'followRedirects': false,
      'maxRedirects': 0,
    };
  }
  
  /// 获取Token安全配置
  static Map<String, dynamic> getTokenSecurityConfig() {
    return {
      'refreshThreshold': tokenRefreshThreshold.inMinutes,
      'maxAge': maxTokenAge.inHours,
      'refreshTokenMaxAge': refreshTokenMaxAge.inDays,
      'autoRefresh': true,
      'validateExpiry': true,
      'clearOnExpiry': true,
    };
  }
  
  /// 获取会话安全配置
  static Map<String, dynamic> getSessionSecurityConfig() {
    return {
      'sessionTimeout': sessionTimeout.inHours,
      'inactivityTimeout': inactivityTimeout.inMinutes,
      'maxLoginAttempts': maxLoginAttempts,
      'lockoutDuration': lockoutDuration.inMinutes,
      'trackFailedAttempts': true,
      'enableSessionValidation': true,
    };
  }
  
  /// 验证密码强度
  static bool validatePasswordStrength(String password) {
    if (password.length < minPasswordLength || password.length > maxPasswordLength) {
      return false;
    }
    
    if (requireUppercase && !password.contains(RegExp(r'[A-Z]'))) {
      return false;
    }
    
    if (requireLowercase && !password.contains(RegExp(r'[a-z]'))) {
      return false;
    }
    
    if (requireNumbers && !password.contains(RegExp(r'[0-9]'))) {
      return false;
    }
    
    if (requireSpecialChars && !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return false;
    }
    
    return true;
  }
  
  /// 获取密码强度要求描述
  static String getPasswordRequirements() {
    final requirements = <String>[];
    
    requirements.add('长度在 $minPasswordLength-$maxPasswordLength 个字符之间');
    
    if (requireUppercase) {
      requirements.add('至少包含一个大写字母');
    }
    
    if (requireLowercase) {
      requirements.add('至少包含一个小写字母');
    }
    
    if (requireNumbers) {
      requirements.add('至少包含一个数字');
    }
    
    if (requireSpecialChars) {
      requirements.add('至少包含一个特殊字符');
    }
    
    return requirements.join('\n');
  }
  
  /// 检查是否为生产环境
  static bool get isProduction {
    // 这里可以根据实际的环境检测逻辑来实现
    // 例如检查 kDebugMode 或环境变量
    return false; // 暂时返回false，实际应用中需要正确实现
  }
  
  /// 获取适用于当前环境的安全级别
  static SecurityLevel get currentSecurityLevel {
    return isProduction ? SecurityLevel.high : SecurityLevel.medium;
  }
}

/// 安全级别枚举
enum SecurityLevel {
  low,    // 开发环境
  medium, // 测试环境
  high,   // 生产环境
}

/// 安全级别配置
extension SecurityLevelConfig on SecurityLevel {
  /// 是否启用详细日志
  bool get enableDetailedLogs {
    switch (this) {
      case SecurityLevel.low:
        return true;
      case SecurityLevel.medium:
        return true;
      case SecurityLevel.high:
        return false;
    }
  }
  
  /// 是否启用网络日志
  bool get enableNetworkLogs {
    switch (this) {
      case SecurityLevel.low:
        return true;
      case SecurityLevel.medium:
        return false;
      case SecurityLevel.high:
        return false;
    }
  }
  
  /// 是否启用Token日志
  bool get enableTokenLogs {
    switch (this) {
      case SecurityLevel.low:
        return true;
      case SecurityLevel.medium:
        return false;
      case SecurityLevel.high:
        return false;
    }
  }
  
  /// 是否启用证书固定
  bool get enableCertificatePinning {
    switch (this) {
      case SecurityLevel.low:
        return false;
      case SecurityLevel.medium:
        return false;
      case SecurityLevel.high:
        return true;
    }
  }
  
  /// Token刷新阈值
  Duration get tokenRefreshThreshold {
    switch (this) {
      case SecurityLevel.low:
        return const Duration(minutes: 10);
      case SecurityLevel.medium:
        return const Duration(minutes: 5);
      case SecurityLevel.high:
        return const Duration(minutes: 2);
    }
  }
} 