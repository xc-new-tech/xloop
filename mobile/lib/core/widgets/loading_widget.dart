import 'package:flutter/material.dart';

/// 通用加载组件
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              color: color ?? Theme.of(context).primaryColor,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// 小型加载指示器
class SmallLoadingWidget extends StatelessWidget {
  final Color? color;
  final double size;

  const SmallLoadingWidget({
    super.key,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color ?? Theme.of(context).primaryColor,
        strokeWidth: 2,
      ),
    );
  }
}

/// 页面级加载组件
class PageLoadingWidget extends StatelessWidget {
  final String? message;

  const PageLoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingWidget(
        message: message ?? '加载中...',
      ),
    );
  }
} 