import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// 通用空状态组件
/// 提供统一的空状态显示界面和交互
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    Key? key,
    required this.message,
    this.title,
    this.icon,
    this.onAction,
    this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: 64,
            color: Colors.grey.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          if (onAction != null && actionText != null) ...[
            const SizedBox(height: 16),
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

/// 空状态类型枚举
enum EmptyStateType {
  general,
  search,
  data,
  files,
  conversations,
  knowledge,
  favorites,
  history,
  notifications,
}

/// 空状态信息数据类
class _EmptyInfo {
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final IconData actionIcon;

  _EmptyInfo({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    required this.actionIcon,
  });
}

/// 带插图的空状态组件
class IllustrationEmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final String illustrationAsset;
  final String? actionText;
  final VoidCallback? onAction;

  const IllustrationEmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.illustrationAsset,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      message: message,
      title: title,
      icon: Icons.inbox_outlined,
      onAction: onAction,
      actionText: actionText,
    );
  }
}

/// 自定义空状态组件
class CustomEmptyWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? color;

  const CustomEmptyWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      message: message,
      title: title,
      icon: icon,
    );
  }
} 