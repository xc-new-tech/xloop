import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/knowledge_base.dart';

class KnowledgeBaseCard extends StatelessWidget {
  final KnowledgeBase knowledgeBase;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const KnowledgeBaseCard({
    super.key,
    required this.knowledgeBase,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildContent(),
              const SizedBox(height: 12),
              _buildMetadata(),
              if (knowledgeBase.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildTags(),
              ],
              const SizedBox(height: 12),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildTypeIcon(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                knowledgeBase.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildTypeChip(),
                  const SizedBox(width: 8),
                  _buildStatusChip(),
                ],
              ),
            ],
          ),
        ),
        _buildMoreButton(context),
      ],
    );
  }

  Widget _buildTypeIcon() {
    IconData iconData;
    Color iconColor;
    
    switch (knowledgeBase.type) {
      case KnowledgeBaseType.personal:
        iconData = Icons.person_outline;
        iconColor = AppColors.primary;
        break;
      case KnowledgeBaseType.team:
        iconData = Icons.group_outlined;
        iconColor = AppColors.secondary;
        break;
      case KnowledgeBaseType.public:
        iconData = Icons.public_outlined;
        iconColor = AppColors.success;
        break;
    }
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  Widget _buildTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        knowledgeBase.type.displayName,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color statusColor;
    switch (knowledgeBase.status) {
      case KnowledgeBaseStatus.active:
        statusColor = AppColors.success;
        break;
      case KnowledgeBaseStatus.archived:
        statusColor = AppColors.warning;
        break;
      case KnowledgeBaseStatus.disabled:
        statusColor = AppColors.error;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        knowledgeBase.status.displayName,
        style: TextStyle(
          fontSize: 12,
          color: statusColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'share':
            onShare?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined),
              SizedBox(width: 12),
              Text('编辑'),
            ],
          ),
        ),
        if (knowledgeBase.type != KnowledgeBaseType.public)
          const PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share_outlined),
                SizedBox(width: 12),
                Text('分享'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outlined, color: Colors.red),
              SizedBox(width: 12),
              Text('删除', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (knowledgeBase.description?.isNotEmpty == true) {
      return Text(
        knowledgeBase.description!,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        _buildMetadataItem(
          Icons.article_outlined,
          '${knowledgeBase.documentCount}',
          '文档',
        ),
        const SizedBox(width: 16),
        _buildMetadataItem(
          Icons.storage_outlined,
          knowledgeBase.formattedSize,
          '大小',
        ),
        const Spacer(),
        _buildFeatureIcons(),
      ],
    );
  }

  Widget _buildMetadataItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (knowledgeBase.searchEnabled)
          Icon(
            Icons.search,
            size: 16,
            color: AppColors.primary.withOpacity(0.7),
          ),
        if (knowledgeBase.searchEnabled && knowledgeBase.aiEnabled)
          const SizedBox(width: 4),
        if (knowledgeBase.aiEnabled)
          Icon(
            Icons.auto_awesome,
            size: 16,
            color: AppColors.secondary.withOpacity(0.7),
          ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: knowledgeBase.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 14,
          color: Colors.grey.withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        Text(
          '最后活动：${_formatDateTime(knowledgeBase.lastActivity)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.withOpacity(0.7),
          ),
        ),
        const Spacer(),
        Text(
          '创建于 ${_formatDateTime(knowledgeBase.createdAt)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 30) {
      return DateFormat('yyyy/MM/dd').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
} 