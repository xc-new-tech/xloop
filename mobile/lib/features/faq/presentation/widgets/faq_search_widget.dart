import 'package:flutter/material.dart';

import '../../domain/entities/faq_entity.dart';

class FaqSearchWidget extends StatefulWidget {
  final String? initialQuery;
  final String? selectedCategory;
  final FaqStatus? selectedStatus;
  final bool? isPublic;
  final List<String> selectedTags;
  final FaqSort sort;
  final List<String> availableCategories;
  final List<String> availableTags;
  final Function(String?) onSearchChanged;
  final Function(String?) onCategoryChanged;
  final Function(FaqStatus?) onStatusChanged;
  final Function(bool?) onPublicChanged;
  final Function(List<String>) onTagsChanged;
  final Function(FaqSort) onSortChanged;
  final VoidCallback? onClearFilters;

  const FaqSearchWidget({
    super.key,
    this.initialQuery,
    this.selectedCategory,
    this.selectedStatus,
    this.isPublic,
    this.selectedTags = const [],
    this.sort = const FaqSort(),
    this.availableCategories = const [],
    this.availableTags = const [],
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onPublicChanged,
    required this.onTagsChanged,
    required this.onSortChanged,
    this.onClearFilters,
  });

  @override
  State<FaqSearchWidget> createState() => _FaqSearchWidgetState();
}

class _FaqSearchWidgetState extends State<FaqSearchWidget> {
  late TextEditingController _searchController;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // 搜索栏
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索FAQ...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              widget.onSearchChanged(null);
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: widget.onSearchChanged,
                  onSubmitted: widget.onSearchChanged,
                ),
              ),
              const SizedBox(width: 8),
              // 筛选按钮
              IconButton.filledTonal(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                ),
              ),
              // 排序按钮
              PopupMenuButton<FaqSort>(
                onSelected: widget.onSortChanged,
                icon: const Icon(Icons.sort),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: const FaqSort(
                      sortBy: FaqSortBy.createdAt,
                      sortOrder: FaqSortOrder.desc,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        const Text('最新创建'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: const FaqSort(
                      sortBy: FaqSortBy.updatedAt,
                      sortOrder: FaqSortOrder.desc,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.update,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        const Text('最近更新'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: const FaqSort(
                      sortBy: FaqSortBy.viewCount,
                      sortOrder: FaqSortOrder.desc,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        const Text('浏览量'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: const FaqSort(
                      sortBy: FaqSortBy.likeCount,
                      sortOrder: FaqSortOrder.desc,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.thumb_up_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        const Text('点赞数'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: const FaqSort(
                      sortBy: FaqSortBy.priority,
                      sortOrder: FaqSortOrder.desc,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.priority_high,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        const Text('优先级'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 筛选面板
        if (_showFilters) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 筛选标题和清除按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '筛选条件',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_hasActiveFilters)
                      TextButton.icon(
                        onPressed: widget.onClearFilters,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('清除筛选'),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 筛选选项
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    // 分类筛选
                    _buildCategoryFilter(context),
                    
                    // 状态筛选
                    _buildStatusFilter(context),
                    
                    // 公开性筛选
                    _buildPublicFilter(context),
                  ],
                ),
                
                // 标签筛选
                if (widget.availableTags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildTagsFilter(context),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<String?>(
        value: widget.selectedCategory,
        decoration: const InputDecoration(
          labelText: '分类',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('全部分类'),
          ),
          ...widget.availableCategories.map(
            (category) => DropdownMenuItem<String?>(
              value: category,
              child: Text(category),
            ),
          ),
        ],
        onChanged: widget.onCategoryChanged,
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context) {
    return SizedBox(
      width: 120,
      child: DropdownButtonFormField<FaqStatus?>(
        value: widget.selectedStatus,
        decoration: const InputDecoration(
          labelText: '状态',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: const [
          DropdownMenuItem<FaqStatus?>(
            value: null,
            child: Text('全部状态'),
          ),
          DropdownMenuItem<FaqStatus?>(
            value: FaqStatus.published,
            child: Text('已发布'),
          ),
          DropdownMenuItem<FaqStatus?>(
            value: FaqStatus.draft,
            child: Text('草稿'),
          ),
          DropdownMenuItem<FaqStatus?>(
            value: FaqStatus.archived,
            child: Text('已归档'),
          ),
        ],
        onChanged: widget.onStatusChanged,
      ),
    );
  }

  Widget _buildPublicFilter(BuildContext context) {
    return SizedBox(
      width: 120,
      child: DropdownButtonFormField<bool?>(
        value: widget.isPublic,
        decoration: const InputDecoration(
          labelText: '可见性',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: const [
          DropdownMenuItem<bool?>(
            value: null,
            child: Text('全部'),
          ),
          DropdownMenuItem<bool?>(
            value: true,
            child: Text('公开'),
          ),
          DropdownMenuItem<bool?>(
            value: false,
            child: Text('私有'),
          ),
        ],
        onChanged: widget.onPublicChanged,
      ),
    );
  }

  Widget _buildTagsFilter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '标签',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableTags.map((tag) {
            final isSelected = widget.selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                final newTags = List<String>.from(widget.selectedTags);
                if (selected) {
                  newTags.add(tag);
                } else {
                  newTags.remove(tag);
                }
                widget.onTagsChanged(newTags);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  bool get _hasActiveFilters {
    return widget.selectedCategory != null ||
        widget.selectedStatus != null ||
        widget.isPublic != null ||
        widget.selectedTags.isNotEmpty;
  }
} 