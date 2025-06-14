import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../knowledge/domain/entities/knowledge_base_entity.dart';
import '../../../knowledge/presentation/bloc/knowledge_base_bloc.dart';
import '../../../knowledge/presentation/bloc/knowledge_base_event.dart';
import '../../../knowledge/presentation/bloc/knowledge_base_state.dart';
import '../../domain/entities/conversation.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import '../bloc/conversation_state.dart';

/// 创建对话页面
class CreateConversationPage extends StatefulWidget {
  const CreateConversationPage({
    super.key,
    this.initialKnowledgeBaseId,
    this.initialType = ConversationType.chat,
  });

  final String? initialKnowledgeBaseId;
  final ConversationType initialType;

  @override
  State<CreateConversationPage> createState() => _CreateConversationPageState();
}

class _CreateConversationPageState extends State<CreateConversationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  late ConversationType _selectedType;
  KnowledgeBaseEntity? _selectedKnowledgeBase;
  final List<String> _tags = [];
  final Map<String, dynamic> _settings = {};

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    
    // 加载知识库列表
    context.read<KnowledgeBaseBloc>().add(const LoadKnowledgeBasesEvent());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationBloc, ConversationState>(
      listener: (context, state) {
        if (state is ConversationOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is ConversationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: const CustomAppBar(
          title: '创建对话',
          showBack: true,
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTypeSection(),
                      const SizedBox(height: 24),
                      _buildTitleSection(),
                      const SizedBox(height: 24),
                      _buildKnowledgeBaseSection(),
                      const SizedBox(height: 24),
                      _buildMessageSection(),
                      const SizedBox(height: 24),
                      _buildTagsSection(),
                      const SizedBox(height: 24),
                      _buildSettingsSection(),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '对话类型',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ConversationType.values.map((type) {
            final isSelected = _selectedType == type;
            return ChoiceChip(
              label: Text(type.displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedType = type;
                  });
                }
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '对话标题',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: '输入对话标题（可选）',
            border: OutlineInputBorder(),
          ),
          maxLength: 100,
          validator: (value) {
            if (value != null && value.length > 100) {
              return '标题不能超过100个字符';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildKnowledgeBaseSection() {
    return BlocBuilder<KnowledgeBaseBloc, KnowledgeBaseState>(
      builder: (context, state) {
        if (state is KnowledgeBaseLoading) {
          return const LoadingWidget();
        }

        if (state is KnowledgeBaseLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '关联知识库',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<KnowledgeBaseEntity>(
                value: _selectedKnowledgeBase,
                decoration: const InputDecoration(
                  hintText: '选择知识库（可选）',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<KnowledgeBaseEntity>(
                    value: null,
                    child: Text('不关联知识库'),
                  ),
                  ...state.knowledgeBases.map((kb) {
                    return DropdownMenuItem<KnowledgeBaseEntity>(
                      value: kb,
                      child: Text(kb.name),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedKnowledgeBase = value;
                  });
                },
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '关联知识库',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text('加载知识库失败'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '首条消息',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _messageController,
          decoration: const InputDecoration(
            hintText: '输入您想要发送的消息...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          maxLength: 1000,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入消息内容';
            }
            if (value.length > 1000) {
              return '消息不能超过1000个字符';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '标签',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              '(可选)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ..._tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
              );
            }),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('添加标签'),
              onPressed: _showAddTagDialog,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '高级设置',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.smart_toy),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('智能推荐相关内容'),
                    ),
                    Switch(
                      value: _settings['enableSmartRecommendation'] ?? true,
                      onChanged: (value) {
                        setState(() {
                          _settings['enableSmartRecommendation'] = value;
                        });
                      },
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    const Icon(Icons.source),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('显示信息来源'),
                    ),
                    Switch(
                      value: _settings['showSources'] ?? true,
                      onChanged: (value) {
                        setState(() {
                          _settings['showSources'] = value;
                        });
                      },
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    const Icon(Icons.history),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('保存对话历史'),
                    ),
                    Switch(
                      value: _settings['saveHistory'] ?? true,
                      onChanged: (value) {
                        setState(() {
                          _settings['saveHistory'] = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: BlocBuilder<ConversationBloc, ConversationState>(
        builder: (context, state) {
          final isLoading = state is ConversationLoading;

          return Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : _createConversation,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('创建对话'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddTagDialog() {
    final tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('添加标签'),
          content: TextField(
            controller: tagController,
            decoration: const InputDecoration(
              hintText: '输入标签名称',
              border: OutlineInputBorder(),
            ),
            maxLength: 20,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final tag = tagController.text.trim();
                if (tag.isNotEmpty && !_tags.contains(tag)) {
                  setState(() {
                    _tags.add(tag);
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  void _createConversation() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final message = _messageController.text.trim();
    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : null;

    context.read<ConversationBloc>().add(
          CreateConversationEvent(
            type: _selectedType,
            title: title,
            knowledgeBaseId: _selectedKnowledgeBase?.id,
            initialMessage: message,
            tags: _tags,
            settings: _settings,
          ),
        );
  }
} 