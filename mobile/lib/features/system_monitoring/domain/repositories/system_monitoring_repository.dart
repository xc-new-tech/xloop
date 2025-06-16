import '../entities/system_metrics.dart';

/// 系统监控仓储接口
abstract class SystemMonitoringRepository {
  /// 获取当前系统指标
  Future<SystemMetrics> getCurrentMetrics();

  /// 获取历史系统指标
  Future<List<SystemMetrics>> getHistoricalMetrics({
    DateTime? startTime,
    DateTime? endTime,
    Duration? interval,
  });

  /// 获取系统健康状态
  Future<SystemHealth> getSystemHealth();

  /// 获取系统警报
  Future<List<SystemAlert>> getSystemAlerts({
    bool? activeOnly,
    AlertSeverity? severity,
    String? category,
  });

  /// 创建系统警报
  Future<void> createAlert(SystemAlert alert);

  /// 更新系统警报
  Future<void> updateAlert(SystemAlert alert);

  /// 删除系统警报
  Future<void> deleteAlert(String alertId);

  /// 确认系统警报
  Future<void> acknowledgeAlert(String alertId);

  /// 获取系统日志
  Future<List<SystemLogEntry>> getSystemLogs({
    DateTime? startTime,
    DateTime? endTime,
    LogLevel? level,
    String? source,
    String? category,
    int? limit,
  });

  /// 添加系统日志
  Future<void> addSystemLog(SystemLogEntry logEntry);

  /// 清理系统日志
  Future<void> cleanupLogs({
    DateTime? beforeDate,
    LogLevel? level,
  });

  /// 获取运维任务
  Future<List<OperationTask>> getOperationTasks({
    OperationTaskStatus? status,
    OperationTaskType? type,
  });

  /// 创建运维任务
  Future<OperationTask> createOperationTask(OperationTask task);

  /// 更新运维任务
  Future<void> updateOperationTask(OperationTask task);

  /// 执行运维任务
  Future<void> executeOperationTask(String taskId);

  /// 取消运维任务
  Future<void> cancelOperationTask(String taskId);

  /// 获取系统配置
  Future<Map<String, dynamic>> getSystemConfiguration();

  /// 更新系统配置
  Future<void> updateSystemConfiguration(Map<String, dynamic> config);

  /// 执行系统诊断
  Future<Map<String, dynamic>> runSystemDiagnostics();

  /// 生成系统报告
  Future<String> generateSystemReport({
    DateTime? startTime,
    DateTime? endTime,
    List<String>? sections,
  });

  /// 导出系统数据
  Future<String> exportSystemData({
    DateTime? startTime,
    DateTime? endTime,
    List<String>? dataTypes,
  });

  /// 开始监控
  Stream<SystemMetrics> startMonitoring({Duration? interval});

  /// 停止监控
  Future<void> stopMonitoring();
} 