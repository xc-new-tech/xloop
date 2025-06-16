import '../entities/system_metrics.dart';
import '../repositories/system_monitoring_repository.dart';

/// 管理运维任务用例
class ManageOperationTasks {
  final SystemMonitoringRepository repository;

  ManageOperationTasks(this.repository);

  /// 获取运维任务列表
  Future<List<OperationTask>> getTasks({
    OperationTaskStatus? status,
    OperationTaskType? type,
  }) async {
    return await repository.getOperationTasks(
      status: status,
      type: type,
    );
  }

  /// 创建运维任务
  Future<OperationTask> createTask({
    required String title,
    required String description,
    required OperationTaskType type,
    DateTime? scheduledAt,
    Map<String, dynamic> parameters = const {},
  }) async {
    final task = OperationTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      type: type,
      status: OperationTaskStatus.pending,
      createdAt: DateTime.now(),
      scheduledAt: scheduledAt,
      parameters: parameters,
    );

    return await repository.createOperationTask(task);
  }

  /// 执行运维任务
  Future<void> executeTask(String taskId) async {
    await repository.executeOperationTask(taskId);
  }

  /// 取消运维任务
  Future<void> cancelTask(String taskId) async {
    await repository.cancelOperationTask(taskId);
  }

  /// 批量执行任务
  Future<void> executeBatchTasks(List<String> taskIds) async {
    for (final taskId in taskIds) {
      try {
        await repository.executeOperationTask(taskId);
      } catch (e) {
        // 记录错误但继续执行其他任务
        print('执行任务 $taskId 失败: $e');
      }
    }
  }

  /// 创建预定义的运维任务
  Future<OperationTask> createBackupTask({
    required String description,
    DateTime? scheduledAt,
    Map<String, dynamic>? backupOptions,
  }) async {
    return await createTask(
      title: '系统备份',
      description: description,
      type: OperationTaskType.backup,
      scheduledAt: scheduledAt,
      parameters: backupOptions ?? {},
    );
  }

  Future<OperationTask> createCleanupTask({
    required String description,
    DateTime? scheduledAt,
    Map<String, dynamic>? cleanupOptions,
  }) async {
    return await createTask(
      title: '系统清理',
      description: description,
      type: OperationTaskType.cleanup,
      scheduledAt: scheduledAt,
      parameters: cleanupOptions ?? {},
    );
  }

  Future<OperationTask> createOptimizationTask({
    required String description,
    DateTime? scheduledAt,
    Map<String, dynamic>? optimizationOptions,
  }) async {
    return await createTask(
      title: '系统优化',
      description: description,
      type: OperationTaskType.optimization,
      scheduledAt: scheduledAt,
      parameters: optimizationOptions ?? {},
    );
  }

  Future<OperationTask> createMaintenanceTask({
    required String description,
    DateTime? scheduledAt,
    Map<String, dynamic>? maintenanceOptions,
  }) async {
    return await createTask(
      title: '系统维护',
      description: description,
      type: OperationTaskType.maintenance,
      scheduledAt: scheduledAt,
      parameters: maintenanceOptions ?? {},
    );
  }
} 