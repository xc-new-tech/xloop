import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/analytics_state.dart';

/// 性能指标卡片
class PerformanceMetricsCard extends StatelessWidget {
  final PerformanceData? performanceData;

  const PerformanceMetricsCard({
    super.key,
    this.performanceData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed,
                  color: AppColors.secondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '性能指标',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (performanceData != null) ...[
              // 响应时间
              _buildMetricRow(
                context,
                '平均响应时间',
                '${performanceData!.averageResponseTime.toStringAsFixed(0)}ms',
                _getResponseTimeColor(performanceData!.averageResponseTime),
              ),
              const SizedBox(height: 8),
              
              // 成功率
              _buildMetricRow(
                context,
                '成功率',
                '${(performanceData!.successRate * 100).toStringAsFixed(1)}%',
                _getSuccessRateColor(performanceData!.successRate),
              ),
              const SizedBox(height: 8),
              
              // 吞吐量
              _buildMetricRow(
                context,
                '吞吐量',
                '${performanceData!.throughput.toStringAsFixed(0)}/秒',
                AppColors.onSurface,
              ),
              
              const SizedBox(height: 12),
              
              // 性能评级
              Row(
                children: [
                  Text(
                    '性能评级',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurface.withOpacity(0.7),
                        ),
                  ),
                  const Spacer(),
                  _buildPerformanceGrade(),
                ],
              ),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.hourglass_empty,
                      size: 32,
                      color: AppColors.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '暂无性能数据',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurface.withOpacity(0.7),
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

  Widget _buildMetricRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurface.withOpacity(0.7),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
        ),
      ],
    );
  }

  Widget _buildPerformanceGrade() {
    if (performanceData == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.onSurface.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '--',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface.withOpacity(0.5),
          ),
        ),
      );
    }

    final grade = _calculatePerformanceGrade();
    final gradeColor = _getGradeColor(grade);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: gradeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        grade,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: gradeColor,
        ),
      ),
    );
  }

  String _calculatePerformanceGrade() {
    if (performanceData == null) return '--';

    final responseTime = performanceData!.averageResponseTime;
    final successRate = performanceData!.successRate;
    
    // 综合评分：响应时间 + 成功率
    double score = 0;
    
    // 响应时间评分 (0-50分)
    if (responseTime <= 100) {
      score += 50;
    } else if (responseTime <= 500) {
      score += 40 - ((responseTime - 100) / 400) * 15;
    } else if (responseTime <= 1000) {
      score += 25 - ((responseTime - 500) / 500) * 15;
    } else {
      score += 10;
    }
    
    // 成功率评分 (0-50分)
    score += successRate * 50;
    
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B+';
    if (score >= 60) return 'B';
    if (score >= 50) return 'C+';
    if (score >= 40) return 'C';
    return 'D';
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return AppColors.success;
      case 'B+':
      case 'B':
        return AppColors.info;
      case 'C+':
      case 'C':
        return AppColors.warning;
      case 'D':
        return AppColors.error;
      default:
        return AppColors.onSurface.withOpacity(0.5);
    }
  }

  Color _getResponseTimeColor(double responseTime) {
    if (responseTime <= 100) return AppColors.success;
    if (responseTime <= 500) return AppColors.warning;
    return AppColors.error;
  }

  Color _getSuccessRateColor(double successRate) {
    if (successRate >= 0.95) return AppColors.success;
    if (successRate >= 0.90) return AppColors.warning;
    return AppColors.error;
  }
} 