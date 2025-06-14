import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 应用主题配置
class AppTheme {
  AppTheme._();

  // 主色调
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryVariant = Color(0xFF1976D2);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);

  // 状态颜色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // 中性色
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  /// 亮色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondary,
        surface: white,
        error: error,
        onPrimary: white,
        onSecondary: black,
        onSurface: grey900,
        onError: white,
      ),
      
      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: grey900,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: grey900,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // 卡片主题
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryColor,
        unselectedItemColor: grey500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: grey200,
        thickness: 1,
      ),

      // 字体主题
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: grey900),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: grey900),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: grey900),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: grey900),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: grey900),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: grey900),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: grey900),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: grey900),
        titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: grey700),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: grey900),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: grey900),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: grey700),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: grey900),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: grey700),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: grey600),
      ),
    );
  }

  /// 暗色主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondary,
        surface: grey800,
        error: error,
        onPrimary: white,
        onSecondary: black,
        onSurface: white,
        onError: black,
      ),
      
      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: grey900,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // 其他组件主题配置...
      // 这里可以继续配置暗色主题的其他组件
    );
  }
} 