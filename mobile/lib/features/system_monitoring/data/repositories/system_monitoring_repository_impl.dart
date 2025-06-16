import 'dart:async';
import 'dart:math';
import '../../domain/entities/system_metrics.dart';
import '../../domain/repositories/system_monitoring_repository.dart';
import '../models/system_metrics_model.dart';

/// 系统监控仓储实现
class SystemMonitoringRepositoryImpl implements SystemMonitoringRepository {
  // 模拟数据存储
  final List<SystemMetrics> _metricsHistory = [];
  final List<SystemAlert> _alerts = [];
  final List<SystemLogEntry> _logs = [];
  final List<OperationTask> _operationTasks = [];
  final Map<String, dynamic> _systemConfig = {};
  
  StreamController<SystemMetrics>? _monitoringController;
  Timer? _monitoringTimer;

  SystemMonitoringRepositoryImpl() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // 初始化模拟数据
    final now = DateTime.now();
    
    // 添加一些历史指标
    for (int i = 0; i < 24; i++) {
      _metricsHistory.add(_generateMockMetrics(
        now.subtract(Duration(hours: i)),
      ));
    }

    // 添加一些警报
    _alerts.addAll([
      SystemAlert(
        id: 'alert_1',
        severity: AlertSeverity.high,
        title: '内存使用率过高',
        description: '系统内存使用率达到85%，建议立即处理',
        category: 'performance',
        timestamp: now.subtract(const Duration(minutes: 30)),
        isActive: true,
        isAcknowledged: false,
        source: 'system_monitor',
        metadata: {'threshold': 80, 'current': 85},
      ),
      SystemAlert(
        id: 'alert_2',
        severity: AlertSeverity.medium,
        title: 'API响应时间增加',
        description: '平均API响应时间超过500ms',
        category: 'api',
        timestamp: now.subtract(const Duration(hours: 1)),
        isActive: true,
        isAcknowledged: false,
        source: 'api_monitor',
        metadata: {'threshold': 500, 'current': 650},
      ),
    ]);

    // 添加一些日志
    _logs.addAll([
      SystemLogEntry(
        id: 'log_1',
        timestamp: now.subtract(const Duration(minutes: 5)),
        level: LogLevel.error,
        source: 'database',
        message: '数据库连接超时',
        category: 'database',
        context: {'connection_id': 'conn_123', 'timeout': 30},
      ),
      SystemLogEntry(
        id: 'log_2',
        timestamp: now.subtract(const Duration(minutes: 10)),
        level: LogLevel.warning,
        source: 'cache',
        message: '缓存命中率低于阈值',
        category: 'cache',
        context: {'hit_rate': 0.65, 'threshold': 0.8},
      ),
      SystemLogEntry(
        id: 'log_3',
        timestamp: now.subtract(const Duration(minutes: 15)),
        level: LogLevel.info,
        source: 'system',
        message: '系统启动完成',
        category: 'system',
        context: {'startup_time': 45.2},
      ),
    ]);

    // 添加一些运维任务
    _operationTasks.addAll([
      OperationTask(
        id: 'task_1',
        title: '数据库备份',
        description: '执行每日数据库备份',
        type: OperationTaskType.backup,
        status: OperationTaskStatus.completed,
        createdAt: now.subtract(const Duration(hours: 2)),
        startedAt: now.subtract(const Duration(hours: 2)),
        completedAt: now.subtract(const Duration(hours: 1, minutes: 30)),
        result: '备份成功，文件大小: 2.5GB',
      ),
      OperationTask(
        id: 'task_2',
        title: '缓存清理',
        description: '清理过期缓存数据',
        type: OperationTaskType.cleanup,
        status: OperationTaskStatus.running,
        createdAt: now.subtract(const Duration(minutes: 30)),
        startedAt: now.subtract(const Duration(minutes: 15)),
      ),
    ]);
  }

  SystemMetrics _generateMockMetrics(DateTime timestamp) {
    final random = Random();
    return SystemMetrics(
      id: timestamp.millisecondsSinceEpoch.toString(),
      timestamp: timestamp,
      cpuUsage: 20 + random.nextDouble() * 60,
      memoryUsage: 40 + random.nextDouble() * 40,
      diskUsage: 30 + random.nextDouble() * 30,
      networkLatency: 50 + random.nextDouble() * 100,
      activeConnections: 100 + random.nextInt(500),
      throughput: 1000 + random.nextDouble() * 2000,
      errorRate: random.nextDouble() * 5,
      uptime: Duration(
        days: 15 + random.nextInt(30),
        hours: random.nextInt(24),
        minutes: random.nextInt(60),
      ),
      customMetrics: {
        'cache_hit_rate': 0.8 + random.nextDouble() * 0.2,
        'queue_size': random.nextInt(100),
      },
    );
  }

  @override
  Future<SystemMetrics> getCurrentMetrics() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _generateMockMetrics(DateTime.now());
  }

  @override
  Future<List<SystemMetrics>> getHistoricalMetrics({
    DateTime? startTime,
    DateTime? endTime,
    Duration? interval,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    var filteredMetrics = _metricsHistory.where((metric) {
      if (startTime != null && metric.timestamp.isBefore(startTime)) {
        return false;
      }
      if (endTime != null && metric.timestamp.isAfter(endTime)) {
        return false;
      }
      return true;
    }).toList();

    filteredMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filteredMetrics;
  }

  @override
  Future<SystemHealth> getSystemHealth() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final checks = [
      HealthCheck(
        name: 'CPU使用率',
        category: 'performance',
        status: SystemHealthStatus.healthy,
        score: 85.0,
        description: 'CPU使用率正常',
        recommendation: '继续监控',
        timestamp: DateTime.now(),
      ),
      HealthCheck(
        name: '内存使用率',
        category: 'performance',
        status: SystemHealthStatus.warning,
        score: 65.0,
        description: '内存使用率偏高',
        recommendation: '考虑清理缓存或增加内存',
        timestamp: DateTime.now(),
      ),
      HealthCheck(
        name: '磁盘空间',
        category: 'storage',
        status: SystemHealthStatus.healthy,
        score: 90.0,
        description: '磁盘空间充足',
        timestamp: DateTime.now(),
      ),
    ];

    final overallScore = checks.map((c) => c.score).reduce((a, b) => a + b) / checks.length;
    final status = overallScore >= 80 
        ? SystemHealthStatus.healthy
        : overallScore >= 60
            ? SystemHealthStatus.warning
            : SystemHealthStatus.critical;

    return SystemHealth(
      status: status,
      overallScore: overallScore,
      checks: checks,
      lastUpdated: DateTime.now(),
      message: _getHealthMessage(status),
    );
  }

  String _getHealthMessage(SystemHealthStatus status) {
    switch (status) {
      case SystemHealthStatus.healthy:
        return '系统运行正常';
      case SystemHealthStatus.warning:
        return '系统存在一些需要关注的问题';
      case SystemHealthStatus.critical:
        return '系统存在严重问题，需要立即处理';
      case SystemHealthStatus.unknown:
        return '系统状态未知';
    }
  }

  @override
  Future<List<SystemAlert>> getSystemAlerts({
    bool? activeOnly,
    AlertSeverity? severity,
    String? category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return _alerts.where((alert) {
      if (activeOnly == true && !alert.isActive) return false;
      if (severity != null && alert.severity != severity) return false;
      if (category != null && alert.category != category) return false;
      return true;
    }).toList();
  }

  @override
  Future<void> createAlert(SystemAlert alert) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _alerts.add(alert);
  }

  @override
  Future<void> updateAlert(SystemAlert alert) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _alerts.indexWhere((a) => a.id == alert.id);
    if (index != -1) {
      _alerts[index] = alert;
    }
  }

  @override
  Future<void> deleteAlert(String alertId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _alerts.removeWhere((alert) => alert.id == alertId);
  }

  @override
  Future<void> acknowledgeAlert(String alertId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _alerts.indexWhere((alert) => alert.id == alertId);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(isAcknowledged: true);
    }
  }

  @override
  Future<List<SystemLogEntry>> getSystemLogs({
    DateTime? startTime,
    DateTime? endTime,
    LogLevel? level,
    String? source,
    String? category,
    int? limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    var filteredLogs = _logs.where((log) {
      if (startTime != null && log.timestamp.isBefore(startTime)) return false;
      if (endTime != null && log.timestamp.isAfter(endTime)) return false;
      if (level != null && log.level != level) return false;
      if (source != null && log.source != source) return false;
      if (category != null && log.category != category) return false;
      return true;
    }).toList();

    filteredLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    if (limit != null && filteredLogs.length > limit) {
      filteredLogs = filteredLogs.take(limit).toList();
    }

    return filteredLogs;
  }

  @override
  Future<void> addSystemLog(SystemLogEntry logEntry) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _logs.add(logEntry);
  }

  @override
  Future<void> cleanupLogs({
    DateTime? beforeDate,
    LogLevel? level,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    _logs.removeWhere((log) {
      if (beforeDate != null && log.timestamp.isAfter(beforeDate)) return false;
      if (level != null && log.level != level) return false;
      return true;
    });
  }

  @override
  Future<List<OperationTask>> getOperationTasks({
    OperationTaskStatus? status,
    OperationTaskType? type,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return _operationTasks.where((task) {
      if (status != null && task.status != status) return false;
      if (type != null && task.type != type) return false;
      return true;
    }).toList();
  }

  @override
  Future<OperationTask> createOperationTask(OperationTask task) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _operationTasks.add(task);
    return task;
  }

  @override
  Future<void> updateOperationTask(OperationTask task) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _operationTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _operationTasks[index] = task;
    }
  }

  @override
  Future<void> executeOperationTask(String taskId) async {
    await Future.delayed(const Duration(seconds: 2)); // 模拟执行时间
    
    final index = _operationTasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = _operationTasks[index];
      _operationTasks[index] = task.copyWith(
        status: OperationTaskStatus.running,
        startedAt: DateTime.now(),
      );
      
      // 模拟异步执行
      Future.delayed(const Duration(seconds: 3), () {
        final completedIndex = _operationTasks.indexWhere((t) => t.id == taskId);
        if (completedIndex != -1) {
          _operationTasks[completedIndex] = _operationTasks[completedIndex].copyWith(
            status: OperationTaskStatus.completed,
            completedAt: DateTime.now(),
            result: '任务执行成功',
          );
        }
      });
    }
  }

  @override
  Future<void> cancelOperationTask(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final index = _operationTasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _operationTasks[index] = _operationTasks[index].copyWith(
        status: OperationTaskStatus.cancelled,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getSystemConfiguration() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Map.from(_systemConfig);
  }

  @override
  Future<void> updateSystemConfiguration(Map<String, dynamic> config) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _systemConfig.addAll(config);
  }

  @override
  Future<Map<String, dynamic>> runSystemDiagnostics() async {
    await Future.delayed(const Duration(seconds: 3)); // 模拟诊断时间
    
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'overall_status': 'healthy',
      'checks': [
        {
          'name': '数据库连接',
          'status': 'ok',
          'response_time': '45ms',
        },
        {
          'name': 'API端点',
          'status': 'ok',
          'response_time': '120ms',
        },
        {
          'name': '缓存服务',
          'status': 'warning',
          'message': '命中率偏低',
        },
      ],
      'recommendations': [
        '优化数据库查询',
        '增加缓存预热',
        '监控内存使用',
      ],
    };
  }

  @override
  Future<String> generateSystemReport({
    DateTime? startTime,
    DateTime? endTime,
    List<String>? sections,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    final buffer = StringBuffer();
    buffer.writeln('=== 系统监控报告 ===');
    buffer.writeln('生成时间: ${DateTime.now()}');
    buffer.writeln('时间范围: ${startTime ?? '开始'} - ${endTime ?? '结束'}');
    buffer.writeln();
    
    if (sections?.contains('metrics') ?? true) {
      buffer.writeln('## 系统指标');
      buffer.writeln('- CPU使用率: 45.2%');
      buffer.writeln('- 内存使用率: 68.9%');
      buffer.writeln('- 磁盘使用率: 34.1%');
      buffer.writeln();
    }
    
    if (sections?.contains('alerts') ?? true) {
      buffer.writeln('## 系统警报');
      buffer.writeln('- 活跃警报: ${_alerts.where((a) => a.isActive).length}');
      buffer.writeln('- 已确认警报: ${_alerts.where((a) => a.isAcknowledged).length}');
      buffer.writeln();
    }
    
    if (sections?.contains('tasks') ?? true) {
      buffer.writeln('## 运维任务');
      buffer.writeln('- 总任务数: ${_operationTasks.length}');
      buffer.writeln('- 已完成: ${_operationTasks.where((t) => t.status == OperationTaskStatus.completed).length}');
      buffer.writeln('- 运行中: ${_operationTasks.where((t) => t.status == OperationTaskStatus.running).length}');
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  @override
  Future<String> exportSystemData({
    DateTime? startTime,
    DateTime? endTime,
    List<String>? dataTypes,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final data = <String, dynamic>{};
    
    if (dataTypes?.contains('metrics') ?? true) {
      data['metrics'] = _metricsHistory.map((m) => SystemMetricsModel.fromEntity(m).toJson()).toList();
    }
    
    if (dataTypes?.contains('alerts') ?? true) {
      data['alerts'] = _alerts.map((a) => SystemAlertModel.fromEntity(a).toJson()).toList();
    }
    
    if (dataTypes?.contains('tasks') ?? true) {
      data['tasks'] = _operationTasks.map((t) => OperationTaskModel.fromEntity(t).toJson()).toList();
    }
    
    return data.toString(); // 实际应用中应使用 json.encode
  }

  @override
  Stream<SystemMetrics> startMonitoring({Duration? interval}) {
    _monitoringController = StreamController<SystemMetrics>.broadcast();
    
    _monitoringTimer = Timer.periodic(
      interval ?? const Duration(seconds: 30),
      (timer) {
        final metrics = _generateMockMetrics(DateTime.now());
        _metricsHistory.insert(0, metrics);
        
        // 保持历史数据在合理范围内
        if (_metricsHistory.length > 100) {
          _metricsHistory.removeRange(100, _metricsHistory.length);
        }
        
        _monitoringController?.add(metrics);
      },
    );
    
    return _monitoringController!.stream;
  }

  @override
  Future<void> stopMonitoring() async {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    await _monitoringController?.close();
    _monitoringController = null;
  }

  void dispose() {
    stopMonitoring();
  }
} 