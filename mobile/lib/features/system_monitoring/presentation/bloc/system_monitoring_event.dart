import 'package:equatable/equatable.dart';
import '../../domain/entities/system_metrics.dart';

/// 系统监控事件基类
abstract class SystemMonitoringEvent extends Equatable {
  const SystemMonitoringEvent();

  @override
  List<Object?> get props => [];
}

/// 加载系统指标事件
class LoadSystemMetricsEvent extends SystemMonitoringEvent {
  const LoadSystemMetricsEvent();
}

/// 加载历史指标事件
class LoadHistoricalMetricsEvent extends SystemMonitoringEvent {
  final DateTime? startTime;
  final DateTime? endTime;
  final Duration? interval;

  const LoadHistoricalMetricsEvent({
    this.startTime,
    this.endTime,
    this.interval,
  });

  @override
  List<Object?> get props => [startTime, endTime, interval];
}

/// 开始实时监控事件
class StartRealTimeMonitoringEvent extends SystemMonitoringEvent {
  final Duration interval;

  const StartRealTimeMonitoringEvent({
    this.interval = const Duration(seconds: 30),
  });

  @override
  List<Object?> get props => [interval];
}

/// 停止实时监控事件
class StopRealTimeMonitoringEvent extends SystemMonitoringEvent {
  const StopRealTimeMonitoringEvent();
}

/// 实时指标更新事件
class RealTimeMetricsUpdatedEvent extends SystemMonitoringEvent {
  final SystemMetrics metrics;

  const RealTimeMetricsUpdatedEvent(this.metrics);

  @override
  List<Object?> get props => [metrics];
}

/// 加载系统健康状态事件
class LoadSystemHealthEvent extends SystemMonitoringEvent {
  const LoadSystemHealthEvent();
}

/// 加载系统警报事件
class LoadSystemAlertsEvent extends SystemMonitoringEvent {
  final bool? activeOnly;
  final AlertSeverity? severity;
  final String? category;

  const LoadSystemAlertsEvent({
    this.activeOnly,
    this.severity,
    this.category,
  });

  @override
  List<Object?> get props => [activeOnly, severity, category];
}

/// 确认警报事件
class AcknowledgeAlertEvent extends SystemMonitoringEvent {
  final String alertId;

  const AcknowledgeAlertEvent(this.alertId);

  @override
  List<Object?> get props => [alertId];
}

/// 删除警报事件
class DeleteAlertEvent extends SystemMonitoringEvent {
  final String alertId;

  const DeleteAlertEvent(this.alertId);

  @override
  List<Object?> get props => [alertId];
}

/// 批量确认警报事件
class AcknowledgeMultipleAlertsEvent extends SystemMonitoringEvent {
  final List<String> alertIds;

  const AcknowledgeMultipleAlertsEvent(this.alertIds);

  @override
  List<Object?> get props => [alertIds];
}

/// 加载系统日志事件
class LoadSystemLogsEvent extends SystemMonitoringEvent {
  final DateTime? startTime;
  final DateTime? endTime;
  final LogLevel? level;
  final String? source;
  final String? category;
  final int? limit;

  const LoadSystemLogsEvent({
    this.startTime,
    this.endTime,
    this.level,
    this.source,
    this.category,
    this.limit,
  });

  @override
  List<Object?> get props => [startTime, endTime, level, source, category, limit];
}

/// 搜索日志事件
class SearchLogsEvent extends SystemMonitoringEvent {
  final String query;
  final DateTime? startTime;
  final DateTime? endTime;
  final LogLevel? level;
  final String? source;
  final int? limit;

  const SearchLogsEvent({
    required this.query,
    this.startTime,
    this.endTime,
    this.level,
    this.source,
    this.limit,
  });

  @override
  List<Object?> get props => [query, startTime, endTime, level, source, limit];
}

/// 清理日志事件
class CleanupLogsEvent extends SystemMonitoringEvent {
  final DateTime? beforeDate;
  final LogLevel? level;

  const CleanupLogsEvent({
    this.beforeDate,
    this.level,
  });

  @override
  List<Object?> get props => [beforeDate, level];
}

/// 加载运维任务事件
class LoadOperationTasksEvent extends SystemMonitoringEvent {
  final OperationTaskStatus? status;
  final OperationTaskType? type;

  const LoadOperationTasksEvent({
    this.status,
    this.type,
  });

  @override
  List<Object?> get props => [status, type];
}

/// 创建运维任务事件
class CreateOperationTaskEvent extends SystemMonitoringEvent {
  final String title;
  final String description;
  final OperationTaskType type;
  final DateTime? scheduledAt;
  final Map<String, dynamic> parameters;

  const CreateOperationTaskEvent({
    required this.title,
    required this.description,
    required this.type,
    this.scheduledAt,
    this.parameters = const {},
  });

  @override
  List<Object?> get props => [title, description, type, scheduledAt, parameters];
}

/// 执行运维任务事件
class ExecuteOperationTaskEvent extends SystemMonitoringEvent {
  final String taskId;

  const ExecuteOperationTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// 取消运维任务事件
class CancelOperationTaskEvent extends SystemMonitoringEvent {
  final String taskId;

  const CancelOperationTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// 批量执行任务事件
class ExecuteBatchTasksEvent extends SystemMonitoringEvent {
  final List<String> taskIds;

  const ExecuteBatchTasksEvent(this.taskIds);

  @override
  List<Object?> get props => [taskIds];
}

/// 运行系统诊断事件
class RunSystemDiagnosticsEvent extends SystemMonitoringEvent {
  const RunSystemDiagnosticsEvent();
}

/// 生成系统报告事件
class GenerateSystemReportEvent extends SystemMonitoringEvent {
  final DateTime? startTime;
  final DateTime? endTime;
  final List<String>? sections;

  const GenerateSystemReportEvent({
    this.startTime,
    this.endTime,
    this.sections,
  });

  @override
  List<Object?> get props => [startTime, endTime, sections];
}

/// 导出系统数据事件
class ExportSystemDataEvent extends SystemMonitoringEvent {
  final DateTime? startTime;
  final DateTime? endTime;
  final List<String>? dataTypes;

  const ExportSystemDataEvent({
    this.startTime,
    this.endTime,
    this.dataTypes,
  });

  @override
  List<Object?> get props => [startTime, endTime, dataTypes];
}

/// 刷新所有数据事件
class RefreshAllDataEvent extends SystemMonitoringEvent {
  const RefreshAllDataEvent();
} 