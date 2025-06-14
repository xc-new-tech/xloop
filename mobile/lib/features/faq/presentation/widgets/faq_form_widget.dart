import 'package:flutter/material.dart';

import '../../domain/entities/faq_entity.dart';

/// FAQ表单组件
class FaqFormWidget extends StatefulWidget {
  final FaqEntity? initialFaq; // 用于编辑模式
  final String? initialKnowledgeBaseId;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback? onCancel;
  final bool isSubmitting;

  const FaqFormWidget({
    super.key,
    this.initialFaq,
    this.initialKnowledgeBaseId,
    required this.onSubmit,
    this.onCancel,
    this.isSubmitting = false,
  });

  @override
  State<FaqFormWidget> createState() => _FaqFormWidgetState();
}

class _FaqFormWidgetState extends State<FaqFormWidget>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // 表单控制器
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late TextEditingController _categoryController;
  late TextEditingController _tagsController;

  // 表单状态
  FaqPriority _selectedPriority = FaqPriority.medium;
  FaqStatus _selectedStatus = FaqStatus.draft;
  bool _isPublic = false;
  String? _selectedKnowledgeBaseId;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // 初始化表单数据
    _initializeFormData();
  }

  void _initializeFormData() {
    final faq = widget.initialFaq;
    
    _questionController = TextEditingController(text: faq?.question ?? '');
    _answerController = TextEditingController(text: faq?.answer ?? '');
    _categoryController = TextEditingController(text: faq?.category ?? '');
    _tagsController = TextEditingController();

    if (faq != null) {
      _selectedPriority = faq.priority;
      _selectedStatus = faq.status;
      _isPublic = faq.isPublic;
      _selectedKnowledgeBaseId = faq.knowledgeBaseId;
      _tags = List.from(faq.tags);
      _tagsController.text = _tags.join(', ');
    } else {
      _selectedKnowledgeBaseId = widget.initialKnowledgeBaseId;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questionController.dispose();
    _answerController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tab栏
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '基本信息', icon: Icon(Icons.info_outline)),
              Tab(text: '预览', icon: Icon(Icons.preview_outlined)),
            ],
          ),
          
          // Tab内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFormTab(),
                _buildPreviewTab(),
              ],
            ),
          ),
          
          // 底部按钮
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildFormTab() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 问题字段
            _buildQuestionField(),
            const SizedBox(height: 24),

            // 答案字段
            _buildAnswerField(),
            const SizedBox(height: 24),

            // 分类字段
            _buildCategoryField(),
            const SizedBox(height: 24),

            // 标签字段
            _buildTagsField(),
            const SizedBox(height: 24),

            // 设置区域
            _buildSettingsSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '问题 *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _questionController,
          decoration: const InputDecoration(
            hintText: '请输入FAQ问题...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.help_outline),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '问题不能为空';
            }
            if (value.trim().length < 10) {
              return '问题长度至少10个字符';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAnswerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '答案 *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _answerController,
          decoration: const InputDecoration(
            hintText: '请输入详细的答案...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.article_outlined),
            alignLabelWithHint: true,
          ),
          maxLines: 8,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '答案不能为空';
            }
            if (value.trim().length < 20) {
              return '答案长度至少20个字符';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分类',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _categoryController,
          decoration: const InputDecoration(
            hintText: '请输入分类名称...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.folder_outlined),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty && value.trim().length < 2) {
              return '分类名称至少2个字符';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '标签',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _tagsController,
          decoration: const InputDecoration(
            hintText: '请输入标签，用逗号分隔...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.local_offer_outlined),
            helperText: '例如：Flutter, 开发, 移动应用',
          ),
          onChanged: (value) {
            setState(() {
              _tags = value
                  .split(',')
                  .map((tag) => tag.trim())
                  .where((tag) => tag.isNotEmpty)
                  .toList();
            });
          },
        ),
        
        // 标签预览
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) => Chip(
              label: Text(tag),
              onDeleted: () {
                setState(() {
                  _tags.remove(tag);
                  _tagsController.text = _tags.join(', ');
                });
              },
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSettingsSection() {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '设置',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 优先级
            _buildPrioritySelector(),
            const SizedBox(height: 16),

            // 状态
            _buildStatusSelector(),
            const SizedBox(height: 16),

            // 可见性
            SwitchListTile(
              title: const Text('公开可见'),
              subtitle: Text(_isPublic ? '所有用户可见' : '仅内部可见'),
              value: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
              secondary: Icon(_isPublic ? Icons.public : Icons.lock_outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('优先级'),
        const SizedBox(height: 8),
        SegmentedButton<FaqPriority>(
          segments: FaqPriority.values.map((priority) => ButtonSegment(
            value: priority,
            label: Text(priority.label),
            icon: Icon(_getPriorityIcon(priority)),
          )).toList(),
          selected: {_selectedPriority},
          onSelectionChanged: (priorities) {
            setState(() {
              _selectedPriority = priorities.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('状态'),
        const SizedBox(height: 8),
        DropdownButtonFormField<FaqStatus>(
          value: _selectedStatus,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          items: FaqStatus.values.map((status) => DropdownMenuItem(
            value: status,
            child: Row(
              children: [
                Icon(_getStatusIcon(status), size: 16),
                const SizedBox(width: 8),
                Text(status.label),
              ],
            ),
          )).toList(),
          onChanged: (status) {
            if (status != null) {
              setState(() {
                _selectedStatus = status;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPreviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 预览卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 状态和优先级标签
                  Row(
                    children: [
                      Chip(
                        label: Text(_selectedStatus.label),
                        avatar: Icon(_getStatusIcon(_selectedStatus), size: 16),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(_selectedPriority.label),
                        avatar: Icon(_getPriorityIcon(_selectedPriority), size: 16),
                      ),
                      const Spacer(),
                      Icon(_isPublic ? Icons.public : Icons.lock_outline),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 问题
                  Text(
                    '问题',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _questionController.text.isEmpty 
                          ? '问题预览将在这里显示...' 
                          : _questionController.text,
                      style: TextStyle(
                        color: _questionController.text.isEmpty 
                            ? Theme.of(context).colorScheme.onSurfaceVariant 
                            : null,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 答案
                  Text(
                    '答案',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      _answerController.text.isEmpty 
                          ? '答案预览将在这里显示...' 
                          : _answerController.text,
                      style: TextStyle(
                        color: _answerController.text.isEmpty 
                            ? Theme.of(context).colorScheme.onSurfaceVariant 
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 分类和标签
                  if (_categoryController.text.isNotEmpty || _tags.isNotEmpty) ...[
                    Text(
                      '分类和标签',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    if (_categoryController.text.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.folder_outlined, size: 16),
                          const SizedBox(width: 8),
                          Text(_categoryController.text),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    if (_tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) => Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 12)),
                        )).toList(),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.isSubmitting ? null : widget.onCancel,
              child: const Text('取消'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: widget.isSubmitting ? null : _submitForm,
              child: widget.isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.initialFaq != null ? '更新' : '创建'),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final faqData = {
      'question': _questionController.text.trim(),
      'answer': _answerController.text.trim(),
      'category': _categoryController.text.trim(),
      'tags': _tags,
      'priority': _selectedPriority.value,
      'status': _selectedStatus.value,
      'isPublic': _isPublic,
      if (_selectedKnowledgeBaseId != null)
        'knowledgeBaseId': _selectedKnowledgeBaseId,
    };

    widget.onSubmit(faqData);
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
} 