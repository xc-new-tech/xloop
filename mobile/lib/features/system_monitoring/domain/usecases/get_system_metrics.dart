import '../entities/system_metrics.dart';
import '../repositories/system_monitoring_repository.dart';

/// 获取系统指标用例
class GetSystemMetrics {
  final SystemMonitoringRepository repository;

  GetSystemMetrics(this.repository);

  /// 获取当前系统指标
  Future<SystemMetrics> getCurrentMetrics() async {
    return await repository.getCurrentMetrics();
  }

  /// 获取历史系统指标
  Future<List<SystemMetrics>> getHistoricalMetrics({
    DateTime? startTime,
    DateTime? endTime,
    Duration? interval,
  }) async {
    return await repository.getHistoricalMetrics(
      startTime: startTime,
      endTime: endTime,
      interval: interval,
    );
  }

  /// 开始实时监控
  Stream<SystemMetrics> startRealTimeMonitoring({
    Duration interval = const Duration(seconds: 30),
  }) {
    return repository.startMonitoring(interval: interval);
  }

  /// 停止监控
  Future<void> stopMonitoring() async {
    await repository.stopMonitoring();
  }
} 