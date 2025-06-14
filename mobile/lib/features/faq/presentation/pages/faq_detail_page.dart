import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/presentation/widgets/base_page.dart';
import '../../domain/entities/faq_entity.dart';
import '../bloc/faq_bloc.dart';
import '../bloc/faq_event.dart';
import '../bloc/faq_state.dart';
import '../widgets/faq_metadata_widget.dart';
import '../widgets/faq_actions_widget.dart';

/// FAQ详情页面
class FaqDetailPage extends StatefulWidget {
  final String faqId;

  const FaqDetailPage({
    super.key,
    required this.faqId,
  });

  @override
  State<FaqDetailPage> createState() => _FaqDetailPageState();
}

class _FaqDetailPageState extends State<FaqDetailPage> {
  late FaqBloc _faqBloc;

  @override
  void initState() {
    super.initState();
    _faqBloc = context.read<FaqBloc>();
    _loadFaqDetail();
  }

  void _loadFaqDetail() {
    _faqBloc.add(GetFaqByIdEvent(id: widget.faqId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FaqBloc, FaqState>(
      listener: (context, state) {
        if (state.hasError && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final faq = state.currentFaq;
        
        return BasePage(
          title: 'FAQ详情',
          actions: [
            if (faq != null) ...[
              IconButton(
                onPressed: () => _editFaq(faq),
                icon: const Icon(Icons.edit_outlined),
                tooltip: '编辑FAQ',
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => _handleMenuAction(value, faq),
                itemBuilder: (context) => [
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
                    value: 'copy',
                    child: Row(
                      children: [
                        Icon(Icons.copy_outlined),
                        SizedBox(width: 12),
                        Text('复制链接'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 12),
                        Text('删除', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(FaqState state) {
    if (state.isLoading && state.currentFaq == null) {
      return const BaseLoadingPage();
    }

    if (state.hasError && state.currentFaq == null) {
      return BaseErrorPage(
        title: '加载失败',
        subtitle: state.errorMessage ?? '无法加载FAQ详情',
        actionText: '重试',
        onAction: _loadFaqDetail,
      );
    }

    final faq = state.currentFaq;
    if (faq == null) {
      return const BaseEmptyPage(
        title: 'FAQ不存在',
        subtitle: '请检查FAQ ID是否正确',
        icon: Icons.quiz_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadFaqDetail();
        await _faqBloc.stream.firstWhere((s) => !s.isLoading);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FAQ状态和优先级
            _buildStatusPriorityRow(faq),
            const SizedBox(height: 16),

            // 问题
            _buildQuestionSection(faq),
            const SizedBox(height: 24),

            // 答案
            _buildAnswerSection(faq),
            const SizedBox(height: 24),

            // 分类和标签
            _buildCategoryTagsSection(faq),
            const SizedBox(height: 24),

            // 操作按钮
            FaqActionsWidget(
              faq: faq,
              onLike: () => _faqBloc.add(LikeFaqEvent(id: faq.id)),
              onDislike: () => _faqBloc.add(DislikeFaqEvent(id: faq.id)),
              onEdit: () => _editFaq(faq),
              onDelete: () => _deleteFaq(faq),
            ),
            const SizedBox(height: 24),

            // 元数据信息
            FaqMetadataWidget(faq: faq),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPriorityRow(FaqEntity faq) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        // 状态标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(faq.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getStatusColor(faq.status).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(faq.status),
                size: 16,
                color: _getStatusColor(faq.status),
              ),
              const SizedBox(width: 4),
              Text(
                faq.status.label,
                style: TextStyle(
                  color: _getStatusColor(faq.status),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // 优先级标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getPriorityColor(faq.priority).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getPriorityColor(faq.priority).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getPriorityIcon(faq.priority),
                size: 16,
                color: _getPriorityColor(faq.priority),
              ),
              const SizedBox(width: 4),
              Text(
                faq.priority.label,
                style: TextStyle(
                  color: _getPriorityColor(faq.priority),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),

        // 可见性指示器
        Icon(
          faq.isPublic ? Icons.public : Icons.lock_outline,
          size: 20,
          color: colorScheme.outline,
        ),
      ],
    );
  }

  Widget _buildQuestionSection(FaqEntity faq) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '问题',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Text(
            faq.question,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerSection(FaqEntity faq) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '答案',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Text(
            faq.answer,
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTagsSection(FaqEntity faq) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分类和标签',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // 分类
        Row(
          children: [
            Icon(
              Icons.folder_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              faq.category,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        if (faq.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: faq.tags.map((tag) => Chip(
              label: Text(
                tag,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(FaqStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case FaqStatus.published:
        return Colors.green;
      case FaqStatus.draft:
        return Colors.orange;
      case FaqStatus.archived:
        return colorScheme.outline;
    }
  }

  IconData _getStatusIcon(FaqStatus status) {
    switch (status) {
      case FaqStatus.published:
        return Icons.check_circle_outline;
      case FaqStatus.draft:
        return Icons.edit_outlined;
      case FaqStatus.archived:
        return Icons.archive_outlined;
    }
  }

  Color _getPriorityColor(FaqPriority priority) {
    switch (priority) {
      case FaqPriority.high:
        return Colors.red;
      case FaqPriority.medium:
        return Colors.orange;
      case FaqPriority.low:
        return Colors.green;
    }
  }

  IconData _getPriorityIcon(FaqPriority priority) {
    switch (priority) {
      case FaqPriority.high:
        return Icons.priority_high;
      case FaqPriority.medium:
        return Icons.remove;
      case FaqPriority.low:
        return Icons.expand_more;
    }
  }

  void _editFaq(FaqEntity faq) {
    context.push('/faq/edit/${faq.id}');
  }

  void _deleteFaq(FaqEntity faq) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除FAQ "${faq.shortQuestion}" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _faqBloc.add(DeleteFaqEvent(id: faq.id));
              context.pop(); // 返回到列表页面
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, FaqEntity faq) {
    switch (action) {
      case 'share':
        // TODO: 实现分享功能
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('分享功能待实现')),
        );
        break;
      case 'copy':
        // TODO: 实现复制链接功能
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('链接已复制到剪贴板')),
        );
        break;
      case 'delete':
        _deleteFaq(faq);
        break;
    }
  }
} 