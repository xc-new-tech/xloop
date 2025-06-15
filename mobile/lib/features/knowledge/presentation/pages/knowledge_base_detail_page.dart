import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/shared/presentation/widgets/custom_app_bar.dart';
import '../../../../features/shared/presentation/widgets/error_widget.dart';
import '../../../../features/shared/presentation/widgets/loading_widget.dart';
import '../../domain/entities/knowledge_base.dart';
import '../bloc/knowledge_base_bloc.dart';
import '../bloc/knowledge_base_event.dart';
import '../bloc/knowledge_base_state.dart';

class KnowledgeBaseDetailPage extends StatefulWidget {
  final String knowledgeBaseId;

  const KnowledgeBaseDetailPage({
    super.key,
    required this.knowledgeBaseId,
  });

  @override
  State<KnowledgeBaseDetailPage> createState() => _KnowledgeBaseDetailPageState();
}

class _KnowledgeBaseDetailPageState extends State<KnowledgeBaseDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadKnowledgeBase();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadKnowledgeBase() {
    context.read<KnowledgeBaseBloc>().add(
          GetKnowledgeBaseDetailEvent(widget.knowledgeBaseId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<KnowledgeBaseBloc, KnowledgeBaseState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(state),
              SliverFillRemaining(
                child: _buildContent(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(KnowledgeBaseState state) {
    final knowledgeBase = state is KnowledgeBaseDetailLoaded ? state.knowledgeBase : null;
    
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          knowledgeBase?.name ?? '知识库详情',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: knowledgeBase != null ? _buildHeaderContent(knowledgeBase) : null,
        ),
      ),
      actions: [
        if (knowledgeBase != null)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handleMenuAction(value, knowledgeBase),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('编辑'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('分享'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('导出'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('删除', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildHeaderContent(KnowledgeBase knowledgeBase) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Row(
            children: [
              Icon(
                knowledgeBase.type.icon,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      knowledgeBase.type.displayName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: knowledgeBase.status.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: knowledgeBase.status.color,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        knowledgeBase.status.displayName,
                        style: TextStyle(
                          color: knowledgeBase.status.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(KnowledgeBaseState state) {
    if (state is KnowledgeBaseLoading) {
      return const LoadingWidget();
    }

    if (state is KnowledgeBaseError) {
      return AppErrorWidget(
        message: state.message,
        onRetry: _loadKnowledgeBase,
      );
    }

    if (state is KnowledgeBaseDetailLoaded) {
      return _buildDetailContent(state.knowledgeBase);
    }

    return const Center(
      child: Text('暂无数据'),
    );
  }

  Widget _buildDetailContent(KnowledgeBase knowledgeBase) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: '概览'),
              Tab(text: '文档'),
              Tab(text: '设置'),
              Tab(text: '统计'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(knowledgeBase),
              _buildDocumentsTab(knowledgeBase),
              _buildSettingsTab(knowledgeBase),
              _buildStatsTab(knowledgeBase),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(KnowledgeBase knowledgeBase) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('基本信息', [
            _buildInfoRow('名称', knowledgeBase.name),
            _buildInfoRow('描述', knowledgeBase.description ?? '暂无描述'),
            _buildInfoRow('类型', knowledgeBase.type.displayName),
            _buildInfoRow('状态', knowledgeBase.status.displayName),
            _buildInfoRow('创建者', knowledgeBase.ownerName),
            _buildInfoRow('创建时间', knowledgeBase.formattedCreatedAt),
            _buildInfoRow('更新时间', knowledgeBase.formattedUpdatedAt),
          ]),
          const SizedBox(height: 20),
          _buildInfoCard('统计信息', [
            _buildInfoRow('文档数量', '${knowledgeBase.documentCount}'),
            _buildInfoRow('存储大小', knowledgeBase.formattedSize),
            _buildInfoRow('向量数量', '${knowledgeBase.vectorCount}'),
            _buildInfoRow('最后活动', knowledgeBase.formattedLastActivity ?? '暂无'),
          ]),
          const SizedBox(height: 20),
          if (knowledgeBase.tags.isNotEmpty)
            _buildInfoCard('标签', [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: knowledgeBase.tags.map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppColors.primary),
                )).toList(),
              ),
            ]),
          const SizedBox(height: 20),
          _buildInfoCard('功能设置', [
            _buildInfoRow('索引功能', knowledgeBase.indexingEnabled ? '已启用' : '已禁用'),
            _buildInfoRow('搜索功能', knowledgeBase.searchEnabled ? '已启用' : '已禁用'),
            _buildInfoRow('AI功能', knowledgeBase.aiEnabled ? '已启用' : '已禁用'),
          ]),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(KnowledgeBase knowledgeBase) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索文档...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showUploadDialog(),
                icon: const Icon(Icons.upload_file),
                label: const Text('上传'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: knowledgeBase.documentCount > 0
                ? _buildDocumentsList()
                : _buildEmptyDocuments(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(KnowledgeBase knowledgeBase) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingSection('权限设置', [
            _buildSettingTile(
              title: '公开可见',
              subtitle: '允许其他用户查看此知识库',
              value: knowledgeBase.type == KnowledgeBaseType.public,
              onChanged: (value) => _updateSetting('visibility', value),
            ),
            _buildSettingTile(
              title: '允许协作',
              subtitle: '允许团队成员编辑此知识库',
              value: knowledgeBase.type == KnowledgeBaseType.team,
              onChanged: (value) => _updateSetting('collaboration', value),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSettingSection('功能设置', [
            _buildSettingTile(
              title: '自动索引',
              subtitle: '自动为新上传的文档创建索引',
              value: knowledgeBase.indexingEnabled,
              onChanged: (value) => _updateSetting('indexing', value),
            ),
            _buildSettingTile(
              title: '智能搜索',
              subtitle: '启用语义搜索和向量检索',
              value: knowledgeBase.searchEnabled,
              onChanged: (value) => _updateSetting('search', value),
            ),
            _buildSettingTile(
              title: 'AI助手',
              subtitle: '基于知识库内容回答问题',
              value: knowledgeBase.aiEnabled,
              onChanged: (value) => _updateSetting('ai', value),
            ),
          ]),
          const SizedBox(height: 32),
          _buildDangerZone(knowledgeBase),
        ],
      ),
    );
  }

  Widget _buildStatsTab(KnowledgeBase knowledgeBase) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCard('使用统计', [
            _buildStatItem('总访问次数', '1,234', Icons.visibility),
            _buildStatItem('今日访问', '56', Icons.today),
            _buildStatItem('搜索次数', '789', Icons.search),
            _buildStatItem('下载次数', '123', Icons.download),
          ]),
          const SizedBox(height: 20),
          _buildStatsCard('内容统计', [
            _buildStatItem('文档数量', '${knowledgeBase.documentCount}', Icons.description),
            _buildStatItem('总大小', knowledgeBase.formattedSize, Icons.storage),
            _buildStatItem('向量数量', '${knowledgeBase.vectorCount}', Icons.scatter_plot),
            _buildStatItem('索引完成度', '95%', Icons.pie_chart),
          ]),
          const SizedBox(height: 20),
          _buildStatsCard('活动统计', [
            _buildStatItem('最后更新', knowledgeBase.formattedUpdatedAt, Icons.update),
            _buildStatItem('最后活动', knowledgeBase.formattedLastActivity ?? '暂无', Icons.access_time),
            _buildStatItem('贡献者', '3', Icons.people),
            _buildStatItem('版本数', '12', Icons.history),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    // 这里应该显示文档列表，暂时显示占位符
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Card(
        child: ListTile(
          leading: const Icon(Icons.description),
          title: Text('文档 ${index + 1}'),
          subtitle: Text('更新于 ${DateTime.now().toString().substring(0, 16)}'),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Text('查看'),
              ),
              const PopupMenuItem(
                value: 'download',
                child: Text('下载'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('删除'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyDocuments() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无文档',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击上传按钮添加文档',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildDangerZone(KnowledgeBase knowledgeBase) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '危险操作',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.archive, color: Colors.orange),
              title: const Text('归档知识库'),
              subtitle: const Text('归档后将不可编辑，但仍可查看'),
              onTap: () => _showArchiveDialog(knowledgeBase),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('删除知识库', style: TextStyle(color: Colors.red)),
              subtitle: const Text('永久删除知识库及其所有数据'),
              onTap: () => _showDeleteDialog(knowledgeBase),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: children,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, KnowledgeBase knowledgeBase) {
    switch (action) {
      case 'edit':
        _showEditDialog(knowledgeBase);
        break;
      case 'share':
        _showShareDialog(knowledgeBase);
        break;
      case 'export':
        _exportKnowledgeBase(knowledgeBase);
        break;
      case 'delete':
        _showDeleteDialog(knowledgeBase);
        break;
    }
  }

  void _showEditDialog(KnowledgeBase knowledgeBase) {
    // TODO: 实现编辑对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('编辑功能开发中')),
    );
  }

  void _showShareDialog(KnowledgeBase knowledgeBase) {
    // TODO: 实现分享对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享功能开发中')),
    );
  }

  void _exportKnowledgeBase(KnowledgeBase knowledgeBase) {
    // TODO: 实现导出功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出功能开发中')),
    );
  }

  void _showUploadDialog() {
    // TODO: 实现上传对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('上传功能开发中')),
    );
  }

  void _updateSetting(String setting, bool value) {
    // TODO: 实现设置更新
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$setting 设置已${value ? '启用' : '禁用'}')),
    );
  }

  void _showArchiveDialog(KnowledgeBase knowledgeBase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('归档知识库'),
        content: Text('确定要归档"${knowledgeBase.name}"吗？归档后将不可编辑。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 实现归档功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('归档功能开发中')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('归档'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(KnowledgeBase knowledgeBase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除知识库'),
        content: Text('确定要删除"${knowledgeBase.name}"吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 实现删除功能
              context.read<KnowledgeBaseBloc>().add(
                    DeleteKnowledgeBaseEvent(knowledgeBase.id),
                  );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
} 