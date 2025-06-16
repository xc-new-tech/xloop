import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 性能优化工具类
class PerformanceUtils {
  PerformanceUtils._();

  static final Map<String, DateTime> _timers = {};
  static final List<PerformanceMetric> _metrics = [];
  static Timer? _memoryMonitorTimer;
  static bool _isMonitoring = false;

  /// 开始性能计时
  static void startTimer(String name) {
    _timers[name] = DateTime.now();
  }

  /// 结束性能计时并返回耗时
  static Duration? endTimer(String name) {
    final startTime = _timers.remove(name);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _addMetric(PerformanceMetric(
        name: name,
        type: MetricType.timing,
        value: duration.inMilliseconds.toDouble(),
        timestamp: DateTime.now(),
      ));
      return duration;
    }
    return null;
  }

  /// 测量函数执行时间
  static Future<T> measureAsync<T>(
    String name,
    Future<T> Function() function,
  ) async {
    startTimer(name);
    try {
      final result = await function();
      final duration = endTimer(name);
      debugPrint('$name 执行时间: ${duration?.inMilliseconds}ms');
      return result;
    } catch (e) {
      endTimer(name);
      rethrow;
    }
  }

  /// 测量同步函数执行时间
  static T measureSync<T>(
    String name,
    T Function() function,
  ) {
    startTimer(name);
    try {
      final result = function();
      final duration = endTimer(name);
      debugPrint('$name 执行时间: ${duration?.inMilliseconds}ms');
      return result;
    } catch (e) {
      endTimer(name);
      rethrow;
    }
  }

  /// 开始内存监控
  static void startMemoryMonitoring({
    Duration interval = const Duration(seconds: 5),
  }) {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _memoryMonitorTimer = Timer.periodic(interval, (timer) {
      _recordMemoryUsage();
    });
  }

  /// 停止内存监控
  static void stopMemoryMonitoring() {
    _memoryMonitorTimer?.cancel();
    _memoryMonitorTimer = null;
    _isMonitoring = false;
  }

  /// 记录内存使用情况
  static void _recordMemoryUsage() {
    if (Platform.isAndroid || Platform.isIOS) {
      // 在移动平台上记录内存使用
      _addMetric(PerformanceMetric(
        name: 'memory_usage',
        type: MetricType.memory,
        value: _getMemoryUsage(),
        timestamp: DateTime.now(),
      ));
    }
  }

  /// 获取内存使用量（MB）
  static double _getMemoryUsage() {
    // 这里可以集成具体的内存监控库
    // 目前返回模拟数据
    return 0.0;
  }

  /// 添加性能指标
  static void _addMetric(PerformanceMetric metric) {
    _metrics.add(metric);
    
    // 保持最近1000条记录
    if (_metrics.length > 1000) {
      _metrics.removeAt(0);
    }
  }

  /// 记录自定义指标
  static void recordMetric({
    required String name,
    required double value,
    MetricType type = MetricType.custom,
    Map<String, dynamic>? metadata,
  }) {
    _addMetric(PerformanceMetric(
      name: name,
      type: type,
      value: value,
      timestamp: DateTime.now(),
      metadata: metadata,
    ));
  }

  /// 获取性能指标
  static List<PerformanceMetric> getMetrics({
    String? name,
    MetricType? type,
    DateTime? since,
  }) {
    return _metrics.where((metric) {
      if (name != null && metric.name != name) return false;
      if (type != null && metric.type != type) return false;
      if (since != null && metric.timestamp.isBefore(since)) return false;
      return true;
    }).toList();
  }

  /// 获取平均值
  static double getAverageMetric(String name, {Duration? period}) {
    final since = period != null 
        ? DateTime.now().subtract(period)
        : null;
    
    final metrics = getMetrics(name: name, since: since);
    if (metrics.isEmpty) return 0.0;
    
    final sum = metrics.fold<double>(0.0, (sum, metric) => sum + metric.value);
    return sum / metrics.length;
  }

  /// 清除性能指标
  static void clearMetrics() {
    _metrics.clear();
  }

  /// 优化图片加载
  static Widget optimizedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
    bool enableMemoryCache = true,
    bool enableDiskCache = true,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? 
            Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? 
            const Icon(Icons.error, color: Colors.red);
      },
    );
  }

  /// 延迟执行
  static Future<void> debounce(
    String key,
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) async {
    final timer = _debounceTimers[key];
    timer?.cancel();
    
    _debounceTimers[key] = Timer(delay, () {
      callback();
      _debounceTimers.remove(key);
    });
  }

  static final Map<String, Timer> _debounceTimers = {};

  /// 节流执行
  static void throttle(
    String key,
    VoidCallback callback, {
    Duration interval = const Duration(milliseconds: 100),
  }) {
    final lastExecution = _throttleTimestamps[key];
    final now = DateTime.now();
    
    if (lastExecution == null || 
        now.difference(lastExecution) >= interval) {
      _throttleTimestamps[key] = now;
      callback();
    }
  }

  static final Map<String, DateTime> _throttleTimestamps = {};

  /// 预加载资源
  static Future<void> preloadAssets(
    BuildContext context,
    List<String> assetPaths,
  ) async {
    final futures = assetPaths.map((path) {
      if (path.startsWith('http')) {
        return precacheImage(NetworkImage(path), context);
      } else {
        return precacheImage(AssetImage(path), context);
      }
    });
    
    await Future.wait(futures);
  }

  /// 批量处理
  static Future<List<T>> batchProcess<T, R>(
    List<T> items,
    Future<R> Function(T item) processor, {
    int batchSize = 10,
    Duration delay = const Duration(milliseconds: 10),
  }) async {
    final results = <T>[];
    
    for (int i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize);
      final batchResults = await Future.wait(
        batch.map(processor),
      );
      
      results.addAll(items.skip(i).take(batchSize));
      
      // 给UI线程一些时间
      if (i + batchSize < items.length) {
        await Future.delayed(delay);
      }
    }
    
    return results;
  }

  /// 在Isolate中执行计算密集型任务
  static Future<R> computeInIsolate<T, R>(
    R Function(T) callback,
    T data,
  ) async {
    return await compute(callback, data);
  }

  /// 优化列表构建
  static Widget optimizedListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? controller,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
    double? itemExtent,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
  }) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      itemCount: itemCount,
      itemExtent: itemExtent,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
    );
  }

  /// 优化网格构建
  static Widget optimizedGridView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required SliverGridDelegate gridDelegate,
    ScrollController? controller,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
  }) {
    return GridView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
    );
  }

  /// 减少重建的Builder
  static Widget optimizedBuilder({
    required Widget Function(BuildContext) builder,
    List<Object?>? dependencies,
  }) {
    return Builder(
      builder: (context) {
        return RepaintBoundary(
          child: builder(context),
        );
      },
    );
  }

  /// 懒加载组件
  static Widget lazyWidget({
    required Widget Function() builder,
    Widget? placeholder,
    bool condition = true,
  }) {
    if (!condition) {
      return placeholder ?? const SizedBox.shrink();
    }
    
    return Builder(
      builder: (context) => builder(),
    );
  }

  /// 缓存组件
  static Widget cachedWidget({
    required String key,
    required Widget Function() builder,
    Duration? ttl,
  }) {
    return _CachedWidget(
      key: ValueKey(key),
      cacheKey: key,
      builder: builder,
      ttl: ttl,
    );
  }

  /// 获取性能报告
  static PerformanceReport getPerformanceReport() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    
    final recentMetrics = getMetrics(since: last24Hours);
    
    final timingMetrics = recentMetrics
        .where((m) => m.type == MetricType.timing)
        .toList();
    
    final memoryMetrics = recentMetrics
        .where((m) => m.type == MetricType.memory)
        .toList();
    
    return PerformanceReport(
      totalMetrics: recentMetrics.length,
      averageResponseTime: timingMetrics.isNotEmpty
          ? timingMetrics.fold<double>(0, (sum, m) => sum + m.value) / timingMetrics.length
          : 0,
      peakMemoryUsage: memoryMetrics.isNotEmpty
          ? memoryMetrics.map((m) => m.value).reduce((a, b) => a > b ? a : b)
          : 0,
      metrics: recentMetrics,
      generatedAt: now,
    );
  }

  /// 启用性能监控
  static void enablePerformanceMonitoring() {
    startMemoryMonitoring();
    
    // 监控帧率
    WidgetsBinding.instance.addTimingsCallback((timings) {
      for (final timing in timings) {
        recordMetric(
          name: 'frame_build_time',
          value: timing.buildDuration.inMicroseconds / 1000.0,
          type: MetricType.timing,
        );
        
        recordMetric(
          name: 'frame_raster_time',
          value: timing.rasterDuration.inMicroseconds / 1000.0,
          type: MetricType.timing,
        );
      }
    });
  }

  /// 禁用性能监控
  static void disablePerformanceMonitoring() {
    stopMemoryMonitoring();
  }
}

/// 性能指标类型
enum MetricType {
  timing,
  memory,
  network,
  custom,
}

/// 性能指标
class PerformanceMetric {
  final String name;
  final MetricType type;
  final double value;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const PerformanceMetric({
    required this.name,
    required this.type,
    required this.value,
    required this.timestamp,
    this.metadata,
  });

  @override
  String toString() {
    return 'PerformanceMetric(name: $name, type: $type, value: $value, timestamp: $timestamp)';
  }
}

/// 性能报告
class PerformanceReport {
  final int totalMetrics;
  final double averageResponseTime;
  final double peakMemoryUsage;
  final List<PerformanceMetric> metrics;
  final DateTime generatedAt;

  const PerformanceReport({
    required this.totalMetrics,
    required this.averageResponseTime,
    required this.peakMemoryUsage,
    required this.metrics,
    required this.generatedAt,
  });

  @override
  String toString() {
    return '''
Performance Report (Generated: $generatedAt)
Total Metrics: $totalMetrics
Average Response Time: ${averageResponseTime.toStringAsFixed(2)}ms
Peak Memory Usage: ${peakMemoryUsage.toStringAsFixed(2)}MB
''';
  }
}

/// 缓存组件
class _CachedWidget extends StatefulWidget {
  final String cacheKey;
  final Widget Function() builder;
  final Duration? ttl;

  const _CachedWidget({
    super.key,
    required this.cacheKey,
    required this.builder,
    this.ttl,
  });

  @override
  State<_CachedWidget> createState() => _CachedWidgetState();
}

class _CachedWidgetState extends State<_CachedWidget> {
  static final Map<String, _CacheEntry> _cache = {};
  
  @override
  Widget build(BuildContext context) {
    final entry = _cache[widget.cacheKey];
    final now = DateTime.now();
    
    if (entry != null && 
        (widget.ttl == null || now.difference(entry.createdAt) < widget.ttl!)) {
      return entry.widget;
    }
    
    final newWidget = widget.builder();
    _cache[widget.cacheKey] = _CacheEntry(
      widget: newWidget,
      createdAt: now,
    );
    
    return newWidget;
  }
}

class _CacheEntry {
  final Widget widget;
  final DateTime createdAt;

  const _CacheEntry({
    required this.widget,
    required this.createdAt,
  });
}

/// 性能监控Mixin
mixin PerformanceMonitorMixin<T extends StatefulWidget> on State<T> {
  late final String _widgetName;
  
  @override
  void initState() {
    super.initState();
    _widgetName = widget.runtimeType.toString();
    PerformanceUtils.startTimer('${_widgetName}_init');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PerformanceUtils.endTimer('${_widgetName}_init');
  }

  @override
  Widget build(BuildContext context) {
    return PerformanceUtils.measureSync(
      '${_widgetName}_build',
      () => buildWidget(context),
    );
  }

  /// 子类需要实现这个方法而不是build
  Widget buildWidget(BuildContext context);

  @override
  void dispose() {
    PerformanceUtils.recordMetric(
      name: '${_widgetName}_lifecycle',
      value: 1,
      type: MetricType.custom,
    );
    super.dispose();
  }
} 