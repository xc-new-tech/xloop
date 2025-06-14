import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/faq_bloc.dart';
import '../bloc/faq_event.dart';
import '../bloc/faq_state.dart';
import '../../domain/entities/faq_entity.dart';

/// FAQ搜索栏组件
class FaqSearchBar extends StatefulWidget {
  const FaqSearchBar({super.key});

  @override
  State<FaqSearchBar> createState() => _FaqSearchBarState();
}

class _FaqSearchBarState extends State<FaqSearchBar> {
  late TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final currentFilter = context.read<FaqBloc>().state.filter;
    _searchController = TextEditingController(text: currentFilter.search ?? '');
    
    // 自动获得焦点
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FaqBloc, FaqState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              Row(
                children: [
                  Text(
                    '搜索FAQ',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 搜索框
              TextField(
                controller: _searchController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: '搜索问题、答案或标签...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.search,
                onChanged: (value) {
                  setState(() {});
                },
                onSubmitted: _performSearch,
              ),
              
              const SizedBox(height: 16),
              
              // 快速筛选选项
              _buildQuickFilters(context, state),
              
              const SizedBox(height: 16),
              
              // 搜索历史
              if (state.filter.search?.isEmpty ?? true)
                _buildSearchHistory(context),
              
              // 搜索建议
              if (_searchController.text.isNotEmpty)
                _buildSearchSuggestions(context),
              
              const SizedBox(height: 16),
              
              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<FaqBloc>().add(const ClearSearchEvent());
                        Navigator.pop(context);
                      },
                      child: const Text('清除筛选'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        _performSearch(_searchController.text);
                        Navigator.pop(context);
                      },
                      child: const Text('搜索'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickFilters(BuildContext context, FaqState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速筛选',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        
        // 状态筛选
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('已发布'),
              selected: state.filter.status == FaqStatus.published,
              onSelected: (selected) {
                final newFilter = state.filter.copyWith(
                  status: selected ? FaqStatus.published : null,
                );
                context.read<FaqBloc>().add(SetFilterEvent(filter: newFilter));
              },
            ),
            FilterChip(
              label: const Text('草稿'),
              selected: state.filter.status == FaqStatus.draft,
              onSelected: (selected) {
                final newFilter = state.filter.copyWith(
                  status: selected ? FaqStatus.draft : null,
                );
                context.read<FaqBloc>().add(SetFilterEvent(filter: newFilter));
              },
            ),
            FilterChip(
              label: const Text('高优先级'),
              selected: state.filter.priority == FaqPriority.high,
              onSelected: (selected) {
                final newFilter = state.filter.copyWith(
                  priority: selected ? FaqPriority.high : null,
                );
                context.read<FaqBloc>().add(SetFilterEvent(filter: newFilter));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchHistory(BuildContext context) {
    // 模拟搜索历史
    final searchHistory = [
      '用户登录',
      '忘记密码',
      '账户安全',
      '系统设置',
    ];

    if (searchHistory.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '搜索历史',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // TODO: 清除搜索历史
              },
              child: const Text('清除'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: searchHistory.map((query) => ActionChip(
            label: Text(query),
            onPressed: () {
              _searchController.text = query;
              _performSearch(query);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchSuggestions(BuildContext context) {
    // 模拟搜索建议
    final suggestions = [
      '${_searchController.text}相关问题',
      '${_searchController.text}常见解决方案',
      '${_searchController.text}设置指南',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '搜索建议',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Column(
          children: suggestions.map((suggestion) => ListTile(
            leading: const Icon(Icons.search, size: 20),
            title: Text(suggestion),
            dense: true,
            onTap: () {
              _searchController.text = suggestion;
              _performSearch(suggestion);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ],
    );
  }

  void _performSearch(String searchQuery) {
    final currentFilter = context.read<FaqBloc>().state.filter;
    final newFilter = currentFilter.copyWith(
      search: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
    );
    
    context.read<FaqBloc>().add(SetFilterEvent(filter: newFilter));
    context.read<FaqBloc>().add(SearchFaqsEvent(
      filter: newFilter,
      sort: context.read<FaqBloc>().state.sort,
      isRefresh: true,
    ));
  }
} 