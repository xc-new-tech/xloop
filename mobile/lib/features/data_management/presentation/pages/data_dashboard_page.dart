import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../shared/presentation/widgets/error_widget.dart';
import '../bloc/data_management_bloc.dart';
import '../bloc/data_management_event.dart';
import '../bloc/data_management_state.dart';
import '../widgets/storage_overview_card.dart';
import '../widgets/backup_status_card.dart';
import '../widgets/data_quality_card.dart';
import '../widgets/sync_status_card.dart';
import '../widgets/audit_log_card.dart';
import '../widgets/data_export_card.dart';

/// 数据管理仪表板页面
class DataDashboardPage extends StatefulWidget {
  const DataDashboardPage({super.key});

  @override
  State<DataDashboardPage> createState() => _DataDashboardPageState();
}

class _DataDashboardPageState extends State<DataDashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // 加载数据管理信息
    context.read<DataManagementBloc>().add(const LoadDataOverviewEvent());
    context.read<DataManagementBloc>().add(const LoadBackupStatusEvent());
    context.read<DataManagementBloc>().add(const LoadDataQualityEvent());
    context.read<DataManagementBloc>().add(const LoadAuditLogsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '数据管理',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'export_all':
                  _exportAllData();
                  break;
                case 'import':
                  _importData();
                  break;
                case 'settings':
                  _showDataSettings();
                  break;
                case 'cleanup':
                  _showDataCleanup();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_all',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('导出全部数据'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload),
                    SizedBox(width: 8),
                    Text('导入数据'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('数据设置'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cleanup',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services),
                    SizedBox(width: 8),
                    Text('数据清理'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard),
              text: '总览',
            ),
            Tab(
              icon: Icon(Icons.backup),
              text: '备份管理',
            ),
            Tab(
              icon: Icon(Icons.sync),
              text: '同步状态',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: '操作日志',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildBackupTab(),
          _buildSyncTab(),
          _buildAuditTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return BlocBuilder<DataManagementBloc, DataManagementState>(
      builder: (context, state) {
        if (state is DataManagementLoading) {
          return const LoadingWidget();
        }

        if (state is DataManagementError) {
          return AppErrorWidget(
            message: state.message,
            onRetry: _refreshData,
          );
        }

        if (state is DataManagementLoaded) {
          return RefreshIndicator(
            onRefresh: _refreshDataAsync,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 系统概览卡片
                  Text(
                    '系统概览',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: StorageOverviewCard(
                          overview: state.storageOverview,
                          onViewDetails: _showStorageDetails,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DataQualityCard(
                          quality: state.dataQuality,
                          onViewDetails: _showQualityDetails,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 备份和同步状态
                  Text(
                    '备份与同步',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: BackupStatusCard(
                          status: state.backupStatus,
                          onViewDetails: () => _tabController.animateTo(1),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SyncStatusCard(
                          status: state.syncStatus,
                          onViewDetails: () => _tabController.animateTo(2),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 快速操作
                  Text(
                    '快速操作',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  DataExportCard(
                    onExportAll: () => _exportData('all'),
                    onExportKnowledgeBases: () => _exportData('knowledge'),
                    onExportConversations: () => _exportData('conversations'),
                    onExportDocuments: () => _exportData('documents'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 最近活动
                  Text(
                    '最近活动',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  AuditLogCard(
                    logs: state.auditLogs,
                    onViewAll: () => _tabController.animateTo(3),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildBackupTab() {
    return BlocBuilder<DataManagementBloc, DataManagementState>(
      builder: (context, state) {
        if (state is DataManagementLoading) {
          return const LoadingWidget();
        }

        if (state is DataManagementError) {
          return AppErrorWidget(
            message: state.message,
            onRetry: _refreshData,
          );
        }

        if (state is DataManagementLoaded) {
          final backups = state.backupHistory ?? [];
          
          return Column(
            children: [
              // 备份操作栏
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _createBackup,
                      icon: const Icon(Icons.backup),
                      label: const Text('创建备份'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _scheduleBackup,
                      icon: const Icon(Icons.schedule),
                      label: const Text('定时备份'),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: _showBackupSettings,
                      tooltip: '备份设置',
                    ),
                  ],
                ),
              ),
              
              // 备份列表
              Expanded(
                child: backups.isEmpty
                    ? _buildEmptyBackupsState()
                    : RefreshIndicator(
                        onRefresh: _refreshDataAsync,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: backups.length,
                          itemBuilder: (context, index) {
                            final backup = backups[index];
                            return _buildBackupItem(backup);
                          },
                        ),
                      ),
              ),
            ],
          );
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildSyncTab() {
    return BlocBuilder<DataManagementBloc, DataManagementState>(
      builder: (context, state) {
        if (state is DataManagementLoading) {
          return const LoadingWidget();
        }

        if (state is DataManagementError) {
          return AppErrorWidget(
            message: state.message,
            onRetry: _refreshData,
          );
        }

        if (state is DataManagementLoaded) {
          return RefreshIndicator(
            onRefresh: _refreshDataAsync,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 同步状态概览
                  SyncStatusCard(
                    status: state.syncStatus,
                    onViewDetails: () {},
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 同步历史
                  Text(
                    '同步历史',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (state.syncHistory?.isNotEmpty == true) ...[
                    ...state.syncHistory!.map((sync) => _buildSyncItem(sync)),
                  ] else ...[
                    _buildEmptySyncState(),
                  ],
                ],
              ),
            ),
          );
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildAuditTab() {
    return BlocBuilder<DataManagementBloc, DataManagementState>(
      builder: (context, state) {
        if (state is DataManagementLoading) {
          return const LoadingWidget();
        }

        if (state is DataManagementError) {
          return AppErrorWidget(
            message: state.message,
            onRetry: _refreshData,
          );
        }

        if (state is DataManagementLoaded) {
          final logs = state.auditLogs ?? [];
          
          return Column(
            children: [
              // 筛选栏
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '搜索操作日志...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _showLogFilters,
                      icon: const Icon(Icons.filter_list),
                      label: const Text('筛选'),
                    ),
                  ],
                ),
              ),
              
              // 日志列表
              Expanded(
                child: logs.isEmpty
                    ? _buildEmptyLogsState()
                    : RefreshIndicator(
                        onRefresh: _refreshDataAsync,
                        child: ListView.builder(
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            return _buildLogItem(log);
                          },
                        ),
                      ),
              ),
            ],
          );
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildBackupItem(dynamic backup) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.backup,
            color: AppColors.success,
          ),
        ),
        title: Text(backup['name'] ?? '未命名备份'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('大小：${backup['size'] ?? '未知'}'),
            Text('创建时间：${backup['createdAt'] ?? '未知'}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'restore':
                _restoreBackup(backup['id']);
                break;
              case 'download':
                _downloadBackup(backup['id']);
                break;
              case 'delete':
                _deleteBackup(backup['id']);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restore',
              child: Text('恢复'),
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
    );
  }

  Widget _buildSyncItem(dynamic sync) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          sync['success'] ? Icons.check_circle : Icons.error,
          color: sync['success'] ? AppColors.success : AppColors.error,
        ),
        title: Text(sync['type'] ?? '同步操作'),
        subtitle: Text(sync['timestamp'] ?? '未知时间'),
        trailing: sync['success']
            ? null
            : IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showSyncError(sync),
              ),
      ),
    );
  }

  Widget _buildLogItem(dynamic log) {
    return ListTile(
      leading: Icon(
        _getLogIcon(log['action']),
        color: _getLogColor(log['level']),
      ),
      title: Text(log['action'] ?? '未知操作'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('用户：${log['user'] ?? '系统'}'),
          Text('时间：${log['timestamp'] ?? '未知'}'),
        ],
      ),
      onTap: () => _showLogDetails(log),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.data_usage, size: 64),
          SizedBox(height: 16),
          Text('暂无数据'),
        ],
      ),
    );
  }

  Widget _buildEmptyBackupsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.backup,
            size: 64,
            color: AppColors.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无备份',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '创建第一个备份以保护您的数据',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface.withOpacity(0.5),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createBackup,
            icon: const Icon(Icons.backup),
            label: const Text('创建备份'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySyncState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sync,
            size: 64,
            color: AppColors.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无同步记录',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLogsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppColors.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无操作日志',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  IconData _getLogIcon(String? action) {
    switch (action?.toLowerCase()) {
      case 'create':
        return Icons.add_circle_outline;
      case 'update':
        return Icons.edit;
      case 'delete':
        return Icons.delete_outline;
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      default:
        return Icons.info_outline;
    }
  }

  Color _getLogColor(String? level) {
    switch (level?.toLowerCase()) {
      case 'error':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      case 'info':
        return AppColors.info;
      default:
        return AppColors.onSurface;
    }
  }

  void _refreshData() {
    context.read<DataManagementBloc>().add(const LoadDataOverviewEvent());
    context.read<DataManagementBloc>().add(const LoadBackupStatusEvent());
    context.read<DataManagementBloc>().add(const LoadDataQualityEvent());
    context.read<DataManagementBloc>().add(const LoadAuditLogsEvent());
  }

  Future<void> _refreshDataAsync() async {
    _refreshData();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _exportAllData() {
    context.read<DataManagementBloc>().add(const ExportAllDataEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('开始导出所有数据...')),
    );
  }

  void _importData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('数据导入功能开发中...')),
    );
  }

  void _showDataSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('数据设置功能开发中...')),
    );
  }

  void _showDataCleanup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('数据清理功能开发中...')),
    );
  }

  void _exportData(String type) {
    context.read<DataManagementBloc>().add(ExportDataEvent(type: type));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('开始导出${type}数据...')),
    );
  }

  void _createBackup() {
    context.read<DataManagementBloc>().add(const CreateBackupEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('开始创建备份...')),
    );
  }

  void _scheduleBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('定时备份功能开发中...')),
    );
  }

  void _showBackupSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('备份设置功能开发中...')),
    );
  }

  void _restoreBackup(String backupId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认恢复'),
        content: const Text('恢复备份将覆盖当前数据，此操作无法撤销。确认继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DataManagementBloc>().add(
                RestoreBackupEvent(backupId),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('确认恢复'),
          ),
        ],
      ),
    );
  }

  void _downloadBackup(String backupId) {
    context.read<DataManagementBloc>().add(
      DownloadBackupEvent(backupId),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('开始下载备份...')),
    );
  }

  void _deleteBackup(String backupId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除此备份吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DataManagementBloc>().add(
                DeleteBackupEvent(backupId),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _forceSync() {
    context.read<DataManagementBloc>().add(const ForceSyncEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('开始强制同步...')),
    );
  }

  void _showStorageDetails() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('存储详情功能开发中...')),
    );
  }

  void _showQualityDetails() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('数据质量详情功能开发中...')),
    );
  }

  void _showSyncError(dynamic sync) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('同步错误'),
        content: Text(sync['error'] ?? '未知错误'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showLogDetails(dynamic log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(log['action'] ?? '操作详情'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('用户：${log['user'] ?? '系统'}'),
            Text('时间：${log['timestamp'] ?? '未知'}'),
            Text('详情：${log['details'] ?? '无'}'),
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

  void _showLogFilters() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('日志筛选功能开发中...')),
    );
  }
} 