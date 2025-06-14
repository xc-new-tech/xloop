import 'package:equatable/equatable.dart';

/// 对话质量评估实体
class ConversationQualityAssessment extends Equatable {
  const ConversationQualityAssessment({
    required this.id,
    required this.conversationId,
    required this.messageId,
    required this.qualityScore,
    required this.dimensions,
    required this.feedback,
    this.suggestions = const [],
    this.automatedAssessment,
    this.manualReview,
    required this.timestamp,
    required this.assessmentType,
    this.metadata = const {},
  });

  final String id;
  final String conversationId;
  final String messageId;
  final double qualityScore; // 0.0 - 1.0
  final QualityDimensions dimensions;
  final QualityFeedback feedback;
  final List<ImprovementSuggestion> suggestions;
  final AutomatedAssessment? automatedAssessment;
  final ManualReview? manualReview;
  final DateTime timestamp;
  final AssessmentType assessmentType;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [
        id,
        conversationId,
        messageId,
        qualityScore,
        dimensions,
        feedback,
        suggestions,
        automatedAssessment,
        manualReview,
        timestamp,
        assessmentType,
        metadata,
      ];

  ConversationQualityAssessment copyWith({
    String? id,
    String? conversationId,
    String? messageId,
    double? qualityScore,
    QualityDimensions? dimensions,
    QualityFeedback? feedback,
    List<ImprovementSuggestion>? suggestions,
    AutomatedAssessment? automatedAssessment,
    ManualReview? manualReview,
    DateTime? timestamp,
    AssessmentType? assessmentType,
    Map<String, dynamic>? metadata,
  }) {
    return ConversationQualityAssessment(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      messageId: messageId ?? this.messageId,
      qualityScore: qualityScore ?? this.qualityScore,
      dimensions: dimensions ?? this.dimensions,
      feedback: feedback ?? this.feedback,
      suggestions: suggestions ?? this.suggestions,
      automatedAssessment: automatedAssessment ?? this.automatedAssessment,
      manualReview: manualReview ?? this.manualReview,
      timestamp: timestamp ?? this.timestamp,
      assessmentType: assessmentType ?? this.assessmentType,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 质量维度评分
class QualityDimensions extends Equatable {
  const QualityDimensions({
    required this.accuracy,
    required this.relevance,
    required this.completeness,
    required this.clarity,
    required this.helpfulness,
    required this.responsiveness,
  });

  final double accuracy; // 准确性 0.0 - 1.0
  final double relevance; // 相关性 0.0 - 1.0
  final double completeness; // 完整性 0.0 - 1.0
  final double clarity; // 清晰度 0.0 - 1.0
  final double helpfulness; // 有用性 0.0 - 1.0
  final double responsiveness; // 响应性 0.0 - 1.0

  @override
  List<Object> get props => [
        accuracy,
        relevance,
        completeness,
        clarity,
        helpfulness,
        responsiveness,
      ];

  /// 计算综合得分
  double get overallScore {
    return (accuracy + relevance + completeness + clarity + helpfulness + responsiveness) / 6;
  }

  /// 获取最低分维度
  String get lowestDimension {
    final scores = {
      'accuracy': accuracy,
      'relevance': relevance,
      'completeness': completeness,
      'clarity': clarity,
      'helpfulness': helpfulness,
      'responsiveness': responsiveness,
    };
    
    return scores.entries.reduce((a, b) => a.value < b.value ? a : b).key;
  }
}

/// 质量反馈
class QualityFeedback extends Equatable {
  const QualityFeedback({
    required this.userRating,
    this.userComment,
    this.userTags = const [],
    this.systemRating,
    this.systemComment,
    this.systemTags = const [],
  });

  final int? userRating; // 1-5 星评分
  final String? userComment;
  final List<String> userTags;
  final double? systemRating; // 0.0 - 1.0
  final String? systemComment;
  final List<String> systemTags;

  @override
  List<Object?> get props => [
        userRating,
        userComment,
        userTags,
        systemRating,
        systemComment,
        systemTags,
      ];
}

/// 改进建议
class ImprovementSuggestion extends Equatable {
  const ImprovementSuggestion({
    required this.type,
    required this.priority,
    required this.description,
    required this.category,
    this.actionRequired,
    this.estimatedImpact,
    this.implementationNotes,
  });

  final SuggestionType type;
  final SuggestionPriority priority;
  final String description;
  final SuggestionCategory category;
  final String? actionRequired;
  final double? estimatedImpact; // 0.0 - 1.0
  final String? implementationNotes;

  @override
  List<Object?> get props => [
        type,
        priority,
        description,
        category,
        actionRequired,
        estimatedImpact,
        implementationNotes,
      ];
}

/// 自动评估结果
class AutomatedAssessment extends Equatable {
  const AutomatedAssessment({
    required this.modelName,
    required this.modelVersion,
    required this.confidence,
    required this.processingTime,
    this.features = const {},
    this.rawOutput = const {},
  });

  final String modelName;
  final String modelVersion;
  final double confidence; // 0.0 - 1.0
  final int processingTime; // milliseconds
  final Map<String, dynamic> features;
  final Map<String, dynamic> rawOutput;

  @override
  List<Object> get props => [
        modelName,
        modelVersion,
        confidence,
        processingTime,
        features,
        rawOutput,
      ];
}

/// 人工审核
class ManualReview extends Equatable {
  const ManualReview({
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewDate,
    required this.reviewScore,
    this.reviewComments,
    this.approvalStatus,
    this.reviewTime, // seconds
  });

  final String reviewerId;
  final String reviewerName;
  final DateTime reviewDate;
  final double reviewScore; // 0.0 - 1.0
  final String? reviewComments;
  final ApprovalStatus? approvalStatus;
  final int? reviewTime;

  @override
  List<Object?> get props => [
        reviewerId,
        reviewerName,
        reviewDate,
        reviewScore,
        reviewComments,
        approvalStatus,
        reviewTime,
      ];
}

/// 知识库调优实体
class KnowledgeBaseOptimization extends Equatable {
  const KnowledgeBaseOptimization({
    required this.id,
    required this.knowledgeBaseId,
    required this.optimizationType,
    required this.analysis,
    required this.recommendations,
    required this.performanceMetrics,
    this.implementedChanges = const [],
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.metadata = const {},
  });

  final String id;
  final String knowledgeBaseId;
  final OptimizationType optimizationType;
  final OptimizationAnalysis analysis;
  final List<OptimizationRecommendation> recommendations;
  final PerformanceMetrics performanceMetrics;
  final List<ImplementedChange> implementedChanges;
  final OptimizationStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [
        id,
        knowledgeBaseId,
        optimizationType,
        analysis,
        recommendations,
        performanceMetrics,
        implementedChanges,
        status,
        createdAt,
        completedAt,
        metadata,
      ];
}

/// 优化分析
class OptimizationAnalysis extends Equatable {
  const OptimizationAnalysis({
    required this.contentQuality,
    required this.searchPerformance,
    required this.userSatisfaction,
    required this.coverage,
    required this.gaps,
    required this.redundancies,
  });

  final ContentQualityAnalysis contentQuality;
  final SearchPerformanceAnalysis searchPerformance;
  final UserSatisfactionAnalysis userSatisfaction;
  final CoverageAnalysis coverage;
  final List<ContentGap> gaps;
  final List<ContentRedundancy> redundancies;

  @override
  List<Object> get props => [
        contentQuality,
        searchPerformance,
        userSatisfaction,
        coverage,
        gaps,
        redundancies,
      ];
}

/// 内容质量分析
class ContentQualityAnalysis extends Equatable {
  const ContentQualityAnalysis({
    required this.averageQuality,
    required this.qualityDistribution,
    required this.lowQualityItems,
    required this.qualityTrends,
  });

  final double averageQuality;
  final Map<String, int> qualityDistribution; // quality_range -> count
  final List<String> lowQualityItems; // item IDs
  final Map<String, double> qualityTrends; // date -> quality

  @override
  List<Object> get props => [
        averageQuality,
        qualityDistribution,
        lowQualityItems,
        qualityTrends,
      ];
}

/// 搜索性能分析
class SearchPerformanceAnalysis extends Equatable {
  const SearchPerformanceAnalysis({
    required this.averageRelevance,
    required this.searchSuccessRate,
    required this.averageResponseTime,
    required this.popularQueries,
    required this.failedQueries,
  });

  final double averageRelevance;
  final double searchSuccessRate;
  final int averageResponseTime; // milliseconds
  final List<QueryAnalysis> popularQueries;
  final List<QueryAnalysis> failedQueries;

  @override
  List<Object> get props => [
        averageRelevance,
        searchSuccessRate,
        averageResponseTime,
        popularQueries,
        failedQueries,
      ];
}

/// 查询分析
class QueryAnalysis extends Equatable {
  const QueryAnalysis({
    required this.query,
    required this.frequency,
    required this.successRate,
    required this.averageRelevance,
    this.suggestions = const [],
  });

  final String query;
  final int frequency;
  final double successRate;
  final double averageRelevance;
  final List<String> suggestions;

  @override
  List<Object> get props => [
        query,
        frequency,
        successRate,
        averageRelevance,
        suggestions,
      ];
}

/// 用户满意度分析
class UserSatisfactionAnalysis extends Equatable {
  const UserSatisfactionAnalysis({
    required this.averageRating,
    required this.ratingDistribution,
    required this.feedbackSentiment,
    required this.commonComplaints,
    required this.userRetention,
  });

  final double averageRating;
  final Map<int, int> ratingDistribution; // rating -> count
  final SentimentAnalysis feedbackSentiment;
  final List<ComplaintAnalysis> commonComplaints;
  final double userRetention;

  @override
  List<Object> get props => [
        averageRating,
        ratingDistribution,
        feedbackSentiment,
        commonComplaints,
        userRetention,
      ];
}

/// 情感分析
class SentimentAnalysis extends Equatable {
  const SentimentAnalysis({
    required this.positive,
    required this.neutral,
    required this.negative,
  });

  final double positive; // 0.0 - 1.0
  final double neutral; // 0.0 - 1.0
  final double negative; // 0.0 - 1.0

  // 添加百分比getter方法
  double? get positivePercentage => positive * 100;
  double? get neutralPercentage => neutral * 100;
  double? get negativePercentage => negative * 100;

  @override
  List<Object> get props => [positive, neutral, negative];
}

/// 投诉分析
class ComplaintAnalysis extends Equatable {
  const ComplaintAnalysis({
    required this.category,
    required this.frequency,
    required this.severity,
    required this.examples,
  });

  final String category;
  final int frequency;
  final ComplaintSeverity severity;
  final List<String> examples;

  @override
  List<Object> get props => [category, frequency, severity, examples];
}

/// 覆盖率分析
class CoverageAnalysis extends Equatable {
  const CoverageAnalysis({
    required this.topicCoverage,
    required this.domainCoverage,
    required this.languageCoverage,
    required this.uncoveredAreas,
  });

  final Map<String, double> topicCoverage; // topic -> coverage_percentage
  final Map<String, double> domainCoverage; // domain -> coverage_percentage
  final Map<String, double> languageCoverage; // language -> coverage_percentage
  final List<String> uncoveredAreas;

  @override
  List<Object> get props => [
        topicCoverage,
        domainCoverage,
        languageCoverage,
        uncoveredAreas,
      ];
}

/// 内容缺口
class ContentGap extends Equatable {
  const ContentGap({
    required this.area,
    required this.priority,
    required this.description,
    required this.frequency,
    this.suggestedContent,
  });

  final String area;
  final GapPriority priority;
  final String description;
  final int frequency; // how often users ask about this
  final String? suggestedContent;

  @override
  List<Object?> get props => [area, priority, description, frequency, suggestedContent];
}

/// 内容冗余
class ContentRedundancy extends Equatable {
  const ContentRedundancy({
    required this.items,
    required this.similarity,
    required this.recommendedAction,
    this.mergedContentSuggestion,
  });

  final List<String> items; // content IDs
  final double similarity; // 0.0 - 1.0
  final RedundancyAction recommendedAction;
  final String? mergedContentSuggestion;

  @override
  List<Object?> get props => [items, similarity, recommendedAction, mergedContentSuggestion];
}

/// 优化建议
class OptimizationRecommendation extends Equatable {
  const OptimizationRecommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.estimatedImpact,
    required this.effort,
    this.implementation,
    this.dependencies = const [],
  });

  final RecommendationType type;
  final RecommendationPriority priority;
  final String title;
  final String description;
  final double estimatedImpact; // 0.0 - 1.0
  final RecommendationEffort effort;
  final String? implementation;
  final List<String> dependencies;

  @override
  List<Object?> get props => [
        type,
        priority,
        title,
        description,
        estimatedImpact,
        effort,
        implementation,
        dependencies,
      ];
}

/// 性能指标
class PerformanceMetrics extends Equatable {
  const PerformanceMetrics({
    required this.before,
    this.after,
    this.improvement,
  });

  final MetricValues before;
  final MetricValues? after;
  final MetricValues? improvement; // calculated difference

  @override
  List<Object?> get props => [before, after, improvement];
}

/// 指标值
class MetricValues extends Equatable {
  const MetricValues({
    required this.qualityScore,
    required this.relevanceScore,
    required this.userSatisfaction,
    required this.responseTime,
    required this.successRate,
  });

  final double qualityScore;
  final double relevanceScore;
  final double userSatisfaction;
  final int responseTime; // milliseconds
  final double successRate;

  @override
  List<Object> get props => [
        qualityScore,
        relevanceScore,
        userSatisfaction,
        responseTime,
        successRate,
      ];
}

/// 已实施变更
class ImplementedChange extends Equatable {
  const ImplementedChange({
    required this.changeId,
    required this.type,
    required this.description,
    required this.implementedAt,
    required this.implementedBy,
    this.impactMeasurement,
  });

  final String changeId;
  final ChangeType type;
  final String description;
  final DateTime implementedAt;
  final String implementedBy;
  final ImpactMeasurement? impactMeasurement;

  @override
  List<Object?> get props => [
        changeId,
        type,
        description,
        implementedAt,
        implementedBy,
        impactMeasurement,
      ];
}

/// 影响度量
class ImpactMeasurement extends Equatable {
  const ImpactMeasurement({
    required this.metricsBefore,
    required this.metricsAfter,
    required this.measuredAt,
    this.notes,
  });

  final MetricValues metricsBefore;
  final MetricValues metricsAfter;
  final DateTime measuredAt;
  final String? notes;

  @override
  List<Object?> get props => [metricsBefore, metricsAfter, measuredAt, notes];
}

// 枚举定义

enum AssessmentType { automated, manual, hybrid }

enum SuggestionType { 
  contentImprovement, 
  processOptimization, 
  userExperience, 
  performance,
  training
}

enum SuggestionPriority { low, medium, high, critical }

enum SuggestionCategory {
  accuracy,
  relevance,
  completeness,
  clarity,
  responsiveness,
  userInterface,
  performance
}

enum ApprovalStatus { pending, approved, rejected, needsRevision }

enum OptimizationType { 
  contentQuality, 
  searchPerformance, 
  userExperience, 
  comprehensive 
}

enum OptimizationStatus { pending, inProgress, completed, failed }

enum ComplaintSeverity { low, medium, high, critical }

enum GapPriority { low, medium, high, urgent }

enum RedundancyAction { merge, remove, keepBest, update }

enum RecommendationType {
  contentUpdate,
  contentAddition,
  contentRemoval,
  structureImprovement,
  searchOptimization,
  userInterfaceImprovement
}

enum RecommendationPriority { low, medium, high, critical }

enum RecommendationEffort { minimal, low, medium, high, extensive }

enum ChangeType {
  contentUpdate,
  contentAddition,
  contentRemoval,
  configurationChange,
  algorithmUpdate
} 