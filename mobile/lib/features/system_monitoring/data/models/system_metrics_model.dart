import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/system_metrics.dart';

part 'system_metrics_model.g.dart';

@JsonSerializable()
class SystemMetricsModel extends SystemMetrics {
  const SystemMetricsModel({
    required super.id,
    required super.timestamp,
    required super.cpuUsage,
    required super.memoryUsage,
    required super.diskUsage,
    required super.networkLatency,
    required super.activeConnections,
    required super.throughput,
    required super.errorRate,
    required super.uptime,
    super.customMetrics = const {},
  });

  factory SystemMetricsModel.fromJson(Map<String, dynamic> json) =>
      _$SystemMetricsModelFromJson(json);

  Map<String, dynamic> toJson() => _$SystemMetricsModelToJson(this);

  factory SystemMetricsModel.fromEntity(SystemMetrics entity) {
    return SystemMetricsModel(
      id: entity.id,
      timestamp: entity.timestamp,
      cpuUsage: entity.cpuUsage,
      memoryUsage: entity.memoryUsage,
      diskUsage: entity.diskUsage,
      networkLatency: entity.networkLatency,
      activeConnections: entity.activeConnections,
      throughput: entity.throughput,
      errorRate: entity.errorRate,
      uptime: entity.uptime,
      customMetrics: entity.customMetrics,
    );
  }

  SystemMetrics toEntity() {
    return SystemMetrics(
      id: id,
      timestamp: timestamp,
      cpuUsage: cpuUsage,
      memoryUsage: memoryUsage,
      diskUsage: diskUsage,
      networkLatency: networkLatency,
      activeConnections: activeConnections,
      throughput: throughput,
      errorRate: errorRate,
      uptime: uptime,
      customMetrics: customMetrics,
    );
  }
}

@JsonSerializable()
class SystemAlertModel extends SystemAlert {
  const SystemAlertModel({
    required super.id,
    required super.severity,
    required super.title,
    required super.description,
    required super.category,
    required super.timestamp,
    required super.isActive,
    required super.isAcknowledged,
    super.source,
    super.metadata = const {},
  });

  factory SystemAlertModel.fromJson(Map<String, dynamic> json) =>
      _$SystemAlertModelFromJson(json);

  Map<String, dynamic> toJson() => _$SystemAlertModelToJson(this);

  factory SystemAlertModel.fromEntity(SystemAlert entity) {
    return SystemAlertModel(
      id: entity.id,
      severity: entity.severity,
      title: entity.title,
      description: entity.description,
      category: entity.category,
      timestamp: entity.timestamp,
      isActive: entity.isActive,
      isAcknowledged: entity.isAcknowledged,
      source: entity.source,
      metadata: entity.metadata,
    );
  }

  SystemAlert toEntity() {
    return SystemAlert(
      id: id,
      severity: severity,
      title: title,
      description: description,
      category: category,
      timestamp: timestamp,
      isActive: isActive,
      isAcknowledged: isAcknowledged,
      source: source,
      metadata: metadata,
    );
  }
}

@JsonSerializable()
class OperationTaskModel extends OperationTask {
  const OperationTaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.status,
    required super.createdAt,
    super.scheduledAt,
    super.startedAt,
    super.completedAt,
    super.result,
    super.errorMessage,
    super.parameters = const {},
  });

  factory OperationTaskModel.fromJson(Map<String, dynamic> json) =>
      _$OperationTaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$OperationTaskModelToJson(this);

  factory OperationTaskModel.fromEntity(OperationTask entity) {
    return OperationTaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      type: entity.type,
      status: entity.status,
      createdAt: entity.createdAt,
      scheduledAt: entity.scheduledAt,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
      result: entity.result,
      errorMessage: entity.errorMessage,
      parameters: entity.parameters,
    );
  }

  OperationTask toEntity() {
    return OperationTask(
      id: id,
      title: title,
      description: description,
      type: type,
      status: status,
      createdAt: createdAt,
      scheduledAt: scheduledAt,
      startedAt: startedAt,
      completedAt: completedAt,
      result: result,
      errorMessage: errorMessage,
      parameters: parameters,
    );
  }
} 