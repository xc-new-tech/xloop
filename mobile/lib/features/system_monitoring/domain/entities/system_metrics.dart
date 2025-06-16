import 'package:equatable/equatable.dart';

/// 系统指标实体
class SystemMetrics extends Equatable {
  final String id;
  final DateTime timestamp;
  final double cpuUsage;
  final double memoryUsage;
  final double diskUsage;
  final double networkLatency;
  final int activeConnections;
  final double throughput;
  final double errorRate;
  final Duration uptime;
  final Map<String, dynamic> customMetrics;

  const SystemMetrics({
    required this.id,
    required this.timestamp,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.networkLatency,
    required this.activeConnections,
    required this.throughput,
    required this.errorRate,
    required this.uptime,
    this.customMetrics = const {},
  });

  @override
  List<Object?> get props => [
        id,
        timestamp,
        cpuUsage,
        memoryUsage,
        diskUsage,
        networkLatency,
        activeConnections,
        throughput,
        errorRate,
        uptime,
        customMetrics,
      ];

  SystemMetrics copyWith({
    String? id,
    DateTime? timestamp,
    double? cpuUsage,
    double? memoryUsage,
    double? diskUsage,
    double? networkLatency,
    int? activeConnections,
    double? throughput,
    double? errorRate,
    Duration? uptime,
    Map<String, dynamic>? customMetrics,
  }) {
    return SystemMetrics(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      diskUsage: diskUsage ?? this.diskUsage,
      networkLatency: networkLatency ?? this.networkLatency,
      activeConnections: activeConnections ?? this.activeConnections,
      throughput: throughput ?? this.throughput,
      errorRate: errorRate ?? this.errorRate,
      uptime: uptime ?? this.uptime,
      customMetrics: customMetrics ?? this.customMetrics,
    );
  }
}

/// 系统健康状态
enum SystemHealthStatus {
  healthy,
  warning,
  critical,
  unknown,
}

/// 系统健康检查结果
class SystemHealth extends Equatable {
  final SystemHealthStatus status;
  final double overallScore;
  final List<HealthCheck> checks;
  final DateTime lastUpdated;
  final String? message;

  const SystemHealth({
    required this.status,
    required this.overallScore,
    required this.checks,
    required this.lastUpdated,
    this.message,
  });

  @override
  List<Object?> get props => [
        status,
        overallScore,
        checks,
        lastUpdated,
        message,
      ];
}

/// 健康检查项
class HealthCheck extends Equatable {
  final String name;
  final String category;
  final SystemHealthStatus status;
  final double score;
  final String description;
  final String? recommendation;
  final DateTime timestamp;

  const HealthCheck({
    required this.name,
    required this.category,
    required this.status,
    required this.score,
    required this.description,
    this.recommendation,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        name,
        category,
        status,
        score,
        description,
        recommendation,
        timestamp,
      ];
}

/// 系统警报
class SystemAlert extends Equatable {
  final String id;
  final AlertSeverity severity;
  final String title;
  final String description;
  final String category;
  final DateTime timestamp;
  final bool isActive;
  final bool isAcknowledged;
  final String? source;
  final Map<String, dynamic> metadata;

  const SystemAlert({
    required this.id,
    required this.severity,
    required this.title,
    required this.description,
    required this.category,
    required this.timestamp,
    required this.isActive,
    required this.isAcknowledged,
    this.source,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        severity,
        title,
        description,
        category,
        timestamp,
        isActive,
        isAcknowledged,
        source,
        metadata,
      ];

  SystemAlert copyWith({
    String? id,
    AlertSeverity? severity,
    String? title,
    String? description,
    String? category,
    DateTime? timestamp,
    bool? isActive,
    bool? isAcknowledged,
    String? source,
    Map<String, dynamic>? metadata,
  }) {
    return SystemAlert(
      id: id ?? this.id,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      isActive: isActive ?? this.isActive,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      source: source ?? this.source,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 警报严重程度
enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

/// 系统日志条目
class SystemLogEntry extends Equatable {
  final String id;
  final DateTime timestamp;
  final LogLevel level;
  final String source;
  final String message;
  final String? category;
  final Map<String, dynamic> context;
  final String? stackTrace;

  const SystemLogEntry({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.source,
    required this.message,
    this.category,
    this.context = const {},
    this.stackTrace,
  });

  @override
  List<Object?> get props => [
        id,
        timestamp,
        level,
        source,
        message,
        category,
        context,
        stackTrace,
      ];
}

/// 日志级别
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// 运维任务
class OperationTask extends Equatable {
  final String id;
  final String title;
  final String description;
  final OperationTaskType type;
  final OperationTaskStatus status;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? result;
  final String? errorMessage;
  final Map<String, dynamic> parameters;

  const OperationTask({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.createdAt,
    this.scheduledAt,
    this.startedAt,
    this.completedAt,
    this.result,
    this.errorMessage,
    this.parameters = const {},
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        status,
        createdAt,
        scheduledAt,
        startedAt,
        completedAt,
        result,
        errorMessage,
        parameters,
      ];

  OperationTask copyWith({
    String? id,
    String? title,
    String? description,
    OperationTaskType? type,
    OperationTaskStatus? status,
    DateTime? createdAt,
    DateTime? scheduledAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? result,
    String? errorMessage,
    Map<String, dynamic>? parameters,
  }) {
    return OperationTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      parameters: parameters ?? this.parameters,
    );
  }
}

/// 运维任务类型
enum OperationTaskType {
  backup,
  cleanup,
  optimization,
  maintenance,
  deployment,
  monitoring,
  security,
}

/// 运维任务状态
enum OperationTaskStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
} 