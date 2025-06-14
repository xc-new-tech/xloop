import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../conversation/domain/entities/conversation.dart';
import '../../../conversation/presentation/bloc/conversation_bloc.dart';
import '../../../conversation/presentation/bloc/conversation_event.dart';
import '../../../conversation/presentation/bloc/conversation_state.dart';
import '../../../conversation/presentation/pages/create_conversation_page.dart';
import '../../../conversation/presentation/widgets/conversation_card.dart';
import '../../../conversation/presentation/widgets/conversation_search_bar.dart';
import '../../../conversation/presentation/widgets/conversation_filter_dialog.dart';

/// 聊天页面
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // 加载对话列表
    context.read<ConversationBloc>().add(const GetConversationsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('智能对话'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewConversation,
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: ConversationSearchBar(
              controller: _searchController,
              onSearch: (query) {
                context.read<ConversationBloc>().add(
                      SearchConversationsEvent(query: query),
                    );
              },
            ),
          ),
          // 对话列表
          Expanded(
            child: BlocBuilder<ConversationBloc, ConversationState>(
              builder: (context, state) {
                if (state is ConversationLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is ConversationError) {
                  return _buildErrorView(state.message);
                }

                if (state is ConversationsLoaded) {
                  if (state.conversations.isEmpty) {
                    return _buildEmptyView();
                  }

                  return _buildConversationList(state.conversations);
                }

                return _buildEmptyView();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewConversation,
        icon: const Icon(Icons.chat),
        label: const Text('新对话'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
    );
  }

  Widget _buildConversationList(List<Conversation> conversations) {
    return RefreshIndicator(
      onRefresh: _refreshConversations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ConversationCard(
              conversation: conversation,
              onTap: () => _openConversation(conversation),
              onDelete: () => _deleteConversation(conversation),

              onRate: (rating) => _rateConversation(conversation, rating.round()),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: AppColors.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            '还没有对话',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '开始您的第一个AI对话吧',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface.withOpacity(0.5),
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _createNewConversation,
            icon: const Icon(Icons.add),
            label: const Text('创建对话'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Text(
          '快速开始',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.onSurface.withOpacity(0.7),
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildQuickActionChip(
              icon: Icons.chat,
              label: '智能聊天',
              type: ConversationType.chat,
            ),
            _buildQuickActionChip(
              icon: Icons.search,
              label: '知识搜索',
              type: ConversationType.search,
            ),
            _buildQuickActionChip(
              icon: Icons.quiz,
              label: '问答咨询',
              type: ConversationType.qa,
            ),
            _buildQuickActionChip(
              icon: Icons.support_agent,
              label: '技术支持',
              type: ConversationType.support,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required ConversationType type,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () => _createConversationWithType(type),
      backgroundColor: AppColors.surface,
      side: BorderSide(color: AppColors.outline),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: 24),
          Text(
            '加载失败',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.error,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ConversationBloc>().add(
                    const GetConversationsEvent(),
                  );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshConversations() async {
    context.read<ConversationBloc>().add(const GetConversationsEvent());
  }

  void _createNewConversation() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateConversationPage(),
      ),
    ).then((result) {
      if (result == true) {
        // 对话创建成功，刷新列表
        _refreshConversations();
      }
    });
  }

  void _createConversationWithType(ConversationType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateConversationPage(
          initialType: type,
        ),
      ),
    ).then((result) {
      if (result == true) {
        // 对话创建成功，刷新列表
        _refreshConversations();
      }
    });
  }

  void _openConversation(Conversation conversation) {
    // 导航到对话详情页面
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConversationDetailPage(
          id: conversation.id,
        ),
      ),
    ).then((_) {
      // 从对话详情页面返回时刷新列表
      _refreshConversations();
    });
  }

  void _deleteConversation(Conversation conversation) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除对话"${conversation.title ?? '未命名对话'}"吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<ConversationBloc>().add(
                      DeleteConversationEvent(id: conversation.id),
                    );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  void _archiveConversation(Conversation conversation) {
    context.read<ConversationBloc>().add(
      ArchiveConversationEvent(id: conversation.id),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已归档对话"${conversation.title ?? '未命名对话'}"'),
        action: SnackBarAction(
          label: '撤销',
          onPressed: () {
            context.read<ConversationBloc>().add(
                  UnarchiveConversationEvent(id: conversation.id),
                );
          },
        ),
      ),
    );
  }

  void _rateConversation(Conversation conversation, int rating) {
    context.read<ConversationBloc>().add(
          RateConversationEvent(
            id: conversation.id,
            rating: rating,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已为对话评分：$rating 星'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ConversationFilterDialog(
          onApplyFilter: (type, status, knowledgeBaseId) {
            context.read<ConversationBloc>().add(
              FilterConversationsEvent(
                type: type,
                status: status,
                knowledgeBaseId: knowledgeBaseId,
              ),
            );
          },
          onClearFilter: () {
            context.read<ConversationBloc>().add(const ClearFiltersEvent());
          },
        );
      },
          );
  }
}

// 需要导入对话详情页面
class ConversationDetailPage extends StatelessWidget {
  const ConversationDetailPage({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    // 这里应该导航到实际的对话详情页面
    // 目前使用占位符实现
    return Scaffold(
      appBar: AppBar(
        title: const Text('对话详情'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text('对话ID: $id'),
            const SizedBox(height: 8),
            const Text('对话详情页面开发中...'),
          ],
        ),
      ),
    );
  }
} 