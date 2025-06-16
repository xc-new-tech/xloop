import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String, {String contentType, String? modelId}) onSend;
  final bool enabled;
  final List<String>? availableModels;
  final String? selectedModel;
  final Function(String)? onModelChanged;
  final Duration? lastResponseTime;

  const MessageInput({
    Key? key,
    required this.controller,
    required this.onSend,
    this.enabled = true,
    this.availableModels,
    this.selectedModel,
    this.onModelChanged,
    this.lastResponseTime,
  }) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _canSend = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final canSend = widget.controller.text.trim().isNotEmpty;
    if (canSend != _canSend) {
      setState(() {
        _canSend = canSend;
      });
    }
  }

  void _sendMessage() {
    if (_canSend && widget.enabled) {
      widget.onSend(
        widget.controller.text,
        modelId: widget.selectedModel,
      );
    }
  }

  bool _handleKeyEvent(KeyEvent event) {
    // 处理Shift + Enter换行，Enter发送
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (HardwareKeyboard.instance.isShiftPressed) {
          // Shift + Enter: 插入换行符
          final text = widget.controller.text;
          final selection = widget.controller.selection;
          final newText = text.replaceRange(
            selection.start,
            selection.end,
            '\n',
          );
          widget.controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(
              offset: selection.start + 1,
            ),
          );
          return true; // 阻止默认行为
        } else {
          // Enter: 发送消息
          _sendMessage();
          return true; // 阻止默认行为
        }
      }
    }
    return false; // 允许其他按键的默认行为
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '添加附件',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('图片'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现图片上传
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('图片上传功能开发中...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('文件'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现文件上传
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('文件上传功能开发中...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('位置'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现位置分享
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('位置分享功能开发中...')),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showModelSelector() {
    if (widget.availableModels == null || widget.availableModels!.isEmpty) {
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '选择AI模型',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...widget.availableModels!.map((model) => ListTile(
              title: Text(model),
              trailing: widget.selectedModel == model
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                Navigator.pop(context);
                widget.onModelChanged?.call(model);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 模型选择和响应时间显示
            if (widget.availableModels != null || widget.lastResponseTime != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    // 模型选择器
                    if (widget.availableModels != null && widget.availableModels!.isNotEmpty) ...[
                      InkWell(
                        onTap: _showModelSelector,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.psychology,
                                size: 16,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.selectedModel ?? '选择模型',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 16,
                                color: theme.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    
                    const Spacer(),
                    
                    // 响应时间显示
                    if (widget.lastResponseTime != null) ...[
                      Icon(
                        Icons.timer,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.lastResponseTime!.inMilliseconds}ms',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            
            // 输入区域
            Row(
              children: [
                // 附件按钮
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: widget.enabled ? _showAttachmentOptions : null,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                
                // 输入框
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.background,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: KeyboardListener(
                      focusNode: _focusNode,
                      onKeyEvent: (event) {
                        if (_handleKeyEvent(event)) {
                          // 事件已处理，阻止进一步传播
                        }
                      },
                      child: TextField(
                        controller: widget.controller,
                        enabled: widget.enabled,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: widget.enabled 
                              ? '输入消息... (Shift+Enter换行，Enter发送)' 
                              : '对话已暂停',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // 发送按钮
                Container(
                  decoration: BoxDecoration(
                    color: _canSend && widget.enabled
                        ? theme.primaryColor
                        : theme.colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _canSend && widget.enabled ? _sendMessage : null,
                    color: _canSend && widget.enabled
                        ? Colors.white
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 