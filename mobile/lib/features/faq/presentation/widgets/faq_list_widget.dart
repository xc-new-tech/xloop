import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/presentation/widgets/base_page.dart';
import '../../domain/entities/faq_entity.dart';
import '../bloc/faq_bloc.dart';
import '../bloc/faq_event.dart';
import '../bloc/faq_state.dart';
import 'faq_item_widget.dart';

class FaqListWidget extends StatefulWidget {
  final String? searchQuery;
  final String? selectedCategory;
  final FaqStatus? selectedStatus;
  final String? knowledgeBaseId;
  final bool? isPublic;
  final List<String> selectedTags;
  final FaqSort sort;
  final Function(FaqEntity)? onFaqTap;
  final Function(FaqEntity)? onFaqEdit;
  final Function(FaqEntity)? onFaqDelete;

  const FaqListWidget({
    super.key,
    this.searchQuery,
    this.selectedCategory,
    this.selectedStatus,
    this.knowledgeBaseId,
    this.isPublic,
    this.selectedTags = const [],
    this.sort = const FaqSort(),
    this.onFaqTap,
    this.onFaqEdit,
    this.onFaqDelete,
  });

  @override
  State<FaqListWidget> createState() => _FaqListWidgetState();
}

class _FaqListWidgetState extends State<FaqListWidget> {
  final ScrollController _scrollController = ScrollController();
  late FaqBloc _faqBloc;

  @override
  void initState() {
    super.initState();
    _faqBloc = context.read<FaqBloc>();
    _scrollController.addListener(_onScroll);
    
    // 初始加载FAQ列表
    _loadFaqs();
  }

  @override
  void didUpdateWidget(FaqListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 检查是否需要重新加载数据
    if (widget.searchQuery != oldWidget.searchQuery ||
        widget.selectedCategory != oldWidget.selectedCategory ||
        widget.selectedStatus != oldWidget.selectedStatus ||
        widget.knowledgeBaseId != oldWidget.knowledgeBaseId ||
        widget.isPublic != oldWidget.isPublic ||
        widget.selectedTags != oldWidget.selectedTags ||
        widget.sort != oldWidget.sort) {
      _loadFaqs();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadFaqs() {
    _faqBloc.add(GetFaqsEvent(
      search: widget.searchQuery,
      category: widget.selectedCategory,
      status: widget.selectedStatus,
      knowledgeBaseId: widget.knowledgeBaseId,
      isPublic: widget.isPublic,
      sort: widget.sort,
      tags: widget.selectedTags,
      page: 1,
      limit: 20,
      isRefresh: true,
    ));
  }

  void _onScroll() {
    if (_isBottom) {
      _faqBloc.add(const LoadMoreFaqsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FaqBloc, FaqState>(
      builder: (context, state) {
        if (state.isInitial || (state.isLoading && state.faqs.isEmpty)) {
          return const BaseLoadingPage();
        }

        if (state.hasError && state.faqs.isEmpty) {
          return BaseErrorPage(
            title: '加载失败',
            subtitle: state.errorMessage ?? '无法加载FAQ列表',
            actionText: '重试',
            onAction: _loadFaqs,
          );
        }

        if (state.faqs.isEmpty) {
          return BaseEmptyPage(
            title: '暂无FAQ',
            subtitle: '还没有创建任何FAQ\n点击添加按钮创建第一个FAQ',
            icon: Icons.quiz_outlined,
            actionText: '创建FAQ',
            onAction: () {
              // TODO: 导航到创建FAQ页面
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _faqBloc.add(const RefreshFaqsEvent());
            // 等待刷新完成
            await _faqBloc.stream.firstWhere(
              (state) => !state.isRefreshing,
            );
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // FAQ列表
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= state.faqs.length) {
                      // 加载更多指示器
                      return state.isLoadingMore
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : const SizedBox.shrink();
                    }

                    final faq = state.faqs[index];
                    return FaqItemWidget(
                      faq: faq,
                      isSelected: state.selectedIds.contains(faq.id),
                      isSelectionMode: state.isSelectionMode,
                      onTap: () => widget.onFaqTap?.call(faq),
                      onLike: () => _faqBloc.add(LikeFaqEvent(id: faq.id)),
                      onDislike: () => _faqBloc.add(DislikeFaqEvent(id: faq.id)),
                      onEdit: () => widget.onFaqEdit?.call(faq),
                      onDelete: () => _showDeleteConfirmation(context, faq),
                      onSelectionChanged: (selected) {
                        if (selected == true) {
                          _faqBloc.add(SelectFaqEvent(id: faq.id));
                        } else {
                          _faqBloc.add(UnselectFaqEvent(id: faq.id));
                        }
                      },
                    );
                  },
                  childCount: state.faqs.length + (state.isLoadingMore ? 1 : 0),
                ),
              ),
              
              // 底部间距
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, FaqEntity faq) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除FAQ "${faq.shortQuestion}" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _faqBloc.add(DeleteFaqEvent(id: faq.id));
              widget.onFaqDelete?.call(faq);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
} 