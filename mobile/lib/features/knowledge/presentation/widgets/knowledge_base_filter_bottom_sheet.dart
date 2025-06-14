import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/knowledge_base.dart';

class KnowledgeBaseFilterBottomSheet extends StatefulWidget {
  final KnowledgeBaseType? selectedType;
  final KnowledgeBaseStatus? selectedStatus;
  final List<String> selectedTags;
  final String currentSort;
  final String currentOrder;
  final Function(
    KnowledgeBaseType? type,
    KnowledgeBaseStatus? status,
    List<String> tags,
    String sort,
    String order,
  ) onApplyFilter;

  const KnowledgeBaseFilterBottomSheet({
    super.key,
    this.selectedType,
    this.selectedStatus,
    this.selectedTags = const [],
    required this.currentSort,
    required this.currentOrder,
    required this.onApplyFilter,
  });

  @override
  State<KnowledgeBaseFilterBottomSheet> createState() =>
      _KnowledgeBaseFilterBottomSheetState();
}

class _KnowledgeBaseFilterBottomSheetState
    extends State<KnowledgeBaseFilterBottomSheet> {
  late KnowledgeBaseType? _selectedType;
  late KnowledgeBaseStatus? _selectedStatus;
  late List<String> _selectedTags;
  late String _currentSort;
  late String _currentOrder;

  final _tagController = TextEditingController();
  final List<String> _availableTags = [
    '技术文档',
    '产品手册',
    '用户指南',
    'FAQ',
    '培训资料',
    'API文档',
    '最佳实践',
    '故障排除',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _selectedStatus = widget.selectedStatus;
    _selectedTags = List.from(widget.selectedTags);
    _currentSort = widget.currentSort;
    _currentOrder = widget.currentOrder;
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeFilter(),
                  const SizedBox(height: 24),
                  _buildStatusFilter(),
                  const SizedBox(height: 24),
                  _buildTagsFilter(),
                  const SizedBox(height: 24),
                  _buildSortOptions(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          const Text(
            '筛选条件',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _resetFilters,
            child: const Text('重置'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '知识库类型',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              label: '全部类型',
              selected: _selectedType == null,
              onTap: () => setState(() => _selectedType = null),
            ),
            ...KnowledgeBaseType.values.map((type) => _buildFilterChip(
                  label: type.displayName,
                  selected: _selectedType == type,
                  onTap: () => setState(() => _selectedType = type),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '状态',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              label: '全部状态',
              selected: _selectedStatus == null,
              onTap: () => setState(() => _selectedStatus = null),
            ),
            ...KnowledgeBaseStatus.values.map((status) => _buildFilterChip(
                  label: status.displayName,
                  selected: _selectedStatus == status,
                  onTap: () => setState(() => _selectedStatus = status),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '标签',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedTags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedTags.map((tag) => _buildSelectedTagChip(tag)).toList(),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: '输入标签名称',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onSubmitted: _addCustomTag,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _addCustomTag(_tagController.text),
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          '常用标签',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags
              .where((tag) => !_selectedTags.contains(tag))
              .map((tag) => _buildAvailableTagChip(tag))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '排序方式',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        _buildSortOption('最后活动', 'last_activity'),
        _buildSortOption('创建时间', 'created_at'),
        _buildSortOption('更新时间', 'updated_at'),
        _buildSortOption('名称', 'name'),
        _buildSortOption('文档数量', 'document_count'),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('排序顺序：'),
            const SizedBox(width: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'DESC', label: Text('降序')),
                ButtonSegment(value: 'ASC', label: Text('升序')),
              ],
              selected: {_currentOrder},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _currentOrder = selection.first;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : Colors.grey[700],
        fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
      ),
    );
  }

  Widget _buildSelectedTagChip(String tag) {
    return Chip(
      label: Text(tag),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => _removeTag(tag),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      labelStyle: TextStyle(color: AppColors.primary),
    );
  }

  Widget _buildAvailableTagChip(String tag) {
    return ActionChip(
      label: Text(tag),
      onPressed: () => _addTag(tag),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildSortOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _currentSort,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _currentSort = newValue;
          });
        }
      },
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('取消'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('应用筛选'),
            ),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
      _selectedTags.clear();
      _currentSort = 'last_activity';
      _currentOrder = 'DESC';
    });
  }

  void _addCustomTag(String tagText) {
    final tag = tagText.trim();
    if (tag.isNotEmpty && !_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _addTag(String tag) {
    if (!_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  void _applyFilters() {
    widget.onApplyFilter(
      _selectedType,
      _selectedStatus,
      _selectedTags,
      _currentSort,
      _currentOrder,
    );
    Navigator.of(context).pop();
  }
} 