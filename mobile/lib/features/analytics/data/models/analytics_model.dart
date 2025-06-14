import '../../domain/entities/analytics_entity.dart';

/// 对话质量评估模型
class ConversationQualityAssessmentModel extends ConversationQualityAssessment {
  const ConversationQualityAssessmentModel({
    required super.id,
    required super.conversationId,
    required super.messageId,
    required super.qualityScore,
    required super.dimensions,
    required super.feedback,
    super.suggestions = const [],
    super.automatedAssessment,
    super.manualReview,
    required super.timestamp,
    required super.assessmentType,
    super.metadata = const {},
  });

  factory ConversationQualityAssessmentModel.fromJson(Map<String, dynamic> json) {
    return ConversationQualityAssessmentModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      messageId: json['message_id'] as String,
      qualityScore: (json['quality_score'] as num).toDouble(),
      dimensions: QualityDimensionsModel.fromJson(json['dimensions'] as Map<String, dynamic>),
      feedback: QualityFeedbackModel.fromJson(json['feedback'] as Map<String, dynamic>),
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((item) => ImprovementSuggestionModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      automatedAssessment: json['automated_assessment'] != null
          ? AutomatedAssessmentModel.fromJson(json['automated_assessment'] as Map<String, dynamic>)
          : null,
      manualReview: json['manual_review'] != null
          ? ManualReviewModel.fromJson(json['manual_review'] as Map<String, dynamic>)
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
      assessmentType: AssessmentType.values.byName(json['assessment_type'] as String),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'message_id': messageId,
      'quality_score': qualityScore,
      'dimensions': (dimensions as QualityDimensionsModel).toJson(),
      'feedback': (feedback as QualityFeedbackModel).toJson(),
      'suggestions': suggestions.map((s) => (s as ImprovementSuggestionModel).toJson()).toList(),
      'automated_assessment': automatedAssessment != null
          ? (automatedAssessment as AutomatedAssessmentModel).toJson()
          : null,
      'manual_review': manualReview != null
          ? (manualReview as ManualReviewModel).toJson()
          : null,
      'timestamp': timestamp.toIso8601String(),
      'assessment_type': assessmentType.name,
      'metadata': metadata,
    };
  }

  factory ConversationQualityAssessmentModel.fromEntity(ConversationQualityAssessment entity) {
    return ConversationQualityAssessmentModel(
      id: entity.id,
      conversationId: entity.conversationId,
      messageId: entity.messageId,
      qualityScore: entity.qualityScore,
      dimensions: entity.dimensions,
      feedback: entity.feedback,
      suggestions: entity.suggestions,
      automatedAssessment: entity.automatedAssessment,
      manualReview: entity.manualReview,
      timestamp: entity.timestamp,
      assessmentType: entity.assessmentType,
      metadata: entity.metadata,
    );
  }
}

/// 质量维度模型
class QualityDimensionsModel extends QualityDimensions {
  const QualityDimensionsModel({
    required super.accuracy,
    required super.relevance,
    required super.completeness,
    required super.clarity,
    required super.helpfulness,
    required super.responsiveness,
  });

  factory QualityDimensionsModel.fromJson(Map<String, dynamic> json) {
    return QualityDimensionsModel(
      accuracy: (json['accuracy'] as num).toDouble(),
      relevance: (json['relevance'] as num).toDouble(),
      completeness: (json['completeness'] as num).toDouble(),
      clarity: (json['clarity'] as num).toDouble(),
      helpfulness: (json['helpfulness'] as num).toDouble(),
      responsiveness: (json['responsiveness'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accuracy': accuracy,
      'relevance': relevance,
      'completeness': completeness,
      'clarity': clarity,
      'helpfulness': helpfulness,
      'responsiveness': responsiveness,
    };
  }
}

/// 质量反馈模型
class QualityFeedbackModel extends QualityFeedback {
  const QualityFeedbackModel({
    required super.userRating,
    super.userComment,
    super.userTags = const [],
    super.systemRating,
    super.systemComment,
    super.systemTags = const [],
  });

  factory QualityFeedbackModel.fromJson(Map<String, dynamic> json) {
    return QualityFeedbackModel(
      userRating: json['user_rating'] as int?,
      userComment: json['user_comment'] as String?,
      userTags: List<String>.from(json['user_tags'] as List<dynamic>? ?? []),
      systemRating: (json['system_rating'] as num?)?.toDouble(),
      systemComment: json['system_comment'] as String?,
      systemTags: List<String>.from(json['system_tags'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_rating': userRating,
      'user_comment': userComment,
      'user_tags': userTags,
      'system_rating': systemRating,
      'system_comment': systemComment,
      'system_tags': systemTags,
    };
  }
}

/// 改进建议模型
class ImprovementSuggestionModel extends ImprovementSuggestion {
  const ImprovementSuggestionModel({
    required super.type,
    required super.priority,
    required super.description,
    required super.category,
    super.actionRequired,
    super.estimatedImpact,
    super.implementationNotes,
  });

  factory ImprovementSuggestionModel.fromJson(Map<String, dynamic> json) {
    return ImprovementSuggestionModel(
      type: SuggestionType.values.byName(json['type'] as String),
      priority: SuggestionPriority.values.byName(json['priority'] as String),
      description: json['description'] as String,
      category: SuggestionCategory.values.byName(json['category'] as String),
      actionRequired: json['action_required'] as String?,
      estimatedImpact: (json['estimated_impact'] as num?)?.toDouble(),
      implementationNotes: json['implementation_notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'priority': priority.name,
      'description': description,
      'category': category.name,
      'action_required': actionRequired,
      'estimated_impact': estimatedImpact,
      'implementation_notes': implementationNotes,
    };
  }
}

/// 自动评估模型
class AutomatedAssessmentModel extends AutomatedAssessment {
  const AutomatedAssessmentModel({
    required super.modelName,
    required super.modelVersion,
    required super.confidence,
    required super.processingTime,
    super.features = const {},
    super.rawOutput = const {},
  });

  factory AutomatedAssessmentModel.fromJson(Map<String, dynamic> json) {
    return AutomatedAssessmentModel(
      modelName: json['model_name'] as String,
      modelVersion: json['model_version'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      processingTime: json['processing_time'] as int,
      features: Map<String, dynamic>.from(json['features'] as Map<String, dynamic>? ?? {}),
      rawOutput: Map<String, dynamic>.from(json['raw_output'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model_name': modelName,
      'model_version': modelVersion,
      'confidence': confidence,
      'processing_time': processingTime,
      'features': features,
      'raw_output': rawOutput,
    };
  }
}

/// 人工审核模型
class ManualReviewModel extends ManualReview {
  const ManualReviewModel({
    required super.reviewerId,
    required super.reviewerName,
    required super.reviewDate,
    required super.reviewScore,
    super.reviewComments,
    super.approvalStatus,
    super.reviewTime,
  });

  factory ManualReviewModel.fromJson(Map<String, dynamic> json) {
    return ManualReviewModel(
      reviewerId: json['reviewer_id'] as String,
      reviewerName: json['reviewer_name'] as String,
      reviewDate: DateTime.parse(json['review_date'] as String),
      reviewScore: (json['review_score'] as num).toDouble(),
      reviewComments: json['review_comments'] as String?,
      approvalStatus: json['approval_status'] != null 
          ? ApprovalStatus.values.byName(json['approval_status'] as String)
          : null,
      reviewTime: json['review_time'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewer_id': reviewerId,
      'reviewer_name': reviewerName,
      'review_date': reviewDate.toIso8601String(),
      'review_score': reviewScore,
      'review_comments': reviewComments,
      'approval_status': approvalStatus?.name,
      'review_time': reviewTime,
    };
  }
}

/// 知识库调优模型
class KnowledgeBaseOptimizationModel extends KnowledgeBaseOptimization {
  const KnowledgeBaseOptimizationModel({
    required super.id,
    required super.knowledgeBaseId,
    required super.optimizationType,
    required super.analysis,
    required super.recommendations,
    required super.performanceMetrics,
    super.implementedChanges = const [],
    required super.status,
    required super.createdAt,
    super.completedAt,
    super.metadata = const {},
  });

  factory KnowledgeBaseOptimizationModel.fromJson(Map<String, dynamic> json) {
    return KnowledgeBaseOptimizationModel(
      id: json['id'] as String,
      knowledgeBaseId: json['knowledge_base_id'] as String,
      optimizationType: OptimizationType.values.byName(json['optimization_type'] as String),
      analysis: OptimizationAnalysisModel.fromJson(json['analysis'] as Map<String, dynamic>),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((item) => OptimizationRecommendationModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      performanceMetrics: PerformanceMetricsModel.fromJson(json['performance_metrics'] as Map<String, dynamic>),
      implementedChanges: (json['implemented_changes'] as List<dynamic>?)
              ?.map((item) => ImplementedChangeModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      status: OptimizationStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'knowledge_base_id': knowledgeBaseId,
      'optimization_type': optimizationType.name,
      'analysis': (analysis as OptimizationAnalysisModel).toJson(),
      'recommendations': recommendations.map((r) => (r as OptimizationRecommendationModel).toJson()).toList(),
      'performance_metrics': (performanceMetrics as PerformanceMetricsModel).toJson(),
      'implemented_changes': implementedChanges.map((c) => (c as ImplementedChangeModel).toJson()).toList(),
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory KnowledgeBaseOptimizationModel.fromEntity(KnowledgeBaseOptimization entity) {
    return KnowledgeBaseOptimizationModel(
      id: entity.id,
      knowledgeBaseId: entity.knowledgeBaseId,
      optimizationType: entity.optimizationType,
      analysis: entity.analysis,
      recommendations: entity.recommendations,
      performanceMetrics: entity.performanceMetrics,
      implementedChanges: entity.implementedChanges,
      status: entity.status,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
      metadata: entity.metadata,
    );
  }
}

/// 优化分析模型
class OptimizationAnalysisModel extends OptimizationAnalysis {
  const OptimizationAnalysisModel({
    required super.contentQuality,
    required super.searchPerformance,
    required super.userSatisfaction,
    required super.coverage,
    required super.gaps,
    required super.redundancies,
  });

  factory OptimizationAnalysisModel.fromJson(Map<String, dynamic> json) {
    return OptimizationAnalysisModel(
      contentQuality: ContentQualityAnalysisModel.fromJson(json['content_quality'] as Map<String, dynamic>),
      searchPerformance: SearchPerformanceAnalysisModel.fromJson(json['search_performance'] as Map<String, dynamic>),
      userSatisfaction: UserSatisfactionAnalysisModel.fromJson(json['user_satisfaction'] as Map<String, dynamic>),
      coverage: CoverageAnalysisModel.fromJson(json['coverage'] as Map<String, dynamic>),
      gaps: (json['gaps'] as List<dynamic>)
          .map((item) => ContentGapModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      redundancies: (json['redundancies'] as List<dynamic>)
          .map((item) => ContentRedundancyModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content_quality': (contentQuality as ContentQualityAnalysisModel).toJson(),
      'search_performance': (searchPerformance as SearchPerformanceAnalysisModel).toJson(),
      'user_satisfaction': (userSatisfaction as UserSatisfactionAnalysisModel).toJson(),
      'coverage': (coverage as CoverageAnalysisModel).toJson(),
      'gaps': gaps.map((g) => (g as ContentGapModel).toJson()).toList(),
      'redundancies': redundancies.map((r) => (r as ContentRedundancyModel).toJson()).toList(),
    };
  }
}

/// 内容质量分析模型
class ContentQualityAnalysisModel extends ContentQualityAnalysis {
  const ContentQualityAnalysisModel({
    required super.averageQuality,
    required super.qualityDistribution,
    required super.lowQualityItems,
    required super.qualityTrends,
  });

  factory ContentQualityAnalysisModel.fromJson(Map<String, dynamic> json) {
    return ContentQualityAnalysisModel(
      averageQuality: (json['average_quality'] as num).toDouble(),
      qualityDistribution: Map<String, int>.from(json['quality_distribution'] as Map<String, dynamic>),
      lowQualityItems: List<String>.from(json['low_quality_items'] as List<dynamic>),
      qualityTrends: Map<String, double>.from(
          (json['quality_trends'] as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toDouble()))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_quality': averageQuality,
      'quality_distribution': qualityDistribution,
      'low_quality_items': lowQualityItems,
      'quality_trends': qualityTrends,
    };
  }
}

/// 搜索性能分析模型
class SearchPerformanceAnalysisModel extends SearchPerformanceAnalysis {
  const SearchPerformanceAnalysisModel({
    required super.averageRelevance,
    required super.searchSuccessRate,
    required super.averageResponseTime,
    required super.popularQueries,
    required super.failedQueries,
  });

  factory SearchPerformanceAnalysisModel.fromJson(Map<String, dynamic> json) {
    return SearchPerformanceAnalysisModel(
      averageRelevance: (json['average_relevance'] as num).toDouble(),
      searchSuccessRate: (json['search_success_rate'] as num).toDouble(),
      averageResponseTime: json['average_response_time'] as int,
      popularQueries: (json['popular_queries'] as List<dynamic>)
          .map((item) => QueryAnalysisModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      failedQueries: (json['failed_queries'] as List<dynamic>)
          .map((item) => QueryAnalysisModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_relevance': averageRelevance,
      'search_success_rate': searchSuccessRate,
      'average_response_time': averageResponseTime,
      'popular_queries': popularQueries.map((q) => (q as QueryAnalysisModel).toJson()).toList(),
      'failed_queries': failedQueries.map((q) => (q as QueryAnalysisModel).toJson()).toList(),
    };
  }
}

/// 查询分析模型
class QueryAnalysisModel extends QueryAnalysis {
  const QueryAnalysisModel({
    required super.query,
    required super.frequency,
    required super.successRate,
    required super.averageRelevance,
    super.suggestions = const [],
  });

  factory QueryAnalysisModel.fromJson(Map<String, dynamic> json) {
    return QueryAnalysisModel(
      query: json['query'] as String,
      frequency: json['frequency'] as int,
      successRate: (json['success_rate'] as num).toDouble(),
      averageRelevance: (json['average_relevance'] as num).toDouble(),
      suggestions: List<String>.from(json['suggestions'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'frequency': frequency,
      'success_rate': successRate,
      'average_relevance': averageRelevance,
      'suggestions': suggestions,
    };
  }
}

/// 用户满意度分析模型
class UserSatisfactionAnalysisModel extends UserSatisfactionAnalysis {
  const UserSatisfactionAnalysisModel({
    required super.averageRating,
    required super.ratingDistribution,
    required super.feedbackSentiment,
    required super.commonComplaints,
    required super.userRetention,
  });

  factory UserSatisfactionAnalysisModel.fromJson(Map<String, dynamic> json) {
    return UserSatisfactionAnalysisModel(
      averageRating: (json['average_rating'] as num).toDouble(),
      ratingDistribution: Map<int, int>.from(
          (json['rating_distribution'] as Map<String, dynamic>).map((k, v) => MapEntry(int.parse(k), v as int))),
      feedbackSentiment: SentimentAnalysisModel.fromJson(json['feedback_sentiment'] as Map<String, dynamic>),
      commonComplaints: (json['common_complaints'] as List<dynamic>)
          .map((item) => ComplaintAnalysisModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      userRetention: (json['user_retention'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_rating': averageRating,
      'rating_distribution': ratingDistribution.map((k, v) => MapEntry(k.toString(), v)),
      'feedback_sentiment': (feedbackSentiment as SentimentAnalysisModel).toJson(),
      'common_complaints': commonComplaints.map((c) => (c as ComplaintAnalysisModel).toJson()).toList(),
      'user_retention': userRetention,
    };
  }
}

/// 情感分析模型
class SentimentAnalysisModel extends SentimentAnalysis {
  const SentimentAnalysisModel({
    required super.positive,
    required super.neutral,
    required super.negative,
  });

  factory SentimentAnalysisModel.fromJson(Map<String, dynamic> json) {
    return SentimentAnalysisModel(
      positive: (json['positive'] as num).toDouble(),
      neutral: (json['neutral'] as num).toDouble(),
      negative: (json['negative'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'positive': positive,
      'neutral': neutral,
      'negative': negative,
    };
  }
}

/// 投诉分析模型
class ComplaintAnalysisModel extends ComplaintAnalysis {
  const ComplaintAnalysisModel({
    required super.category,
    required super.frequency,
    required super.severity,
    required super.examples,
  });

  factory ComplaintAnalysisModel.fromJson(Map<String, dynamic> json) {
    return ComplaintAnalysisModel(
      category: json['category'] as String,
      frequency: json['frequency'] as int,
      severity: ComplaintSeverity.values.byName(json['severity'] as String),
      examples: List<String>.from(json['examples'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'frequency': frequency,
      'severity': severity.name,
      'examples': examples,
    };
  }
}

/// 覆盖率分析模型
class CoverageAnalysisModel extends CoverageAnalysis {
  const CoverageAnalysisModel({
    required super.topicCoverage,
    required super.domainCoverage,
    required super.languageCoverage,
    required super.uncoveredAreas,
  });

  factory CoverageAnalysisModel.fromJson(Map<String, dynamic> json) {
    return CoverageAnalysisModel(
      topicCoverage: Map<String, double>.from(
          (json['topic_coverage'] as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toDouble()))),
      domainCoverage: Map<String, double>.from(
          (json['domain_coverage'] as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toDouble()))),
      languageCoverage: Map<String, double>.from(
          (json['language_coverage'] as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toDouble()))),
      uncoveredAreas: List<String>.from(json['uncovered_areas'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic_coverage': topicCoverage,
      'domain_coverage': domainCoverage,
      'language_coverage': languageCoverage,
      'uncovered_areas': uncoveredAreas,
    };
  }
}

/// 内容缺口模型
class ContentGapModel extends ContentGap {
  const ContentGapModel({
    required super.area,
    required super.priority,
    required super.description,
    required super.frequency,
    super.suggestedContent,
  });

  factory ContentGapModel.fromJson(Map<String, dynamic> json) {
    return ContentGapModel(
      area: json['area'] as String,
      priority: GapPriority.values.byName(json['priority'] as String),
      description: json['description'] as String,
      frequency: json['frequency'] as int,
      suggestedContent: json['suggested_content'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area': area,
      'priority': priority.name,
      'description': description,
      'frequency': frequency,
      'suggested_content': suggestedContent,
    };
  }
}

/// 内容冗余模型
class ContentRedundancyModel extends ContentRedundancy {
  const ContentRedundancyModel({
    required super.items,
    required super.similarity,
    required super.recommendedAction,
    super.mergedContentSuggestion,
  });

  factory ContentRedundancyModel.fromJson(Map<String, dynamic> json) {
    return ContentRedundancyModel(
      items: List<String>.from(json['items'] as List<dynamic>),
      similarity: (json['similarity'] as num).toDouble(),
      recommendedAction: RedundancyAction.values.byName(json['recommended_action'] as String),
      mergedContentSuggestion: json['merged_content_suggestion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items,
      'similarity': similarity,
      'recommended_action': recommendedAction.name,
      'merged_content_suggestion': mergedContentSuggestion,
    };
  }
}

/// 优化建议模型
class OptimizationRecommendationModel extends OptimizationRecommendation {
  const OptimizationRecommendationModel({
    required super.type,
    required super.priority,
    required super.title,
    required super.description,
    required super.estimatedImpact,
    required super.effort,
    super.implementation,
    super.dependencies = const [],
  });

  factory OptimizationRecommendationModel.fromJson(Map<String, dynamic> json) {
    return OptimizationRecommendationModel(
      type: RecommendationType.values.byName(json['type'] as String),
      priority: RecommendationPriority.values.byName(json['priority'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      estimatedImpact: (json['estimated_impact'] as num).toDouble(),
      effort: RecommendationEffort.values.byName(json['effort'] as String),
      implementation: json['implementation'] as String?,
      dependencies: List<String>.from(json['dependencies'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'priority': priority.name,
      'title': title,
      'description': description,
      'estimated_impact': estimatedImpact,
      'effort': effort.name,
      'implementation': implementation,
      'dependencies': dependencies,
    };
  }
}

/// 性能指标模型
class PerformanceMetricsModel extends PerformanceMetrics {
  const PerformanceMetricsModel({
    required super.before,
    super.after,
    super.improvement,
  });

  factory PerformanceMetricsModel.fromJson(Map<String, dynamic> json) {
    return PerformanceMetricsModel(
      before: MetricValuesModel.fromJson(json['before'] as Map<String, dynamic>),
      after: json['after'] != null 
          ? MetricValuesModel.fromJson(json['after'] as Map<String, dynamic>)
          : null,
      improvement: json['improvement'] != null 
          ? MetricValuesModel.fromJson(json['improvement'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'before': (before as MetricValuesModel).toJson(),
      'after': after != null ? (after as MetricValuesModel).toJson() : null,
      'improvement': improvement != null ? (improvement as MetricValuesModel).toJson() : null,
    };
  }
}

/// 指标值模型
class MetricValuesModel extends MetricValues {
  const MetricValuesModel({
    required super.qualityScore,
    required super.relevanceScore,
    required super.userSatisfaction,
    required super.responseTime,
    required super.successRate,
  });

  factory MetricValuesModel.fromJson(Map<String, dynamic> json) {
    return MetricValuesModel(
      qualityScore: (json['quality_score'] as num).toDouble(),
      relevanceScore: (json['relevance_score'] as num).toDouble(),
      userSatisfaction: (json['user_satisfaction'] as num).toDouble(),
      responseTime: json['response_time'] as int,
      successRate: (json['success_rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quality_score': qualityScore,
      'relevance_score': relevanceScore,
      'user_satisfaction': userSatisfaction,
      'response_time': responseTime,
      'success_rate': successRate,
    };
  }
}

/// 已实施变更模型
class ImplementedChangeModel extends ImplementedChange {
  const ImplementedChangeModel({
    required super.changeId,
    required super.type,
    required super.description,
    required super.implementedAt,
    required super.implementedBy,
    super.impactMeasurement,
  });

  factory ImplementedChangeModel.fromJson(Map<String, dynamic> json) {
    return ImplementedChangeModel(
      changeId: json['change_id'] as String,
      type: ChangeType.values.byName(json['type'] as String),
      description: json['description'] as String,
      implementedAt: DateTime.parse(json['implemented_at'] as String),
      implementedBy: json['implemented_by'] as String,
      impactMeasurement: json['impact_measurement'] != null 
          ? ImpactMeasurementModel.fromJson(json['impact_measurement'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'change_id': changeId,
      'type': type.name,
      'description': description,
      'implemented_at': implementedAt.toIso8601String(),
      'implemented_by': implementedBy,
      'impact_measurement': impactMeasurement != null 
          ? (impactMeasurement as ImpactMeasurementModel).toJson()
          : null,
    };
  }
}

/// 影响度量模型
class ImpactMeasurementModel extends ImpactMeasurement {
  const ImpactMeasurementModel({
    required super.metricsBefore,
    required super.metricsAfter,
    required super.measuredAt,
    super.notes,
  });

  factory ImpactMeasurementModel.fromJson(Map<String, dynamic> json) {
    return ImpactMeasurementModel(
      metricsBefore: MetricValuesModel.fromJson(json['metrics_before'] as Map<String, dynamic>),
      metricsAfter: MetricValuesModel.fromJson(json['metrics_after'] as Map<String, dynamic>),
      measuredAt: DateTime.parse(json['measured_at'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metrics_before': (metricsBefore as MetricValuesModel).toJson(),
      'metrics_after': (metricsAfter as MetricValuesModel).toJson(),
      'measured_at': measuredAt.toIso8601String(),
      'notes': notes,
    };
  }
} 