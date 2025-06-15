import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../shared/presentation/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../shared/presentation/widgets/empty_state_widget.dart';
import '../../domain/entities/conversation.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import '../bloc/conversation_state.dart';
import '../widgets/conversation_card.dart';
import '../widgets/conversation_search_bar.dart';
import '../widgets/conversation_filter_dialog.dart';
import '../widgets/conversation_sort_dialog.dart';
import '../widgets/conversation_selection_bar.dart';
import 'create_conversation_page.dart';

class ConversationListPage extends StatefulWidget {
  final String? knowledgeBaseId;

  const ConversationListPage({
    Key? key,
    this.knowledgeBaseId,
  }) : super(key: key);

  @override
  State<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  late ConversationBloc _conversationBloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _conversationBloc = GetIt.instance<ConversationBloc>();
    _scrollController.addListener(_onScroll);
    
    // 初始加载对话列表
    _conversationBloc.add(GetConversationsEvent(
      knowledgeBaseId: widget.knowledgeBaseId,
      refresh: true,
    ));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _conversationBloc.add(const LoadMoreConversationsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onRefresh() {
    _conversationBloc.add(GetConversationsEvent(
      knowledgeBaseId: widget.knowledgeBaseId,
      refresh: true,
    ));
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) {
      _conversationBloc.add(const ClearSearchEvent());
    } else {
      _conversationBloc.add(SearchConversationsEvent(
        query: query.trim(),
        knowledgeBaseId: widget.knowledgeBaseId,
      ));
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => ConversationFilterDialog(
        onApplyFilter: (type, status, knowledgeBaseId) {
          _conversationBloc.add(FilterConversationsEvent(
            type: type,
            status: status,
            knowledgeBaseId: knowledgeBaseId ?? widget.knowledgeBaseId,
          ));
        },
        onClearFilter: () {
          _conversationBloc.add(const ClearFiltersEvent());
        },
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => ConversationSortDialog(
        onSort: (sortBy, sortOrder) {
          _conversationBloc.add(SortConversationsEvent(
            sortBy: sortBy,
            sortOrder: sortOrder,
          ));
        },
      ),
    );
  }

  void _createNewConversation() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateConversationPage(
          initialKnowledgeBaseId: widget.knowledgeBaseId,
        ),
      ),
    );
  }

  void _deleteSelectedConversations(List<String> selectedIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 ${selectedIds.length} 个对话吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _conversationBloc.add(BulkDeleteConversationsEvent(ids: selectedIds));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _conversationBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('对话管理'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
              tooltip: '筛选',
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: _showSortDialog,
              tooltip: '排序',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'refresh':
                    _onRefresh();
                    break;
                  case 'clear_cache':
                    _conversationBloc.add(const ClearConversationCacheEvent());
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'refresh',
                  child: ListTile(
                    leading: Icon(Icons.refresh),
                    title: Text('刷新'),
                    dense: true,
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_cache',
                  child: ListTile(
                    leading: Icon(Icons.clear_all),
                    title: Text('清除缓存'),
                    dense: true,
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // 搜索栏
            ConversationSearchBar(
              controller: _searchController,
              onSearch: _onSearch,
              onClear: () {
                _searchController.clear();
                _conversationBloc.add(const ClearSearchEvent());
              },
            ),
            
            // 选择模式工具栏
            BlocBuilder<ConversationBloc, ConversationState>(
              builder: (context, state) {
                if (state is ConversationsLoaded && state.isSelectionMode) {
                  return ConversationSelectionBar(
                    selectedCount: state.selectedCount,
                    isAllSelected: state.isAllSelected,
                    onSelectAll: (selectAll) {
                      _conversationBloc.add(
                        SelectAllConversationsEvent(selectAll: selectAll),
                      );
                    },
                    onDelete: () {
                      _deleteSelectedConversations(state.selectedIds.toList());
                    },
                    onCancel: () {
                      _conversationBloc.add(const ClearSelectionEvent());
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            
            // 对话列表
            Expanded(
              child: BlocConsumer<ConversationBloc, ConversationState>(
                listener: (context, state) {
                  if (state is ConversationError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is ConversationsBulkDeleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('已删除 ${state.deletedCount} 个对话'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (state is ConversationOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ConversationLoading) {
                    return const LoadingWidget();
                  }
                  
                  if (state is ConversationError) {
                    return AppErrorWidget(
                      message: state.message,
                      onRetry: _onRefresh,
                    );
                  }
                  
                  if (state is ConversationsLoaded) {
                    final conversations = state.filteredConversations;
                    
                    if (conversations.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.chat_bubble_outline,
                        title: state.hasActiveFilters ? '没有找到匹配的对话' : '还没有对话',
                        message: state.hasActiveFilters 
                            ? '尝试调整筛选条件' 
                            : '点击下方按钮创建第一个对话',
                        actionText: state.hasActiveFilters ? '清除筛选' : '创建对话',
                        onAction: state.hasActiveFilters 
                            ? () => _conversationBloc.add(const ClearFiltersEvent())
                            : _createNewConversation,
                      );
                    }
                    
                    return RefreshIndicator(
                      onRefresh: () async => _onRefresh(),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: conversations.length + 
                            (state.hasReachedMax ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (index >= conversations.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          
                          final conversation = conversations[index];
                          final isSelected = state.selectedIds.contains(conversation.id);
                          
                          return ConversationCard(
                            conversation: conversation,
                            isSelected: isSelected,
                            isSelectionMode: state.isSelectionMode,
                            onTap: () {
                              if (state.isSelectionMode) {
                                _conversationBloc.add(
                                  SelectConversationEvent(
                                    id: conversation.id,
                                    selected: !isSelected,
                                  ),
                                );
                              } else {
                                Navigator.of(context).pushNamed(
                                  '/conversation/detail',
                                  arguments: conversation.id,
                                );
                              }
                            },
                            onLongPress: () {
                              if (!state.isSelectionMode) {
                                _conversationBloc.add(
                                  SelectConversationEvent(
                                    id: conversation.id,
                                    selected: true,
                                  ),
                                );
                              }
                            },
                            onDelete: () {
                              _conversationBloc.add(
                                DeleteConversationEvent(id: conversation.id),
                              );
                            },
                            onEdit: () {
                              Navigator.of(context).pushNamed(
                                '/conversation/edit',
                                arguments: conversation.id,
                              );
                            },
                          );
                        },
                      ),
                    );
                  }
                  
                  return const EmptyStateWidget(
                    icon: Icons.chat_bubble_outline,
                    title: '加载对话中...',
                    message: '请稍候',
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: BlocBuilder<ConversationBloc, ConversationState>(
          builder: (context, state) {
            if (state is ConversationsLoaded && state.isSelectionMode) {
              return const SizedBox.shrink();
            }
            
            return FloatingActionButton(
              onPressed: _createNewConversation,
              child: const Icon(Icons.add),
              tooltip: '新建对话',
            );
          },
        ),
      ),
    );
  }
} 