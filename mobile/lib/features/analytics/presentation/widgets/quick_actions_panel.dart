import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 快速操作面板
class QuickActionsPanel extends StatelessWidget {
  const QuickActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 快速分析
          _buildActionSection(
            context,
            '快速分析',
            [
              _ActionItem(
                icon: Icons.analytics,
                title: '生成质量报告',
                subtitle: '生成最新的质量分析报告',
                onTap: () => _generateQualityReport(context),
              ),
              _ActionItem(
                icon: Icons.speed,
                title: '性能检查',
                subtitle: '运行系统性能诊断',
                onTap: () => _runPerformanceCheck(context),
              ),
              _ActionItem(
                icon: Icons.sentiment_satisfied,
                title: '满意度分析',
                subtitle: '分析用户反馈和满意度',
                onTap: () => _analyzeSatisfaction(context),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 优化操作
          _buildActionSection(
            context,
            '优化操作',
            [
              _ActionItem(
                icon: Icons.auto_fix_high,
                title: '自动优化',
                subtitle: '应用推荐的优化建议',
                onTap: () => _runAutoOptimization(context),
              ),
              _ActionItem(
                icon: Icons.cleaning_services,
                title: '清理数据',
                subtitle: '清理过期和无效数据',
                onTap: () => _cleanupData(context),
              ),
              _ActionItem(
                icon: Icons.refresh,
                title: '重建索引',
                subtitle: '重建搜索索引以提升性能',
                onTap: () => _rebuildIndex(context),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 监控设置
          _buildActionSection(
            context,
            '监控设置',
            [
              _ActionItem(
                icon: Icons.monitor,
                title: '实时监控',
                subtitle: '启动或停止实时监控',
                onTap: () => _toggleMonitoring(context),
              ),
              _ActionItem(
                icon: Icons.notifications,
                title: '警报设置',
                subtitle: '配置警报规则和通知',
                onTap: () => _configureAlerts(context),
              ),
              _ActionItem(
                icon: Icons.download,
                title: '导出数据',
                subtitle: '导出分析数据和报告',
                onTap: () => _exportData(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(
    BuildContext context,
    String title,
    List<_ActionItem> actions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 12),
        ...actions.map((action) => _buildActionTile(context, action)),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, _ActionItem action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                action.icon,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    action.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurface.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  void _generateQualityReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在生成质量报告...')),
    );
    // TODO: 实现质量报告生成
  }

  void _runPerformanceCheck(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在运行性能检查...')),
    );
    // TODO: 实现性能检查
  }

  void _analyzeSatisfaction(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在分析用户满意度...')),
    );
    // TODO: 实现满意度分析
  }

  void _runAutoOptimization(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自动优化'),
        content: const Text('确定要运行自动优化吗？这可能需要几分钟时间。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('正在运行自动优化...')),
              );
              // TODO: 实现自动优化
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _cleanupData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在清理数据...')),
    );
    // TODO: 实现数据清理
  }

  void _rebuildIndex(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在重建索引...')),
    );
    // TODO: 实现索引重建
  }

  void _toggleMonitoring(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('切换监控状态...')),
    );
    // TODO: 实现监控状态切换
  }

  void _configureAlerts(BuildContext context) {
    Navigator.of(context).pushNamed('/analytics/alerts');
  }

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在导出数据...')),
    );
    // TODO: 实现数据导出
  }
}

class _ActionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
} 