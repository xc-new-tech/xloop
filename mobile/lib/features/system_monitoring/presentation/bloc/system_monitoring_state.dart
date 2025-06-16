import 'package:equatable/equatable.dart';
import '../../domain/entities/system_metrics.dart';

/// 系统监控状态基类
abstract class SystemMonitoringState extends Equatable {
  const SystemMonitoringState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class SystemMonitoringInitial extends SystemMonitoringState {
  const SystemMonitoringInitial();
}

/// 加载中状态
class SystemMonitoringLoading extends SystemMonitoringState {
  final String? message;

  const SystemMonitoringLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// 加载成功状态
class SystemMonitoringLoaded extends SystemMonitoringState {
  final SystemMetrics? currentMetrics;
  final List<SystemMetrics> historicalMetrics;
  final SystemHealth? systemHealth;
  final List<SystemAlert> alerts;
  final List<SystemLogEntry> logs;
  final List<OperationTask> operationTasks;
  final bool isRealTimeMonitoring;
  final Map<String, dynamic>? diagnosticsResult;
  final String? systemReport;
  final String? exportedData;

  const SystemMonitoringLoaded({
    this.currentMetrics,
    this.historicalMetrics = const [],
    this.systemHealth,
    this.alerts = const [],
    this.logs = const [],
    this.operationTasks = const [],
    this.isRealTimeMonitoring = false,
    this.diagnosticsResult,
    this.systemReport,
    this.exportedData,
  });

  @override
  List<Object?> get props => [
        currentMetrics,
        historicalMetrics,
        systemHealth,
        alerts,
        logs,
        operationTasks,
        isRealTimeMonitoring,
        diagnosticsResult,
        systemReport,
        exportedData,
      ];

  SystemMonitoringLoaded copyWith({
    SystemMetrics? currentMetrics,
    List<SystemMetrics>? historicalMetrics,
    SystemHealth? systemHealth,
    List<SystemAlert>? alerts,
    List<SystemLogEntry>? logs,
    List<OperationTask>? operationTasks,
    bool? isRealTimeMonitoring,
    Map<String, dynamic>? diagnosticsResult,
    String? systemReport,
    String? exportedData,
  }) {
    return SystemMonitoringLoaded(
      currentMetrics: currentMetrics ?? this.currentMetrics,
      historicalMetrics: historicalMetrics ?? this.historicalMetrics,
      systemHealth: systemHealth ?? this.systemHealth,
      alerts: alerts ?? this.alerts,
      logs: logs ?? this.logs,
      operationTasks: operationTasks ?? this.operationTasks,
      isRealTimeMonitoring: isRealTimeMonitoring ?? this.isRealTimeMonitoring,
      diagnosticsResult: diagnosticsResult ?? this.diagnosticsResult,
      systemReport: systemReport ?? this.systemReport,
      exportedData: exportedData ?? this.exportedData,
    );
  }
}

/// 错误状态
class SystemMonitoringError extends SystemMonitoringState {
  final String message;
  final String? details;

  const SystemMonitoringError({
    required this.message,
    this.details,
  });

  @override
  List<Object?> get props => [message, details];
}

/// 操作成功状态
class SystemMonitoringOperationSuccess extends SystemMonitoringState {
  final String message;
  final String? operationType;

  const SystemMonitoringOperationSuccess({
    required this.message,
    this.operationType,
  });

  @override
  List<Object?> get props => [message, operationType];
}

/// 实时监控状态
class SystemMonitoringRealTimeUpdate extends SystemMonitoringState {
  final SystemMetrics metrics;

  const SystemMonitoringRealTimeUpdate(this.metrics);

  @override
  List<Object?> get props => [metrics];
}

/// 警报操作状态
class AlertOperationState extends SystemMonitoringState {
  final String message;
  final String alertId;
  final String operation; // acknowledge, delete, etc.

  const AlertOperationState({
    required this.message,
    required this.alertId,
    required this.operation,
  });

  @override
  List<Object?> get props => [message, alertId, operation];
}

/// 任务操作状态
class TaskOperationState extends SystemMonitoringState {
  final String message;
  final String taskId;
  final String operation; // execute, cancel, create, etc.

  const TaskOperationState({
    required this.message,
    required this.taskId,
    required this.operation,
  });

  @override
  List<Object?> get props => [message, taskId, operation];
}

/// 日志操作状态
class LogOperationState extends SystemMonitoringState {
  final String message;
  final String operation; // search, cleanup, export, etc.
  final List<SystemLogEntry>? searchResults;

  const LogOperationState({
    required this.message,
    required this.operation,
    this.searchResults,
  });

  @override
  List<Object?> get props => [message, operation, searchResults];
}

/// 系统诊断状态
class SystemDiagnosticsState extends SystemMonitoringState {
  final Map<String, dynamic> result;
  final bool isRunning;

  const SystemDiagnosticsState({
    required this.result,
    this.isRunning = false,
  });

  @override
  List<Object?> get props => [result, isRunning];
}

/// 报告生成状态
class ReportGenerationState extends SystemMonitoringState {
  final String report;
  final bool isGenerating;

  const ReportGenerationState({
    required this.report,
    this.isGenerating = false,
  });

  @override
  List<Object?> get props => [report, isGenerating];
}

/// 数据导出状态
class DataExportState extends SystemMonitoringState {
  final String exportedData;
  final bool isExporting;

  const DataExportState({
    required this.exportedData,
    this.isExporting = false,
  });

  @override
  List<Object?> get props => [exportedData, isExporting];
} 