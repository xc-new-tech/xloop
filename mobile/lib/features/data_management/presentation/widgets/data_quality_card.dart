import 'package:flutter/material.dart';
import '../bloc/data_management_state.dart';

/// 数据质量卡片
class DataQualityCard extends StatelessWidget {
  final DataQuality quality;
  final VoidCallback? onViewDetails;

  const DataQualityCard({
    super.key,
    required this.quality,
    this.onViewDetails,
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
                Icon(
                  Icons.assessment,
                  color: _getGradeColor(),
                ),
                const SizedBox(width: 8),
                Text(
                  '数据质量',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (onViewDetails != null)
                  TextButton(
                    onPressed: onViewDetails,
                    child: const Text('详情'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 总体评分
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getGradeColor().withOpacity(0.1),
                  ),
                  child: Center(
                    child: Text(
                      quality.overallGrade,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getGradeColor(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '总体评分',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${quality.overallScore.toStringAsFixed(1)}分',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getGradeColor(),
                            ),
                      ),
                      if (quality.issuesCount > 0)
                        Text(
                          '${quality.issuesCount}个问题待解决',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.orange,
                              ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 详细评分
            _buildScoreItem(context, '完整性', quality.completenessScore),
            const SizedBox(height: 8),
            _buildScoreItem(context, '准确性', quality.accuracyScore),
            const SizedBox(height: 8),
            _buildScoreItem(context, '一致性', quality.consistencyScore),
            const SizedBox(height: 8),
            _buildScoreItem(context, '有效性', quality.validityScore),
            
            const SizedBox(height: 12),
            
            Text(
              '上次分析: ${_formatDateTime(quality.lastAnalyzed)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(BuildContext context, String label, double score) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${score.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getGradeColor() {
    switch (quality.overallGrade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.lightGreen;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.orange;
    if (score >= 60) return Colors.deepOrange;
    return Colors.red;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
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