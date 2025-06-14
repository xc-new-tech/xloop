import 'package:equatable/equatable.dart';

import '../../domain/entities/data_source_entity.dart';

/// 数据管理事件基类
abstract class DataManagementEvent extends Equatable {
  const DataManagementEvent();

  @override
  List<Object?> get props => [];
}

// ==================== 数据源管理事件 ====================

/// 加载数据源列表
class LoadDataSources extends DataManagementEvent {
  /// 搜索关键词
  final String? searchQuery;
  
  /// 数据源类型过滤
  final DataSourceType? typeFilter;
  
  /// 状态过滤
  final DataSourceStatus? statusFilter;
  
  /// 页面编号
  final int page;
  
  /// 每页大小
  final int pageSize;

  const LoadDataSources({
    this.searchQuery,
    this.typeFilter,
    this.statusFilter,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [
        searchQuery,
        typeFilter,
        statusFilter,
        page,
        pageSize,
      ];
}

/// 获取数据源详情
class GetDataSourceDetails extends DataManagementEvent {
  /// 数据源ID
  final String dataSourceId;

  const GetDataSourceDetails(this.dataSourceId);

  @override
  List<Object?> get props => [dataSourceId];
}

/// 创建数据源
class CreateDataSource extends DataManagementEvent {
  /// 数据源信息
  final DataSource dataSource;

  const CreateDataSource(this.dataSource);

  @override
  List<Object?> get props => [dataSource];
}

/// 更新数据源
class UpdateDataSource extends DataManagementEvent {
  /// 更新的数据源信息
  final DataSource dataSource;

  const UpdateDataSource(this.dataSource);

  @override
  List<Object?> get props => [dataSource];
}

/// 删除数据源
class DeleteDataSource extends DataManagementEvent {
  /// 数据源ID
  final String dataSourceId;

  const DeleteDataSource(this.dataSourceId);

  @override
  List<Object?> get props => [dataSourceId];
}

/// 测试数据源连接
class TestDataSourceConnection extends DataManagementEvent {
  /// 数据源ID或连接配置
  final String? dataSourceId;
  final ConnectionConfig? connectionConfig;

  const TestDataSourceConnection({
    this.dataSourceId,
    this.connectionConfig,
  });

  @override
  List<Object?> get props => [dataSourceId, connectionConfig];
}

/// 刷新数据源状态
class RefreshDataSourceStatus extends DataManagementEvent {
  /// 数据源ID（为空则刷新所有）
  final String? dataSourceId;

  const RefreshDataSourceStatus([this.dataSourceId]);

  @override
  List<Object?> get props => [dataSourceId];
}

// ==================== 数据同步事件 ====================

/// 开始同步
class StartDataSync extends DataManagementEvent {
  /// 数据源ID
  final String dataSourceId;
  
  /// 同步类型
  final SyncStrategy? syncType;
  
  /// 是否强制同步
  final bool force;

  const StartDataSync(
    this.dataSourceId, {
    this.syncType,
    this.force = false,
  });

  @override
  List<Object?> get props => [dataSourceId, syncType, force];
}

/// 停止同步
class StopDataSync extends DataManagementEvent {
  /// 同步记录ID
  final String syncRecordId;

  const StopDataSync(this.syncRecordId);

  @override
  List<Object?> get props => [syncRecordId];
}

/// 获取同步历史
class GetSyncHistory extends DataManagementEvent {
  /// 数据源ID
  final String? dataSourceId;
  
  /// 状态过滤
  final SyncStatus? statusFilter;
  
  /// 开始时间过滤
  final DateTime? startTime;
  
  /// 结束时间过滤
  final DateTime? endTime;
  
  /// 页面编号
  final int page;
  
  /// 每页大小
  final int pageSize;

  const GetSyncHistory({
    this.dataSourceId,
    this.statusFilter,
    this.startTime,
    this.endTime,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [
        dataSourceId,
        statusFilter,
        startTime,
        endTime,
        page,
        pageSize,
      ];
}

/// 获取同步详情
class GetSyncDetails extends DataManagementEvent {
  /// 同步记录ID
  final String syncRecordId;

  const GetSyncDetails(this.syncRecordId);

  @override
  List<Object?> get props => [syncRecordId];
}

/// 重试失败的同步
class RetrySyncRecord extends DataManagementEvent {
  /// 同步记录ID
  final String syncRecordId;

  const RetrySyncRecord(this.syncRecordId);

  @override
  List<Object?> get props => [syncRecordId];
}

// ==================== 数据操作事件 ====================

/// 导入数据
class ImportData extends DataManagementEvent {
  /// 数据源ID
  final String dataSourceId;
  
  /// 文件路径或数据
  final String dataPath;
  
  /// 导入配置
  final Map<String, dynamic> importConfig;

  const ImportData({
    required this.dataSourceId,
    required this.dataPath,
    this.importConfig = const {},
  });

  @override
  List<Object?> get props => [dataSourceId, dataPath, importConfig];
}

/// 导出数据
class ExportData extends DataManagementEvent {
  /// 数据源ID
  final String dataSourceId;
  
  /// 导出格式
  final String format;
  
  /// 导出配置
  final Map<String, dynamic> exportConfig;

  const ExportData({
    required this.dataSourceId,
    required this.format,
    this.exportConfig = const {},
  });

  @override
  List<Object?> get props => [dataSourceId, format, exportConfig];
}

/// 清理数据
class CleanupData extends DataManagementEvent {
  /// 数据源ID
  final String dataSourceId;
  
  /// 清理类型
  final CleanupType cleanupType;
  
  /// 清理配置
  final Map<String, dynamic> cleanupConfig;

  const CleanupData({
    required this.dataSourceId,
    required this.cleanupType,
    this.cleanupConfig = const {},
  });

  @override
  List<Object?> get props => [dataSourceId, cleanupType, cleanupConfig];
}

/// 数据备份
class BackupData extends DataManagementEvent {
  /// 数据源ID
  final String dataSourceId;
  
  /// 备份名称
  final String backupName;
  
  /// 备份配置
  final Map<String, dynamic> backupConfig;

  const BackupData({
    required this.dataSourceId,
    required this.backupName,
    this.backupConfig = const {},
  });

  @override
  List<Object?> get props => [dataSourceId, backupName, backupConfig];
}

/// 数据恢复
class RestoreData extends DataManagementEvent {
  /// 数据源ID
  final String dataSourceId;
  
  /// 备份ID
  final String backupId;
  
  /// 恢复配置
  final Map<String, dynamic> restoreConfig;

  const RestoreData({
    required this.dataSourceId,
    required this.backupId,
    this.restoreConfig = const {},
  });

  @override
  List<Object?> get props => [dataSourceId, backupId, restoreConfig];
}

// ==================== 监控和统计事件 ====================

/// 获取数据统计
class GetDataStatistics extends DataManagementEvent {
  /// 数据源ID（为空则获取全部）
  final String? dataSourceId;
  
  /// 统计时间范围
  final DateTime? startTime;
  final DateTime? endTime;

  const GetDataStatistics({
    this.dataSourceId,
    this.startTime,
    this.endTime,
  });

  @override
  List<Object?> get props => [dataSourceId, startTime, endTime];
}

/// 启动实时监控
class StartRealtimeMonitoring extends DataManagementEvent {
  /// 数据源ID列表
  final List<String> dataSourceIds;

  const StartRealtimeMonitoring(this.dataSourceIds);

  @override
  List<Object?> get props => [dataSourceIds];
}

/// 停止实时监控
class StopRealtimeMonitoring extends DataManagementEvent {
  const StopRealtimeMonitoring();
}

/// 获取系统健康状态
class GetSystemHealth extends DataManagementEvent {
  const GetSystemHealth();
}

// ==================== 配置管理事件 ====================

/// 更新同步配置
class UpdateSyncConfig extends DataManagementEvent {
  /// 数据源ID
  final String dataSourceId;
  
  /// 新的同步配置
  final SyncConfig syncConfig;

  const UpdateSyncConfig(this.dataSourceId, this.syncConfig);

  @override
  List<Object?> get props => [dataSourceId, syncConfig];
}

/// 批量操作
class BatchOperation extends DataManagementEvent {
  /// 操作类型
  final BatchOperationType operationType;
  
  /// 数据源ID列表
  final List<String> dataSourceIds;
  
  /// 操作参数
  final Map<String, dynamic> parameters;

  const BatchOperation({
    required this.operationType,
    required this.dataSourceIds,
    this.parameters = const {},
  });

  @override
  List<Object?> get props => [operationType, dataSourceIds, parameters];
}

/// 清理类型枚举
enum CleanupType {
  duplicates,
  outdated,
  invalid,
  all,
}

/// 批量操作类型枚举
enum BatchOperationType {
  enable,
  disable,
  sync,
  delete,
  updateConfig,
} 