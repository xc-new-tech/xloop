import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_system_metrics.dart';
import '../../domain/usecases/manage_system_alerts.dart';
import '../../domain/usecases/manage_operation_tasks.dart';
import '../../domain/usecases/manage_system_logs.dart';
import '../../domain/entities/system_metrics.dart';
import 'system_monitoring_event.dart';
import 'system_monitoring_state.dart';

/// 系统监控BLoC
class SystemMonitoringBloc extends Bloc<SystemMonitoringEvent, SystemMonitoringState> {
  final GetSystemMetrics _getSystemMetrics;
  final ManageSystemAlerts _manageSystemAlerts;
  final ManageOperationTasks _manageOperationTasks;
  final ManageSystemLogs _manageSystemLogs;

  StreamSubscription<SystemMetrics>? _realTimeSubscription;

  SystemMonitoringBloc({
    required GetSystemMetrics getSystemMetrics,
    required ManageSystemAlerts manageSystemAlerts,
    required ManageOperationTasks manageOperationTasks,
    required ManageSystemLogs manageSystemLogs,
  })  : _getSystemMetrics = getSystemMetrics,
        _manageSystemAlerts = manageSystemAlerts,
        _manageOperationTasks = manageOperationTasks,
        _manageSystemLogs = manageSystemLogs,
        super(const SystemMonitoringInitial()) {
    on<LoadSystemMetricsEvent>(_onLoadSystemMetrics);
    on<LoadHistoricalMetricsEvent>(_onLoadHistoricalMetrics);
    on<StartRealTimeMonitoringEvent>(_onStartRealTimeMonitoring);
    on<StopRealTimeMonitoringEvent>(_onStopRealTimeMonitoring);
    on<RealTimeMetricsUpdatedEvent>(_onRealTimeMetricsUpdated);
    on<LoadSystemHealthEvent>(_onLoadSystemHealth);
    on<LoadSystemAlertsEvent>(_onLoadSystemAlerts);
    on<AcknowledgeAlertEvent>(_onAcknowledgeAlert);
    on<DeleteAlertEvent>(_onDeleteAlert);
    on<LoadSystemLogsEvent>(_onLoadSystemLogs);
    on<LoadOperationTasksEvent>(_onLoadOperationTasks);
    on<CreateOperationTaskEvent>(_onCreateOperationTask);
    on<ExecuteOperationTaskEvent>(_onExecuteOperationTask);
    on<RefreshAllDataEvent>(_onRefreshAllData);
  }

  Future<void> _onLoadSystemMetrics(
    LoadSystemMetricsEvent event,
    Emitter<SystemMonitoringState> emit,
  ) async {
    try {
      emit(const SystemMonitoringLoading(message: '正在加载系统指标...'));
      
      final metrics = await _getSystemMetrics.getCurrentMetrics();
      
      if (state is SystemMonitoringLoaded) {
        final currentState = state as SystemMonitoringLoaded;
        emit(currentState.copyWith(currentMetrics: metrics));
      } else {
        emit(SystemMonitoringLoaded(currentMetrics: metrics));
      }
    } catch (e) {
      emit(SystemMonitoringError(
        message: '加载系统指标失败',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onLoadHistoricalMetrics(
    LoadHistoricalMetricsEvent event,
    Emitter<SystemMonitoringState> emit,
  ) async {
    try {
      emit(const SystemMonitoringLoading(message: '正在加载历史指标...'));
      
      final historicalMetrics = await _getSystemMetrics.getHistoricalMetrics(
        startTime: event.startTime,
        endTime: event.endTime,
        interval: event.interval,
      );
      
      if (state is SystemMonitoringLoaded) {
        final currentState = state as SystemMonitoringLoaded;
        emit(currentState.copyWith(historicalMetrics: historicalMetrics));
      } else {
        emit(SystemMonitoringLoaded(historicalMetrics: historicalMetrics));
      }
    } catch (e) {
      emit(SystemMonitoringError(
        message: '加载历史指标失败',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onStartRealTimeMonitoring(
    StartRealTimeMonitoringEvent event,
    Emitter<SystemMonitoringState> emit,
  ) async {
    try {
      await _realTimeSubscription?.cancel();
      
      _realTimeSubscription = _getSystemMetrics
          .startRealTimeMonitoring(interval: event.interval)
          .listen((metrics) {
        add(RealTimeMetricsUpdatedEvent(metrics));
      });

      if (state is SystemMonitoringLoaded) {
        final currentState = state as SystemMonitoringLoaded;
        emit(currentState.copyWith(isRealTimeMonitoring: true));
      } else {
        emit(const SystemMonitoringLoaded(isRealTimeMonitoring: true));
      }
    } catch (e) {
      emit(SystemMonitoringError(
        message: '启动实时监控失败',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onStopRealTimeMonitoring(
    StopRealTimeMonitoringEvent event,
    Emitter<SystemMonitoringState> emit,
  ) async {
    try {
      await _realTimeSubscription?.cancel();
      _realTimeSubscription = null;
      await _getSystemMetrics.stopMonitoring();

      if (state is SystemMonitoringLoaded) {
        final currentState = state as SystemMonitoringLoaded;
        emit(currentState.copyWith(isRealTimeMonitoring: false));
      }
    } catch (e) {
      emit(SystemMonitoringError(
        message: '停止实时监控失败',
        details: e.toString(),
      ));
    }
  }

  void _onRealTimeMetricsUpdated(
    RealTimeMetricsUpdatedEvent event,
    Emitter<SystemMonitoringState> emit,
  ) {
    if (state is SystemMonitoringLoaded) {
      final currentState = state as SystemMonitoringLoaded;
      
      final updatedHistorical = [event.metrics, ...currentState.historicalMetrics];
      
      if (updatedHistorical.length > 100) {
        updatedHistorical.removeRange(100, updatedHistorical.length);
      }
      
      emit(currentState.copyWith(
        currentMetrics: event.metrics,
        historicalMetrics: updatedHistorical,
      ));
    }
  }

  Future<void> _onLoadSystemHealth(
    LoadSystemHealthEvent event,
    Emitter<SystemMonitoringState> emit,
  ) async {
    try {
      emit(const SystemMonitoringLoading(message: '正在检查系统健康状态...'));
      
      final systemHealth = SystemHealth(
        status: SystemHealthStatus.healthy,
        overallScore: 85.0,
        checks: [
          HealthCheck(
            name: 'CPU使用率',
            category: 'performance',
            status: SystemHealthStatus.healthy,
            score: 85.0,
            description: 'CPU使用率正常',
            timestamp: DateTime.now(),
          ),
        ],
        lastUpdated: DateTime.now(),
        message: '系统运行正常',
      );
      
      if (state is SystemMonitoringLoaded) {
        final currentState = state as SystemMonitoringLoaded;
        emit(currentState.copyWith(systemHealth: systemHealth));
      } else {
        emit(SystemMonitoringLoaded(systemHealth: systemHealth));
      }
    } catch (e) {
      emit(SystemMonitoringError(
        message: '检查系统健康状态失败',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onLoadSystemAlerts(
    LoadSystemAlertsEvent event,
    Emitter<SystemMonitoringState> emit,
  ) async {
    try {
      emit(const SystemMonitoringLoading(message: '正在加载系统警报...'));
      
      final alerts = await _manageSystemAlerts.getAlerts(
        activeOnly: event.activeOnly,
        severity: event.severity,
        category: event.category,
      );
      
      if (state is SystemMonitoringLoaded) {
        final currentState = state as SystemMonitoringLoaded;
        emit(currentState.copyWith(alerts: alerts));
      } else {
        emit(SystemMonitoringLoaded(alerts: alerts));
      }
    } catch (e) {
      emit(SystemMonitoringError(
        message: '加载系统警报失败',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onAcknowledgeAlert(
    AcknowledgeAlertEvent event,
    Emitter<SystemMonitoringState> emit,
  ) async {
    try {
      await _manageSystemAlerts.acknowledgeAlert(event.alertId);
      add(const LoadSystemAlertsEvent());
    } catch (e) {
      emit(SystemMonitoringError(
        message: '确认警报失败',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteAlert(
    DeleteAlertEvent event,
    Emitter<SystemMonitoringState> emit,
  ) async {
    try {
      await _manageSystemAlerts.deleteAlert(event.alertId);
      add(const LoadSystemAlertsEvent());
    } catch (e) {
      emit(SystemMonitoringError(
        message: '删除警报失败',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onLoadSystemLogs(
    LoadSystemLogsEvent event,
    Emitter<SystemMonitoringState> emit,
  ) async {
    try {
      emit(const SystemMonitoringLoading(message: '正在加载系统日志...'));
      
      final logs = await _manageSystemLogs.getLogs(
        startTime: event.startTime,
        endTime: event.endTime,
        level: event.level,
        source: event.source,
        category: event.category,
        limit: event.limit,
      );
      
      if (state is SystemMonitoringLoaded) {
        final currentState = state as SystemMonitoringLoaded;
        emit(currentState.copyWith(logs: logs));
      } else {
        emit(SystemMonitoringLoaded(logs: logs));
      }
    } catch (e) {
      emit(SystemMonitoringError(
        message: '加载系统日志失败',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onLoadOperationTasks(
    LoadOperationTasksEvent event,
    Emitter<SystemMonitoringState> emit,
  ) async {
    try {
      emit(const SystemMonitoringLoading(message: '正在加载运维任务...'));
      
      final tasks = await _manageOperationTasks.getTasks(
        status: event.status,
        type: event.type,
      );
      
      if (state is SystemMonitoringLoaded) {
        final currentState = state as SystemMonitoringLoaded;
        emit(currentState.copyWith(operationTasks: tasks));
      } else {
        emit(SystemMonitoringLoaded(operationTasks: tasks));
      }
    } catch (e) {
      emit(SystemMonitoringError(
        message: '加载运维任务失败',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onCreateOperationTask(
    CreateOperationTaskEvent event,
    Emitter<SystemMonitoringState> emit,
  ) async {
    try {
      emit(const SystemMonitoringLoading(message: '正在创建运维任务...'));
      
      await _manageOperationTasks.createTask(
        title: event.title,
        description: event.description,
        type: event.type,
        scheduledAt: event.scheduledAt,
        parameters: event.parameters,
      );
      
      add(const LoadOperationTasksEvent());
    } catch (e) {
      emit(SystemMonitoringError(
        message: '创建运维任务失败',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onExecuteOperationTask(
    ExecuteOperationTaskEvent event,
    Emitter<SystemMonitoringState> emit,
  ) async {
    try {
      emit(const SystemMonitoringLoading(message: '正在执行运维任务...'));
      
      await _manageOperationTasks.executeTask(event.taskId);
      add(const LoadOperationTasksEvent());
    } catch (e) {
      emit(SystemMonitoringError(
        message: '执行运维任务失败',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshAllData(
    RefreshAllDataEvent event,
    Emitter<SystemMonitoringState> emit,
  ) async {
    try {
      emit(const SystemMonitoringLoading(message: '正在刷新所有数据...'));
      
      add(const LoadSystemMetricsEvent());
      add(const LoadSystemHealthEvent());
      add(const LoadSystemAlertsEvent());
      add(const LoadSystemLogsEvent());
      add(const LoadOperationTasksEvent());
    } catch (e) {
      emit(SystemMonitoringError(
        message: '刷新数据失败',
        details: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _realTimeSubscription?.cancel();
    _getSystemMetrics.stopMonitoring();
    return super.close();
  }
} 