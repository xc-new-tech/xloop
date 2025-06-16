import '../entities/system_metrics.dart';
import '../repositories/system_monitoring_repository.dart';

/// 管理系统警报用例
class ManageSystemAlerts {
  final SystemMonitoringRepository repository;

  ManageSystemAlerts(this.repository);

  /// 获取系统警报
  Future<List<SystemAlert>> getAlerts({
    bool? activeOnly,
    AlertSeverity? severity,
    String? category,
  }) async {
    return await repository.getSystemAlerts(
      activeOnly: activeOnly,
      severity: severity,
      category: category,
    );
  }

  /// 创建警报
  Future<void> createAlert(SystemAlert alert) async {
    await repository.createAlert(alert);
  }

  /// 确认警报
  Future<void> acknowledgeAlert(String alertId) async {
    await repository.acknowledgeAlert(alertId);
  }

  /// 删除警报
  Future<void> deleteAlert(String alertId) async {
    await repository.deleteAlert(alertId);
  }

  /// 批量确认警报
  Future<void> acknowledgeMultipleAlerts(List<String> alertIds) async {
    for (final alertId in alertIds) {
      await repository.acknowledgeAlert(alertId);
    }
  }

  /// 根据条件清理警报
  Future<void> cleanupAlerts({
    DateTime? beforeDate,
    AlertSeverity? maxSeverity,
    bool acknowledgedOnly = true,
  }) async {
    final alerts = await repository.getSystemAlerts();
    
    for (final alert in alerts) {
      bool shouldDelete = true;
      
      if (beforeDate != null && alert.timestamp.isAfter(beforeDate)) {
        shouldDelete = false;
      }
      
      if (maxSeverity != null && _getSeverityLevel(alert.severity) > _getSeverityLevel(maxSeverity)) {
        shouldDelete = false;
      }
      
      if (acknowledgedOnly && !alert.isAcknowledged) {
        shouldDelete = false;
      }
      
      if (shouldDelete) {
        await repository.deleteAlert(alert.id);
      }
    }
  }

  /// 获取严重程度级别
  int _getSeverityLevel(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return 1;
      case AlertSeverity.medium:
        return 2;
      case AlertSeverity.high:
        return 3;
      case AlertSeverity.critical:
        return 4;
    }
  }
} 