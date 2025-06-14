import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 系统状态面板
class SystemStatusPanel extends StatelessWidget {
  const SystemStatusPanel({super.key});

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
                  Icons.health_and_safety,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '系统状态',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '运行正常',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 模块状态列表
            _buildModuleStatus('认证系统', ModuleStatus.normal),
            _buildModuleStatus('知识库管理', ModuleStatus.normal),
            _buildModuleStatus('文件解析引擎', ModuleStatus.normal),
            _buildModuleStatus('语义检索', ModuleStatus.warning),
            _buildModuleStatus('对话系统', ModuleStatus.normal),
            _buildModuleStatus('调优系统', ModuleStatus.maintenance),
            _buildModuleStatus('数据管理', ModuleStatus.developing),
            
            const SizedBox(height: 12),
            
            // 系统性能指标
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem('响应时间', '< 200ms', AppColors.success),
                ),
                Expanded(
                  child: _buildMetricItem('内存使用', '68%', AppColors.warning),
                ),
                Expanded(
                  child: _buildMetricItem('可用性', '99.9%', AppColors.success),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleStatus(String moduleName, ModuleStatus status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(status),
            size: 16,
            color: _getStatusColor(status),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              moduleName,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getStatusText(status),
              style: TextStyle(
                fontSize: 10,
                color: _getStatusColor(status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  IconData _getStatusIcon(ModuleStatus status) {
    switch (status) {
      case ModuleStatus.normal:
        return Icons.check_circle;
      case ModuleStatus.warning:
        return Icons.warning;
      case ModuleStatus.error:
        return Icons.error;
      case ModuleStatus.maintenance:
        return Icons.build;
      case ModuleStatus.developing:
        return Icons.construction;
    }
  }

  Color _getStatusColor(ModuleStatus status) {
    switch (status) {
      case ModuleStatus.normal:
        return AppColors.success;
      case ModuleStatus.warning:
        return AppColors.warning;
      case ModuleStatus.error:
        return AppColors.error;
      case ModuleStatus.maintenance:
        return AppColors.info;
      case ModuleStatus.developing:
        return AppColors.primary;
    }
  }

  String _getStatusText(ModuleStatus status) {
    switch (status) {
      case ModuleStatus.normal:
        return '正常';
      case ModuleStatus.warning:
        return '警告';
      case ModuleStatus.error:
        return '错误';
      case ModuleStatus.maintenance:
        return '维护';
      case ModuleStatus.developing:
        return '开发中';
    }
  }
}

/// 模块状态枚举
enum ModuleStatus {
  normal,
  warning,
  error,
  maintenance,
  developing,
} 