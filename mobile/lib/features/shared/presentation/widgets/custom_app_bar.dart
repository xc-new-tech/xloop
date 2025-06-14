import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// 自定义应用栏组件
/// 提供统一的应用栏样式和功能
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final double? leadingWidth;
  final TextStyle? titleTextStyle;
  final double toolbarOpacity;
  final double bottomOpacity;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 1.0,
    this.centerTitle = true,
    this.bottom,
    this.leadingWidth,
    this.titleTextStyle,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      titleTextStyle: titleTextStyle ??
          Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: foregroundColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? AppColors.surface,
      foregroundColor: foregroundColor ?? AppColors.textPrimary,
      elevation: elevation,
      centerTitle: centerTitle,
      bottom: bottom,
      leadingWidth: leadingWidth,
      toolbarOpacity: toolbarOpacity,
      bottomOpacity: bottomOpacity,
      surfaceTintColor: Colors.transparent,
      shadowColor: AppColors.shadow.withOpacity(0.1),
    );
  }

  @override
  Size get preferredSize {
    double height = kToolbarHeight;
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }

  /// 创建一个带搜索功能的应用栏
  factory CustomAppBar.withSearch({
    Key? key,
    String? title,
    required VoidCallback onSearchPressed,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    Color? backgroundColor,
    Color? foregroundColor,
    double elevation = 1.0,
    bool centerTitle = true,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchPressed,
          tooltip: '搜索',
        ),
        ...(actions ?? []),
      ],
    );
  }

  /// 创建一个带返回按钮的应用栏
  factory CustomAppBar.withBackButton({
    Key? key,
    String? title,
    Widget? titleWidget,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    Color? backgroundColor,
    Color? foregroundColor,
    double elevation = 1.0,
    bool centerTitle = true,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      titleWidget: titleWidget,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
          tooltip: '返回',
        ),
      ),
      actions: actions,
    );
  }

  /// 创建一个透明的应用栏
  factory CustomAppBar.transparent({
    Key? key,
    String? title,
    Widget? titleWidget,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    Color? foregroundColor,
    bool centerTitle = true,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      titleWidget: titleWidget,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor ?? AppColors.textPrimary,
      elevation: 0,
      centerTitle: centerTitle,
    );
  }

  /// 创建一个带标签栏的应用栏
  factory CustomAppBar.withTabs({
    Key? key,
    String? title,
    Widget? titleWidget,
    required TabBar tabBar,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    Color? backgroundColor,
    Color? foregroundColor,
    double elevation = 1.0,
    bool centerTitle = true,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      titleWidget: titleWidget,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      bottom: tabBar,
    );
  }
}

/// 自定义搜索应用栏
class CustomSearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClosed;
  final TextEditingController? controller;
  final bool autofocus;
  final List<Widget>? actions;

  const CustomSearchAppBar({
    super.key,
    this.hintText = '搜索...',
    this.onChanged,
    this.onSubmitted,
    this.onClosed,
    this.controller,
    this.autofocus = true,
    this.actions,
  });

  @override
  State<CustomSearchAppBar> createState() => _CustomSearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomSearchAppBarState extends State<CustomSearchAppBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 1.0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: widget.onClosed ?? () => Navigator.of(context).pop(),
      ),
      title: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: AppColors.textHint,
            fontSize: 16,
          ),
        ),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
      ),
      actions: [
        if (_controller.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              widget.onChanged?.call('');
            },
          ),
        ...(widget.actions ?? []),
      ],
    );
  }
} 