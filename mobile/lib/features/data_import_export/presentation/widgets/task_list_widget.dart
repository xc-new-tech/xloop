import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/widgets/adaptive_layout.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/import_export_entity.dart';
import 'task_item_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/import_export_bloc.dart';

class TaskListWidget extends StatelessWidget {
  const TaskListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImportExportBloc, ImportExportState>(
      builder: (context, state) {
        if (state is ImportExportLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ImportExportLoaded) {
          return _buildTaskList(context, state.tasks);
        } else if (state is ImportExportError) {
          return _buildErrorView(context, state.message);
        }
        
        return _buildEmptyView(context);
      },
    );
  }

  Widget _buildTaskList(BuildContext context, List<ImportExportTask> tasks) {
    if (tasks.isEmpty) {
      return _buildEmptyView(context);
    }

    // 按状态分组任务
    final groupedTasks = _groupTasksByStatus(tasks);
    
    return ListView(
      padding: ResponsiveUtils.getAdaptivePadding(context),
      children: [
        if (groupedTasks['in-progress']?.isNotEmpty == true)
          _buildTaskSection(context, '进行中', groupedTasks['in-progress']!, Colors.blue),
        
        if (groupedTasks['pending']?.isNotEmpty == true)
          _buildTaskSection(context, '待处理', groupedTasks['pending']!, Colors.orange),
        
        if (groupedTasks['completed']?.isNotEmpty == true)
          _buildTaskSection(context, '已完成', groupedTasks['completed']!, Colors.green),
        
        if (groupedTasks['failed']?.isNotEmpty == true)
          _buildTaskSection(context, '失败', groupedTasks['failed']!, Colors.red),
        
        if (groupedTasks['cancelled']?.isNotEmpty == true)
          _buildTaskSection(context, '已取消', groupedTasks['cancelled']!, Colors.grey),
      ],
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无任务',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮创建新的导入导出任务',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败: $message',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '请检查网络连接并重试',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSection(
    BuildContext context,
    String title,
    List<ImportExportTask> tasks,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                _getIconForStatus(title),
                size: 20,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tasks.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...tasks.map((task) => TaskItemWidget(
          task: task,
          onAction: (task, action) => _handleTaskAction(context, task, action),
        )),
        const SizedBox(height: 16),
      ],
    );
  }

  IconData _getIconForStatus(String status) {
    switch (status) {
      case '进行中':
        return Icons.play_circle_outline;
      case '待处理':
        return Icons.schedule;
      case '已完成':
        return Icons.check_circle_outline;
      case '失败':
        return Icons.error_outline;
      case '已取消':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  void _handleTaskAction(BuildContext context, ImportExportTask task, String action) {
    switch (action) {
      case 'start':
        context.read<ImportExportBloc>().add(StartTaskEvent(task.id));
        break;
      case 'cancel':
        context.read<ImportExportBloc>().add(CancelTaskEvent(task.id));
        break;
      case 'delete':
        context.read<ImportExportBloc>().add(DeleteTaskEvent(task.id));
        break;
      case 'share':
        context.read<ImportExportBloc>().add(ShareTaskEvent(task.id));
        break;
    }
  }

  Map<String, List<ImportExportTask>> _groupTasksByStatus(
    List<ImportExportTask> tasks,
  ) {
    final groups = <String, List<ImportExportTask>>{
      'in-progress': [],
      'pending': [],
      'completed': [],
      'failed': [],
      'cancelled': [],
    };

    for (final task in tasks) {
      switch (task.status) {
        case ImportExportStatus.inProgress:
          groups['in-progress']!.add(task);
          break;
        case ImportExportStatus.pending:
          groups['pending']!.add(task);
          break;
        case ImportExportStatus.completed:
          groups['completed']!.add(task);
          break;
        case ImportExportStatus.failed:
          groups['failed']!.add(task);
          break;
        case ImportExportStatus.cancelled:
          groups['cancelled']!.add(task);
          break;
      }
    }

    // 按创建时间排序
    for (final group in groups.values) {
      group.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return groups;
  }
} 