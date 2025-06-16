// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_metrics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemMetricsModel _$SystemMetricsModelFromJson(Map<String, dynamic> json) =>
    SystemMetricsModel(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      cpuUsage: (json['cpuUsage'] as num).toDouble(),
      memoryUsage: (json['memoryUsage'] as num).toDouble(),
      diskUsage: (json['diskUsage'] as num).toDouble(),
      networkLatency: (json['networkLatency'] as num).toDouble(),
      activeConnections: (json['activeConnections'] as num).toInt(),
      throughput: (json['throughput'] as num).toDouble(),
      errorRate: (json['errorRate'] as num).toDouble(),
      uptime: Duration(microseconds: (json['uptime'] as num).toInt()),
      customMetrics: json['customMetrics'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$SystemMetricsModelToJson(SystemMetricsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'cpuUsage': instance.cpuUsage,
      'memoryUsage': instance.memoryUsage,
      'diskUsage': instance.diskUsage,
      'networkLatency': instance.networkLatency,
      'activeConnections': instance.activeConnections,
      'throughput': instance.throughput,
      'errorRate': instance.errorRate,
      'uptime': instance.uptime.inMicroseconds,
      'customMetrics': instance.customMetrics,
    };

SystemAlertModel _$SystemAlertModelFromJson(Map<String, dynamic> json) =>
    SystemAlertModel(
      id: json['id'] as String,
      severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isActive: json['isActive'] as bool,
      isAcknowledged: json['isAcknowledged'] as bool,
      source: json['source'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$SystemAlertModelToJson(SystemAlertModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'timestamp': instance.timestamp.toIso8601String(),
      'isActive': instance.isActive,
      'isAcknowledged': instance.isAcknowledged,
      'source': instance.source,
      'metadata': instance.metadata,
    };

const _$AlertSeverityEnumMap = {
  AlertSeverity.low: 'low',
  AlertSeverity.medium: 'medium',
  AlertSeverity.high: 'high',
  AlertSeverity.critical: 'critical',
};

OperationTaskModel _$OperationTaskModelFromJson(Map<String, dynamic> json) =>
    OperationTaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$OperationTaskTypeEnumMap, json['type']),
      status: $enumDecode(_$OperationTaskStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledAt: json['scheduledAt'] == null
          ? null
          : DateTime.parse(json['scheduledAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      result: json['result'] as String?,
      errorMessage: json['errorMessage'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$OperationTaskModelToJson(OperationTaskModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$OperationTaskTypeEnumMap[instance.type]!,
      'status': _$OperationTaskStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'result': instance.result,
      'errorMessage': instance.errorMessage,
      'parameters': instance.parameters,
    };

const _$OperationTaskTypeEnumMap = {
  OperationTaskType.backup: 'backup',
  OperationTaskType.cleanup: 'cleanup',
  OperationTaskType.optimization: 'optimization',
  OperationTaskType.maintenance: 'maintenance',
  OperationTaskType.deployment: 'deployment',
  OperationTaskType.monitoring: 'monitoring',
  OperationTaskType.security: 'security',
};

const _$OperationTaskStatusEnumMap = {
  OperationTaskStatus.pending: 'pending',
  OperationTaskStatus.running: 'running',
  OperationTaskStatus.completed: 'completed',
  OperationTaskStatus.failed: 'failed',
  OperationTaskStatus.cancelled: 'cancelled',
};
