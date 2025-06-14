import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/knowledge_base.dart';
import '../bloc/knowledge_base_bloc.dart';
import '../bloc/knowledge_base_event.dart';
import '../bloc/knowledge_base_state.dart';
import '../widgets/knowledge_base_card.dart';
import '../widgets/knowledge_base_search_widget.dart';

/// 知识库管理页面
class KnowledgeBasePage extends StatelessWidget {
  const KnowledgeBasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<KnowledgeBaseBloc>()..add(const LoadKnowledgeBasesEvent()),
      child: const _KnowledgeBasePageContent(),
    );
  }
}

class _KnowledgeBasePageContent extends StatefulWidget {
  const _KnowledgeBasePageContent();

  @override
  State<_KnowledgeBasePageContent> createState() => _KnowledgeBasePageContentState();
}

class _KnowledgeBasePageContentState extends State<_KnowledgeBasePageContent> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;
  String _currentFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('知识库'),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          // 搜索按钮
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  context.read<KnowledgeBaseBloc>().add(const ClearKnowledgeBaseSearchEvent());
                }
              });
            },
          ),
          // 筛选按钮
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _currentFilter = value;
              });
              context.read<KnowledgeBaseBloc>().add(FilterKnowledgeBasesEvent(
                filter: value == 'all' ? null : value,
              ));
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(
                      Icons.all_inclusive,
                      color: _currentFilter == 'all' ? AppColors.primary : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '全部',
                      style: TextStyle(
                        color: _currentFilter == 'all' ? AppColors.primary : null,
                        fontWeight: _currentFilter == 'all' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'active',
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: _currentFilter == 'active' ? AppColors.primary : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '活跃',
                      style: TextStyle(
                        color: _currentFilter == 'active' ? AppColors.primary : null,
                        fontWeight: _currentFilter == 'active' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'private',
                child: Row(
                  children: [
                    Icon(
                      Icons.lock,
                      color: _currentFilter == 'private' ? AppColors.primary : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '私有',
                      style: TextStyle(
                        color: _currentFilter == 'private' ? AppColors.primary : null,
                        fontWeight: _currentFilter == 'private' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'public',
                child: Row(
                  children: [
                    Icon(
                      Icons.public,
                      color: _currentFilter == 'public' ? AppColors.primary : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '公开',
                      style: TextStyle(
                        color: _currentFilter == 'public' ? AppColors.primary : null,
                        fontWeight: _currentFilter == 'public' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 更多操作菜单
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  context.read<KnowledgeBaseBloc>().add(const LoadKnowledgeBasesEvent());
                  break;
                case 'settings':
                  _showSettingsDialog();
                  break;
                case 'import':
                  _showImportDialog();
                  break;
                case 'export':
                  _showExportDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('刷新'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload),
                    SizedBox(width: 8),
                    Text('导入知识库'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('导出知识库'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('设置'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          if (_isSearchVisible)
            Container(
              padding: const EdgeInsets.all(16),
              child: KnowledgeBaseSearchWidget(
                controller: _searchController,
                onSearchChanged: (query) {
                  context.read<KnowledgeBaseBloc>().add(SearchKnowledgeBasesEvent(query: query));
                },
                onSearchSubmitted: (query) {
                  context.read<KnowledgeBaseBloc>().add(SearchKnowledgeBasesEvent(query: query));
                },
              ),
            ),
          
          // 统计信息栏
          _buildStatsBar(),
          
          // 知识库列表
          Expanded(
            child: BlocBuilder<KnowledgeBaseBloc, KnowledgeBaseState>(
              builder: (context, state) {
                if (state is KnowledgeBaseLoading) {
                  return const LoadingWidget();
                }
                
                if (state is KnowledgeBaseError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '加载失败',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<KnowledgeBaseBloc>().add(const LoadKnowledgeBasesEvent());
                          },
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is KnowledgeBaseListLoaded) {
                  if (state.knowledgeBases.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<KnowledgeBaseBloc>().add(const LoadKnowledgeBasesEvent());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.knowledgeBases.length,
                      itemBuilder: (context, index) {
                        final knowledgeBase = state.knowledgeBases[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: KnowledgeBaseCard(
                            knowledgeBase: knowledgeBase,
                            onTap: () {
                              context.go('/knowledge-base/${knowledgeBase.id}');
                            },
                            onEdit: () => _editKnowledgeBase(knowledgeBase),
                            onDelete: () => _deleteKnowledgeBase(knowledgeBase),
                            onShare: () => _shareKnowledgeBase(knowledgeBase),
                          ),
                        );
                      },
                    ),
                  );
                }
                
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createKnowledgeBase,
        icon: const Icon(Icons.add),
        label: const Text('创建知识库'),
      ),
    );
  }

  Widget _buildStatsBar() {
    return BlocBuilder<KnowledgeBaseBloc, KnowledgeBaseState>(
      builder: (context, state) {
        if (state is KnowledgeBaseListLoaded) {
          final total = state.knowledgeBases.length;
          final active = state.knowledgeBases.where((kb) => kb.isActive).length;
          final private = state.knowledgeBases.where((kb) => !kb.isPublic).length;
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                _buildStatItem('总计', total.toString(), Icons.folder),
                const SizedBox(width: 24),
                _buildStatItem('活跃', active.toString(), Icons.check_circle),
                const SizedBox(width: 24),
                _buildStatItem('私有', private.toString(), Icons.lock),
                const Spacer(),
                if (_currentFilter != 'all')
                  Chip(
                    label: Text('筛选: ${_getFilterLabel(_currentFilter)}'),
                    onDeleted: () {
                      setState(() {
                        _currentFilter = 'all';
                      });
                      context.read<KnowledgeBaseBloc>().add(const FilterKnowledgeBasesEvent(filter: null));
                    },
                    deleteIcon: const Icon(Icons.close, size: 16),
                  ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无知识库',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮创建您的第一个知识库',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createKnowledgeBase,
            icon: const Icon(Icons.add),
            label: const Text('创建知识库'),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'active':
        return '活跃';
      case 'private':
        return '私有';
      case 'public':
        return '公开';
      default:
        return filter;
    }
  }

  void _createKnowledgeBase() {
    _showKnowledgeBaseDialog();
  }

  void _editKnowledgeBase(dynamic knowledgeBase) {
    _showKnowledgeBaseDialog(knowledgeBase: knowledgeBase);
  }

  void _deleteKnowledgeBase(dynamic knowledgeBase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除知识库'),
        content: Text('确定要删除知识库"${knowledgeBase.name}"吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<KnowledgeBaseBloc>().add(DeleteKnowledgeBaseEvent(knowledgeBase.id));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _shareKnowledgeBase(dynamic knowledgeBase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('分享知识库'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('知识库: ${knowledgeBase.name}'),
            const SizedBox(height: 16),
            const Text('分享链接:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                'https://xloop.ai/kb/${knowledgeBase.id}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              // 复制链接到剪贴板
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('链接已复制到剪贴板')),
              );
            },
            child: const Text('复制链接'),
          ),
        ],
      ),
    );
  }

  void _showKnowledgeBaseDialog({dynamic knowledgeBase}) {
    final nameController = TextEditingController(text: knowledgeBase?.name ?? '');
    final descriptionController = TextEditingController(text: knowledgeBase?.description ?? '');
    bool isPublic = knowledgeBase?.isPublic ?? false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(knowledgeBase == null ? '创建知识库' : '编辑知识库'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '知识库名称',
                  hintText: '请输入知识库名称',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述',
                  hintText: '请输入知识库描述',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('公开知识库'),
                subtitle: const Text('其他用户可以查看和使用'),
                value: isPublic,
                onChanged: (value) {
                  setState(() {
                    isPublic = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final description = descriptionController.text.trim();
                
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入知识库名称')),
                  );
                  return;
                }
                
                Navigator.of(context).pop();
                
                if (knowledgeBase == null) {
                  context.read<KnowledgeBaseBloc>().add(CreateKnowledgeBaseEvent(
                    type: KnowledgeBaseType.personal,
                    name: name,
                    description: description,
                    isPublic: isPublic,
                  ));
                } else {
                  context.read<KnowledgeBaseBloc>().add(UpdateKnowledgeBaseEvent(
                    id: knowledgeBase.id,
                    name: name,
                    description: description,
                    isPublic: isPublic,
                  ));
                }
              },
              child: Text(knowledgeBase == null ? '创建' : '保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('知识库设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('存储管理'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).pop();
                // 导航到存储管理页面
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('同步设置'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).pop();
                // 导航到同步设置页面
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('安全设置'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).pop();
                // 导航到安全设置页面
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入知识库'),
        content: const Text('选择要导入的知识库文件或数据源'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 实现导入逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('导入功能正在开发中...')),
              );
            },
            child: const Text('选择文件'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出知识库'),
        content: const Text('选择要导出的知识库和格式'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 实现导出逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('导出功能正在开发中...')),
              );
            },
            child: const Text('导出'),
          ),
        ],
      ),
    );
  }
} 