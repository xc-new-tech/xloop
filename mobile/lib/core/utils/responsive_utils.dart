import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 响应式设计工具类
class ResponsiveUtils {
  ResponsiveUtils._();

  /// 屏幕断点定义
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// 获取当前设备类型
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// 判断是否为移动设备
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// 判断是否为平板设备
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// 判断是否为桌面设备
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// 判断是否为横屏
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// 判断是否为竖屏
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// 获取安全区域高度
  static double getSafeAreaHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height - 
           mediaQuery.padding.top - 
           mediaQuery.padding.bottom;
  }

  /// 获取状态栏高度
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// 获取底部安全区域高度
  static double getBottomSafeAreaHeight(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  /// 获取键盘高度
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// 判断键盘是否弹出
  static bool isKeyboardVisible(BuildContext context) {
    return getKeyboardHeight(context) > 0;
  }

  /// 根据设备类型返回不同的值
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// 根据屏幕宽度返回列数
  static int getGridColumns(BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
  }) {
    return responsive(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );
  }

  /// 获取适应性的内边距
  static EdgeInsets getAdaptivePadding(BuildContext context, {
    double mobile = 16.0,
    double? tablet,
    double? desktop,
  }) {
    final padding = responsive(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.5,
      desktop: desktop ?? mobile * 2,
    );
    return EdgeInsets.all(padding);
  }

  /// 获取适应性的字体大小
  static double getAdaptiveFontSize(BuildContext context, {
    required double baseFontSize,
    double mobileScale = 1.0,
    double tabletScale = 1.1,
    double desktopScale = 1.2,
  }) {
    final scale = responsive(
      context,
      mobile: mobileScale,
      tablet: tabletScale,
      desktop: desktopScale,
    );
    return baseFontSize * scale;
  }

  /// 获取适应性的图标大小
  static double getAdaptiveIconSize(BuildContext context, {
    double mobile = 24.0,
    double? tablet,
    double? desktop,
  }) {
    return responsive(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.2,
      desktop: desktop ?? mobile * 1.4,
    );
  }

  /// 获取适应性的卡片高度
  static double getAdaptiveCardHeight(BuildContext context, {
    double mobile = 120.0,
    double? tablet,
    double? desktop,
  }) {
    return responsive(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.2,
      desktop: desktop ?? mobile * 1.4,
    );
  }

  /// 获取适应性的按钮高度
  static double getAdaptiveButtonHeight(BuildContext context, {
    double mobile = 48.0,
    double? tablet,
    double? desktop,
  }) {
    return responsive(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.1,
      desktop: desktop ?? mobile * 1.2,
    );
  }

  /// 获取适应性的间距
  static double getAdaptiveSpacing(BuildContext context, {
    double mobile = 16.0,
    double? tablet,
    double? desktop,
  }) {
    return responsive(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.2,
      desktop: desktop ?? mobile * 1.5,
    );
  }

  /// 获取适应性的圆角半径
  static double getAdaptiveBorderRadius(BuildContext context, {
    double mobile = 8.0,
    double? tablet,
    double? desktop,
  }) {
    return responsive(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.2,
      desktop: desktop ?? mobile * 1.5,
    );
  }

  /// 获取最大内容宽度（防止在大屏幕上内容过宽）
  static double getMaxContentWidth(BuildContext context, {
    double maxWidth = 600.0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > maxWidth ? maxWidth : screenWidth;
  }

  /// 获取适应性的对话框宽度
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isMobile(context)) {
      return screenWidth * 0.9;
    } else if (isTablet(context)) {
      return screenWidth * 0.7;
    } else {
      return 500.0;
    }
  }

  /// 获取适应性的侧边栏宽度
  static double getSidebarWidth(BuildContext context) {
    return responsive(
      context,
      mobile: 280.0,
      tablet: 320.0,
      desktop: 360.0,
    );
  }

  /// 判断是否应该显示侧边栏
  static bool shouldShowSidebar(BuildContext context) {
    return !isMobile(context);
  }

  /// 获取适应性的应用栏高度
  static double getAppBarHeight(BuildContext context) {
    return responsive(
      context,
      mobile: kToolbarHeight,
      tablet: kToolbarHeight + 8,
      desktop: kToolbarHeight + 16,
    );
  }

  /// 获取适应性的底部导航栏高度
  static double getBottomNavHeight(BuildContext context) {
    return responsive(
      context,
      mobile: 60.0,
      tablet: 70.0,
      desktop: 80.0,
    );
  }

  /// 获取触摸目标的最小尺寸
  static double getMinTouchTargetSize(BuildContext context) {
    return responsive(
      context,
      mobile: 44.0,
      tablet: 48.0,
      desktop: 52.0,
    );
  }

  /// 获取列表项的高度
  static double getListItemHeight(BuildContext context) {
    return responsive(
      context,
      mobile: 56.0,
      tablet: 64.0,
      desktop: 72.0,
    );
  }

  /// 获取卡片的阴影
  static List<BoxShadow> getAdaptiveCardShadow(BuildContext context) {
    final elevation = responsive(
      context,
      mobile: 2.0,
      tablet: 4.0,
      desktop: 6.0,
    );
    
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
      ),
    ];
  }

  /// 获取适应性的网格交叉轴间距
  static double getGridCrossAxisSpacing(BuildContext context) {
    return responsive(
      context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );
  }

  /// 获取适应性的网格主轴间距
  static double getGridMainAxisSpacing(BuildContext context) {
    return responsive(
      context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );
  }

  /// 获取适应性的子宽高比
  static double getGridChildAspectRatio(BuildContext context) {
    return responsive(
      context,
      mobile: 1.0,
      tablet: 1.2,
      desktop: 1.4,
    );
  }
}

/// 设备类型枚举
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// 屏幕尺寸扩展
extension ScreenSizeExtension on BuildContext {
  /// 获取屏幕宽度
  double get screenWidth => MediaQuery.of(this).size.width;
  
  /// 获取屏幕高度
  double get screenHeight => MediaQuery.of(this).size.height;
  
  /// 获取设备类型
  DeviceType get deviceType => ResponsiveUtils.getDeviceType(this);
  
  /// 是否为移动设备
  bool get isMobile => ResponsiveUtils.isMobile(this);
  
  /// 是否为平板设备
  bool get isTablet => ResponsiveUtils.isTablet(this);
  
  /// 是否为桌面设备
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  
  /// 是否为横屏
  bool get isLandscape => ResponsiveUtils.isLandscape(this);
  
  /// 是否为竖屏
  bool get isPortrait => ResponsiveUtils.isPortrait(this);
  
  /// 键盘是否可见
  bool get isKeyboardVisible => ResponsiveUtils.isKeyboardVisible(this);
} 