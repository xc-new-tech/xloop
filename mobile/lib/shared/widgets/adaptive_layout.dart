import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/utils/responsive_utils.dart';

/// 自适应布局组件
class AdaptiveLayout extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget child;

  const AdaptiveLayout({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.responsive(
      context,
      mobile: mobile ?? child,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// 自适应容器
class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;
  final AlignmentGeometry? alignment;

  const AdaptiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.decoration,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? ResponsiveUtils.getAdaptivePadding(context),
      margin: margin,
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }
}

/// 自适应网格
class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final double? childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const AdaptiveGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.childAspectRatio,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.getGridColumns(
      context,
      mobileColumns: mobileColumns ?? 1,
      tabletColumns: tabletColumns ?? 2,
      desktopColumns: desktopColumns ?? 3,
    );

    return GridView.builder(
      padding: padding ?? ResponsiveUtils.getAdaptivePadding(context),
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: crossAxisSpacing ?? ResponsiveUtils.getGridCrossAxisSpacing(context),
        mainAxisSpacing: mainAxisSpacing ?? ResponsiveUtils.getGridMainAxisSpacing(context),
        childAspectRatio: childAspectRatio ?? ResponsiveUtils.getGridChildAspectRatio(context),
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// 自适应卡片
class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const AdaptiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = ResponsiveUtils.getAdaptiveCardHeight(context);
    final cardBorderRadius = borderRadius ?? 
        BorderRadius.circular(ResponsiveUtils.getAdaptiveBorderRadius(context));

    return Container(
      height: cardHeight,
      margin: margin ?? EdgeInsets.all(ResponsiveUtils.getAdaptiveSpacing(context) / 2),
      child: Card(
        color: color,
        elevation: elevation,
        shape: RoundedRectangleBorder(borderRadius: cardBorderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: cardBorderRadius,
          child: Padding(
            padding: padding ?? ResponsiveUtils.getAdaptivePadding(context),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 自适应按钮
class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;

  const AdaptiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = ResponsiveUtils.getAdaptiveButtonHeight(context);
    final borderRadius = ResponsiveUtils.getAdaptiveBorderRadius(context);

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: icon ?? const SizedBox.shrink(),
              label: isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(text),
              style: OutlinedButton.styleFrom(
                foregroundColor: textColor ?? Theme.of(context).primaryColor,
                side: BorderSide(
                  color: backgroundColor ?? Theme.of(context).primaryColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: icon ?? const SizedBox.shrink(),
              label: isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(text),
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
                foregroundColor: textColor ?? Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ),
    );
  }
}

/// 自适应文本
class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? baseFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AdaptiveText({
    super.key,
    required this.text,
    this.style,
    this.baseFontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final adaptiveFontSize = baseFontSize != null
        ? ResponsiveUtils.getAdaptiveFontSize(context, baseFontSize: baseFontSize!)
        : null;

    return Text(
      text,
      style: (style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
        fontSize: adaptiveFontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// 自适应图标
class AdaptiveIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  const AdaptiveIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final adaptiveSize = size != null
        ? ResponsiveUtils.getAdaptiveIconSize(context, mobile: size!)
        : ResponsiveUtils.getAdaptiveIconSize(context);

    return Icon(
      icon,
      size: adaptiveSize,
      color: color,
    );
  }
}

/// 自适应列表项
class AdaptiveListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  const AdaptiveListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final listItemHeight = ResponsiveUtils.getListItemHeight(context);

    return SizedBox(
      height: listItemHeight,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        contentPadding: contentPadding ?? ResponsiveUtils.getAdaptivePadding(context),
      ),
    );
  }
}

/// 自适应对话框
class AdaptiveDialog extends StatelessWidget {
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;

  const AdaptiveDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.contentPadding,
    this.actionsPadding,
  });

  @override
  Widget build(BuildContext context) {
    final dialogWidth = ResponsiveUtils.getDialogWidth(context);

    return Dialog(
      child: Container(
        width: dialogWidth,
        padding: contentPadding ?? ResponsiveUtils.getAdaptivePadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              title!,
              SizedBox(height: ResponsiveUtils.getAdaptiveSpacing(context)),
            ],
            if (content != null) ...[
              content!,
              SizedBox(height: ResponsiveUtils.getAdaptiveSpacing(context)),
            ],
            if (actions != null && actions!.isNotEmpty) ...[
              Padding(
                padding: actionsPadding ?? EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 显示自适应对话框
  static Future<T?> show<T>(
    BuildContext context, {
    Widget? title,
    Widget? content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AdaptiveDialog(
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }
}

/// 自适应底部弹窗
class AdaptiveBottomSheet extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool isScrollControlled;

  const AdaptiveBottomSheet({
    super.key,
    required this.child,
    this.height,
    this.padding,
    this.isScrollControlled = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;
    final sheetHeight = height ?? (isScrollControlled ? null : maxHeight * 0.6);

    return Container(
      height: sheetHeight,
      padding: padding ?? ResponsiveUtils.getAdaptivePadding(context),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUtils.getAdaptiveBorderRadius(context) * 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  /// 显示自适应底部弹窗
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    double? height,
    EdgeInsetsGeometry? padding,
    bool isScrollControlled = false,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => AdaptiveBottomSheet(
        height: height,
        padding: padding,
        isScrollControlled: isScrollControlled,
        child: child,
      ),
    );
  }
}

/// 自适应应用栏
class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final double? elevation;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const AdaptiveAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.elevation,
    this.centerTitle = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize {
    final appBarHeight = kToolbarHeight;
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(appBarHeight + bottomHeight);
  }
}

/// 自适应底部导航栏
class AdaptiveBottomNavigationBar extends StatelessWidget {
  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final BottomNavigationBarType? type;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const AdaptiveBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.type,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    final navHeight = ResponsiveUtils.getBottomNavHeight(context);

    return SizedBox(
      height: navHeight,
      child: BottomNavigationBar(
        items: items,
        currentIndex: currentIndex,
        onTap: onTap,
        type: type,
        backgroundColor: backgroundColor,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
      ),
    );
  }
}

/// 自适应侧边栏
class AdaptiveSidebar extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double? width;

  const AdaptiveSidebar({
    super.key,
    required this.child,
    this.backgroundColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = width ?? ResponsiveUtils.getSidebarWidth(context);

    return Container(
      width: sidebarWidth,
      color: backgroundColor ?? Theme.of(context).colorScheme.surface,
      child: child,
    );
  }
}

/// 自适应脚手架
class AdaptiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  const AdaptiveScaffold({
    super.key,
    this.appBar,
    this.body,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      backgroundColor: backgroundColor,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
} 