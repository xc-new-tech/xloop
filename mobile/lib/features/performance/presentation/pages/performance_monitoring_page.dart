import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 性能监控页面
/// 
/// 提供系统性能监控、缓存管理、内存优化等功能
class PerformanceMonitoringPage extends StatefulWidget {
  const PerformanceMonitoringPage({super.key});

  @override
  State<PerformanceMonitoringPage> createState() => _PerformanceMonitoringPageState();
}

class _PerformanceMonitoringPageState extends State<PerformanceMonitoringPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  PerformanceMetrics? _performanceMetrics;
  CacheStatus? _cacheStatus;
  List<PerformanceAlert> _alerts = [];
  bool _isMonitoring = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPerformanceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPerformanceData() {
    // 模拟性能指标数据
    _performanceMetrics = PerformanceMetrics(
      cpuUsage: 45.2,
      memoryUsage: 68.9,
      diskUsage: 34.1,
      networkLatency: 87,
      responseTime: 245,
      throughput: 1250,
      errorRate: 0.8,
      uptime: const Duration(days: 15, hours: 8, minutes: 23),
    );

    // 模拟缓存状态数据
    _cacheStatus = CacheStatus(
      totalSize: 256.7,
      usedSize: 178.3,
      hitRate: 94.2,
      missRate: 5.8,
      cacheItems: [
        CacheItem(key: 'knowledge_base_list', size: 45.2, hits: 2340, lastAccess: DateTime.now().subtract(const Duration(minutes: 5))),
        CacheItem(key: 'user_profiles', size: 23.1, hits: 1890, lastAccess: DateTime.now().subtract(const Duration(hours: 1))),
        CacheItem(key: 'search_results', size: 67.8, hits: 5670, lastAccess: DateTime.now().subtract(const Duration(minutes: 2))),
        CacheItem(key: 'api_responses', size: 42.2, hits: 3450, lastAccess: DateTime.now().subtract(const Duration(minutes: 10))),
      ],
    );

    // 模拟性能警报
    _alerts = [
      PerformanceAlert(
        id: 'alert_1',
        type: AlertType.warning,
        title: '内存使用率偏高',
        description: '当前内存使用率为68.9%，建议清理缓存或优化内存使用',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isActive: true,
      ),
      PerformanceAlert(
        id: 'alert_2',
        type: AlertType.info,
        title: '缓存命中率优秀',
        description: '缓存命中率达到94.2%，系统响应性能良好',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isActive: false,
      ),
    ];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '性能监控',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _toggleMonitoring(),
            icon: Icon(_isMonitoring ? Icons.pause : Icons.play_arrow),
            tooltip: _isMonitoring ? '暂停监控' : '开始监控',
          ),
          IconButton(
            onPressed: () => _refreshData(),
            icon: const Icon(Icons.refresh),
            tooltip: '刷新数据',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: '系统概览'),
            Tab(icon: Icon(Icons.memory), text: '缓存管理'),
            Tab(icon: Icon(Icons.timeline), text: '性能趋势'),
            Tab(icon: Icon(Icons.tune), text: '优化工具'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSystemOverviewTab(),
          _buildCacheManagementTab(),
          _buildPerformanceTrendsTab(),
          _buildOptimizationToolsTab(),
        ],
      ),
    );
  }

  // 系统概览标签页
  Widget _buildSystemOverviewTab() {
    if (_performanceMetrics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 性能警报
        if (_alerts.where((alert) => alert.isActive).isNotEmpty) ...[
          _buildAlertsSection(),
          const SizedBox(height: 16),
        ],
        
        // 关键指标网格
        _buildMetricsGrid(),
        const SizedBox(height: 16),
        
        // 系统状态卡片
        _buildSystemStatusCard(),
        const SizedBox(height: 16),
        
        // 实时性能图表
        _buildRealTimeChart(),
      ],
    );
  }

  Widget _buildAlertsSection() {
    final activeAlerts = _alerts.where((alert) => alert.isActive).toList();
    
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
                Icon(Icons.warning, color: AppColors.warning, size: 24),
                const SizedBox(width: 12),
                Text(
                  '性能警报',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _viewAllAlerts(),
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...activeAlerts.map((alert) => _buildAlertItem(alert)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(PerformanceAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getAlertColor(alert.type).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getAlertColor(alert.type).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getAlertIcon(alert.type),
            color: _getAlertColor(alert.type),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _dismissAlert(alert),
            child: const Text('忽略'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'CPU使用率',
          '${_performanceMetrics!.cpuUsage.toStringAsFixed(1)}%',
          Icons.memory,
          AppColors.primary,
          _performanceMetrics!.cpuUsage,
        ),
        _buildMetricCard(
          '内存使用率',
          '${_performanceMetrics!.memoryUsage.toStringAsFixed(1)}%',
          Icons.storage,
          AppColors.secondary,
          _performanceMetrics!.memoryUsage,
        ),
        _buildMetricCard(
          '响应时间',
          '${_performanceMetrics!.responseTime}ms',
          Icons.speed,
          AppColors.success,
          _performanceMetrics!.responseTime / 10,
        ),
        _buildMetricCard(
          '错误率',
          '${_performanceMetrics!.errorRate}%',
          Icons.error_outline,
          AppColors.error,
          _performanceMetrics!.errorRate * 10,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, double percentage) {
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
              style: AppTextStyles.headlineSmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatusCard() {
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
            Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    '运行时间',
                    _formatDuration(_performanceMetrics!.uptime),
                    Icons.access_time,
                  ),
                ),
                Expanded(
                  child: _buildStatusItem(
                    '吞吐量',
                    '${_performanceMetrics!.throughput}/min',
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    '网络延迟',
                    '${_performanceMetrics!.networkLatency}ms',
                    Icons.network_check,
                  ),
                ),
                Expanded(
                  child: _buildStatusItem(
                    '磁盘使用',
                    '${_performanceMetrics!.diskUsage.toStringAsFixed(1)}%',
                    Icons.storage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRealTimeChart() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '实时性能趋势',
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
              child: const Center(
                child: Text('实时性能图表 (需要图表库实现)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 缓存管理标签页
  Widget _buildCacheManagementTab() {
    if (_cacheStatus == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 缓存概览
        _buildCacheOverview(),
        const SizedBox(height: 16),
        
        // 缓存操作按钮
        _buildCacheActions(),
        const SizedBox(height: 16),
        
        // 缓存项列表
        _buildCacheItemsList(),
      ],
    );
  }

  Widget _buildCacheOverview() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '缓存概览',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCacheMetric(
                    '总容量',
                    '${_cacheStatus!.totalSize.toStringAsFixed(1)} MB',
                    Icons.storage,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildCacheMetric(
                    '已使用',
                    '${_cacheStatus!.usedSize.toStringAsFixed(1)} MB',
                    Icons.folder,
                    AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCacheMetric(
                    '命中率',
                    '${_cacheStatus!.hitRate.toStringAsFixed(1)}%',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildCacheMetric(
                    '缺失率',
                    '${_cacheStatus!.missRate.toStringAsFixed(1)}%',
                    Icons.error_outline,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 使用率进度条
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '存储使用率: ${(_cacheStatus!.usedSize / _cacheStatus!.totalSize * 100).toStringAsFixed(1)}%',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _cacheStatus!.usedSize / _cacheStatus!.totalSize,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCacheActions() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '缓存操作',
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
                  onPressed: () => _clearExpiredCache(),
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('清理过期缓存'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _clearAllCache(),
                  icon: const Icon(Icons.clear_all),
                  label: const Text('清空所有缓存'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.onError,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _optimizeCache(),
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('优化缓存'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.onSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheItemsList() {
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
                  '缓存项目',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _sortCacheItems(),
                  child: const Text('排序'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._cacheStatus!.cacheItems.map((item) => _buildCacheItemCard(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheItemCard(CacheItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.key,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '大小: ${item.size.toStringAsFixed(1)} MB',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '命中: ${item.hits} 次',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '最后访问: ${_formatDateTime(item.lastAccess)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleCacheItemAction(value, item),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'refresh', child: Text('刷新')),
              const PopupMenuItem(value: 'delete', child: Text('删除')),
              const PopupMenuItem(value: 'details', child: Text('详情')),
            ],
          ),
        ],
      ),
    );
  }

  // 性能趋势标签页
  Widget _buildPerformanceTrendsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildTrendChart('CPU使用率趋势'),
        const SizedBox(height: 16),
        _buildTrendChart('内存使用趋势'),
        const SizedBox(height: 16),
        _buildTrendChart('响应时间趋势'),
        const SizedBox(height: 16),
        _buildPerformanceComparison(),
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

  Widget _buildPerformanceComparison() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '性能对比分析',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildComparisonItem('今日vs昨日', '+5.2%', true),
            _buildComparisonItem('本周vs上周', '-2.1%', false),
            _buildComparisonItem('本月vs上月', '+12.8%', true),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonItem(String label, String change, bool isPositive) {
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
            color: isPositive ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            change,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isPositive ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 优化工具标签页
  Widget _buildOptimizationToolsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildOptimizationSuggestions(),
        const SizedBox(height: 16),
        _buildAutoOptimization(),
        const SizedBox(height: 16),
        _buildSystemMaintenance(),
      ],
    );
  }

  Widget _buildOptimizationSuggestions() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '优化建议',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSuggestionItem(
              '内存优化',
              '清理未使用的缓存，释放68MB内存空间',
              Icons.memory,
              AppColors.primary,
              () => _applyOptimization('memory'),
            ),
            _buildSuggestionItem(
              '数据库优化',
              '重建索引，预计提升查询性能25%',
              Icons.storage,
              AppColors.secondary,
              () => _applyOptimization('database'),
            ),
            _buildSuggestionItem(
              '网络优化',
              '启用压缩传输，减少带宽使用40%',
              Icons.network_check,
              AppColors.tertiary,
              () => _applyOptimization('network'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String title, String description, IconData icon, Color color, VoidCallback onApply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            child: const Text('应用'),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoOptimization() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '自动优化设置',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildAutoOptimizationOption(
              '自动清理缓存',
              '定期清理过期和低频使用的缓存',
              true,
            ),
            _buildAutoOptimizationOption(
              '性能监控告警',
              '当系统性能指标异常时自动发送通知',
              true,
            ),
            _buildAutoOptimizationOption(
              '智能资源调度',
              '根据负载情况自动调整资源分配',
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoOptimizationOption(String title, String description, bool enabled) {
    return ListTile(
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        description,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: enabled,
        onChanged: (value) {
          // TODO: 实现开关逻辑
        },
        activeColor: AppColors.primary,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSystemMaintenance() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '系统维护',
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
                  onPressed: () => _runSystemDiagnostics(),
                  icon: const Icon(Icons.bug_report),
                  label: const Text('系统诊断'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _generatePerformanceReport(),
                  icon: const Icon(Icons.assessment),
                  label: const Text('生成报告'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.onSecondary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _exportPerformanceData(),
                  icon: const Icon(Icons.download),
                  label: const Text('导出数据'),
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
  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.error:
        return AppColors.error;
      case AlertType.warning:
        return AppColors.warning;
      case AlertType.info:
        return AppColors.success;
    }
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.error:
        return Icons.error;
      case AlertType.warning:
        return Icons.warning;
      case AlertType.info:
        return Icons.info;
    }
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    return '${days}天 ${hours}小时 ${minutes}分';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
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
  void _toggleMonitoring() {
    setState(() {
      _isMonitoring = !_isMonitoring;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isMonitoring ? '性能监控已启动' : '性能监控已暂停'),
      ),
    );
  }

  void _refreshData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在刷新性能数据...')),
    );
    _loadPerformanceData();
  }

  void _viewAllAlerts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('查看所有性能警报')),
    );
  }

  void _dismissAlert(PerformanceAlert alert) {
    setState(() {
      alert.isActive = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已忽略警报: ${alert.title}')),
    );
  }

  void _clearExpiredCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在清理过期缓存...')),
    );
  }

  void _clearAllCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空缓存'),
        content: const Text('这将清空所有缓存数据，可能会暂时影响系统性能。确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('正在清空所有缓存...')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _optimizeCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在优化缓存配置...')),
    );
  }

  void _sortCacheItems() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('按大小排序缓存项')),
    );
  }

  void _handleCacheItemAction(String action, CacheItem item) {
    switch (action) {
      case 'refresh':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('刷新缓存项: ${item.key}')),
        );
        break;
      case 'delete':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除缓存项: ${item.key}')),
        );
        break;
      case 'details':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('查看缓存项详情: ${item.key}')),
        );
        break;
    }
  }

  void _applyOptimization(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在应用$type优化...')),
    );
  }

  void _runSystemDiagnostics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在运行系统诊断...')),
    );
  }

  void _generatePerformanceReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在生成性能报告...')),
    );
  }

  void _exportPerformanceData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在导出性能数据...')),
    );
  }
}

// 数据模型

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

class CacheStatus {
  final double totalSize;
  final double usedSize;
  final double hitRate;
  final double missRate;
  final List<CacheItem> cacheItems;

  CacheStatus({
    required this.totalSize,
    required this.usedSize,
    required this.hitRate,
    required this.missRate,
    required this.cacheItems,
  });
}

class CacheItem {
  final String key;
  final double size;
  final int hits;
  final DateTime lastAccess;

  CacheItem({
    required this.key,
    required this.size,
    required this.hits,
    required this.lastAccess,
  });
}

enum AlertType { error, warning, info }

class PerformanceAlert {
  final String id;
  final AlertType type;
  final String title;
  final String description;
  final DateTime timestamp;
  bool isActive;

  PerformanceAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isActive,
  });
} 