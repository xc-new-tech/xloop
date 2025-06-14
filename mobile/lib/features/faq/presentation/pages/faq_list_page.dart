import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/faq_bloc.dart';
import '../bloc/faq_event.dart';
import '../bloc/faq_state.dart';
import '../widgets/faq_list_item.dart';
import '../widgets/faq_search_bar.dart';
import '../../../shared/presentation/widgets/base_page.dart';
import '../../domain/entities/faq_entity.dart';

/// FAQ列表页面
class FaqListPage extends StatefulWidget {
  final String? categoryId;
  final String? knowledgeBaseId;

  const FaqListPage({
    super.key,
    this.categoryId,
    this.knowledgeBaseId,
  });

  @override
  State<FaqListPage> createState() => _FaqListPageState();
}

class _FaqListPageState extends State<FaqListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFaqs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadFaqs() {
    context.read<FaqBloc>().add(const SearchFaqsEvent(
      filter: const FaqFilter(),
      sort: const FaqSort(),
      isRefresh: true,
    ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = context.read<FaqBloc>().state;
      if (!state.isLoadingMore && state.hasMore) {
        context.read<FaqBloc>().add(const LoadMoreFaqsEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FaqBloc, FaqState>(
      builder: (context, state) {
        return BasePage(
          title: '常见问题',
          actions: [
            // 搜索按钮
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchBottomSheet(context),
            ),
            
            // 筛选按钮
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.filter_list),
                  if (state.filter.hasActiveFilters)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () => _showFilterBottomSheet(context),
            ),
            
            // 选择模式切换按钮
            if (state.faqs.isNotEmpty)
              IconButton(
                icon: Icon(state.isSelectionMode
                    ? Icons.close
                    : Icons.checklist),
                onPressed: () {
                  if (state.isSelectionMode) {
                    context.read<FaqBloc>().add(const ExitSelectionModeEvent());
                  } else {
                    context.read<FaqBloc>().add(const EnterSelectionModeEvent());
                  }
                },
              ),
          ],
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/faq/create'),
            child: const Icon(Icons.add),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, FaqState state) {
    if (state.isLoading && state.faqs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && state.faqs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage ?? '加载失败'),
            ElevatedButton(
              onPressed: _loadFaqs,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (state.faqs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz_outlined, size: 64),
            const SizedBox(height: 16),
            const Text('暂无FAQ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('还没有创建任何FAQ，点击右下角按钮开始创建吧！'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/faq/create'),
              child: const Text('创建FAQ'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 选择模式工具栏
        if (state.isSelectionMode) _buildSelectionToolbar(context, state),
        
        // FAQ列表
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<FaqBloc>().add(const RefreshFaqsEvent());
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.faqs.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.faqs.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final faq = state.faqs[index];
                final isSelected = state.selectedFaqIds.contains(faq.id);

                return FaqListItem(
                  faq: faq,
                  isSelected: isSelected,
                  isSelectionMode: state.isSelectionMode,
                  onTap: () => context.push('/faq/${faq.id}'),
                  onLongPress: () {
                    if (!state.isSelectionMode) {
                      context.read<FaqBloc>().add(const EnterSelectionModeEvent());
                    }
                    context.read<FaqBloc>().add(SelectFaqEvent(id: faq.id));
                  },
                  onToggleSelection: () {
                    if (isSelected) {
                      context.read<FaqBloc>().add(UnselectFaqEvent(id: faq.id));
                    } else {
                      context.read<FaqBloc>().add(SelectFaqEvent(id: faq.id));
                    }
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionToolbar(BuildContext context, FaqState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '已选择 ${state.selectedFaqIds.length} 项',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const Spacer(),
          
          // 全选/取消全选
          TextButton(
            onPressed: () {
              if (state.selectedFaqIds.length == state.faqs.length) {
                context.read<FaqBloc>().add(const UnselectAllFaqsEvent());
              } else {
                context.read<FaqBloc>().add(const SelectAllFaqsEvent());
              }
            },
            child: Text(
              state.selectedFaqIds.length == state.faqs.length ? '取消全选' : '全选',
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 批量删除
          if (state.selectedFaqIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showBulkDeleteDialog(context, state),
            ),
        ],
      ),
    );
  }

  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: context.read<FaqBloc>(),
        child: const FaqSearchBar(),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: context.read<FaqBloc>(),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '筛选和排序',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              // TODO: 实现筛选和排序UI
              const Text('筛选选项开发中...'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('确定'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBulkDeleteDialog(BuildContext context, FaqState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('批量删除'),
        content: Text('确定要删除选中的 ${state.selectedFaqIds.length} 个FAQ吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              context.read<FaqBloc>().add(
                BulkDeleteFaqsEvent(ids: state.selectedFaqIds.toList()),
              );
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
} 