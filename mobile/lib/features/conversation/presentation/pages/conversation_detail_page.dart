import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/widgets/loading_widget.dart';
import '../../../shared/presentation/widgets/error_widget.dart';
import '../../domain/entities/conversation.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import '../bloc/conversation_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/conversation_info_sheet.dart';

class ConversationDetailPage extends StatefulWidget {
  final String conversationId;

  const ConversationDetailPage({
    Key? key,
    required this.conversationId,
  }) : super(key: key);

  @override
  State<ConversationDetailPage> createState() => _ConversationDetailPageState();
}

class _ConversationDetailPageState extends State<ConversationDetailPage> {
  late ConversationBloc _conversationBloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  
  Conversation? _currentConversation;

  @override
  void initState() {
    super.initState();
    _conversationBloc = GetIt.instance<ConversationBloc>();
    
    // 加载对话详情
    _conversationBloc.add(GetConversationEvent(id: widget.conversationId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage(String content, {String contentType = 'text'}) {
    if (content.trim().isEmpty) return;

    _conversationBloc.add(SendMessageEvent(
      conversationId: widget.conversationId,
      content: content.trim(),
      contentType: contentType,
    ));

    _messageController.clear();
    
    // 滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showConversationInfo() {
    if (_currentConversation != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => ConversationInfoSheet(
          conversation: _currentConversation!,
          onUpdate: (title, tags, settings) {
            _conversationBloc.add(UpdateConversationEvent(
              id: widget.conversationId,
              title: title,
              tags: tags,
              settings: settings,
            ));
          },
          onRate: (rating, feedback) {
            _conversationBloc.add(RateConversationEvent(
              id: widget.conversationId,
              rating: rating.round(),
              feedback: feedback,
            ));
          },
          onDelete: () {
            _showDeleteConfirm();
          },
        ),
      );
    }
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个对话吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _conversationBloc.add(DeleteConversationEvent(id: widget.conversationId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _refreshConversation() {
    _conversationBloc.add(GetConversationEvent(id: widget.conversationId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _conversationBloc,
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<ConversationBloc, ConversationState>(
            builder: (context, state) {
              if (state is ConversationDetailLoaded) {
                _currentConversation = state.conversation;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.conversation.title ?? '未命名对话',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${state.conversation.messageCount} 条消息',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                );
              }
              return const Text('对话详情');
            },
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshConversation,
              tooltip: '刷新',
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showConversationInfo,
              tooltip: '对话信息',
            ),
          ],
        ),
        body: BlocConsumer<ConversationBloc, ConversationState>(
          listener: (context, state) {
            if (state is MessageSent) {
              // 消息发送成功，刷新对话
              _conversationBloc.add(GetConversationEvent(id: widget.conversationId));
              
              // 滚动到底部显示新消息
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            } else if (state is ConversationDeleted) {
              // 对话删除成功，返回上一页
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('对话已删除'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is ConversationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is ConversationUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('对话信息已更新'),
                  backgroundColor: Colors.green,
                ),
              );
              // 刷新对话详情
              _conversationBloc.add(GetConversationEvent(id: widget.conversationId));
            } else if (state is ConversationRated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('评分已提交'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ConversationLoading) {
              return const LoadingWidget();
            }
            
            if (state is ConversationError) {
              return AppErrorWidget(
                message: state.message,
                onRetry: _refreshConversation,
              );
            }
            
            if (state is ConversationDetailLoaded) {
              final conversation = state.conversation;
              final messages = conversation.messages;
              
              return Column(
                children: [
                  // 消息列表
                  Expanded(
                    child: messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '还没有消息',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '发送第一条消息开始对话',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              return MessageBubble(
                                message: message,
                                isUser: message.role == MessageRole.user,
                              );
                            },
                          ),
                  ),
                  
                  // 发送状态指示器
                  if (state is MessageSending)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          const Text('AI正在思考...'),
                        ],
                      ),
                    ),
                  
                  // 消息输入框
                  MessageInput(
                    controller: _messageController,
                    onSend: _sendMessage,
                    enabled: conversation.status == ConversationStatus.active,
                  ),
                ],
              );
            }
            
            return const Center(
              child: Text('加载对话中...'),
            );
          },
        ),
      ),
    );
  }
} 