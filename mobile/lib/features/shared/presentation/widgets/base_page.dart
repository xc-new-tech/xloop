import 'package:flutter/material.dart';

export 'base_loading_page.dart';
export 'base_error_page.dart';
export 'base_empty_page.dart';

/// 基础页面组件
/// 提供统一的页面布局、样式和通用功能
class BasePage extends StatelessWidget {
  final String? title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool showAppBar;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final VoidCallback? onWillPop;
  final EdgeInsetsGeometry? padding;
  final bool safeArea;

  const BasePage({
    super.key,
    this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.bottom,
    this.drawer,
    this.endDrawer,
    this.showAppBar = true,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.floatingActionButtonLocation,
    this.onWillPop,
    this.padding,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget pageBody = body;

    // 添加内边距
    if (padding != null) {
      pageBody = Padding(
        padding: padding!,
        child: pageBody,
      );
    }

    // 添加安全区域
    if (safeArea) {
      pageBody = SafeArea(child: pageBody);
    }

    Widget scaffold = Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: title != null ? Text(title!) : null,
              actions: actions,
              bottom: bottom,
              backgroundColor: backgroundColor,
            )
          : null,
      body: pageBody,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );

    // 处理返回按钮
    if (onWillPop != null) {
      scaffold = PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (!didPop) {
            onWillPop!();
          }
        },
        child: scaffold,
      );
    }

    return scaffold;
  }
}

/// 基础页面组件（带有滚动）
class BaseScrollPage extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const BaseScrollPage({
    super.key,
    this.title,
    required this.children,
    this.floatingActionButton,
    this.actions,
    this.bottom,
    this.padding,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: title,
      actions: actions,
      bottom: bottom,
      floatingActionButton: floatingActionButton,
      body: SingleChildScrollView(
        controller: controller,
        physics: physics,
        padding: padding,
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          children: children,
        ),
      ),
    );
  }
}

/// 基础空状态页面
class BaseEmptyPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? illustration;
  final String? actionText;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  const BaseEmptyPage({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.illustration,
    this.actionText,
    this.onAction,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: padding ?? const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标或插图
          if (illustration != null)
            illustration!
          else if (icon != null)
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.outline,
            ),
          
          const SizedBox(height: 16),
          
          // 标题
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          
          // 副标题
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          // 操作按钮
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionText!),
            ),
          ],
        ],
      ),
    );
  }
}

/// 基础加载页面
class BaseLoadingPage extends StatelessWidget {
  final String? message;
  final EdgeInsetsGeometry? padding;

  const BaseLoadingPage({
    super.key,
    this.message,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: padding ?? const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// 基础错误页面
class BaseErrorPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  const BaseErrorPage({
    super.key,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: padding ?? const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionText!),
            ),
          ],
        ],
      ),
    );
  }
} 