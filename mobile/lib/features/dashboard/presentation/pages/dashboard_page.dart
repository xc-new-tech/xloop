import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 仪表板页面
/// 
/// 提供系统关键指标的统一视图和实时监控
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  DashboardData? _dashboardData;
  String _selectedPeriod = '本周';
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDashboardData() {
    setState(() => _isRefreshing = true);
    
    // 模拟数据加载
    Future.delayed(const Duration(milliseconds: 800), () {
      _dashboardData = DashboardData(
        totalUsers: 2847,
        activeUsers: 1892,
        totalKnowledgeBases: 156,
        totalDocuments: 12450,
        totalQueries: 45678,
        avgResponseTime: 1.8,
        systemUptime: 99.94,
        storageUsed: 78.5,
        recentActivities: [
          Activity(
            type: ActivityType.userJoined,
            description: '新用户注册',
            user: '张三',
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          ),
          Activity(
            type: ActivityType.documentAdded,
            description: '添加文档到知识库',
            user: '李四',
            timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
          ),
          Activity(
            type: ActivityType.queryProcessed,
            description: '处理智能查询',
            user: '王五',
            timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
          ),
          Activity(
            type: ActivityType.workflowExecuted,
            description: '执行审核工作流',
            user: '系统',
            timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
          ),
        ],
        topKnowledgeBases: [
          TopItem(name: '技术文档', count: 3450, percentage: 28.5),
          TopItem(name: '产品手册', count: 2890, percentage: 23.2),
          TopItem(name: '用户指南', count: 2234, percentage: 18.0),
          TopItem(name: 'FAQ集合', count: 1876, percentage: 15.1),
          TopItem(name: '培训材料', count: 1890, percentage: 15.2),
        ],
        performanceMetrics: PerformanceMetrics(
          cpuUsage: 45.2,
          memoryUsage: 68.9,
          diskUsage: 34.1,
          networkLatency: 87,
          responseTime: 245,
          throughput: 1250,
          errorRate: 0.8,
          uptime: const Duration(days: 15, hours: 8, minutes: 23),
        ),
        trends: TrendData(
          userGrowth: 12.5,
          queryVolume: 8.3,
          responseTimeImprovement: -15.2,
          systemReliability: 2.1,
        ),
      );
      
      setState(() => _isRefreshing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '仪表板',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) => _changePeriod(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: '今日', child: Text('今日')),
              const PopupMenuItem(value: '本周', child: Text('本周')),
              const PopupMenuItem(value: '本月', child: Text('本月')),
              const PopupMenuItem(value: '本年', child: Text('本年')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => _refreshDashboard(),
            icon: _isRefreshing 
                ? const SizedBox(
                    width: 16, 
                    height: 16, 
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: '刷新数据',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: '概览'),
            Tab(icon: Icon(Icons.trending_up), text: '趋势分析'),
            Tab(icon: Icon(Icons.analytics), text: '详细报告'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: _dashboardData == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTrendsTab(),
                _buildReportsTab(),
              ],
            ),
    );
  }

  // 概览标签页
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 关键指标网格
          _buildKeyMetricsGrid(),
          const SizedBox(height: 20),
          
          // 系统状态和活动
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildSystemStatus()),
              const SizedBox(width: 16),
              Expanded(child: _buildRecentActivities()),
            ],
          ),
          const SizedBox(height: 20),
          
          // 热门知识库
          _buildTopKnowledgeBases(),
          const SizedBox(height: 20),
          
          // 快速操作
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        _buildMetricCard(
          '总用户数',
          '${_dashboardData!.totalUsers}',
          '+${_dashboardData!.trends.userGrowth}%',
          Icons.people,
          AppColors.primary,
          true,
        ),
        _buildMetricCard(
          '活跃用户',
          '${_dashboardData!.activeUsers}',
          '${(_dashboardData!.activeUsers / _dashboardData!.totalUsers * 100).toStringAsFixed(1)}%',
          Icons.person_outline,
          AppColors.success,
          true,
        ),
        _buildMetricCard(
          '知识库数量',
          '${_dashboardData!.totalKnowledgeBases}',
          '共${_dashboardData!.totalDocuments}文档',
          Icons.library_books,
          AppColors.secondary,
          false,
        ),
        _buildMetricCard(
          '查询次数',
          '${_dashboardData!.totalQueries}',
          '+${_dashboardData!.trends.queryVolume}%',
          Icons.search,
          AppColors.tertiary,
          true,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    bool showTrend,
  ) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (showTrend && subtitle.startsWith('+'))
                  Icon(Icons.trending_up, size: 16, color: AppColors.success)
                else if (showTrend && subtitle.startsWith('-'))
                  Icon(Icons.trending_down, size: 16, color: AppColors.error),
                if (showTrend) const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: showTrend && subtitle.startsWith('+')
                          ? AppColors.success
                          : showTrend && subtitle.startsWith('-')
                              ? AppColors.error
                              : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '系统状态',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              '响应时间',
              '${_dashboardData!.avgResponseTime}s',
              Icons.speed,
              AppColors.success,
            ),
            _buildStatusItem(
              '系统可用性',
              '${_dashboardData!.systemUptime}%',
              Icons.check_circle,
              AppColors.success,
            ),
            _buildStatusItem(
              '存储使用',
              '${_dashboardData!.storageUsed}%',
              Icons.storage,
              AppColors.warning,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _dashboardData!.storageUsed / 100,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '最近活动',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _viewAllActivities(),
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._dashboardData!.recentActivities.map((activity) => _buildActivityItem(activity)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Activity activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _buildActivityIcon(activity.type),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: AppTextStyles.bodyMedium,
                ),
                Text(
                  '${activity.user} • ${_formatTime(activity.timestamp)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityIcon(ActivityType type) {
    IconData icon;
    Color color;
    
    switch (type) {
      case ActivityType.userJoined:
        icon = Icons.person_add;
        color = AppColors.success;
        break;
      case ActivityType.documentAdded:
        icon = Icons.note_add;
        color = AppColors.primary;
        break;
      case ActivityType.queryProcessed:
        icon = Icons.search;
        color = AppColors.secondary;
        break;
      case ActivityType.workflowExecuted:
        icon = Icons.play_arrow;
        color = AppColors.tertiary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildTopKnowledgeBases() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '热门知识库',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ..._dashboardData!.topKnowledgeBases.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildTopKnowledgeBaseItem(index + 1, item);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopKnowledgeBaseItem(int rank, TopItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${item.count} 查询 (${item.percentage.toStringAsFixed(1)}%)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: LinearProgressIndicator(
              value: item.percentage / 100,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(_getRankColor(rank)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '快速操作',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildQuickActionChip('创建知识库', Icons.add, AppColors.primary),
                _buildQuickActionChip('导入文档', Icons.upload, AppColors.secondary),
                _buildQuickActionChip('查看报告', Icons.assessment, AppColors.tertiary),
                _buildQuickActionChip('系统设置', Icons.settings, AppColors.onSurfaceVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String label, IconData icon, Color color) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      onPressed: () => _handleQuickAction(label),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }

  // 趋势分析标签页
  Widget _buildTrendsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildTrendChart('用户增长趋势'),
        const SizedBox(height: 16),
        _buildTrendChart('查询量趋势'),
        const SizedBox(height: 16),
        _buildTrendChart('响应时间趋势'),
        const SizedBox(height: 16),
        _buildTrendComparison(),
      ],
    );
  }

  Widget _buildTrendChart(String title) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('$title图表 (需要图表库实现)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendComparison() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '趋势对比',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildTrendComparisonItem('用户增长', _dashboardData!.trends.userGrowth),
            _buildTrendComparisonItem('查询量变化', _dashboardData!.trends.queryVolume),
            _buildTrendComparisonItem('响应时间改善', _dashboardData!.trends.responseTimeImprovement),
            _buildTrendComparisonItem('系统可靠性', _dashboardData!.trends.systemReliability),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendComparisonItem(String label, double value) {
    final isPositive = value > 0;
    final color = isPositive ? AppColors.success : AppColors.error;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '${value > 0 ? '+' : ''}${value.toStringAsFixed(1)}%',
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 详细报告标签页
  Widget _buildReportsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildReportSection('系统概况报告'),
        const SizedBox(height: 16),
        _buildReportSection('用户行为分析'),
        const SizedBox(height: 16),
        _buildReportSection('性能监控报告'),
        const SizedBox(height: 16),
        _buildReportActions(),
      ],
    );
  }

  Widget _buildReportSection(String title) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleReportAction(value, title),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view', child: Text('查看详情')),
                    const PopupMenuItem(value: 'export', child: Text('导出报告')),
                    const PopupMenuItem(value: 'schedule', child: Text('定时发送')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('$title内容预览'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportActions() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '报告操作',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _generateCustomReport(),
                  icon: const Icon(Icons.create),
                  label: const Text('自定义报告'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _scheduleReport(),
                  icon: const Icon(Icons.schedule),
                  label: const Text('定时报告'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.onSecondary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _exportAllReports(),
                  icon: const Icon(Icons.download),
                  label: const Text('批量导出'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiary,
                    foregroundColor: AppColors.onTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 辅助方法
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.primary;
      case 2:
        return AppColors.secondary;
      case 3:
        return AppColors.tertiary;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else {
      return '${difference.inDays}天前';
    }
  }

  // 事件处理方法
  void _changePeriod(String period) {
    setState(() => _selectedPeriod = period);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('切换到$period数据')),
    );
    _loadDashboardData();
  }

  void _refreshDashboard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在刷新仪表板数据...')),
    );
    _loadDashboardData();
  }

  void _viewAllActivities() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('查看所有活动记录')),
    );
  }

  void _handleQuickAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('执行快速操作: $action')),
    );
  }

  void _handleReportAction(String action, String reportTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action: $reportTitle')),
    );
  }

  void _generateCustomReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('生成自定义报告')),
    );
  }

  void _scheduleReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('设置定时报告')),
    );
  }

  void _exportAllReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('批量导出所有报告')),
    );
  }
}

// 数据模型

class DashboardData {
  final int totalUsers;
  final int activeUsers;
  final int totalKnowledgeBases;
  final int totalDocuments;
  final int totalQueries;
  final double avgResponseTime;
  final double systemUptime;
  final double storageUsed;
  final List<Activity> recentActivities;
  final List<TopItem> topKnowledgeBases;
  final PerformanceMetrics performanceMetrics;
  final TrendData trends;

  DashboardData({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalKnowledgeBases,
    required this.totalDocuments,
    required this.totalQueries,
    required this.avgResponseTime,
    required this.systemUptime,
    required this.storageUsed,
    required this.recentActivities,
    required this.topKnowledgeBases,
    required this.performanceMetrics,
    required this.trends,
  });
}

enum ActivityType { userJoined, documentAdded, queryProcessed, workflowExecuted }

class Activity {
  final ActivityType type;
  final String description;
  final String user;
  final DateTime timestamp;

  Activity({
    required this.type,
    required this.description,
    required this.user,
    required this.timestamp,
  });
}

class TopItem {
  final String name;
  final int count;
  final double percentage;

  TopItem({
    required this.name,
    required this.count,
    required this.percentage,
  });
}

class PerformanceMetrics {
  final double cpuUsage;
  final double memoryUsage;
  final double diskUsage;
  final int networkLatency;
  final int responseTime;
  final int throughput;
  final double errorRate;
  final Duration uptime;

  PerformanceMetrics({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.networkLatency,
    required this.responseTime,
    required this.throughput,
    required this.errorRate,
    required this.uptime,
  });
}

class TrendData {
  final double userGrowth;
  final double queryVolume;
  final double responseTimeImprovement;
  final double systemReliability;

  TrendData({
    required this.userGrowth,
    required this.queryVolume,
    required this.responseTimeImprovement,
    required this.systemReliability,
  });
} 