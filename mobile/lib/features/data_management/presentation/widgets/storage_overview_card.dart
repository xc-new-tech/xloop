import 'package:flutter/material.dart';
import '../bloc/data_management_state.dart';

/// 存储概览卡片
class StorageOverviewCard extends StatelessWidget {
  final StorageOverview overview;
  final VoidCallback? onViewDetails;

  const StorageOverviewCard({
    super.key,
    required this.overview,
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
                const Icon(Icons.storage, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '存储概览',
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
            
            // 存储使用情况
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '已使用',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        overview.formattedUsedSize,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '总容量',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        overview.formattedTotalSize,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 进度条
            LinearProgressIndicator(
              value: overview.usagePercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                overview.usagePercentage > 80 ? Colors.red : Colors.blue,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '使用率: ${overview.usagePercentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            
            const SizedBox(height: 16),
            
            // 数据统计
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    '文档',
                    overview.documentsCount.toString(),
                    Icons.description,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    '知识库',
                    overview.knowledgeBasesCount.toString(),
                    Icons.library_books,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    '对话',
                    overview.conversationsCount.toString(),
                    Icons.chat,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
} 