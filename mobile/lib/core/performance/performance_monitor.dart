import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// 性能监控器
class PerformanceMonitor {
  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance {
    _instance ??= PerformanceMonitor._internal();
    return _instance!;
  }
  
  PerformanceMonitor._internal();
  
  final List<PerformanceMetric> _metrics = [];
  Timer? _memoryTimer;
  Timer? _frameTimer;
  
  bool _isMonitoring = false;
  
  /// 开始性能监控
  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    
    // 监控内存使用
    _startMemoryMonitoring();
    
    // 监控帧率
    if (!kIsWeb) {
      _startFrameMonitoring();
    }
    
    // 监控网络请求
    _startNetworkMonitoring();
    
    if (kDebugMode) {
      print('🔍 性能监控已启动');
    }
  }
  
  /// 停止性能监控
  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    _memoryTimer?.cancel();
    _frameTimer?.cancel();
    
    if (kDebugMode) {
      print('🔍 性能监控已停止');
    }
  }
  
  /// 记录自定义性能指标
  void recordMetric(String name, double value, {String? unit}) {
    final metric = PerformanceMetric(
      name: name,
      value: value,
      unit: unit ?? '',
      timestamp: DateTime.now(),
    );
    
    _metrics.add(metric);
    
    // 保持最近1000条记录
    if (_metrics.length > 1000) {
      _metrics.removeAt(0);
    }
    
    if (kDebugMode) {
      print('📊 性能指标: $name = $value ${unit ?? ''}');
    }
  }
  
  /// 开始计时
  PerformanceTimer startTimer(String name) {
    return PerformanceTimer(name, this);
  }
  
  /// 获取性能报告
  PerformanceReport getReport() {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    
    final recentMetrics = _metrics
        .where((metric) => metric.timestamp.isAfter(oneHourAgo))
        .toList();
    
    return PerformanceReport(
      timestamp: now,
      totalMetrics: _metrics.length,
      recentMetrics: recentMetrics,
      memoryUsage: _getMemoryUsage(),
      averageFrameTime: _getAverageFrameTime(),
      networkMetrics: _getNetworkMetrics(),
    );
  }
  
  /// 清理性能数据
  void clearMetrics() {
    _metrics.clear();
    if (kDebugMode) {
      print('🗑️ 性能数据已清理');
    }
  }
  
  void _startMemoryMonitoring() {
    _memoryTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _recordMemoryUsage();
    });
  }
  
  void _startFrameMonitoring() {
    // 使用WidgetsBinding监控帧率
    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
      _recordFrameTime(timeStamp);
    });
  }
  
  void _startNetworkMonitoring() {
    // 网络监控将在HTTP客户端中实现
  }
  
  void _recordMemoryUsage() {
    // 这里可以使用dart:io的ProcessInfo或其他方式获取内存使用
    if (Platform.isAndroid || Platform.isIOS) {
      // 移动平台内存监控
      recordMetric('memory_usage', _estimateMemoryUsage(), unit: 'MB');
    }
  }
  
  void _recordFrameTime(Duration timeStamp) {
    final frameTime = timeStamp.inMicroseconds / 1000.0;
    recordMetric('frame_time', frameTime, unit: 'ms');
  }
  
  double _estimateMemoryUsage() {
    // 简单的内存使用估算
    try {
      return ProcessInfo.currentRss / (1024 * 1024); // 转换为MB
    } catch (e) {
      return 0.0;
    }
  }
  
  MemoryUsageInfo _getMemoryUsage() {
    final memoryMetrics = _metrics
        .where((m) => m.name == 'memory_usage')
        .toList();
    
    if (memoryMetrics.isEmpty) {
      return const MemoryUsageInfo(current: 0, peak: 0, average: 0);
    }
    
    final current = memoryMetrics.last.value;
    final peak = memoryMetrics.map((m) => m.value).reduce((a, b) => a > b ? a : b);
    final average = memoryMetrics.map((m) => m.value).reduce((a, b) => a + b) / memoryMetrics.length;
    
    return MemoryUsageInfo(current: current, peak: peak, average: average);
  }
  
  double _getAverageFrameTime() {
    final frameMetrics = _metrics
        .where((m) => m.name == 'frame_time')
        .toList();
    
    if (frameMetrics.isEmpty) return 0.0;
    
    return frameMetrics.map((m) => m.value).reduce((a, b) => a + b) / frameMetrics.length;
  }
  
  NetworkMetrics _getNetworkMetrics() {
    final networkMetrics = _metrics
        .where((m) => m.name.startsWith('network_'))
        .toList();
    
    final requestCount = networkMetrics
        .where((m) => m.name == 'network_request_count')
        .length;
    
    final avgResponseTime = networkMetrics
        .where((m) => m.name == 'network_response_time')
        .map((m) => m.value)
        .fold(0.0, (a, b) => a + b) / (networkMetrics.isNotEmpty ? networkMetrics.length : 1);
    
    final errorCount = networkMetrics
        .where((m) => m.name == 'network_error_count')
        .length;
    
    return NetworkMetrics(
      requestCount: requestCount,
      averageResponseTime: avgResponseTime,
      errorCount: errorCount,
    );
  }
}

/// 性能指标数据类
class PerformanceMetric {
  final String name;
  final double value;
  final String unit;
  final DateTime timestamp;
  
  PerformanceMetric({
    required this.name,
    required this.value,
    required this.unit,
    required this.timestamp,
  });
  
  @override
  String toString() {
    return 'PerformanceMetric(name: $name, value: $value, unit: $unit, timestamp: $timestamp)';
  }
}

/// 性能计时器
class PerformanceTimer {
  final String name;
  final PerformanceMonitor monitor;
  final DateTime startTime;
  
  PerformanceTimer(this.name, this.monitor) : startTime = DateTime.now();
  
  /// 停止计时并记录
  void stop() {
    final duration = DateTime.now().difference(startTime);
    monitor.recordMetric(name, duration.inMilliseconds.toDouble(), unit: 'ms');
  }
}

/// 性能报告
class PerformanceReport {
  final DateTime timestamp;
  final int totalMetrics;
  final List<PerformanceMetric> recentMetrics;
  final MemoryUsageInfo memoryUsage;
  final double averageFrameTime;
  final NetworkMetrics networkMetrics;
  
  PerformanceReport({
    required this.timestamp,
    required this.totalMetrics,
    required this.recentMetrics,
    required this.memoryUsage,
    required this.averageFrameTime,
    required this.networkMetrics,
  });
  
  /// 获取性能评分 (0-100)
  double get performanceScore {
    double score = 100.0;
    
    // 内存使用评分 (< 100MB: 满分, > 500MB: 0分)
    if (memoryUsage.current > 500) {
      score -= 30;
    } else if (memoryUsage.current > 200) {
      score -= 15;
    }
    
    // 帧率评分 (< 16.67ms: 满分, > 33.33ms: 0分)
    if (averageFrameTime > 33.33) {
      score -= 30;
    } else if (averageFrameTime > 20) {
      score -= 15;
    }
    
    // 网络性能评分
    if (networkMetrics.averageResponseTime > 2000) {
      score -= 20;
    } else if (networkMetrics.averageResponseTime > 1000) {
      score -= 10;
    }
    
    // 错误率评分
    if (networkMetrics.requestCount > 0) {
      final errorRate = networkMetrics.errorCount / networkMetrics.requestCount;
      if (errorRate > 0.1) {
        score -= 20;
      } else if (errorRate > 0.05) {
        score -= 10;
      }
    }
    
    return score.clamp(0.0, 100.0);
  }
  
  /// 获取性能等级
  String get performanceGrade {
    final score = performanceScore;
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }
}

/// 内存使用信息
class MemoryUsageInfo {
  final double current;
  final double peak;
  final double average;
  
  const MemoryUsageInfo({
    required this.current,
    required this.peak,
    required this.average,
  });
}

/// 网络性能指标
class NetworkMetrics {
  final int requestCount;
  final double averageResponseTime;
  final int errorCount;
  
  const NetworkMetrics({
    required this.requestCount,
    required this.averageResponseTime,
    required this.errorCount,
  });
} 