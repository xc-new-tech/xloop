import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// 通用空状态组件
/// 提供统一的空状态显示界面和交互
class EmptyStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final Widget? illustration;
  final String? actionText;
  final VoidCallback? onAction;
  final EmptyStateType type;
  final bool compact;

  const EmptyStateWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.illustration,
    this.actionText,
    this.onAction,
    this.type = EmptyStateType.general,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final emptyInfo = _getEmptyInfo();
    
    if (compact) {
      return _buildCompactEmpty(context, emptyInfo);
    }
    
    return _buildFullEmpty(context, emptyInfo);
  }

  Widget _buildFullEmpty(BuildContext context, _EmptyInfo emptyInfo) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 空状态插图或图标
            if (illustration != null)
              illustration!
            else
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: emptyInfo.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? emptyInfo.icon,
                  size: 60,
                  color: emptyInfo.color,
                ),
              ),
            const SizedBox(height: 32),
            
            // 空状态标题
            Text(
              title ?? emptyInfo.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // 空状态消息
            Text(
              message ?? emptyInfo.message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 操作按钮
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onAction,
                icon: Icon(emptyInfo.actionIcon, size: 18),
                label: Text(actionText!),
                style: FilledButton.styleFrom(
                  backgroundColor: emptyInfo.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactEmpty(BuildContext context, _EmptyInfo emptyInfo) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? emptyInfo.icon,
            size: 48,
            color: emptyInfo.color,
          ),
          const SizedBox(height: 16),
          Text(
            title ?? emptyInfo.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (onAction != null && actionText != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: emptyInfo.color,
                side: BorderSide(color: emptyInfo.color),
              ),
              child: Text(actionText!),
            ),
          ],
        ],
      ),
    );
  }

  _EmptyInfo _getEmptyInfo() {
    switch (type) {
      case EmptyStateType.search:
        return _EmptyInfo(
          icon: Icons.search_off,
          title: '未找到相关内容',
          message: '尝试调整搜索条件或关键词',
          color: AppColors.info,
          actionIcon: Icons.refresh,
        );
      case EmptyStateType.data:
        return _EmptyInfo(
          icon: Icons.inbox_outlined,
          title: '暂无数据',
          message: '当前还没有任何数据',
          color: AppColors.neutral,
          actionIcon: Icons.add,
        );
      case EmptyStateType.files:
        return _EmptyInfo(
          icon: Icons.folder_open_outlined,
          title: '暂无文件',
          message: '还没有上传任何文件',
          color: AppColors.info,
          actionIcon: Icons.upload_file,
        );
      case EmptyStateType.conversations:
        return _EmptyInfo(
          icon: Icons.chat_bubble_outline,
          title: '暂无对话',
          message: '开始您的第一次对话',
          color: AppColors.primary,
          actionIcon: Icons.add_comment,
        );
      case EmptyStateType.knowledge:
        return _EmptyInfo(
          icon: Icons.library_books_outlined,
          title: '暂无知识库',
          message: '创建您的第一个知识库',
          color: AppColors.tertiary,
          actionIcon: Icons.add,
        );
      case EmptyStateType.favorites:
        return _EmptyInfo(
          icon: Icons.favorite_border,
          title: '暂无收藏',
          message: '收藏感兴趣的内容',
          color: AppColors.warning,
          actionIcon: Icons.favorite,
        );
      case EmptyStateType.history:
        return _EmptyInfo(
          icon: Icons.history,
          title: '暂无历史记录',
          message: '您的操作历史将显示在这里',
          color: AppColors.neutral,
          actionIcon: Icons.refresh,
        );
      case EmptyStateType.notifications:
        return _EmptyInfo(
          icon: Icons.notifications_none,
          title: '暂无通知',
          message: '所有通知已读或暂无新通知',
          color: AppColors.info,
          actionIcon: Icons.refresh,
        );
      case EmptyStateType.general:
      default:
        return _EmptyInfo(
          icon: Icons.inbox_outlined,
          title: '暂无内容',
          message: '这里还没有任何内容',
          color: AppColors.neutral,
          actionIcon: Icons.add,
        );
    }
  }

  /// 创建搜索空状态组件
  factory EmptyStateWidget.search({
    String? title,
    String? message,
    VoidCallback? onRetry,
    bool compact = false,
  }) {
    return EmptyStateWidget(
      type: EmptyStateType.search,
      title: title,
      message: message,
      onAction: onRetry,
      actionText: onRetry != null ? '重新搜索' : null,
      compact: compact,
    );
  }

  /// 创建数据空状态组件
  factory EmptyStateWidget.data({
    String? title,
    String? message,
    VoidCallback? onCreate,
    String? createText,
    bool compact = false,
  }) {
    return EmptyStateWidget(
      type: EmptyStateType.data,
      title: title,
      message: message,
      onAction: onCreate,
      actionText: createText ?? '创建',
      compact: compact,
    );
  }

  /// 创建文件空状态组件
  factory EmptyStateWidget.files({
    String? title,
    String? message,
    VoidCallback? onUpload,
    bool compact = false,
  }) {
    return EmptyStateWidget(
      type: EmptyStateType.files,
      title: title,
      message: message,
      onAction: onUpload,
      actionText: onUpload != null ? '上传文件' : null,
      compact: compact,
    );
  }

  /// 创建对话空状态组件
  factory EmptyStateWidget.conversations({
    String? title,
    String? message,
    VoidCallback? onCreate,
    bool compact = false,
  }) {
    return EmptyStateWidget(
      type: EmptyStateType.conversations,
      title: title,
      message: message,
      onAction: onCreate,
      actionText: onCreate != null ? '开始对话' : null,
      compact: compact,
    );
  }

  /// 创建知识库空状态组件
  factory EmptyStateWidget.knowledge({
    String? title,
    String? message,
    VoidCallback? onCreate,
    bool compact = false,
  }) {
    return EmptyStateWidget(
      type: EmptyStateType.knowledge,
      title: title,
      message: message,
      onAction: onCreate,
      actionText: onCreate != null ? '创建知识库' : null,
      compact: compact,
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
      title: title,
      message: message,
      illustration: Image.asset(
        illustrationAsset,
        width: 200,
        height: 200,
        fit: BoxFit.contain,
      ),
      actionText: actionText,
      onAction: onAction,
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
      title: title,
      message: message,
      icon: icon,
      type: EmptyStateType.general,
    );
  }
} 