import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/conversation.dart';

class MessageBubble extends StatefulWidget {
  final ConversationMessage message;
  final bool isUser;
  final Function(String)? onRegenerate;
  final Function(String, bool)? onReaction; // messageId, isLike
  final Function(String)? onQuote; // messageId
  final Function(String)? onEdit; // messageId

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isUser,
    this.onRegenerate,
    this.onReaction,
    this.onQuote,
    this.onEdit,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _showActions = false;
  bool _isLiked = false;
  bool _isDisliked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = widget.isUser;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(theme),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onLongPress: () => setState(() => _showActions = !_showActions),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUser 
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMessageContent(theme),
                    const SizedBox(height: 8),
                    _buildMessageFooter(theme),
                    if (_showActions && !isUser) ...[
                      const SizedBox(height: 8),
                      _buildActionButtons(theme),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _buildAvatar(theme),
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: widget.isUser 
        ? theme.colorScheme.primary 
        : theme.colorScheme.secondary,
      child: Icon(
        widget.isUser ? Icons.person : Icons.smart_toy,
        size: 16,
        color: Colors.white,
      ),
    );
  }

  Widget _buildMessageContent(ThemeData theme) {
    return SelectableText(
      widget.message.content,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: widget.isUser 
          ? theme.colorScheme.onSurface 
          : theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildMessageFooter(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(widget.message.timestamp),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        if (widget.message.processingTime != null) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.schedule,
            size: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 2),
          Text(
            '${widget.message.processingTime}ms',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
        if (widget.message.error != null) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.error_outline,
            size: 12,
            color: theme.colorScheme.error,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 点赞按钮
        IconButton(
          onPressed: () {
            setState(() => _isLiked = !_isLiked);
            if (_isLiked && _isDisliked) {
              setState(() => _isDisliked = false);
            }
            widget.onReaction?.call(widget.message.id, true);
          },
          icon: Icon(
            _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            size: 16,
            color: _isLiked 
              ? theme.colorScheme.primary 
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        
        // 点踩按钮
        IconButton(
          onPressed: () {
            setState(() => _isDisliked = !_isDisliked);
            if (_isDisliked && _isLiked) {
              setState(() => _isLiked = false);
            }
            widget.onReaction?.call(widget.message.id, false);
          },
          icon: Icon(
            _isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
            size: 16,
            color: _isDisliked 
              ? theme.colorScheme.error 
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        
        // 复制按钮
        IconButton(
          onPressed: () => _copyMessage(),
          icon: Icon(
            Icons.copy,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        
        // 引用按钮
        IconButton(
          onPressed: () => widget.onQuote?.call(widget.message.id),
          icon: Icon(
            Icons.format_quote,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        
        // 重新生成按钮
        IconButton(
          onPressed: () => widget.onRegenerate?.call(widget.message.id),
          icon: Icon(
            Icons.refresh,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return DateFormat('HH:mm').format(timestamp);
    } else {
      return DateFormat('MM-dd HH:mm').format(timestamp);
    }
  }

  void _copyMessage() {
    Clipboard.setData(ClipboardData(text: widget.message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('消息已复制到剪贴板'),
        duration: Duration(seconds: 2),
      ),
    );
  }
} 