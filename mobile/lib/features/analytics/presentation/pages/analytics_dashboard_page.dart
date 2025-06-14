import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';
import '../widgets/quality_metrics_card.dart';
import '../widgets/performance_metrics_card.dart';
import '../widgets/user_satisfaction_card.dart';
import '../widgets/optimization_status_card.dart';
import '../widgets/quality_trend_chart.dart';
import '../widgets/real_time_monitoring_panel.dart';
import '../widgets/alerts_panel.dart';
import '../widgets/quick_actions_panel.dart';
import '../../domain/entities/alert.dart';

/// 调优系统主仪表板页面
class AnalyticsDashboardPage extends StatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadDashboardData() {
    final bloc = context.read<AnalyticsBloc>();
    bloc.add(const LoadConversationAssessmentsEvent(limit: 10));
    bloc.add(const LoadKnowledgeBaseOptimizationsEvent(limit: 5));
    bloc.add(const GenerateQualityTrendReportEvent());
    bloc.add(const GeneratePerformanceReportEvent());
    bloc.add(const GenerateUserSatisfactionReportEvent());
    bloc.add(const StartRealtimeMonitoringEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: '智能调优系统',
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: '刷新数据',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: '设置',
          ),
        ],
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const LoadingWidget(message: '加载调优数据中...');
          }

          if (state is AnalyticsError) {
            return _buildErrorView(state.message);
          }

          return Column(
            children: [
              // Tab导航
              Container(
                color: AppColors.surface,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.onSurface.withOpacity(0.6),
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.dashboard),
                      text: '总览',
                    ),
                    Tab(
                      icon: Icon(Icons.trending_up),
                      text: '质量分析',
                    ),
                    Tab(
                      icon: Icon(Icons.tune),
                      text: '优化建议',
                    ),
                    Tab(
                      icon: Icon(Icons.monitor),
                      text: '实时监控',
                    ),
                  ],
                ),
              ),
              // Tab内容
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(state),
                    _buildQualityAnalysisTab(state),
                    _buildOptimizationTab(state),
                    _buildMonitoringTab(state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickActions,
        icon: const Icon(Icons.auto_fix_high),
        label: const Text('快速优化'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
    );
  }

  Widget _buildOverviewTab(AnalyticsState state) {
    if (state is! AnalyticsLoaded) {
      return const Center(child: Text('暂无数据'));
    }

    return RefreshIndicator(
      onRefresh: () async => _loadDashboardData(),
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 关键指标卡片
            _buildMetricsGrid(state),
            const SizedBox(height: 24),
            
            // 质量趋势图表
            if (state.qualityTrendData != null) ...[
              Text(
                '质量趋势',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              QualityTrendChart(data: state.qualityTrendData!),
              const SizedBox(height: 24),
            ],

            // 警报面板
            if (state.realtimeMetrics?.alerts.isNotEmpty == true) ...[
              Text(
                '系统警报',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              AlertsPanel(alerts: _convertMetricAlertsToAlerts(state.realtimeMetrics!.alerts)),
              const SizedBox(height: 24),
            ],

            // 快速操作
            Text(
              '快速操作',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const QuickActionsPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(AnalyticsLoaded state) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        QualityMetricsCard(
          averageScore: state.averageQualityScore,
          assessmentCount: state.assessments.length,
          latestAssessment: state.latestAssessment,
        ),
        PerformanceMetricsCard(
          performanceData: state.performanceData,
        ),
        UserSatisfactionCard(
          satisfactionData: state.userSatisfactionData,
        ),
        OptimizationStatusCard(
          inProgress: state.inProgressOptimizations.length,
          completed: state.completedOptimizations.length,
          highPriority: state.highPriorityRecommendationsCount,
        ),
      ],
    );
  }

  Widget _buildQualityAnalysisTab(AnalyticsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 质量维度分析
          _buildQualityDimensionsSection(state),
          const SizedBox(height: 24),
          
          // 质量趋势详细分析
          _buildQualityTrendSection(state),
          const SizedBox(height: 24),
          
          // 评估历史
          _buildAssessmentHistorySection(state),
        ],
      ),
    );
  }

  Widget _buildOptimizationTab(AnalyticsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 优化建议列表
          _buildOptimizationRecommendationsSection(state),
          const SizedBox(height: 24),
          
          // 优化历史
          _buildOptimizationHistorySection(state),
          const SizedBox(height: 24),
          
          // 性能改进追踪
          _buildPerformanceImprovementSection(state),
        ],
      ),
    );
  }

  Widget _buildMonitoringTab(AnalyticsState state) {
    if (state is! AnalyticsLoaded) {
      return const Center(child: Text('暂无监控数据'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 实时监控面板
          if (state.realtimeMetrics != null)
            RealtimeMonitoringPanel(
              metrics: state.realtimeMetrics!,
              isMonitoring: state.isMonitoring,
              onToggleMonitoring: _toggleMonitoring,
            ),
          const SizedBox(height: 24),
          
          // 系统资源监控
          _buildResourceMonitoringSection(state),
          const SizedBox(height: 24),
          
          // 警报配置
          _buildAlertConfigurationSection(),
        ],
      ),
    );
  }

  Widget _buildQualityDimensionsSection(AnalyticsState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '质量维度分析',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text('质量维度详细分析功能开发中...'),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityTrendSection(AnalyticsState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '质量趋势详细分析',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text('质量趋势详细分析功能开发中...'),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentHistorySection(AnalyticsState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '评估历史',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text('评估历史功能开发中...'),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationRecommendationsSection(AnalyticsState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '优化建议',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text('优化建议功能开发中...'),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationHistorySection(AnalyticsState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '优化历史',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text('优化历史功能开发中...'),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceImprovementSection(AnalyticsState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '性能改进追踪',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text('性能改进追踪功能开发中...'),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceMonitoringSection(AnalyticsLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '系统资源监控',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (state.performanceData?.resourceUsage != null)
              _buildResourceUsageIndicators(state.performanceData!.resourceUsage)
            else
              const Text('暂无资源监控数据'),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceUsageIndicators(ResourceUsage resourceUsage) {
    return Column(
      children: [
        _buildResourceIndicator('CPU使用率', resourceUsage.cpuUsage, '%'),
        const SizedBox(height: 12),
        _buildResourceIndicator('内存使用率', resourceUsage.memoryUsage, '%'),
        const SizedBox(height: 12),
        _buildResourceIndicator('存储使用率', resourceUsage.storageUsage, '%'),
        const SizedBox(height: 12),
        _buildResourceIndicator('网络使用', resourceUsage.networkUsage, 'Mbps'),
      ],
    );
  }

  Widget _buildResourceIndicator(String label, double value, String unit) {
    final color = value > 80 ? AppColors.error : 
                  value > 60 ? AppColors.warning : 
                  AppColors.success;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label),
        ),
        Expanded(
          flex: 3,
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: Text(
            '${value.toStringAsFixed(1)}$unit',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertConfigurationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '警报配置',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text('警报配置功能开发中...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: 24),
          Text(
            '加载失败',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.error,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }

  void _toggleMonitoring() {
    final bloc = context.read<AnalyticsBloc>();
    final state = bloc.state;
    
    if (state is AnalyticsLoaded && state.isMonitoring) {
      bloc.add(const StopRealtimeMonitoringEvent());
    } else {
      bloc.add(const StartRealtimeMonitoringEvent());
    }
  }

  void _showSettings() {
    // 导航到设置页面
    Navigator.of(context).pushNamed('/analytics/settings');
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '快速操作',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Expanded(
                child: const QuickActionsPanel(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 将MetricAlert转换为Alert
  List<Alert> _convertMetricAlertsToAlerts(List<MetricAlert> metricAlerts) {
    return metricAlerts.map((metricAlert) {
      return Alert(
        id: '${metricAlert.metricName}_${metricAlert.timestamp.millisecondsSinceEpoch}',
        title: metricAlert.metricName,
        message: metricAlert.message,
        level: _convertAlertSeverityToLevel(metricAlert.severity),
        status: AlertStatus.active,
        createdAt: metricAlert.timestamp,
        metadata: {
          'currentValue': metricAlert.currentValue,
          'threshold': metricAlert.threshold,
          'type': metricAlert.type.toString(),
        },
      );
    }).toList();
  }

  /// 将AlertSeverity转换为AlertLevel
  AlertLevel _convertAlertSeverityToLevel(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return AlertLevel.info;
      case AlertSeverity.medium:
        return AlertLevel.warning;
      case AlertSeverity.high:
        return AlertLevel.error;
      case AlertSeverity.critical:
        return AlertLevel.critical;
    }
  }
} 