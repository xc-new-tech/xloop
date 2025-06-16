import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/system_monitoring_bloc.dart';
import '../bloc/system_monitoring_event.dart';
import '../widgets/metrics_dashboard_widget.dart';
import '../widgets/alerts_widget.dart';
import '../widgets/logs_widget.dart';
import '../widgets/operation_tasks_widget.dart';

/// 系统监控主页面
class SystemMonitoringPage extends StatelessWidget {
  const SystemMonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<SystemMonitoringBloc>()
        ..add(const LoadSystemMetricsEvent())
        ..add(const LoadSystemHealthEvent())
        ..add(const LoadSystemAlertsEvent())
        ..add(const LoadSystemLogsEvent())
        ..add(const LoadOperationTasksEvent()),
      child: const SystemMonitoringView(),
    );
  }
}

class SystemMonitoringView extends StatefulWidget {
  const SystemMonitoringView({super.key});

  @override
  State<SystemMonitoringView> createState() => _SystemMonitoringViewState();
}

class _SystemMonitoringViewState extends State<SystemMonitoringView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('系统监控'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: '仪表板'),
            Tab(icon: Icon(Icons.warning), text: '警报'),
            Tab(icon: Icon(Icons.list_alt), text: '日志'),
            Tab(icon: Icon(Icons.task), text: '运维任务'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MetricsDashboardWidget(),
          AlertsWidget(),
          LogsWidget(),
          OperationTasksWidget(),
        ],
      ),
    );
  }
}
