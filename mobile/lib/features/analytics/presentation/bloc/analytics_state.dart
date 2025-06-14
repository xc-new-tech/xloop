import 'package:equatable/equatable.dart';

import '../../domain/entities/analytics_entity.dart';

/// 调优系统状态基类
abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

/// 加载中状态
class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// 分析中状态
class AnalyticsAnalyzing extends AnalyticsState {
  const AnalyticsAnalyzing({
    required this.operation,
    this.progress = 0.0,
    this.estimatedTime,
  });

  final String operation;
  final double progress; // 0.0 - 1.0
  final Duration? estimatedTime;

  @override
  List<Object?> get props => [operation, progress, estimatedTime];
}

/// 数据加载完成状态
class AnalyticsLoaded extends AnalyticsState {
  const AnalyticsLoaded({
    this.assessments = const [],
    this.optimizations = const [],
    this.currentAssessment,
    this.currentOptimization,
    this.qualityTrendData,
    this.performanceData,
    this.userSatisfactionData,
    this.realtimeMetrics,
    this.hasMoreAssessments = false,
    this.hasMoreOptimizations = false,
    this.filters = const {},
    this.searchQuery,
    this.isMonitoring = false,
  });

  final List<ConversationQualityAssessment> assessments;
  final List<KnowledgeBaseOptimization> optimizations;
  final ConversationQualityAssessment? currentAssessment;
  final KnowledgeBaseOptimization? currentOptimization;
  final QualityTrendData? qualityTrendData;
  final PerformanceData? performanceData;
  final UserSatisfactionData? userSatisfactionData;
  final RealtimeMetrics? realtimeMetrics;
  final bool hasMoreAssessments;
  final bool hasMoreOptimizations;
  final Map<String, dynamic> filters;
  final String? searchQuery;
  final bool isMonitoring;

  @override
  List<Object?> get props => [
        assessments,
        optimizations,
        currentAssessment,
        currentOptimization,
        qualityTrendData,
        performanceData,
        userSatisfactionData,
        realtimeMetrics,
        hasMoreAssessments,
        hasMoreOptimizations,
        filters,
        searchQuery,
        isMonitoring,
      ];

  AnalyticsLoaded copyWith({
    List<ConversationQualityAssessment>? assessments,
    List<KnowledgeBaseOptimization>? optimizations,
    ConversationQualityAssessment? currentAssessment,
    KnowledgeBaseOptimization? currentOptimization,
    QualityTrendData? qualityTrendData,
    PerformanceData? performanceData,
    UserSatisfactionData? userSatisfactionData,
    RealtimeMetrics? realtimeMetrics,
    bool? hasMoreAssessments,
    bool? hasMoreOptimizations,
    Map<String, dynamic>? filters,
    String? searchQuery,
    bool? isMonitoring,
  }) {
    return AnalyticsLoaded(
      assessments: assessments ?? this.assessments,
      optimizations: optimizations ?? this.optimizations,
      currentAssessment: currentAssessment ?? this.currentAssessment,
      currentOptimization: currentOptimization ?? this.currentOptimization,
      qualityTrendData: qualityTrendData ?? this.qualityTrendData,
      performanceData: performanceData ?? this.performanceData,
      userSatisfactionData: userSatisfactionData ?? this.userSatisfactionData,
      realtimeMetrics: realtimeMetrics ?? this.realtimeMetrics,
      hasMoreAssessments: hasMoreAssessments ?? this.hasMoreAssessments,
      hasMoreOptimizations: hasMoreOptimizations ?? this.hasMoreOptimizations,
      filters: filters ?? this.filters,
      searchQuery: searchQuery ?? this.searchQuery,
      isMonitoring: isMonitoring ?? this.isMonitoring,
    );
  }

  /// 添加评估
  AnalyticsLoaded addAssessments(List<ConversationQualityAssessment> newAssessments) {
    final updatedAssessments = List<ConversationQualityAssessment>.from(assessments)
      ..addAll(newAssessments);
    return copyWith(assessments: updatedAssessments);
  }

  /// 更新评估
  AnalyticsLoaded updateAssessment(ConversationQualityAssessment assessment) {
    final updatedAssessments = assessments.map((a) {
      return a.id == assessment.id ? assessment : a;
    }).toList();
    return copyWith(assessments: updatedAssessments);
  }

  /// 删除评估
  AnalyticsLoaded removeAssessment(String assessmentId) {
    final updatedAssessments = assessments.where((a) => a.id != assessmentId).toList();
    return copyWith(assessments: updatedAssessments);
  }

  /// 添加优化
  AnalyticsLoaded addOptimizations(List<KnowledgeBaseOptimization> newOptimizations) {
    final updatedOptimizations = List<KnowledgeBaseOptimization>.from(optimizations)
      ..addAll(newOptimizations);
    return copyWith(optimizations: updatedOptimizations);
  }

  /// 更新优化
  AnalyticsLoaded updateOptimization(KnowledgeBaseOptimization optimization) {
    final updatedOptimizations = optimizations.map((o) {
      return o.id == optimization.id ? optimization : o;
    }).toList();
    return copyWith(optimizations: updatedOptimizations);
  }

  /// 删除优化
  AnalyticsLoaded removeOptimization(String optimizationId) {
    final updatedOptimizations = optimizations.where((o) => o.id != optimizationId).toList();
    return copyWith(optimizations: updatedOptimizations);
  }

  /// 清除搜索
  AnalyticsLoaded clearSearch() {
    return copyWith(
      searchQuery: '',
      filters: const {},
    );
  }

  /// 获取平均质量分数
  double get averageQualityScore {
    if (assessments.isEmpty) return 0.0;
    final totalScore = assessments.fold<double>(0.0, (sum, assessment) => sum + assessment.qualityScore);
    return totalScore / assessments.length;
  }

  /// 获取最新评估
  ConversationQualityAssessment? get latestAssessment {
    if (assessments.isEmpty) return null;
    return assessments.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
  }

  /// 获取进行中的优化
  List<KnowledgeBaseOptimization> get inProgressOptimizations {
    return optimizations.where((o) => o.status == OptimizationStatus.inProgress).toList();
  }

  /// 获取已完成的优化
  List<KnowledgeBaseOptimization> get completedOptimizations {
    return optimizations.where((o) => o.status == OptimizationStatus.completed).toList();
  }

  /// 获取高优先级建议数量
  int get highPriorityRecommendationsCount {
    return optimizations
        .expand((o) => o.recommendations)
        .where((r) => r.priority == RecommendationPriority.high || r.priority == RecommendationPriority.critical)
        .length;
  }
}

/// 操作成功状态
class AnalyticsOperationSuccess extends AnalyticsState {
  const AnalyticsOperationSuccess({
    required this.message,
    this.data,
  });

  final String message;
  final dynamic data;

  @override
  List<Object?> get props => [message, data];
}

/// 报告生成成功状态
class AnalyticsReportGenerated extends AnalyticsState {
  const AnalyticsReportGenerated({
    required this.reportType,
    required this.reportData,
    this.exportPath,
  });

  final String reportType;
  final Map<String, dynamic> reportData;
  final String? exportPath;

  @override
  List<Object?> get props => [reportType, reportData, exportPath];
}

/// 分析完成状态
class AnalyticsAnalysisCompleted extends AnalyticsState {
  const AnalyticsAnalysisCompleted({
    required this.analysisType,
    required this.results,
    this.recommendations = const [],
  });

  final String analysisType;
  final Map<String, dynamic> results;
  final List<OptimizationRecommendation> recommendations;

  @override
  List<Object> get props => [analysisType, results, recommendations];
}

/// 实时数据更新状态
class AnalyticsRealtimeUpdate extends AnalyticsState {
  const AnalyticsRealtimeUpdate({
    required this.metrics,
    required this.timestamp,
    this.alerts = const [],
  });

  final RealtimeMetrics metrics;
  final DateTime timestamp;
  final List<MetricAlert> alerts;

  @override
  List<Object> get props => [metrics, timestamp, alerts];
}

/// 错误状态
class AnalyticsError extends AnalyticsState {
  const AnalyticsError({
    required this.message,
    this.error,
    this.stackTrace,
  });

  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [message, error, stackTrace];
}

/// 网络错误状态
class AnalyticsNetworkError extends AnalyticsError {
  const AnalyticsNetworkError({
    required super.message,
    super.error,
    super.stackTrace,
  });
}

/// 权限错误状态
class AnalyticsPermissionError extends AnalyticsError {
  const AnalyticsPermissionError({
    required super.message,
    super.error,
    super.stackTrace,
  });
}

/// 验证错误状态
class AnalyticsValidationError extends AnalyticsError {
  const AnalyticsValidationError({
    required super.message,
    required this.validationErrors,
    super.error,
    super.stackTrace,
  });

  final Map<String, String> validationErrors;

  @override
  List<Object?> get props => [message, validationErrors, error, stackTrace];
}

// 数据类定义

/// 质量趋势数据
class QualityTrendData extends Equatable {
  const QualityTrendData({
    required this.dataPoints,
    required this.timeRange,
    this.trend,
    this.averageScore,
    this.improvements = const [],
    this.degradations = const [],
  });

  final List<QualityDataPoint> dataPoints;
  final DateTimeRange timeRange;
  final TrendDirection? trend;
  final double? averageScore;
  final List<QualityChange> improvements;
  final List<QualityChange> degradations;

  @override
  List<Object?> get props => [
        dataPoints,
        timeRange,
        trend,
        averageScore,
        improvements,
        degradations,
      ];
}

/// 质量数据点
class QualityDataPoint extends Equatable {
  const QualityDataPoint({
    required this.timestamp,
    required this.qualityScore,
    required this.dimensions,
    this.volume,
  });

  final DateTime timestamp;
  final double qualityScore;
  final QualityDimensions dimensions;
  final int? volume; // number of assessments

  @override
  List<Object?> get props => [timestamp, qualityScore, dimensions, volume];
}

/// 质量变化
class QualityChange extends Equatable {
  const QualityChange({
    required this.dimension,
    required this.previousValue,
    required this.currentValue,
    required this.changePercent,
    required this.period,
  });

  final String dimension;
  final double previousValue;
  final double currentValue;
  final double changePercent;
  final DateTimeRange period;

  @override
  List<Object> get props => [
        dimension,
        previousValue,
        currentValue,
        changePercent,
        period,
      ];
}

/// 性能数据
class PerformanceData extends Equatable {
  const PerformanceData({
    required this.searchMetrics,
    required this.responseTimeMetrics,
    required this.resourceUsage,
    this.optimizationImpacts = const [],
  });

  final SearchMetrics searchMetrics;
  final ResponseTimeMetrics responseTimeMetrics;
  final ResourceUsage resourceUsage;
  final List<OptimizationImpact> optimizationImpacts;

  @override
  List<Object> get props => [
        searchMetrics,
        responseTimeMetrics,
        resourceUsage,
        optimizationImpacts,
      ];
}

/// 搜索指标
class SearchMetrics extends Equatable {
  const SearchMetrics({
    required this.averageRelevance,
    required this.successRate,
    required this.totalQueries,
    required this.uniqueQueries,
    this.topQueries = const [],
    this.failedQueries = const [],
  });

  final double averageRelevance;
  final double successRate;
  final int totalQueries;
  final int uniqueQueries;
  final List<QueryAnalysis> topQueries;
  final List<QueryAnalysis> failedQueries;

  @override
  List<Object> get props => [
        averageRelevance,
        successRate,
        totalQueries,
        uniqueQueries,
        topQueries,
        failedQueries,
      ];
}

/// 响应时间指标
class ResponseTimeMetrics extends Equatable {
  const ResponseTimeMetrics({
    required this.averageResponseTime,
    required this.p50ResponseTime,
    required this.p95ResponseTime,
    required this.p99ResponseTime,
    this.timeDistribution = const {},
  });

  final int averageResponseTime;
  final int p50ResponseTime;
  final int p95ResponseTime;
  final int p99ResponseTime;
  final Map<String, int> timeDistribution; // time_bucket -> count

  @override
  List<Object> get props => [
        averageResponseTime,
        p50ResponseTime,
        p95ResponseTime,
        p99ResponseTime,
        timeDistribution,
      ];
}

/// 资源使用情况
class ResourceUsage extends Equatable {
  const ResourceUsage({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.storageUsage,
    required this.networkUsage,
    this.alerts = const [],
  });

  final double cpuUsage; // percentage
  final double memoryUsage; // percentage
  final double storageUsage; // percentage
  final double networkUsage; // mbps
  final List<ResourceAlert> alerts;

  @override
  List<Object> get props => [
        cpuUsage,
        memoryUsage,
        storageUsage,
        networkUsage,
        alerts,
      ];
}

/// 优化影响
class OptimizationImpact extends Equatable {
  const OptimizationImpact({
    required this.optimizationId,
    required this.implementedAt,
    required this.beforeMetrics,
    required this.afterMetrics,
    required this.improvementPercent,
  });

  final String optimizationId;
  final DateTime implementedAt;
  final MetricValues beforeMetrics;
  final MetricValues afterMetrics;
  final double improvementPercent;

  @override
  List<Object> get props => [
        optimizationId,
        implementedAt,
        beforeMetrics,
        afterMetrics,
        improvementPercent,
      ];
}

/// 用户满意度数据
class UserSatisfactionData extends Equatable {
  const UserSatisfactionData({
    required this.averageRating,
    required this.ratingDistribution,
    required this.sentimentAnalysis,
    required this.feedbackCategories,
    this.trendData = const [],
  });

  final double averageRating;
  final Map<int, int> ratingDistribution;
  final SentimentAnalysis sentimentAnalysis;
  final List<FeedbackCategory> feedbackCategories;
  final List<SatisfactionTrendPoint> trendData;

  @override
  List<Object> get props => [
        averageRating,
        ratingDistribution,
        sentimentAnalysis,
        feedbackCategories,
        trendData,
      ];
}

/// 反馈分类
class FeedbackCategory extends Equatable {
  const FeedbackCategory({
    required this.category,
    required this.count,
    required this.averageRating,
    this.examples = const [],
  });

  final String category;
  final int count;
  final double averageRating;
  final List<String> examples;

  @override
  List<Object> get props => [category, count, averageRating, examples];
}

/// 满意度趋势点
class SatisfactionTrendPoint extends Equatable {
  const SatisfactionTrendPoint({
    required this.date,
    required this.rating,
    required this.volume,
  });

  final DateTime date;
  final double rating;
  final int volume;

  @override
  List<Object> get props => [date, rating, volume];
}

/// 实时指标
class RealtimeMetrics extends Equatable {
  const RealtimeMetrics({
    required this.currentQualityScore,
    required this.activeConversations,
    required this.responseTime,
    required this.systemLoad,
    required this.timestamp,
    this.alerts = const [],
  });

  final double currentQualityScore;
  final int activeConversations;
  final int responseTime;
  final double systemLoad;
  final DateTime timestamp;
  final List<MetricAlert> alerts;

  @override
  List<Object> get props => [
        currentQualityScore,
        activeConversations,
        responseTime,
        systemLoad,
        timestamp,
        alerts,
      ];
}

/// 指标警报
class MetricAlert extends Equatable {
  const MetricAlert({
    required this.type,
    required this.severity,
    required this.message,
    required this.metricName,
    required this.currentValue,
    required this.threshold,
    required this.timestamp,
  });

  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final String metricName;
  final double currentValue;
  final double threshold;
  final DateTime timestamp;

  @override
  List<Object> get props => [
        type,
        severity,
        message,
        metricName,
        currentValue,
        threshold,
        timestamp,
      ];
}

/// 资源警报
class ResourceAlert extends Equatable {
  const ResourceAlert({
    required this.resource,
    required this.usage,
    required this.threshold,
    required this.message,
    required this.timestamp,
  });

  final String resource;
  final double usage;
  final double threshold;
  final String message;
  final DateTime timestamp;

  @override
  List<Object> get props => [resource, usage, threshold, message, timestamp];
}

/// 时间范围
class DateTimeRange extends Equatable {
  const DateTimeRange({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;

  @override
  List<Object> get props => [start, end];
}

// 枚举定义

enum TrendDirection { improving, declining, stable }

enum AlertType { threshold, anomaly, performance }

enum AlertSeverity { low, medium, high, critical } 