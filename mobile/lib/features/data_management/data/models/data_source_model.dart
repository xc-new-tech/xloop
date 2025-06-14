import '../../domain/entities/data_source_entity.dart';

/// 数据源模型
class DataSourceModel extends DataSource {
  const DataSourceModel({
    required super.id,
    required super.name,
    required super.type,
    required super.description,
    required super.connectionConfig,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.lastSyncAt,
    required super.stats,
    required super.syncConfig,
    super.isEnabled,
    super.tags,
  });

  /// 从JSON创建模型
  factory DataSourceModel.fromJson(Map<String, dynamic> json) {
    return DataSourceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: DataSourceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DataSourceType.custom,
      ),
      description: json['description'] as String? ?? '',
      connectionConfig: ConnectionConfigModel.fromJson(
        json['connection_config'] as Map<String, dynamic>? ?? {},
      ),
      status: DataSourceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DataSourceStatus.disconnected,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'] as String)
          : null,
      stats: DataSourceStatsModel.fromJson(
        json['stats'] as Map<String, dynamic>? ?? {},
      ),
      syncConfig: SyncConfigModel.fromJson(
        json['sync_config'] as Map<String, dynamic>? ?? {},
      ),
      isEnabled: json['is_enabled'] as bool? ?? true,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'description': description,
      'connection_config': (connectionConfig as ConnectionConfigModel).toJson(),
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'stats': (stats as DataSourceStatsModel).toJson(),
      'sync_config': (syncConfig as SyncConfigModel).toJson(),
      'is_enabled': isEnabled,
      'tags': tags,
    };
  }

  /// 转换为实体
  DataSource toEntity() {
    return DataSource(
      id: id,
      name: name,
      type: type,
      description: description,
      connectionConfig: connectionConfig,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastSyncAt: lastSyncAt,
      stats: stats,
      syncConfig: syncConfig,
      isEnabled: isEnabled,
      tags: tags,
    );
  }

  /// 从实体创建模型
  factory DataSourceModel.fromEntity(DataSource entity) {
    return DataSourceModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      description: entity.description,
      connectionConfig: entity.connectionConfig,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastSyncAt: entity.lastSyncAt,
      stats: entity.stats,
      syncConfig: entity.syncConfig,
      isEnabled: entity.isEnabled,
      tags: entity.tags,
    );
  }
}

/// 连接配置模型
class ConnectionConfigModel extends ConnectionConfig {
  const ConnectionConfigModel({
    super.host,
    super.port,
    super.username,
    super.password,
    super.database,
    super.apiKey,
    super.baseUrl,
    super.filePath,
    super.parameters,
    super.timeoutSeconds,
    super.useSSL,
  });

  factory ConnectionConfigModel.fromJson(Map<String, dynamic> json) {
    return ConnectionConfigModel(
      host: json['host'] as String?,
      port: json['port'] as int?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      database: json['database'] as String?,
      apiKey: json['api_key'] as String?,
      baseUrl: json['base_url'] as String?,
      filePath: json['file_path'] as String?,
      parameters: Map<String, dynamic>.from(
        json['parameters'] as Map<String, dynamic>? ?? {},
      ),
      timeoutSeconds: json['timeout_seconds'] as int? ?? 30,
      useSSL: json['use_ssl'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
      'username': username,
      'password': password,
      'database': database,
      'api_key': apiKey,
      'base_url': baseUrl,
      'file_path': filePath,
      'parameters': parameters,
      'timeout_seconds': timeoutSeconds,
      'use_ssl': useSSL,
    };
  }
}

/// 数据源统计信息模型
class DataSourceStatsModel extends DataSourceStats {
  const DataSourceStatsModel({
    super.totalRecords,
    super.todayRecords,
    super.dataSize,
    super.lastUpdateRecords,
    super.errorCount,
    super.successRate,
    super.avgResponseTime,
  });

  factory DataSourceStatsModel.fromJson(Map<String, dynamic> json) {
    return DataSourceStatsModel(
      totalRecords: json['total_records'] as int? ?? 0,
      todayRecords: json['today_records'] as int? ?? 0,
      dataSize: json['data_size'] as int? ?? 0,
      lastUpdateRecords: json['last_update_records'] as int? ?? 0,
      errorCount: json['error_count'] as int? ?? 0,
      successRate: (json['success_rate'] as num?)?.toDouble() ?? 0.0,
      avgResponseTime: (json['avg_response_time'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_records': totalRecords,
      'today_records': todayRecords,
      'data_size': dataSize,
      'last_update_records': lastUpdateRecords,
      'error_count': errorCount,
      'success_rate': successRate,
      'avg_response_time': avgResponseTime,
    };
  }
}

/// 同步配置模型
class SyncConfigModel extends SyncConfig {
  const SyncConfigModel({
    super.intervalMinutes,
    super.autoSync,
    super.strategy,
    super.conflictStrategy,
    super.maxRetries,
    super.batchSize,
    super.incrementalSync,
  });

  factory SyncConfigModel.fromJson(Map<String, dynamic> json) {
    return SyncConfigModel(
      intervalMinutes: json['interval_minutes'] as int? ?? 60,
      autoSync: json['auto_sync'] as bool? ?? false,
      strategy: SyncStrategy.values.firstWhere(
        (e) => e.name == json['strategy'],
        orElse: () => SyncStrategy.full,
      ),
      conflictStrategy: ConflictResolutionStrategy.values.firstWhere(
        (e) => e.name == json['conflict_strategy'],
        orElse: () => ConflictResolutionStrategy.sourceWins,
      ),
      maxRetries: json['max_retries'] as int? ?? 3,
      batchSize: json['batch_size'] as int? ?? 1000,
      incrementalSync: json['incremental_sync'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interval_minutes': intervalMinutes,
      'auto_sync': autoSync,
      'strategy': strategy.name,
      'conflict_strategy': conflictStrategy.name,
      'max_retries': maxRetries,
      'batch_size': batchSize,
      'incremental_sync': incrementalSync,
    };
  }
}

/// 同步记录模型
class SyncRecordModel extends SyncRecord {
  const SyncRecordModel({
    required super.id,
    required super.dataSourceId,
    required super.startTime,
    super.endTime,
    required super.status,
    super.syncedRecords,
    super.errorCount,
    super.errorMessage,
    required super.details,
  });

  factory SyncRecordModel.fromJson(Map<String, dynamic> json) {
    return SyncRecordModel(
      id: json['id'] as String,
      dataSourceId: json['data_source_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      status: SyncStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SyncStatus.pending,
      ),
      syncedRecords: json['synced_records'] as int? ?? 0,
      errorCount: json['error_count'] as int? ?? 0,
      errorMessage: json['error_message'] as String?,
      details: SyncDetailsModel.fromJson(
        json['details'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data_source_id': dataSourceId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'status': status.name,
      'synced_records': syncedRecords,
      'error_count': errorCount,
      'error_message': errorMessage,
      'details': (details as SyncDetailsModel).toJson(),
    };
  }

  SyncRecord toEntity() {
    return SyncRecord(
      id: id,
      dataSourceId: dataSourceId,
      startTime: startTime,
      endTime: endTime,
      status: status,
      syncedRecords: syncedRecords,
      errorCount: errorCount,
      errorMessage: errorMessage,
      details: details,
    );
  }

  factory SyncRecordModel.fromEntity(SyncRecord entity) {
    return SyncRecordModel(
      id: entity.id,
      dataSourceId: entity.dataSourceId,
      startTime: entity.startTime,
      endTime: entity.endTime,
      status: entity.status,
      syncedRecords: entity.syncedRecords,
      errorCount: entity.errorCount,
      errorMessage: entity.errorMessage,
      details: entity.details,
    );
  }
}

/// 同步详情模型
class SyncDetailsModel extends SyncDetails {
  const SyncDetailsModel({
    super.insertedCount,
    super.updatedCount,
    super.deletedCount,
    super.skippedCount,
    super.durationMs,
    super.bytesTransferred,
    super.recordsPerSecond,
  });

  factory SyncDetailsModel.fromJson(Map<String, dynamic> json) {
    return SyncDetailsModel(
      insertedCount: json['inserted_count'] as int? ?? 0,
      updatedCount: json['updated_count'] as int? ?? 0,
      deletedCount: json['deleted_count'] as int? ?? 0,
      skippedCount: json['skipped_count'] as int? ?? 0,
      durationMs: json['duration_ms'] as int? ?? 0,
      bytesTransferred: json['bytes_transferred'] as int? ?? 0,
      recordsPerSecond: (json['records_per_second'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inserted_count': insertedCount,
      'updated_count': updatedCount,
      'deleted_count': deletedCount,
      'skipped_count': skippedCount,
      'duration_ms': durationMs,
      'bytes_transferred': bytesTransferred,
      'records_per_second': recordsPerSecond,
    };
  }
} 