import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 优化状态卡片
class OptimizationStatusCard extends StatelessWidget {
  final int inProgress;
  final int completed;
  final int highPriority;

  const OptimizationStatusCard({
    super.key,
    required this.inProgress,
    required this.completed,
    required this.highPriority,
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
                  Icons.tune,
                  color: AppColors.warning,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '优化状态',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 进行中的优化
            _buildStatusRow(
              context,
              '进行中',
              inProgress,
              AppColors.info,
              Icons.play_circle_outline,
            ),
            const SizedBox(height: 8),
            
            // 已完成的优化
            _buildStatusRow(
              context,
              '已完成',
              completed,
              AppColors.success,
              Icons.check_circle_outline,
            ),
            const SizedBox(height: 8),
            
            // 高优先级建议
            _buildStatusRow(
              context,
              '高优先级',
              highPriority,
              AppColors.error,
              Icons.priority_high,
            ),
            
            const SizedBox(height: 12),
            
            // 效率指标
            Row(
              children: [
                Text(
                  '完成率',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurface.withOpacity(0.7),
                      ),
                ),
                const Spacer(),
                _buildEfficiencyIndicator(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurface.withOpacity(0.7),
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEfficiencyIndicator() {
    final total = inProgress + completed;
    final efficiency = total > 0 ? completed / total : 0.0;
    final percentage = (efficiency * 100).toInt();
    
    Color color;
    if (efficiency >= 0.8) {
      color = AppColors.success;
    } else if (efficiency >= 0.5) {
      color = AppColors.warning;
    } else {
      color = AppColors.error;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: color.withOpacity(0.2),
          ),
          child: FractionallySizedBox(
            widthFactor: efficiency,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
} 