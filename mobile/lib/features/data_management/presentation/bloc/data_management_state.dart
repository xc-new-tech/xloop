import 'package:equatable/equatable.dart';

/// 数据管理状态基类
abstract class DataManagementState extends Equatable {
  const DataManagementState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class DataManagementInitial extends DataManagementState {}

/// 加载中状态
class DataManagementLoading extends DataManagementState {}

/// 加载完成状态
class DataManagementLoaded extends DataManagementState {
  final StorageOverview storageOverview;
  final DataQuality dataQuality;
  final BackupStatus backupStatus;
  final SyncStatus syncStatus;
  final List<AuditLog> auditLogs;
  final List<dynamic>? backupHistory;
  final List<dynamic>? syncHistory;

  const DataManagementLoaded({
    required this.storageOverview,
    required this.dataQuality,
    required this.backupStatus,
    required this.syncStatus,
    required this.auditLogs,
    this.backupHistory,
    this.syncHistory,
  });

  @override
  List<Object?> get props => [
        storageOverview,
        dataQuality,
        backupStatus,
        syncStatus,
        auditLogs,
        backupHistory,
        syncHistory,
      ];
}

/// 错误状态
class DataManagementError extends DataManagementState {
  final String message;

  const DataManagementError(this.message);

  @override
  List<Object?> get props => [message];
}

/// 存储概览数据模型
class StorageOverview extends Equatable {
  final int totalSize;
  final int usedSize;
  final int availableSize;
  final int documentsCount;
  final int knowledgeBasesCount;
  final int conversationsCount;
  final DateTime lastUpdated;

  const StorageOverview({
    required this.totalSize,
    required this.usedSize,
    required this.availableSize,
    required this.documentsCount,
    required this.knowledgeBasesCount,
    required this.conversationsCount,
    required this.lastUpdated,
  });

  double get usagePercentage => totalSize > 0 ? (usedSize / totalSize) * 100 : 0;

  String get formattedTotalSize => _formatBytes(totalSize);
  String get formattedUsedSize => _formatBytes(usedSize);
  String get formattedAvailableSize => _formatBytes(availableSize);

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  List<Object?> get props => [
        totalSize,
        usedSize,
        availableSize,
        documentsCount,
        knowledgeBasesCount,
        conversationsCount,
        lastUpdated,
      ];
}

/// 数据质量数据模型
class DataQuality extends Equatable {
  final double overallScore;
  final double completenessScore;
  final double accuracyScore;
  final double consistencyScore;
  final double validityScore;
  final int issuesCount;
  final DateTime lastAnalyzed;

  const DataQuality({
    required this.overallScore,
    required this.completenessScore,
    required this.accuracyScore,
    required this.consistencyScore,
    required this.validityScore,
    required this.issuesCount,
    required this.lastAnalyzed,
  });

  String get overallGrade {
    if (overallScore >= 90) return 'A';
    if (overallScore >= 80) return 'B';
    if (overallScore >= 70) return 'C';
    if (overallScore >= 60) return 'D';
    return 'F';
  }

  @override
  List<Object?> get props => [
        overallScore,
        completenessScore,
        accuracyScore,
        consistencyScore,
        validityScore,
        issuesCount,
        lastAnalyzed,
      ];
}

/// 备份状态数据模型
class BackupStatus extends Equatable {
  final DateTime? lastBackupTime;
  final DateTime? nextBackupTime;
  final int backupSize;
  final bool isAutoBackupEnabled;
  final BackupFrequency backupFrequency;
  final String backupLocation;
  final BackupStatusType status;

  const BackupStatus({
    this.lastBackupTime,
    this.nextBackupTime,
    required this.backupSize,
    required this.isAutoBackupEnabled,
    required this.backupFrequency,
    required this.backupLocation,
    required this.status,
  });

  String get formattedBackupSize => StorageOverview._formatBytes(backupSize);

  @override
  List<Object?> get props => [
        lastBackupTime,
        nextBackupTime,
        backupSize,
        isAutoBackupEnabled,
        backupFrequency,
        backupLocation,
        status,
      ];
}

/// 备份频率枚举
enum BackupFrequency {
  hourly('每小时'),
  daily('每天'),
  weekly('每周'),
  monthly('每月'),
  manual('手动');

  const BackupFrequency(this.displayName);
  final String displayName;
}

/// 备份状态类型枚举
enum BackupStatusType {
  completed('已完成'),
  inProgress('进行中'),
  failed('失败'),
  scheduled('已计划'),
  disabled('已禁用');

  const BackupStatusType(this.displayName);
  final String displayName;
}

/// 同步状态数据模型
class SyncStatus extends Equatable {
  final DateTime? lastSyncTime;
  final DateTime? nextSyncTime;
  final bool isAutoSyncEnabled;
  final SyncFrequency syncFrequency;
  final int pendingChanges;
  final SyncStatusType status;

  const SyncStatus({
    this.lastSyncTime,
    this.nextSyncTime,
    required this.isAutoSyncEnabled,
    required this.syncFrequency,
    required this.pendingChanges,
    required this.status,
  });

  @override
  List<Object?> get props => [
        lastSyncTime,
        nextSyncTime,
        isAutoSyncEnabled,
        syncFrequency,
        pendingChanges,
        status,
      ];
}

/// 同步频率枚举
enum SyncFrequency {
  realTime('实时'),
  hourly('每小时'),
  daily('每天'),
  manual('手动');

  const SyncFrequency(this.displayName);
  final String displayName;
}

/// 同步状态类型枚举
enum SyncStatusType {
  synced('已同步'),
  syncing('同步中'),
  pending('待同步'),
  failed('同步失败'),
  offline('离线');

  const SyncStatusType(this.displayName);
  final String displayName;
}

/// 审计日志数据模型
class AuditLog extends Equatable {
  final String id;
  final String action;
  final String description;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final Map<String, dynamic> details;

  const AuditLog({
    required this.id,
    required this.action,
    required this.description,
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.details,
  });

  @override
  List<Object?> get props => [
        id,
        action,
        description,
        userId,
        userName,
        timestamp,
        details,
      ];
} 