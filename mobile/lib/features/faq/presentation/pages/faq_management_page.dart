import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../shared/presentation/widgets/base_page.dart';
import '../../../shared/presentation/widgets/loading_overlay.dart';
import '../../domain/entities/faq_entity.dart';
import '../bloc/faq_bloc.dart';
import '../bloc/faq_event.dart';
import '../bloc/faq_state.dart';
import '../widgets/faq_list_widget.dart';
import '../widgets/faq_search_widget.dart';

class FaqManagementPage extends StatefulWidget {
  final String? knowledgeBaseId;

  const FaqManagementPage({
    super.key,
    this.knowledgeBaseId,
  });

  @override
  State<FaqManagementPage> createState() => _FaqManagementPageState();
}

class _FaqManagementPageState extends State<FaqManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // 搜索和筛选状态
  String? _searchQuery;
  String? _selectedCategory;
  FaqStatus? _selectedStatus;
  bool? _isPublic;
  List<String> _selectedTags = [];
  FaqSort _sort = const FaqSort(
    sortBy: FaqSortBy.updatedAt,
    sortOrder: FaqSortOrder.desc,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FaqBloc>(),
      child: BlocBuilder<FaqBloc, FaqState>(
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state.isSubmitting,
            child: BasePage(
              title: 'FAQ管理',
              actions: [
                // 选择模式切换
                if (state.isSelectionMode) ...[
                  TextButton(
                    onPressed: () {
                      context.read<FaqBloc>().add(const ExitSelectionModeEvent());
                    },
                    child: const Text('取消'),
                  ),
                  if (state.selectedIds.isNotEmpty) ...[
                    IconButton(
                      onPressed: () => _showBulkDeleteConfirmation(context, state),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: '批量删除',
                    ),
                  ],
                ] else ...[
                  IconButton(
                    onPressed: () {
                      context.read<FaqBloc>().add(const EnterSelectionModeEvent());
                    },
                    icon: const Icon(Icons.checklist_outlined),
                    tooltip: '选择',
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: 导航到创建FAQ页面
                      _showComingSoon(context, '创建FAQ');
                    },
                    icon: const Icon(Icons.add),
                    tooltip: '创建FAQ',
                  ),
                ],
              ],
              body: Column(
                children: [
                  // 搜索和筛选
                  FaqSearchWidget(
                    initialQuery: _searchQuery,
                    selectedCategory: _selectedCategory,
                    selectedStatus: _selectedStatus,
                    isPublic: _isPublic,
                    selectedTags: _selectedTags,
                    sort: _sort,
                    availableCategories: state.categories.map((cat) => cat.category).toList(),
                    availableTags: state.tags,
                    onSearchChanged: _onSearchChanged,
                    onCategoryChanged: _onCategoryChanged,
                    onStatusChanged: _onStatusChanged,
                    onPublicChanged: _onPublicChanged,
                    onTagsChanged: _onTagsChanged,
                    onSortChanged: _onSortChanged,
                    onClearFilters: _onClearFilters,
                  ),
                  
                  // 标签页
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.list_outlined),
                              const SizedBox(width: 8),
                              Text('全部 (${state.totalCount})'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.public),
                              const SizedBox(width: 8),
                              Text('公开 (${state.publicCount})'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.drafts_outlined),
                              const SizedBox(width: 8),
                              Text('草稿 (${state.draftCount})'),
                            ],
                          ),
                        ),
                      ],
                      onTap: _onTabChanged,
                    ),
                  ),
                  
                  // FAQ列表
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // 全部FAQ
                        FaqListWidget(
                          searchQuery: _searchQuery,
                          selectedCategory: _selectedCategory,
                          selectedStatus: _selectedStatus,
                          knowledgeBaseId: widget.knowledgeBaseId,
                          isPublic: _isPublic,
                          selectedTags: _selectedTags,
                          sort: _sort,
                          onFaqTap: _onFaqTap,
                          onFaqEdit: _onFaqEdit,
                          onFaqDelete: _onFaqDelete,
                        ),
                        
                        // 公开FAQ
                        FaqListWidget(
                          searchQuery: _searchQuery,
                          selectedCategory: _selectedCategory,
                          selectedStatus: _selectedStatus,
                          knowledgeBaseId: widget.knowledgeBaseId,
                          isPublic: true,
                          selectedTags: _selectedTags,
                          sort: _sort,
                          onFaqTap: _onFaqTap,
                          onFaqEdit: _onFaqEdit,
                          onFaqDelete: _onFaqDelete,
                        ),
                        
                        // 草稿FAQ
                        FaqListWidget(
                          searchQuery: _searchQuery,
                          selectedCategory: _selectedCategory,
                          selectedStatus: FaqStatus.draft,
                          knowledgeBaseId: widget.knowledgeBaseId,
                          isPublic: _isPublic,
                          selectedTags: _selectedTags,
                          sort: _sort,
                          onFaqTap: _onFaqTap,
                          onFaqEdit: _onFaqEdit,
                          onFaqDelete: _onFaqDelete,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              floatingActionButton: state.isSelectionMode 
                  ? null 
                  : FloatingActionButton(
                      onPressed: () {
                        context.push('/faq/create');
                      },
                      child: const Icon(Icons.add),
                    ),
            ),
          );
        },
      ),
    );
  }

  void _onSearchChanged(String? query) {
    setState(() {
      _searchQuery = query?.trim().isEmpty == true ? null : query?.trim();
    });
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onStatusChanged(FaqStatus? status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  void _onPublicChanged(bool? isPublic) {
    setState(() {
      _isPublic = isPublic;
    });
  }

  void _onTagsChanged(List<String> tags) {
    setState(() {
      _selectedTags = tags;
    });
  }

  void _onSortChanged(FaqSort sort) {
    setState(() {
      _sort = sort;
    });
  }

  void _onClearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedStatus = null;
      _isPublic = null;
      _selectedTags = [];
    });
  }

  void _onTabChanged(int index) {
    // 根据标签页切换筛选条件
    switch (index) {
      case 0: // 全部
        setState(() {
          _isPublic = null;
          _selectedStatus = null;
        });
        break;
      case 1: // 公开
        setState(() {
          _isPublic = true;
          _selectedStatus = null;
        });
        break;
      case 2: // 草稿
        setState(() {
          _isPublic = null;
          _selectedStatus = FaqStatus.draft;
        });
        break;
    }
  }

  void _onFaqTap(FaqEntity faq) {
    context.push('/faq/detail/${faq.id}');
  }

  void _onFaqEdit(FaqEntity faq) {
    context.push('/faq/edit/${faq.id}');
  }

  void _onFaqDelete(FaqEntity faq) {
    // 删除操作已在FaqListWidget中处理
  }

  void _showBulkDeleteConfirmation(BuildContext context, FaqState state) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('批量删除确认'),
        content: Text('确定要删除选中的 ${state.selectedIds.length} 个FAQ吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<FaqBloc>().add(
                BulkDeleteFaqsEvent(ids: List.from(state.selectedIds)),
              );
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 功能即将推出'),
        action: SnackBarAction(
          label: '知道了',
          onPressed: () {},
        ),
      ),
    );
  }
} 