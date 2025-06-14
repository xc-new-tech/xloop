import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// 通用错误组件
/// 提供统一的错误显示界面和交互
class AppErrorWidget extends StatelessWidget {
  final String? message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? actionText;
  final VoidCallback? onAction;
  final ErrorType type;
  final bool compact;

  const AppErrorWidget({
    super.key,
    this.message,
    this.title,
    this.icon,
    this.onRetry,
    this.actionText,
    this.onAction,
    this.type = ErrorType.general,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final errorInfo = _getErrorInfo();
    
    if (compact) {
      return _buildCompactError(context, errorInfo);
    }
    
    return _buildFullError(context, errorInfo);
  }

  Widget _buildFullError(BuildContext context, _ErrorInfo errorInfo) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 错误图标
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: errorInfo.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                errorInfo.icon,
                size: 40,
                color: errorInfo.color,
              ),
            ),
            const SizedBox(height: 24),
            
            // 错误标题
            Text(
              title ?? errorInfo.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // 错误信息
            Text(
              message ?? errorInfo.message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // 操作按钮
            _buildActionButtons(errorInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactError(BuildContext context, _ErrorInfo errorInfo) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: errorInfo.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: errorInfo.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            errorInfo.icon,
            color: errorInfo.color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title ?? errorInfo.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    message!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              color: errorInfo.color,
              iconSize: 20,
              tooltip: '重试',
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(_ErrorInfo errorInfo) {
    final buttons = <Widget>[];

    // 重试按钮
    if (onRetry != null) {
      buttons.add(
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('重试'),
          style: FilledButton.styleFrom(
            backgroundColor: errorInfo.color,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    // 自定义操作按钮
    if (onAction != null && actionText != null) {
      buttons.add(
        OutlinedButton(
          onPressed: onAction,
          style: OutlinedButton.styleFrom(
            foregroundColor: errorInfo.color,
            side: BorderSide(color: errorInfo.color),
          ),
          child: Text(actionText!),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    if (buttons.length == 1) {
      return buttons.first;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          buttons[i],
        ],
      ],
    );
  }

  _ErrorInfo _getErrorInfo() {
    switch (type) {
      case ErrorType.network:
        return _ErrorInfo(
          icon: Icons.wifi_off,
          title: '网络连接错误',
          message: '请检查您的网络连接并重试',
          color: AppColors.warning,
        );
      case ErrorType.server:
        return _ErrorInfo(
          icon: Icons.error_outline,
          title: '服务器错误',
          message: '服务器暂时无法响应，请稍后重试',
          color: AppColors.error,
        );
      case ErrorType.notFound:
        return _ErrorInfo(
          icon: Icons.search_off,
          title: '内容不存在',
          message: '您要查找的内容不存在或已被删除',
          color: AppColors.warning,
        );
      case ErrorType.permission:
        return _ErrorInfo(
          icon: Icons.lock_outline,
          title: '权限不足',
          message: '您没有权限访问此内容',
          color: AppColors.error,
        );
      case ErrorType.timeout:
        return _ErrorInfo(
          icon: Icons.schedule,
          title: '请求超时',
          message: '网络请求超时，请检查网络连接并重试',
          color: AppColors.warning,
        );
      case ErrorType.validation:
        return _ErrorInfo(
          icon: Icons.warning_outlined,
          title: '数据验证失败',
          message: '请检查输入的数据是否正确',
          color: AppColors.warning,
        );
      case ErrorType.general:
      default:
        return _ErrorInfo(
          icon: Icons.error_outline,
          title: '出错了',
          message: '发生了未知错误，请重试',
          color: AppColors.error,
        );
    }
  }

  /// 创建网络错误组件
  factory AppErrorWidget.network({
    String? message,
    VoidCallback? onRetry,
    bool compact = false,
  }) {
    return AppErrorWidget(
      type: ErrorType.network,
      message: message,
      onRetry: onRetry,
      compact: compact,
    );
  }

  /// 创建服务器错误组件
  factory AppErrorWidget.server({
    String? message,
    VoidCallback? onRetry,
    bool compact = false,
  }) {
    return AppErrorWidget(
      type: ErrorType.server,
      message: message,
      onRetry: onRetry,
      compact: compact,
    );
  }

  /// 创建未找到错误组件
  factory AppErrorWidget.notFound({
    String? message,
    VoidCallback? onAction,
    String? actionText,
    bool compact = false,
  }) {
    return AppErrorWidget(
      type: ErrorType.notFound,
      message: message,
      onAction: onAction,
      actionText: actionText,
      compact: compact,
    );
  }

  /// 创建权限错误组件
  factory AppErrorWidget.permission({
    String? message,
    VoidCallback? onAction,
    String? actionText,
    bool compact = false,
  }) {
    return AppErrorWidget(
      type: ErrorType.permission,
      message: message,
      onAction: onAction,
      actionText: actionText,
      compact: compact,
    );
  }
}

/// 错误类型枚举
enum ErrorType {
  general,
  network,
  server,
  notFound,
  permission,
  timeout,
  validation,
}

/// 错误信息数据类
class _ErrorInfo {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  _ErrorInfo({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });
}

/// 自定义错误组件，用于处理异常情况
class CustomErrorWidget extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      message: message,
      actionText: actionText,
      onAction: onAction,
    );
  }
}

/// 错误边界组件，用于捕获和显示错误
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace stackTrace)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace!) ??
          AppErrorWidget(
            title: '应用程序错误',
            message: _error.toString(),
            onRetry: () {
              setState(() {
                _error = null;
                _stackTrace = null;
              });
            },
          );
    }

    return widget.child;
  }

  void _handleError(Object error, StackTrace stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });
  }
} 