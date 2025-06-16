import '../entities/system_metrics.dart';
import '../repositories/system_monitoring_repository.dart';

/// 管理系统日志用例
class ManageSystemLogs {
  final SystemMonitoringRepository repository;

  ManageSystemLogs(this.repository);

  /// 获取系统日志
  Future<List<SystemLogEntry>> getLogs({
    DateTime? startTime,
    DateTime? endTime,
    LogLevel? level,
    String? source,
    String? category,
    int? limit,
  }) async {
    return await repository.getSystemLogs(
      startTime: startTime,
      endTime: endTime,
      level: level,
      source: source,
      category: category,
      limit: limit,
    );
  }

  /// 添加系统日志
  Future<void> addLog({
    required LogLevel level,
    required String source,
    required String message,
    String? category,
    Map<String, dynamic> context = const {},
    String? stackTrace,
  }) async {
    final logEntry = SystemLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      level: level,
      source: source,
      message: message,
      category: category,
      context: context,
      stackTrace: stackTrace,
    );

    await repository.addSystemLog(logEntry);
  }

  /// 清理系统日志
  Future<void> cleanupLogs({
    DateTime? beforeDate,
    LogLevel? level,
  }) async {
    await repository.cleanupLogs(
      beforeDate: beforeDate,
      level: level,
    );
  }

  /// 搜索日志
  Future<List<SystemLogEntry>> searchLogs({
    required String query,
    DateTime? startTime,
    DateTime? endTime,
    LogLevel? level,
    String? source,
    int? limit,
  }) async {
    final logs = await repository.getSystemLogs(
      startTime: startTime,
      endTime: endTime,
      level: level,
      source: source,
      limit: limit,
    );

    // 简单的文本搜索
    return logs.where((log) {
      return log.message.toLowerCase().contains(query.toLowerCase()) ||
          (log.category?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          log.source.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// 获取日志统计
  Future<Map<String, dynamic>> getLogStatistics({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final logs = await repository.getSystemLogs(
      startTime: startTime,
      endTime: endTime,
    );

    final statistics = <String, dynamic>{};
    
    // 按级别统计
    final levelCounts = <LogLevel, int>{};
    for (final level in LogLevel.values) {
      levelCounts[level] = 0;
    }
    
    // 按来源统计
    final sourceCounts = <String, int>{};
    
    // 按类别统计
    final categoryCounts = <String, int>{};

    for (final log in logs) {
      levelCounts[log.level] = (levelCounts[log.level] ?? 0) + 1;
      sourceCounts[log.source] = (sourceCounts[log.source] ?? 0) + 1;
      
      if (log.category != null) {
        categoryCounts[log.category!] = (categoryCounts[log.category!] ?? 0) + 1;
      }
    }

    statistics['total'] = logs.length;
    statistics['levelCounts'] = levelCounts;
    statistics['sourceCounts'] = sourceCounts;
    statistics['categoryCounts'] = categoryCounts;
    statistics['timeRange'] = {
      'start': startTime?.toIso8601String(),
      'end': endTime?.toIso8601String(),
    };

    return statistics;
  }

  /// 导出日志
  Future<String> exportLogs({
    DateTime? startTime,
    DateTime? endTime,
    LogLevel? level,
    String? source,
    String format = 'json',
  }) async {
    final logs = await repository.getSystemLogs(
      startTime: startTime,
      endTime: endTime,
      level: level,
      source: source,
    );

    switch (format.toLowerCase()) {
      case 'csv':
        return _exportToCsv(logs);
      case 'txt':
        return _exportToText(logs);
      case 'json':
      default:
        return _exportToJson(logs);
    }
  }

  String _exportToJson(List<SystemLogEntry> logs) {
    // 简化的JSON导出
    final data = logs.map((log) => {
      'id': log.id,
      'timestamp': log.timestamp.toIso8601String(),
      'level': log.level.name,
      'source': log.source,
      'message': log.message,
      'category': log.category,
      'context': log.context,
      'stackTrace': log.stackTrace,
    }).toList();
    
    return data.toString(); // 实际应用中应使用 json.encode
  }

  String _exportToCsv(List<SystemLogEntry> logs) {
    final buffer = StringBuffer();
    buffer.writeln('ID,Timestamp,Level,Source,Message,Category');
    
    for (final log in logs) {
      buffer.writeln('${log.id},${log.timestamp.toIso8601String()},${log.level.name},${log.source},"${log.message}",${log.category ?? ""}');
    }
    
    return buffer.toString();
  }

  String _exportToText(List<SystemLogEntry> logs) {
    final buffer = StringBuffer();
    
    for (final log in logs) {
      buffer.writeln('[${log.timestamp.toIso8601String()}] ${log.level.name.toUpperCase()} ${log.source}: ${log.message}');
      if (log.category != null) {
        buffer.writeln('  Category: ${log.category}');
      }
      if (log.stackTrace != null) {
        buffer.writeln('  Stack Trace: ${log.stackTrace}');
      }
      buffer.writeln();
    }
    
    return buffer.toString();
  }
} 