import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/analytics_state.dart';

/// 用户满意度卡片
class UserSatisfactionCard extends StatelessWidget {
  final UserSatisfactionData? satisfactionData;

  const UserSatisfactionCard({
    super.key,
    this.satisfactionData,
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
                  Icons.sentiment_satisfied,
                  color: AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '用户满意度',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (satisfactionData != null) ...[
              // 平均满意度
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '平均满意度',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurface.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(satisfactionData!.averageRating * 20).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getSatisfactionColor(satisfactionData!.averageRating),
                              ),
                        ),
                      ],
                    ),
                  ),
                  _buildSatisfactionIndicator(satisfactionData!.averageRating),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 反馈数量
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '总反馈数',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurface.withOpacity(0.7),
                        ),
                  ),
                  Text(
                    '${satisfactionData!.totalFeedbacks}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 情感分布
              if (satisfactionData!.sentimentDistribution.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '积极情感',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurface.withOpacity(0.7),
                          ),
                    ),
                    Text(
                      '${(satisfactionData!.sentimentDistribution['positive'] ?? 0.0 * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                    ),
                  ],
                ),
              ],
            ] else ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.sentiment_neutral,
                      size: 32,
                      color: AppColors.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '暂无满意度数据',
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

  Widget _buildSatisfactionIndicator(double rating) {
    final progress = rating / 5.0;
    final color = _getSatisfactionColor(rating);

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
        Icon(
          _getSatisfactionIcon(rating),
          size: 20,
          color: color,
        ),
      ],
    );
  }

  Color _getSatisfactionColor(double rating) {
    if (rating >= 4.0) return AppColors.success;
    if (rating >= 3.0) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getSatisfactionIcon(double rating) {
    if (rating >= 4.5) return Icons.sentiment_very_satisfied;
    if (rating >= 3.5) return Icons.sentiment_satisfied;
    if (rating >= 2.5) return Icons.sentiment_neutral;
    if (rating >= 1.5) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_very_dissatisfied;
  }
} 