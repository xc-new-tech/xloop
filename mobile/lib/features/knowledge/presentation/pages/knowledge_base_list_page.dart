import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/logger_utils.dart';
import '../../../../features/shared/presentation/widgets/loading_widget.dart';
import '../../../../features/shared/presentation/widgets/error_widget.dart';
import '../../../../features/shared/presentation/widgets/empty_state_widget.dart';
import '../../domain/entities/knowledge_base.dart';
import '../bloc/knowledge_base_bloc.dart';
import '../bloc/knowledge_base_event.dart';
import '../bloc/knowledge_base_state.dart';
import '../widgets/knowledge_base_card.dart';
import '../widgets/knowledge_base_filter_bottom_sheet.dart';
// import '../widgets/knowledge_base_search_delegate.dart'; // TODO: 实现搜索委托

class KnowledgeBaseListPage extends StatefulWidget {
  const KnowledgeBaseListPage({super.key});

  @override
  State<KnowledgeBaseListPage> createState() => _KnowledgeBaseListPageState();
}

class _KnowledgeBaseListPageState extends State<KnowledgeBaseListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  
  // 筛选参数
  String _currentSort = 'last_activity';
  String _currentOrder = 'DESC';
  KnowledgeBaseType? _selectedType;
  KnowledgeBaseStatus? _selectedStatus;
  List<String> _selectedTags = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
    
    // 初始加载数据
    _loadData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _loadData();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 触发加载更多
      _loadMoreData();
    }
  }

  void _loadData() {
    final bloc = context.read<KnowledgeBaseBloc>();
    
    switch (_tabController.index) {
      case 0: // 全部
        bloc.add(GetKnowledgeBasesEvent(
          search: _searchController.text.isEmpty ? null : _searchController.text,
          type: _selectedType,
          status: _selectedStatus,
          tags: _selectedTags.isEmpty ? null : _selectedTags,
          page: 1,
        ));
        break;
      case 1: // 我的
        bloc.add(GetMyKnowledgeBasesEvent(
          status: _selectedStatus,
          type: _selectedType,
          page: 1,
        ));
        break;
      case 2: // 公开
        bloc.add(GetPublicKnowledgeBasesEvent(
          search: _searchController.text.isEmpty ? null : _searchController.text,
          tags: _selectedTags.isEmpty ? null : _selectedTags,
          page: 1,
        ));
        break;
    }
  }

  void _loadMoreData() {
    final bloc = context.read<KnowledgeBaseBloc>();
    final state = bloc.state;
    
    if (state is KnowledgeBaseListLoaded && state.hasMore) {
      switch (_tabController.index) {
        case 0: // 全部
          bloc.add(GetKnowledgeBasesEvent(
            search: _searchController.text.isEmpty ? null : _searchController.text,
            type: _selectedType,
            status: _selectedStatus,
            tags: _selectedTags.isEmpty ? null : _selectedTags,
            page: state.currentPage + 1,
          ));
          break;
        case 1: // 我的
          bloc.add(GetMyKnowledgeBasesEvent(
            status: _selectedStatus,
            type: _selectedType,
            page: state.currentPage + 1,
          ));
          break;
        case 2: // 公开
          bloc.add(GetPublicKnowledgeBasesEvent(
            search: _searchController.text.isEmpty ? null : _searchController.text,
            tags: _selectedTags.isEmpty ? null : _selectedTags,
            page: state.currentPage + 1,
          ));
          break;
      }
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KnowledgeBaseFilterBottomSheet(
        selectedType: _selectedType,
        selectedStatus: _selectedStatus,
        selectedTags: _selectedTags,
        currentSort: _currentSort,
        currentOrder: _currentOrder,
        onApplyFilter: (type, status, tags, sort, order) {
          setState(() {
            _selectedType = type;
            _selectedStatus = status;
            _selectedTags = tags;
            _currentSort = sort;
            _currentOrder = order;
          });
          _loadData();
        },
      ),
    );
  }

  void _showSearch() {
    // TODO: 实现搜索功能
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '输入搜索关键词',
          ),
          onSubmitted: (value) {
            Navigator.of(context).pop();
            _loadData();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadData();
            },
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  void _createKnowledgeBase() {
    context.push('/knowledge-base/new');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('知识库'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch,
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilterBottomSheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '我的'),
            Tab(text: '公开'),
          ],
        ),
      ),
      body: BlocConsumer<KnowledgeBaseBloc, KnowledgeBaseState>(
        listener: (context, state) {
          if (state is KnowledgeBaseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is KnowledgeBaseInitial) {
            return const Center(child: LoadingWidget());
          } else if (state is KnowledgeBaseLoading) {
            return const Center(child: LoadingWidget());
          } else if (state is KnowledgeBaseListLoaded) {
            if (state.knowledgeBases.isEmpty) {
              return _buildEmptyState();
            }
            return _buildKnowledgeBaseList(state);
          } else if (state is KnowledgeBaseError) {
            return Center(
              child: AppErrorWidget(
                message: state.message,
                onRetry: _loadData,
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createKnowledgeBase,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    String title = '';
    String description = '';
    
    switch (_tabController.index) {
      case 0:
        title = '暂无知识库';
        description = '还没有任何知识库，创建您的第一个知识库吧！';
        break;
      case 1:
        title = '您还没有创建知识库';
        description = '创建一个知识库来开始管理您的知识内容';
        break;
      case 2:
        title = '暂无公开知识库';
        description = '目前还没有公开的知识库可供浏览';
        break;
    }
    
    return EmptyStateWidget(
      message: title,
      actionText: _tabController.index == 2 ? null : '创建知识库',
      onAction: _tabController.index == 2 ? null : _createKnowledgeBase,
    );
  }

  Widget _buildKnowledgeBaseList(KnowledgeBaseListLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.knowledgeBases.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.knowledgeBases.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: LoadingWidget()),
            );
          }
          
          final knowledgeBase = state.knowledgeBases[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: KnowledgeBaseCard(
              knowledgeBase: knowledgeBase,
              onTap: () => _onKnowledgeBaseTap(knowledgeBase),
              onEdit: () => _onKnowledgeBaseEdit(knowledgeBase),
              onDelete: () => _onKnowledgeBaseDelete(knowledgeBase),
              onShare: () => _onKnowledgeBaseShare(knowledgeBase),
            ),
          );
        },
      ),
    );
  }

  void _onKnowledgeBaseTap(KnowledgeBase knowledgeBase) {
    LoggerUtils.d('点击知识库: ${knowledgeBase.name}');
    context.push('/knowledge-base/${knowledgeBase.id}');
  }

  void _onKnowledgeBaseEdit(KnowledgeBase knowledgeBase) {
    LoggerUtils.d('编辑知识库: ${knowledgeBase.name}');
    context.push('/knowledge-base/edit/${knowledgeBase.id}');
  }

  void _onKnowledgeBaseDelete(KnowledgeBase knowledgeBase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除知识库'),
        content: Text('确定要删除知识库"${knowledgeBase.name}"吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<KnowledgeBaseBloc>().add(
                    DeleteKnowledgeBaseEvent(knowledgeBase.id),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _onKnowledgeBaseShare(KnowledgeBase knowledgeBase) {
    LoggerUtils.d('分享知识库: ${knowledgeBase.name}');
    // TODO: 实现分享功能，需要选择用户
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享功能开发中')),
    );
  }
} 