import 'package:flutter/material.dart';

/// XLoop应用的颜色配置
/// 基于Material Design 3颜色系统
class AppColors {
  // 防止实例化
  AppColors._();

  // ===== 主色调 =====
  static const Color primary = Color(0xFF1565C0); // 蓝色主题
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFD1E4FF);
  static const Color onPrimaryContainer = Color(0xFF001D36);

  // ===== 次级色调 =====
  static const Color secondary = Color(0xFF535F70);
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = Color(0xFFD7E3F7);
  static const Color onSecondaryContainer = Color(0xFF101C2B);

  // ===== 第三级色调 =====
  static const Color tertiary = Color(0xFF6B5B7B);
  static const Color onTertiary = Colors.white;
  static const Color tertiaryContainer = Color(0xFFF2DAFF);
  static const Color onTertiaryContainer = Color(0xFF251431);

  // ===== 错误色调 =====
  static const Color error = Color(0xFFD32F2F);
  static const Color onError = Colors.white;
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410E0B);

  // ===== 成功色调 =====
  static const Color success = Color(0xFF388E3C);
  static const Color onSuccess = Colors.white;
  static const Color successContainer = Color(0xFFD1F2EB);
  static const Color onSuccessContainer = Color(0xFF002114);

  // ===== 警告色调 =====
  static const Color warning = Color(0xFFFF8F00);
  static const Color onWarning = Colors.white;
  static const Color warningContainer = Color(0xFFFFE0B2);
  static const Color onWarningContainer = Color(0xFF2D1B00);

  // ===== 信息色调 =====
  static const Color info = Color(0xFF0288D1);
  static const Color onInfo = Colors.white;
  static const Color infoContainer = Color(0xFFB3E5FC);
  static const Color onInfoContainer = Color(0xFF001E2A);

  // ===== 背景色调 =====
  static const Color background = Color(0xFFFDFCFF);
  static const Color onBackground = Color(0xFF1A1C1E);
  static const Color surface = Color(0xFFFDFCFF);
  static const Color onSurface = Color(0xFF1A1C1E);

  // ===== 表面变体 =====
  static const Color surfaceVariant = Color(0xFFDFE2EB);
  static const Color onSurfaceVariant = Color(0xFF43474E);
  static const Color surfaceTint = primary;

  // ===== 轮廓 =====
  static const Color outline = Color(0xFF73777F);
  static const Color outlineVariant = Color(0xFFC3C7CF);

  // ===== 阴影和叠加 =====
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
  static const Color inverseSurface = Color(0xFF2F3033);
  static const Color onInverseSurface = Color(0xFFF1F0F4);
  static const Color inversePrimary = Color(0xFF9ECAFF);

  // ===== 表面容器级别 =====
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF7F2FA);
  static const Color surfaceContainer = Color(0xFFF1ECF4);
  static const Color surfaceContainerHigh = Color(0xFFEBE6EE);
  static const Color surfaceContainerHighest = Color(0xFFE6E0E9);

  // ===== 中性色调 =====
  static const Color neutral = Color(0xFF79747E);
  static const Color neutralVariant = Color(0xFF49454F);

  // ===== 透明度变体 =====
  static Color primaryWithOpacity(double opacity) => primary.withOpacity(opacity);
  static Color secondaryWithOpacity(double opacity) => secondary.withOpacity(opacity);
  static Color errorWithOpacity(double opacity) => error.withOpacity(opacity);
  static Color successWithOpacity(double opacity) => success.withOpacity(opacity);
  static Color warningWithOpacity(double opacity) => warning.withOpacity(opacity);
  static Color infoWithOpacity(double opacity) => info.withOpacity(opacity);

  // ===== 渐变色 =====
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF535F70), Color(0xFF607D8B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== 特殊用途色彩 =====
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0); // 通用边框颜色
  static const Color divider = Color(0xFFE1E3E6);
  static const Color disabledBackground = Color(0xFFF5F5F5);
  static const Color disabledText = Color(0xFF9E9E9E);

  // ===== 文本色彩 =====
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Colors.white;

  // ===== 图标色彩 =====
  static const Color iconPrimary = Color(0xFF212121);
  static const Color iconSecondary = Color(0xFF757575);

  // ===== 链接和交互色彩 =====
  static const Color link = Color(0xFF1976D2);
  static const Color linkVisited = Color(0xFF7B1FA2);
  static const Color linkHover = Color(0xFF1565C0);

  // ===== 状态指示色彩 =====
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color busy = Color(0xFFFF9800);
  static const Color away = Color(0xFFFFC107);

  // ===== 优先级色彩 =====
  static const Color priorityHigh = Color(0xFFE53935);
  static const Color priorityMedium = Color(0xFFFF8F00);
  static const Color priorityLow = Color(0xFF43A047);

  // ===== 知识库类型色彩 =====
  static const Color publicKnowledgeBase = Color(0xFF4CAF50);
  static const Color privateKnowledgeBase = Color(0xFF2196F3);
  static const Color teamKnowledgeBase = Color(0xFF9C27B0);

  // ===== 文件类型色彩 =====
  static const Color pdfFile = Color(0xFFD32F2F);
  static const Color docFile = Color(0xFF1976D2);
  static const Color excelFile = Color(0xFF388E3C);
  static const Color imageFile = Color(0xFF7B1FA2);
  static const Color textFile = Color(0xFF616161);
  static const Color otherFile = Color(0xFF795548);

  // ===== 对话状态色彩 =====
  static const Color userMessage = Color(0xFF1565C0);
  static const Color aiMessage = Color(0xFF757575);
  static const Color systemMessage = Color(0xFF9C27B0);
  static const Color errorMessage = Color(0xFFD32F2F);

  // ===== 深色主题 (Dark Theme) =====
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkPrimary = Color(0xFF90CAF9);
  static const Color darkOnPrimary = Color(0xFF003258);
  static const Color darkSecondary = Color(0xFFBBC7DB);
  static const Color darkOnSecondary = Color(0xFF253140);

  // ===== 辅助方法 =====
  
  /// 根据背景色自动选择合适的文本颜色
  static Color getTextColorForBackground(Color backgroundColor) {
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    return brightness == Brightness.dark ? Colors.white : Colors.black87;
  }

  /// 获取状态对应的颜色
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'enabled':
      case 'online':
      case 'success':
        return success;
      case 'inactive':
      case 'disabled':
      case 'offline':
        return offline;
      case 'pending':
      case 'processing':
        return warning;
      case 'error':
      case 'failed':
        return error;
      case 'info':
      case 'information':
        return info;
      default:
        return neutral;
    }
  }

  /// 获取优先级对应的颜色
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return priorityHigh;
      case 'medium':
      case 'normal':
        return priorityMedium;
      case 'low':
        return priorityLow;
      default:
        return neutral;
    }
  }

  /// 获取文件类型对应的颜色
  static Color getFileTypeColor(String fileType) {
    final type = fileType.toLowerCase();
    if (type.contains('pdf')) return pdfFile;
    if (type.contains('doc') || type.contains('word')) return docFile;
    if (type.contains('xls') || type.contains('excel')) return excelFile;
    if (type.contains('jpg') || type.contains('png') || type.contains('image')) return imageFile;
    if (type.contains('txt') || type.contains('text')) return textFile;
    return otherFile;
  }
} 