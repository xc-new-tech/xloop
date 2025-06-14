import 'package:equatable/equatable.dart';

import '../../domain/entities/analytics_entity.dart';

/// 调优系统事件基类
abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

// 对话质量评估事件

/// 加载对话质量评估列表
class LoadConversationAssessmentsEvent extends AnalyticsEvent {
  const LoadConversationAssessmentsEvent({
    this.conversationId,
    this.assessmentType,
    this.startDate,
    this.endDate,
    this.page = 1,
    this.limit = 20,
  });

  final String? conversationId;
  final AssessmentType? assessmentType;
  final DateTime? startDate;
  final DateTime? endDate;
  final int page;
  final int limit;

  @override
  List<Object?> get props => [conversationId, assessmentType, startDate, endDate, page, limit];
}

/// 获取单个对话质量评估
class GetConversationAssessmentEvent extends AnalyticsEvent {
  const GetConversationAssessmentEvent({required this.assessmentId});

  final String assessmentId;

  @override
  List<Object> get props => [assessmentId];
}

/// 创建对话质量评估
class CreateConversationAssessmentEvent extends AnalyticsEvent {
  const CreateConversationAssessmentEvent({
    required this.conversationId,
    required this.messageId,
    required this.dimensions,
    required this.feedback,
    this.suggestions = const [],
    this.assessmentType = AssessmentType.automated,
    this.metadata = const {},
  });

  final String conversationId;
  final String messageId;
  final QualityDimensions dimensions;
  final QualityFeedback feedback;
  final List<ImprovementSuggestion> suggestions;
  final AssessmentType assessmentType;
  final Map<String, dynamic> metadata;

  @override
  List<Object> get props => [
        conversationId,
        messageId,
        dimensions,
        feedback,
        suggestions,
        assessmentType,
        metadata,
      ];
}

/// 更新对话质量评估
class UpdateConversationAssessmentEvent extends AnalyticsEvent {
  const UpdateConversationAssessmentEvent({
    required this.assessmentId,
    this.qualityScore,
    this.dimensions,
    this.feedback,
    this.suggestions,
    this.manualReview,
    this.metadata,
  });

  final String assessmentId;
  final double? qualityScore;
  final QualityDimensions? dimensions;
  final QualityFeedback? feedback;
  final List<ImprovementSuggestion>? suggestions;
  final ManualReview? manualReview;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [
        assessmentId,
        qualityScore,
        dimensions,
        feedback,
        suggestions,
        manualReview,
        metadata,
      ];
}

/// 删除对话质量评估
class DeleteConversationAssessmentEvent extends AnalyticsEvent {
  const DeleteConversationAssessmentEvent({required this.assessmentId});

  final String assessmentId;

  @override
  List<Object> get props => [assessmentId];
}

/// 批量评估对话质量
class BatchAssessConversationsEvent extends AnalyticsEvent {
  const BatchAssessConversationsEvent({
    required this.conversationIds,
    this.assessmentType = AssessmentType.automated,
    this.forceReassess = false,
  });

  final List<String> conversationIds;
  final AssessmentType assessmentType;
  final bool forceReassess;

  @override
  List<Object> get props => [conversationIds, assessmentType, forceReassess];
}

// 知识库优化事件

/// 加载知识库优化列表
class LoadKnowledgeBaseOptimizationsEvent extends AnalyticsEvent {
  const LoadKnowledgeBaseOptimizationsEvent({
    this.knowledgeBaseId,
    this.optimizationType,
    this.status,
    this.page = 1,
    this.limit = 20,
  });

  final String? knowledgeBaseId;
  final OptimizationType? optimizationType;
  final OptimizationStatus? status;
  final int page;
  final int limit;

  @override
  List<Object?> get props => [knowledgeBaseId, optimizationType, status, page, limit];
}

/// 获取单个知识库优化
class GetKnowledgeBaseOptimizationEvent extends AnalyticsEvent {
  const GetKnowledgeBaseOptimizationEvent({required this.optimizationId});

  final String optimizationId;

  @override
  List<Object> get props => [optimizationId];
}

/// 创建知识库优化
class CreateKnowledgeBaseOptimizationEvent extends AnalyticsEvent {
  const CreateKnowledgeBaseOptimizationEvent({
    required this.knowledgeBaseId,
    required this.optimizationType,
    this.metadata = const {},
  });

  final String knowledgeBaseId;
  final OptimizationType optimizationType;
  final Map<String, dynamic> metadata;

  @override
  List<Object> get props => [knowledgeBaseId, optimizationType, metadata];
}

/// 运行知识库分析
class RunKnowledgeBaseAnalysisEvent extends AnalyticsEvent {
  const RunKnowledgeBaseAnalysisEvent({
    required this.knowledgeBaseId,
    required this.optimizationType,
    this.includeUserFeedback = true,
    this.includePerformanceMetrics = true,
    this.analysisDepth = AnalysisDepth.comprehensive,
  });

  final String knowledgeBaseId;
  final OptimizationType optimizationType;
  final bool includeUserFeedback;
  final bool includePerformanceMetrics;
  final AnalysisDepth analysisDepth;

  @override
  List<Object> get props => [
        knowledgeBaseId,
        optimizationType,
        includeUserFeedback,
        includePerformanceMetrics,
        analysisDepth,
      ];
}

/// 应用优化建议
class ApplyOptimizationRecommendationEvent extends AnalyticsEvent {
  const ApplyOptimizationRecommendationEvent({
    required this.optimizationId,
    required this.recommendationIndex,
    this.implementationNotes,
  });

  final String optimizationId;
  final int recommendationIndex;
  final String? implementationNotes;

  @override
  List<Object?> get props => [optimizationId, recommendationIndex, implementationNotes];
}

/// 更新优化状态
class UpdateOptimizationStatusEvent extends AnalyticsEvent {
  const UpdateOptimizationStatusEvent({
    required this.optimizationId,
    required this.status,
    this.completedAt,
    this.notes,
  });

  final String optimizationId;
  final OptimizationStatus status;
  final DateTime? completedAt;
  final String? notes;

  @override
  List<Object?> get props => [optimizationId, status, completedAt, notes];
}

/// 删除知识库优化
class DeleteKnowledgeBaseOptimizationEvent extends AnalyticsEvent {
  const DeleteKnowledgeBaseOptimizationEvent({required this.optimizationId});

  final String optimizationId;

  @override
  List<Object> get props => [optimizationId];
}

// 分析报告事件

/// 生成质量趋势报告
class GenerateQualityTrendReportEvent extends AnalyticsEvent {
  const GenerateQualityTrendReportEvent({
    this.knowledgeBaseId,
    this.startDate,
    this.endDate,
    this.granularity = ReportGranularity.daily,
    this.includeComparisons = true,
  });

  final String? knowledgeBaseId;
  final DateTime? startDate;
  final DateTime? endDate;
  final ReportGranularity granularity;
  final bool includeComparisons;

  @override
  List<Object?> get props => [knowledgeBaseId, startDate, endDate, granularity, includeComparisons];
}

/// 生成用户满意度报告
class GenerateUserSatisfactionReportEvent extends AnalyticsEvent {
  const GenerateUserSatisfactionReportEvent({
    this.knowledgeBaseId,
    this.startDate,
    this.endDate,
    this.includeSegmentation = true,
    this.includeSentimentAnalysis = true,
  });

  final String? knowledgeBaseId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool includeSegmentation;
  final bool includeSentimentAnalysis;

  @override
  List<Object?> get props => [
        knowledgeBaseId,
        startDate,
        endDate,
        includeSegmentation,
        includeSentimentAnalysis,
      ];
}

/// 生成性能报告
class GeneratePerformanceReportEvent extends AnalyticsEvent {
  const GeneratePerformanceReportEvent({
    this.knowledgeBaseId,
    this.startDate,
    this.endDate,
    this.includeOptimizations = true,
    this.includeComparisons = true,
  });

  final String? knowledgeBaseId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool includeOptimizations;
  final bool includeComparisons;

  @override
  List<Object?> get props => [
        knowledgeBaseId,
        startDate,
        endDate,
        includeOptimizations,
        includeComparisons,
      ];
}

/// 导出分析数据
class ExportAnalyticsDataEvent extends AnalyticsEvent {
  const ExportAnalyticsDataEvent({
    required this.dataType,
    this.knowledgeBaseId,
    this.startDate,
    this.endDate,
    this.format = ExportFormat.csv,
    this.includeMetadata = false,
  });

  final AnalyticsDataType dataType;
  final String? knowledgeBaseId;
  final DateTime? startDate;
  final DateTime? endDate;
  final ExportFormat format;
  final bool includeMetadata;

  @override
  List<Object?> get props => [
        dataType,
        knowledgeBaseId,
        startDate,
        endDate,
        format,
        includeMetadata,
      ];
}

// 搜索和筛选事件

/// 搜索评估
class SearchAssessmentsEvent extends AnalyticsEvent {
  const SearchAssessmentsEvent({
    required this.query,
    this.filters = const {},
    this.sortBy = 'timestamp',
    this.sortOrder = SortOrder.desc,
  });

  final String query;
  final Map<String, dynamic> filters;
  final String sortBy;
  final SortOrder sortOrder;

  @override
  List<Object> get props => [query, filters, sortBy, sortOrder];
}

/// 筛选评估
class FilterAssessmentsEvent extends AnalyticsEvent {
  const FilterAssessmentsEvent({
    this.conversationId,
    this.assessmentType,
    this.qualityScoreRange,
    this.startDate,
    this.endDate,
    this.tags = const [],
  });

  final String? conversationId;
  final AssessmentType? assessmentType;
  final QualityScoreRange? qualityScoreRange;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> tags;

  @override
  List<Object?> get props => [
        conversationId,
        assessmentType,
        qualityScoreRange,
        startDate,
        endDate,
        tags,
      ];
}

/// 搜索优化
class SearchOptimizationsEvent extends AnalyticsEvent {
  const SearchOptimizationsEvent({
    required this.query,
    this.filters = const {},
    this.sortBy = 'created_at',
    this.sortOrder = SortOrder.desc,
  });

  final String query;
  final Map<String, dynamic> filters;
  final String sortBy;
  final SortOrder sortOrder;

  @override
  List<Object> get props => [query, filters, sortBy, sortOrder];
}

/// 筛选优化
class FilterOptimizationsEvent extends AnalyticsEvent {
  const FilterOptimizationsEvent({
    this.knowledgeBaseId,
    this.optimizationType,
    this.status,
    this.priority,
    this.startDate,
    this.endDate,
  });

  final String? knowledgeBaseId;
  final OptimizationType? optimizationType;
  final OptimizationStatus? status;
  final RecommendationPriority? priority;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [
        knowledgeBaseId,
        optimizationType,
        status,
        priority,
        startDate,
        endDate,
      ];
}

// 实时监控事件

/// 开始实时监控
class StartRealtimeMonitoringEvent extends AnalyticsEvent {
  const StartRealtimeMonitoringEvent({
    this.knowledgeBaseId,
    this.metricsToMonitor = const [],
    this.alertThresholds = const {},
  });

  final String? knowledgeBaseId;
  final List<String> metricsToMonitor;
  final Map<String, double> alertThresholds;

  @override
  List<Object?> get props => [knowledgeBaseId, metricsToMonitor, alertThresholds];
}

/// 停止实时监控
class StopRealtimeMonitoringEvent extends AnalyticsEvent {
  const StopRealtimeMonitoringEvent();
}

/// 更新监控配置
class UpdateMonitoringConfigEvent extends AnalyticsEvent {
  const UpdateMonitoringConfigEvent({
    this.metricsToMonitor,
    this.alertThresholds,
    this.refreshInterval,
  });

  final List<String>? metricsToMonitor;
  final Map<String, double>? alertThresholds;
  final Duration? refreshInterval;

  @override
  List<Object?> get props => [metricsToMonitor, alertThresholds, refreshInterval];
}

// 枚举定义

enum AnalysisDepth { basic, detailed, comprehensive }

enum ReportGranularity { hourly, daily, weekly, monthly }

enum AnalyticsDataType { 
  assessments, 
  optimizations, 
  performance, 
  userFeedback,
  qualityTrends
}

enum ExportFormat { csv, json, excel, pdf }

enum SortOrder { asc, desc }

/// 质量评分范围
class QualityScoreRange extends Equatable {
  const QualityScoreRange({
    required this.min,
    required this.max,
  });

  final double min;
  final double max;

  @override
  List<Object> get props => [min, max];
} 