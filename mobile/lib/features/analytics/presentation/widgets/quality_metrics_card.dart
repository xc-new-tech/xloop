import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/analytics_entity.dart';

/// 质量指标卡片
class QualityMetricsCard extends StatelessWidget {
  final double? averageScore;
  final int assessmentCount;
  final ConversationQualityAssessment? latestAssessment;

  const QualityMetricsCard({
    super.key,
    this.averageScore,
    required this.assessmentCount,
    this.latestAssessment,
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
                  Icons.assessment,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '质量评估',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 平均分数
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '平均分数',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurface.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        averageScore?.toStringAsFixed(1) ?? '--',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(averageScore),
                            ),
                      ),
                    ],
                  ),
                ),
                _buildScoreCircle(averageScore),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 评估数量
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '总评估数',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurface.withOpacity(0.7),
                      ),
                ),
                Text(
                  '$assessmentCount',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            
            // 最新评估时间
            if (latestAssessment != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '最新评估',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurface.withOpacity(0.7),
                        ),
                  ),
                  Text(
                    _formatTime(latestAssessment!.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurface.withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle(double? score) {
    if (score == null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.onSurface.withOpacity(0.1),
        ),
        child: const Center(
          child: Text(
            '--',
            style: TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    final progress = score / 10.0;
    final color = _getScoreColor(score);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 3,
          ),
        ),
        Text(
          score.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double? score) {
    if (score == null) return AppColors.onSurface.withOpacity(0.5);
    
    if (score >= 8.0) return AppColors.success;
    if (score >= 6.0) return AppColors.warning;
    return AppColors.error;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
} 