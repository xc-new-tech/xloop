import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/analytics_state.dart';

/// 实时监控面板
class RealtimeMonitoringPanel extends StatelessWidget {
  final RealtimeMetrics metrics;
  final bool isMonitoring;
  final VoidCallback onToggleMonitoring;

  const RealtimeMonitoringPanel({
    super.key,
    required this.metrics,
    required this.isMonitoring,
    required this.onToggleMonitoring,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '实时监控',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Switch(
                  value: isMonitoring,
                  onChanged: (_) => onToggleMonitoring(),
                  activeColor: AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (isMonitoring) ...[
              Text(
                '当前系统状态',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              
              // 监控指标
              _buildMetricRow('活跃连接', '${metrics.activeConnections}'),
              _buildMetricRow('队列长度', '${metrics.queueLength}'),
              _buildMetricRow('错误率', '${(metrics.errorRate * 100).toStringAsFixed(1)}%'),
              _buildMetricRow('响应时间', '${metrics.avgResponseTime.toStringAsFixed(0)}ms'),
              
              if (metrics.alerts.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '活跃警报 (${metrics.alerts.length})',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                ),
                const SizedBox(height: 8),
                ...metrics.alerts.take(3).map((alert) => _buildAlertItem(alert)),
              ],
            ] else ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.monitor_outlined,
                      size: 48,
                      color: AppColors.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '监控已停止',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.onSurface.withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '启用监控以查看实时数据',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurface.withOpacity(0.5),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(Alert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getAlertColor(alert.severity).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _getAlertColor(alert.severity).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getAlertIcon(alert.severity),
            size: 16,
            color: _getAlertColor(alert.severity),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              alert.message,
              style: TextStyle(
                fontSize: 12,
                color: _getAlertColor(alert.severity),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAlertColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      case 'info':
        return AppColors.info;
      default:
        return AppColors.onSurface;
    }
  }

  IconData _getAlertIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
} 