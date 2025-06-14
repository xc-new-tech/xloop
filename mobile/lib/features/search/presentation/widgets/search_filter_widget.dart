import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 搜索筛选器组件
class SearchFilterWidget extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>>? onFiltersChanged;
  final Map<String, dynamic> initialFilters;

  const SearchFilterWidget({
    super.key,
    this.onFiltersChanged,
    this.initialFilters = const {},
  });

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  late Map<String, dynamic> _filters;
  
  // 筛选选项
  final List<String> _contentTypes = ['全部', '文档', 'FAQ', '对话'];
  final List<String> _dateSortOptions = ['相关性', '最新', '最旧'];
  final List<String> _sources = ['全部', '知识库A', '知识库B', '上传文件'];
  
  String _selectedContentType = '全部';
  String _selectedDateSort = '相关性';
  String _selectedSource = '全部';
  RangeValues _scoreRange = const RangeValues(0.0, 1.0);
  bool _includeArchived = false;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.initialFilters);
    _initializeFromFilters();
  }

  void _initializeFromFilters() {
    _selectedContentType = _filters['contentType'] ?? '全部';
    _selectedDateSort = _filters['dateSort'] ?? '相关性';
    _selectedSource = _filters['source'] ?? '全部';
    _scoreRange = RangeValues(
      _filters['minScore']?.toDouble() ?? 0.0,
      _filters['maxScore']?.toDouble() ?? 1.0,
    );
    _includeArchived = _filters['includeArchived'] ?? false;
  }

  void _updateFilters() {
    _filters = {
      'contentType': _selectedContentType == '全部' ? null : _selectedContentType,
      'dateSort': _selectedDateSort,
      'source': _selectedSource == '全部' ? null : _selectedSource,
      'minScore': _scoreRange.start,
      'maxScore': _scoreRange.end,
      'includeArchived': _includeArchived,
    };
    
    // 移除空值
    _filters.removeWhere((key, value) => value == null);
    
    widget.onFiltersChanged?.call(_filters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '搜索筛选',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _resetFilters,
                child: Text(
                  '重置',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFilterRow(),
          const SizedBox(height: 16),
          _buildScoreFilter(),
          const SizedBox(height: 16),
          _buildAdvancedOptions(),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdownFilter(
            label: '内容类型',
            value: _selectedContentType,
            options: _contentTypes,
            onChanged: (value) {
              setState(() {
                _selectedContentType = value!;
              });
              _updateFilters();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDropdownFilter(
            label: '排序方式',
            value: _selectedDateSort,
            options: _dateSortOptions,
            onChanged: (value) {
              setState(() {
                _selectedDateSort = value!;
              });
              _updateFilters();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDropdownFilter(
            label: '来源',
            value: _selectedSource,
            options: _sources,
            onChanged: (value) {
              setState(() {
                _selectedSource = value!;
              });
              _updateFilters();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              isExpanded: true,
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '相关性分数范围',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '${(_scoreRange.start * 100).toInt()}% - ${(_scoreRange.end * 100).toInt()}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _scoreRange,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          labels: RangeLabels(
            '${(_scoreRange.start * 100).toInt()}%',
            '${(_scoreRange.end * 100).toInt()}%',
          ),
          onChanged: (values) {
            setState(() {
              _scoreRange = values;
            });
          },
          onChangeEnd: (values) {
            _updateFilters();
          },
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primary.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '高级选项',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: _includeArchived,
              onChanged: (value) {
                setState(() {
                  _includeArchived = value ?? false;
                });
                _updateFilters();
              },
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '包含已归档内容',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedContentType = '全部';
      _selectedDateSort = '相关性';
      _selectedSource = '全部';
      _scoreRange = const RangeValues(0.0, 1.0);
      _includeArchived = false;
    });
    _updateFilters();
  }
}

/// 快速筛选器组件
class QuickFilterChips extends StatelessWidget {
  final List<String> selectedFilters;
  final ValueChanged<List<String>>? onFiltersChanged;

  const QuickFilterChips({
    super.key,
    required this.selectedFilters,
    this.onFiltersChanged,
  });

  static const List<String> _quickFilters = [
    '文档',
    'FAQ',
    '最新',
    '高分',
    '今日',
    '本周',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickFilters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _quickFilters[index];
          final isSelected = selectedFilters.contains(filter);

          return FilterChip(
            label: Text(
              filter,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              final newFilters = List<String>.from(selectedFilters);
              if (selected) {
                newFilters.add(filter);
              } else {
                newFilters.remove(filter);
              }
              onFiltersChanged?.call(newFilters);
            },
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.primary,
            checkmarkColor: Colors.white,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          );
        },
      ),
    );
  }
}

/// 活跃筛选器显示组件
class ActiveFiltersDisplay extends StatelessWidget {
  final Map<String, dynamic> filters;
  final ValueChanged<String>? onRemoveFilter;
  final VoidCallback? onClearAll;

  const ActiveFiltersDisplay({
    super.key,
    required this.filters,
    this.onRemoveFilter,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final activeFilters = _getActiveFilterTexts();
    
    if (activeFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '当前筛选',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (activeFilters.isNotEmpty)
                TextButton(
                  onPressed: onClearAll,
                  child: Text(
                    '清除全部',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: activeFilters.map((filterText) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filterText,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => onRemoveFilter?.call(filterText),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<String> _getActiveFilterTexts() {
    final List<String> texts = [];

    if (filters['contentType'] != null) {
      texts.add('类型: ${filters['contentType']}');
    }
    
    if (filters['source'] != null) {
      texts.add('来源: ${filters['source']}');
    }
    
    if (filters['dateSort'] != null && filters['dateSort'] != '相关性') {
      texts.add('排序: ${filters['dateSort']}');
    }
    
    if (filters['minScore'] != null && filters['minScore'] > 0.0) {
      texts.add('最低分: ${(filters['minScore'] * 100).toInt()}%');
    }
    
    if (filters['maxScore'] != null && filters['maxScore'] < 1.0) {
      texts.add('最高分: ${(filters['maxScore'] * 100).toInt()}%');
    }
    
    if (filters['includeArchived'] == true) {
      texts.add('包含归档');
    }

    return texts;
  }
} 