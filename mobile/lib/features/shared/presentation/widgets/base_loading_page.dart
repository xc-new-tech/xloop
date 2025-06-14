import 'package:flutter/material.dart';

/// 基础加载页面组件
class BaseLoadingPage extends StatelessWidget {
  final String? message;
  final bool showAppBar;

  const BaseLoadingPage({
    super.key,
    this.message,
    this.showAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final content = Center(
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

    if (showAppBar) {
      return Scaffold(
        appBar: AppBar(),
        body: content,
      );
    }

    return content;
  }
} 