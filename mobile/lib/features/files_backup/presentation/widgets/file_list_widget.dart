import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../domain/entities/file_entity.dart';
import '../bloc/file_bloc.dart';
import '../bloc/file_event.dart';
import '../bloc/file_state.dart';
import 'file_item_widget.dart';

/// 文件列表组件
class FileListWidget extends StatefulWidget {
  final String? knowledgeBaseId;
  final String? category;
  final String? status;
  final bool enableSelection;
  final bool enableSearch;
  final bool enableFilter;
  final VoidCallback? onFileSelected;
  final Function(List<String>)? onSelectionChanged;

  const FileListWidget({
    super.key,
    this.knowledgeBaseId,
    this.category,
    this.status,
    this.enableSelection = false,
    this.enableSearch = true,
    this.enableFilter = true,
    this.onFileSelected,
    this.onSelectionChanged,
  });

  @override
  State<FileListWidget> createState() => _FileListWidgetState();
}

class _FileListWidgetState extends State<FileListWidget> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  String? _currentCategory;
  String? _currentStatus;
  String? _searchQuery;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _currentCategory = widget.category;
    _currentStatus = widget.status;
    
    // 初始加载文件列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFiles(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.enableSearch) _buildSearchBar(),
        if (widget.enableFilter) _buildFilterBar(),
        if (widget.enableSelection) _buildSelectionBar(),
        Expanded(child: _buildFileList()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索文件...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery?.isNotEmpty == true
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onSubmitted: _performSearch,
        onChanged: (value) {
          if (value.isEmpty && _searchQuery?.isNotEmpty == true) {
            _clearSearch();
          }
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _currentCategory,
              decoration: const InputDecoration(
                labelText: '文件类型',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('全部类型')),
                const DropdownMenuItem(value: 'document', child: Text('文档')),
                const DropdownMenuItem(value: 'image', child: Text('图片')),
                const DropdownMenuItem(value: 'audio', child: Text('音频')),
                const DropdownMenuItem(value: 'video', child: Text('视频')),
                const DropdownMenuItem(value: 'other', child: Text('其他')),
              ],
              onChanged: _onCategoryChanged,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _currentStatus,
              decoration: const InputDecoration(
                labelText: '状态',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('全部状态')),
                const DropdownMenuItem(value: 'uploading', child: Text('上传中')),
                const DropdownMenuItem(value: 'processing', child: Text('处理中')),
                const DropdownMenuItem(value: 'processed', child: Text('已处理')),
                const DropdownMenuItem(value: 'failed', child: Text('失败')),
              ],
              onChanged: _onStatusChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBar() {
    return BlocBuilder<FileBloc, FileState>(
      builder: (context, state) {
        if (state is FileListLoaded) {
          final selectedCount = state.selectedFileIds.length;
          final totalCount = state.files.length;
          
          if (selectedCount == 0) {
            return const SizedBox.shrink();
          }
          
          return Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withOpacity(0.1),
            child: Row(
              children: [
                Text(
                  '已选择 $selectedCount/$totalCount 个文件',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _selectAll,
                  child: Text(selectedCount == totalCount ? '取消全选' : '全选'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _clearSelection,
                  child: const Text('清除'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _deleteSelected,
                  icon: const Icon(Icons.delete),
                  tooltip: '删除选中',
                  color: AppColors.error,
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFileList() {
    return BlocBuilder<FileBloc, FileState>(
      builder: (context, state) {
        if (state is FileLoading && 
            (state is! FileListLoaded || (state as FileListLoaded).files.isEmpty)) {
          return const LoadingWidget(message: '加载文件列表...');
        }
        
        if (state is FileError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: () => _loadFiles(refresh: true),
          );
        }
        
        if (state is FileListLoaded) {
          if (state.files.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.folder_open,
              title: '暂无文件',
              subtitle: _searchQuery?.isNotEmpty == true 
                  ? '没有找到匹配的文件'
                  : '还没有上传任何文件',
              actionText: _searchQuery?.isNotEmpty == true ? '清除搜索' : null,
              onAction: _searchQuery?.isNotEmpty == true ? _clearSearch : null,
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async => _loadFiles(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.files.length + (state.hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= state.files.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                final file = state.files[index];
                final isSelected = state.selectedFileIds.contains(file.id);
                
                return FileItemWidget(
                  file: file,
                  isSelected: widget.enableSelection ? isSelected : null,
                  onTap: () => _onFileItemTap(file),
                  onSelectionChanged: widget.enableSelection 
                      ? (selected) => _onFileSelectionChanged(file.id, selected)
                      : null,
                );
              },
            ),
          );
        }
        
        if (state is FileSearchLoaded) {
          if (state.searchResults.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.search_off,
              title: '未找到文件',
              subtitle: '没有找到匹配 "${state.query}" 的文件',
              actionText: '清除搜索',
              onAction: _clearSearch,
            );
          }
          
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.searchResults.length + (state.hasReachedMax ? 0 : 1),
            itemBuilder: (context, index) {
              if (index >= state.searchResults.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              final file = state.searchResults[index];
              
              return FileItemWidget(
                file: file,
                onTap: () => _onFileItemTap(file),
                searchQuery: state.query,
              );
            },
          );
        }
        
        return const EmptyStateWidget(
          icon: Icons.folder_open,
          title: '暂无文件',
          subtitle: '还没有上传任何文件',
        );
      },
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = context.read<FileBloc>().state;
      if (state is FileListLoaded && !state.hasReachedMax) {
        context.read<FileBloc>().add(const LoadMoreFilesEvent());
      } else if (state is FileSearchLoaded && !state.hasReachedMax) {
        // 加载更多搜索结果
        context.read<FileBloc>().add(SearchFilesEvent(
          query: state.query,
          knowledgeBaseId: widget.knowledgeBaseId,
          category: _currentCategory,
          status: _currentStatus,
          page: state.currentPage + 1,
        ));
      }
    }
  }

  void _loadFiles({bool refresh = false}) {
    context.read<FileBloc>().add(GetFilesEvent(
      knowledgeBaseId: widget.knowledgeBaseId,
      category: _currentCategory,
      status: _currentStatus,
      search: _searchQuery,
      refresh: refresh,
    ));
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.trim().isEmpty ? null : query.trim();
    });
    
    if (_searchQuery != null) {
      context.read<FileBloc>().add(SearchFilesEvent(
        query: _searchQuery!,
        knowledgeBaseId: widget.knowledgeBaseId,
        category: _currentCategory,
        status: _currentStatus,
      ));
    } else {
      _loadFiles(refresh: true);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = null;
    });
    _loadFiles(refresh: true);
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _currentCategory = category;
    });
    
    if (_searchQuery != null) {
      _performSearch(_searchQuery!);
    } else {
      _loadFiles(refresh: true);
    }
  }

  void _onStatusChanged(String? status) {
    setState(() {
      _currentStatus = status;
    });
    
    if (_searchQuery != null) {
      _performSearch(_searchQuery!);
    } else {
      _loadFiles(refresh: true);
    }
  }

  void _onFileItemTap(FileEntity file) {
    widget.onFileSelected?.call();
    
    // 导航到文件详情页
    Navigator.pushNamed(
      context,
      '/files/detail',
      arguments: {'fileId': file.id},
    );
  }

  void _onFileSelectionChanged(String fileId, bool selected) {
    context.read<FileBloc>().add(SelectFileEvent(
      fileId: fileId,
      isSelected: selected,
    ));
    
    // 通知父组件选择状态变化
    final state = context.read<FileBloc>().state;
    if (state is FileListLoaded) {
      widget.onSelectionChanged?.call(state.selectedFileIds);
    }
  }

  void _selectAll() {
    final state = context.read<FileBloc>().state;
    if (state is FileListLoaded) {
      final allSelected = state.selectedFileIds.length == state.files.length;
      context.read<FileBloc>().add(SelectAllFilesEvent(!allSelected));
      
      widget.onSelectionChanged?.call(
        allSelected ? [] : state.files.map((f) => f.id).toList(),
      );
    }
  }

  void _clearSelection() {
    context.read<FileBloc>().add(const SelectAllFilesEvent(false));
    widget.onSelectionChanged?.call([]);
  }

  void _deleteSelected() {
    final state = context.read<FileBloc>().state;
    if (state is FileListLoaded && state.selectedFileIds.isNotEmpty) {
      _showDeleteConfirmDialog(state.selectedFileIds);
    }
  }

  void _showDeleteConfirmDialog(List<String> fileIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 ${fileIds.length} 个文件吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<FileBloc>().add(DeleteFilesEvent(fileIds));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
} 