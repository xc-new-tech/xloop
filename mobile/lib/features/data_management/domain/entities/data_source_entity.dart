import 'package:equatable/equatable.dart';

/// 数据源实体
class DataSource extends Equatable {
  /// 数据源ID
  final String id;
  
  /// 数据源名称
  final String name;
  
  /// 数据源类型
  final DataSourceType type;
  
  /// 数据源描述
  final String description;
  
  /// 连接配置
  final ConnectionConfig connectionConfig;
  
  /// 数据源状态
  final DataSourceStatus status;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime updatedAt;
  
  /// 最后同步时间
  final DateTime? lastSyncAt;
  
  /// 数据量统计
  final DataSourceStats stats;
  
  /// 同步配置
  final SyncConfig syncConfig;
  
  /// 是否启用
  final bool isEnabled;
  
  /// 标签
  final List<String> tags;

  const DataSource({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.connectionConfig,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncAt,
    required this.stats,
    required this.syncConfig,
    this.isEnabled = true,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        description,
        connectionConfig,
        status,
        createdAt,
        updatedAt,
        lastSyncAt,
        stats,
        syncConfig,
        isEnabled,
        tags,
      ];
}

/// 数据源类型枚举
enum DataSourceType {
  database,
  api,
  file,
  cloud,
  realtime,
  custom;

  String get displayName {
    switch (this) {
      case DataSourceType.database:
        return '数据库';
      case DataSourceType.api:
        return 'API接口';
      case DataSourceType.file:
        return '文件系统';
      case DataSourceType.cloud:
        return '云存储';
      case DataSourceType.realtime:
        return '实时流';
      case DataSourceType.custom:
        return '自定义';
    }
  }
}

/// 数据源状态枚举
enum DataSourceStatus {
  connected,
  disconnected,
  syncing,
  error,
  maintenance;

  String get displayName {
    switch (this) {
      case DataSourceStatus.connected:
        return '已连接';
      case DataSourceStatus.disconnected:
        return '未连接';
      case DataSourceStatus.syncing:
        return '同步中';
      case DataSourceStatus.error:
        return '错误';
      case DataSourceStatus.maintenance:
        return '维护中';
    }
  }
}

/// 连接配置
class ConnectionConfig extends Equatable {
  /// 主机地址
  final String? host;
  
  /// 端口
  final int? port;
  
  /// 用户名
  final String? username;
  
  /// 密码（加密存储）
  final String? password;
  
  /// 数据库名称
  final String? database;
  
  /// API密钥
  final String? apiKey;
  
  /// API基础URL
  final String? baseUrl;
  
  /// 文件路径
  final String? filePath;
  
  /// 其他参数
  final Map<String, dynamic> parameters;
  
  /// 连接超时时间（秒）
  final int timeoutSeconds;
  
  /// 是否使用SSL
  final bool useSSL;

  const ConnectionConfig({
    this.host,
    this.port,
    this.username,
    this.password,
    this.database,
    this.apiKey,
    this.baseUrl,
    this.filePath,
    this.parameters = const {},
    this.timeoutSeconds = 30,
    this.useSSL = false,
  });

  @override
  List<Object?> get props => [
        host,
        port,
        username,
        password,
        database,
        apiKey,
        baseUrl,
        filePath,
        parameters,
        timeoutSeconds,
        useSSL,
      ];
}

/// 数据源统计信息
class DataSourceStats extends Equatable {
  /// 总记录数
  final int totalRecords;
  
  /// 今日新增记录数
  final int todayRecords;
  
  /// 数据大小（字节）
  final int dataSize;
  
  /// 最后更新记录数
  final int lastUpdateRecords;
  
  /// 错误次数
  final int errorCount;
  
  /// 成功率
  final double successRate;
  
  /// 平均响应时间（毫秒）
  final double avgResponseTime;

  const DataSourceStats({
    this.totalRecords = 0,
    this.todayRecords = 0,
    this.dataSize = 0,
    this.lastUpdateRecords = 0,
    this.errorCount = 0,
    this.successRate = 0.0,
    this.avgResponseTime = 0.0,
  });

  @override
  List<Object?> get props => [
        totalRecords,
        todayRecords,
        dataSize,
        lastUpdateRecords,
        errorCount,
        successRate,
        avgResponseTime,
      ];
}

/// 同步配置
class SyncConfig extends Equatable {
  /// 同步间隔（分钟）
  final int intervalMinutes;
  
  /// 是否启用自动同步
  final bool autoSync;
  
  /// 同步策略
  final SyncStrategy strategy;
  
  /// 冲突解决策略
  final ConflictResolutionStrategy conflictStrategy;
  
  /// 最大重试次数
  final int maxRetries;
  
  /// 批量大小
  final int batchSize;
  
  /// 是否增量同步
  final bool incrementalSync;

  const SyncConfig({
    this.intervalMinutes = 60,
    this.autoSync = false,
    this.strategy = SyncStrategy.full,
    this.conflictStrategy = ConflictResolutionStrategy.sourceWins,
    this.maxRetries = 3,
    this.batchSize = 1000,
    this.incrementalSync = true,
  });

  @override
  List<Object?> get props => [
        intervalMinutes,
        autoSync,
        strategy,
        conflictStrategy,
        maxRetries,
        batchSize,
        incrementalSync,
      ];
}

/// 同步策略枚举
enum SyncStrategy {
  full,
  incremental,
  realtime;

  String get displayName {
    switch (this) {
      case SyncStrategy.full:
        return '完全同步';
      case SyncStrategy.incremental:
        return '增量同步';
      case SyncStrategy.realtime:
        return '实时同步';
    }
  }
}

/// 冲突解决策略枚举
enum ConflictResolutionStrategy {
  sourceWins,
  targetWins,
  manual,
  newest;

  String get displayName {
    switch (this) {
      case ConflictResolutionStrategy.sourceWins:
        return '源优先';
      case ConflictResolutionStrategy.targetWins:
        return '目标优先';
      case ConflictResolutionStrategy.manual:
        return '手动解决';
      case ConflictResolutionStrategy.newest:
        return '最新优先';
    }
  }
}

/// 数据同步记录
class SyncRecord extends Equatable {
  /// 同步记录ID
  final String id;
  
  /// 数据源ID
  final String dataSourceId;
  
  /// 开始时间
  final DateTime startTime;
  
  /// 结束时间
  final DateTime? endTime;
  
  /// 同步状态
  final SyncStatus status;
  
  /// 同步的记录数
  final int syncedRecords;
  
  /// 错误数
  final int errorCount;
  
  /// 错误信息
  final String? errorMessage;
  
  /// 同步详情
  final SyncDetails details;

  const SyncRecord({
    required this.id,
    required this.dataSourceId,
    required this.startTime,
    this.endTime,
    required this.status,
    this.syncedRecords = 0,
    this.errorCount = 0,
    this.errorMessage,
    required this.details,
  });

  @override
  List<Object?> get props => [
        id,
        dataSourceId,
        startTime,
        endTime,
        status,
        syncedRecords,
        errorCount,
        errorMessage,
        details,
      ];
}

/// 同步状态枚举
enum SyncStatus {
  pending,
  running,
  completed,
  failed,
  cancelled;

  String get displayName {
    switch (this) {
      case SyncStatus.pending:
        return '等待中';
      case SyncStatus.running:
        return '运行中';
      case SyncStatus.completed:
        return '已完成';
      case SyncStatus.failed:
        return '失败';
      case SyncStatus.cancelled:
        return '已取消';
    }
  }
}

/// 同步详情
class SyncDetails extends Equatable {
  /// 插入记录数
  final int insertedCount;
  
  /// 更新记录数
  final int updatedCount;
  
  /// 删除记录数
  final int deletedCount;
  
  /// 跳过记录数
  final int skippedCount;
  
  /// 同步耗时（毫秒）
  final int durationMs;
  
  /// 数据传输大小（字节）
  final int bytesTransferred;
  
  /// 处理速度（记录/秒）
  final double recordsPerSecond;

  const SyncDetails({
    this.insertedCount = 0,
    this.updatedCount = 0,
    this.deletedCount = 0,
    this.skippedCount = 0,
    this.durationMs = 0,
    this.bytesTransferred = 0,
    this.recordsPerSecond = 0.0,
  });

  @override
  List<Object?> get props => [
        insertedCount,
        updatedCount,
        deletedCount,
        skippedCount,
        durationMs,
        bytesTransferred,
        recordsPerSecond,
      ];
} 