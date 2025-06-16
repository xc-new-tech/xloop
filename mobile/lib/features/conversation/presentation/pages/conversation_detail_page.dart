import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus/share_plus.dart';

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
  bool _isFavorited = false;
  Duration? _lastResponseTime;
  String? _selectedModel;
  
  // 可用的AI模型列表
  final List<String> _availableModels = [
    'GPT-4',
    'GPT-3.5-turbo',
    'Claude-3',
    'Gemini Pro',
    'LLaMA-2',
  ];

  @override
  void initState() {
    super.initState();
    _conversationBloc = GetIt.instance<ConversationBloc>();
    _selectedModel = _availableModels.first; // 默认选择第一个模型
    
    // 加载对话详情
    _conversationBloc.add(GetConversationEvent(id: widget.conversationId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage(String content, {String contentType = 'text', String? modelId}) {
    if (content.trim().isEmpty) return;

    final startTime = DateTime.now();
    
    _conversationBloc.add(SendMessageEvent(
      conversationId: widget.conversationId,
      content: content.trim(),
      contentType: contentType,
      metadata: {
        'modelId': modelId ?? _selectedModel,
        'timestamp': startTime.toIso8601String(),
      },
    ));

    _messageController.clear();
    
    // 模拟响应时间计算（实际应该从API响应中获取）
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _lastResponseTime = DateTime.now().difference(startTime);
        });
      }
    });
    
    // 滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _onModelChanged(String model) {
    setState(() {
      _selectedModel = model;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已切换到 $model 模型'),
        duration: const Duration(seconds: 1),
      ),
    );
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

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
    
    // TODO: 实现收藏功能的后端调用
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorited ? '已添加到收藏' : '已取消收藏'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareConversation() {
    if (_currentConversation == null) return;
    
    final messages = _currentConversation!.messages;
    final conversationText = messages.map((message) {
      final role = message.role == MessageRole.user ? '用户' : 'AI';
      return '$role: ${message.content}';
    }).join('\n\n');
    
    final shareText = '''
对话标题: ${_currentConversation!.title ?? '未命名对话'}
创建时间: ${_currentConversation!.createdAt.toString().substring(0, 19)}
消息数量: ${messages.length}

对话内容:
$conversationText

--- 
来自 XLoop 智能对话平台
''';

    Share.share(
      shareText,
      subject: '分享对话: ${_currentConversation!.title ?? '未命名对话'}',
    );
  }

  void _exportConversation() {
    if (_currentConversation == null) return;
    
    // TODO: 实现对话导出功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('对话导出功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
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

  void _regenerateMessage(String messageId) {
    // TODO: 实现重新生成消息功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在重新生成回答...'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // 模拟重新生成
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('回答已重新生成'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshConversation();
      }
    });
  }

  void _reactToMessage(String messageId, bool isLike) {
    // TODO: 实现消息反应功能
    final reactionType = isLike ? '点赞' : '点踩';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已${reactionType}该消息'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _quoteMessage(String messageId) {
    // 查找要引用的消息
    final conversation = _currentConversation;
    if (conversation == null) return;
    
    final message = conversation.messages.firstWhere(
      (msg) => msg.id == messageId,
      orElse: () => conversation.messages.first,
    );
    
    // 在输入框中添加引用内容
    final quotedText = '> ${message.content}\n\n';
    final currentText = _messageController.text;
    _messageController.text = quotedText + currentText;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: _messageController.text.length),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已引用该消息'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _editMessage(String messageId) {
    // TODO: 实现消息编辑功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('消息编辑功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
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
                    Row(
                      children: [
                        Text(
                          '${state.conversation.messageCount} 条消息',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (_selectedModel != null) ...[
                          const Text(' • ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            _selectedModel!,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ],
                );
              }
              return const Text('对话详情');
            },
          ),
          elevation: 0,
          actions: [
            // 收藏按钮
            IconButton(
              icon: Icon(
                _isFavorited ? Icons.favorite : Icons.favorite_border,
                color: _isFavorited ? Colors.red : null,
              ),
              onPressed: _toggleFavorite,
              tooltip: _isFavorited ? '取消收藏' : '收藏对话',
            ),
            // 分享按钮
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareConversation,
              tooltip: '分享对话',
            ),
            // 更多选项
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'refresh':
                    _refreshConversation();
                    break;
                  case 'export':
                    _exportConversation();
                    break;
                  case 'info':
                    _showConversationInfo();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text('刷新'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.download),
                      SizedBox(width: 8),
                      Text('导出对话'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'info',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline),
                      SizedBox(width: 8),
                      Text('对话信息'),
                    ],
                  ),
                ),
              ],
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
                                onRegenerate: (messageId) => _regenerateMessage(messageId),
                                onReaction: (messageId, isLike) => _reactToMessage(messageId, isLike),
                                onQuote: (messageId) => _quoteMessage(messageId),
                                onEdit: (messageId) => _editMessage(messageId),
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
                          Text('AI正在思考... (${_selectedModel ?? '默认模型'})'),
                        ],
                      ),
                    ),
                  
                  // 消息输入框
                  MessageInput(
                    controller: _messageController,
                    onSend: _sendMessage,
                    enabled: conversation.status == ConversationStatus.active,
                    availableModels: _availableModels,
                    selectedModel: _selectedModel,
                    onModelChanged: _onModelChanged,
                    lastResponseTime: _lastResponseTime,
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