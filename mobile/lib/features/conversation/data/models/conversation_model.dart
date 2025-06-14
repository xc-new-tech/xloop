import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/conversation.dart';

part 'conversation_model.g.dart';

@JsonSerializable()
class ConversationMessageModel extends ConversationMessage {
  @override
  final List<MessageSourceModel> sources;

  @override
  @JsonKey(fromJson: _tokenUsageFromJson, toJson: _tokenUsageToJson)
  final TokenUsage? tokens;

  @override
  @JsonKey(fromJson: _messageErrorFromJson, toJson: _messageErrorToJson)
  final MessageError? error;

  const ConversationMessageModel({
    required super.id,
    required super.role,
    required super.content,
    required super.contentType,
    required super.timestamp,
    super.metadata = const {},
    this.sources = const [],
    this.tokens,
    super.processingTime,
    this.error,
  }) : super(sources: sources, tokens: tokens, error: error);

  static TokenUsage? _tokenUsageFromJson(Map<String, dynamic>? json) {
    return json != null ? TokenUsageModel.fromJson(json) : null;
  }

  static Map<String, dynamic>? _tokenUsageToJson(TokenUsage? tokens) {
    return tokens != null ? TokenUsageModel.fromEntity(tokens).toJson() : null;
  }

  static MessageError? _messageErrorFromJson(Map<String, dynamic>? json) {
    return json != null ? MessageErrorModel.fromJson(json) : null;
  }

  static Map<String, dynamic>? _messageErrorToJson(MessageError? error) {
    return error != null ? MessageErrorModel.fromEntity(error).toJson() : null;
  }

  factory ConversationMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationMessageModelToJson(this);

  factory ConversationMessageModel.fromEntity(ConversationMessage entity) {
    return ConversationMessageModel(
      id: entity.id,
      role: entity.role,
      content: entity.content,
      contentType: entity.contentType,
      timestamp: entity.timestamp,
      metadata: entity.metadata,
      sources: entity.sources.map((s) => MessageSourceModel.fromEntity(s)).toList(),
      tokens: entity.tokens != null ? TokenUsageModel.fromEntity(entity.tokens!) : null,
      processingTime: entity.processingTime,
      error: entity.error != null ? MessageErrorModel.fromEntity(entity.error!) : null,
    );
  }

  ConversationMessage toEntity() {
    return ConversationMessage(
      id: id,
      role: role,
      content: content,
      contentType: contentType,
      timestamp: timestamp,
      metadata: metadata,
      sources: sources.map((s) => s.toEntity()).toList(),
      tokens: tokens,
      processingTime: processingTime,
      error: error,
    );
  }
}

@JsonSerializable()
class MessageSourceModel extends MessageSource {
  const MessageSourceModel({
    required super.type,
    required super.id,
    required super.title,
    required super.content,
    required super.similarity,
  });

  factory MessageSourceModel.fromJson(Map<String, dynamic> json) =>
      _$MessageSourceModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageSourceModelToJson(this);

  factory MessageSourceModel.fromEntity(MessageSource entity) {
    return MessageSourceModel(
      type: entity.type,
      id: entity.id,
      title: entity.title,
      content: entity.content,
      similarity: entity.similarity,
    );
  }

  MessageSource toEntity() {
    return MessageSource(
      type: type,
      id: id,
      title: title,
      content: content,
      similarity: similarity,
    );
  }
}

@JsonSerializable()
class TokenUsageModel extends TokenUsage {
  const TokenUsageModel({
    required super.promptTokens,
    required super.completionTokens,
    required super.totalTokens,
  });

  factory TokenUsageModel.fromJson(Map<String, dynamic> json) =>
      _$TokenUsageModelFromJson(json);

  Map<String, dynamic> toJson() => _$TokenUsageModelToJson(this);

  factory TokenUsageModel.fromEntity(TokenUsage entity) {
    return TokenUsageModel(
      promptTokens: entity.promptTokens,
      completionTokens: entity.completionTokens,
      totalTokens: entity.totalTokens,
    );
  }

  TokenUsage toEntity() {
    return TokenUsage(
      promptTokens: promptTokens,
      completionTokens: completionTokens,
      totalTokens: totalTokens,
    );
  }
}

@JsonSerializable()
class MessageErrorModel extends MessageError {
  const MessageErrorModel({
    required super.code,
    required super.message,
    super.details,
  });

  factory MessageErrorModel.fromJson(Map<String, dynamic> json) =>
      _$MessageErrorModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageErrorModelToJson(this);

  factory MessageErrorModel.fromEntity(MessageError entity) {
    return MessageErrorModel(
      code: entity.code,
      message: entity.message,
      details: entity.details,
    );
  }

  MessageError toEntity() {
    return MessageError(
      code: code,
      message: message,
      details: details,
    );
  }
}

@JsonSerializable()
class ConversationModel extends Conversation {
  @override
  final List<ConversationMessageModel> messages;

  const ConversationModel({
    required super.id,
    required super.sessionId,
    super.userId,
    super.knowledgeBaseId,
    super.title,
    required super.type,
    required super.status,
    required this.messages,
    super.context = const {},
    super.settings = const {},
    super.tags = const [],
    super.rating,
    super.feedback,
    required super.messageCount,
    super.lastMessageAt,
    required super.startedAt,
    super.endedAt,
    super.clientInfo = const {},
    super.ipAddress,
    super.userAgent,
    required super.createdAt,
    required super.updatedAt,
  }) : super(messages: messages);

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);

  factory ConversationModel.fromEntity(Conversation entity) {
    return ConversationModel(
      id: entity.id,
      sessionId: entity.sessionId,
      userId: entity.userId,
      knowledgeBaseId: entity.knowledgeBaseId,
      title: entity.title,
      type: entity.type,
      status: entity.status,
      messages: entity.messages.map((m) => ConversationMessageModel.fromEntity(m)).toList(),
      context: entity.context,
      settings: entity.settings,
      tags: entity.tags,
      rating: entity.rating,
      feedback: entity.feedback,
      messageCount: entity.messageCount,
      lastMessageAt: entity.lastMessageAt,
      startedAt: entity.startedAt,
      endedAt: entity.endedAt,
      clientInfo: entity.clientInfo,
      ipAddress: entity.ipAddress,
      userAgent: entity.userAgent,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Conversation toEntity() {
    return Conversation(
      id: id,
      sessionId: sessionId,
      userId: userId,
      knowledgeBaseId: knowledgeBaseId,
      title: title,
      type: type,
      status: status,
      messages: messages.map((m) => m.toEntity()).toList(),
      context: context,
      settings: settings,
      tags: tags,
      rating: rating,
      feedback: feedback,
      messageCount: messageCount,
      lastMessageAt: lastMessageAt,
      startedAt: startedAt,
      endedAt: endedAt,
      clientInfo: clientInfo,
      ipAddress: ipAddress,
      userAgent: userAgent,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

@JsonSerializable()
class ConversationStatsModel extends ConversationStats {
  @override
  @JsonKey(fromJson: _overviewFromJson, toJson: _overviewToJson)
  final ConversationOverview overview;

  @override
  @JsonKey(fromJson: _breakdownsFromJson, toJson: _breakdownsToJson)
  final ConversationBreakdowns breakdowns;

  const ConversationStatsModel({
    required this.overview,
    required this.breakdowns,
  }) : super(overview: overview, breakdowns: breakdowns);

  static ConversationOverview _overviewFromJson(Map<String, dynamic> json) {
    return ConversationOverviewModel.fromJson(json);
  }

  static Map<String, dynamic> _overviewToJson(ConversationOverview overview) {
    return ConversationOverviewModel.fromEntity(overview).toJson();
  }

  static ConversationBreakdowns _breakdownsFromJson(Map<String, dynamic> json) {
    return ConversationBreakdownsModel.fromJson(json);
  }

  static Map<String, dynamic> _breakdownsToJson(ConversationBreakdowns breakdowns) {
    return ConversationBreakdownsModel.fromEntity(breakdowns).toJson();
  }

  factory ConversationStatsModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationStatsModelToJson(this);

  factory ConversationStatsModel.fromEntity(ConversationStats entity) {
    return ConversationStatsModel(
      overview: ConversationOverviewModel.fromEntity(entity.overview),
      breakdowns: ConversationBreakdownsModel.fromEntity(entity.breakdowns),
    );
  }

  ConversationStats toEntity() {
    return ConversationStats(
      overview: overview,
      breakdowns: breakdowns,
    );
  }
}

@JsonSerializable()
class ConversationOverviewModel extends ConversationOverview {
  const ConversationOverviewModel({
    required super.totalConversations,
    required super.activeConversations,
    required super.avgRating,
    required super.ratedCount,
    required super.totalMessages,
  });

  factory ConversationOverviewModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationOverviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationOverviewModelToJson(this);

  factory ConversationOverviewModel.fromEntity(ConversationOverview entity) {
    return ConversationOverviewModel(
      totalConversations: entity.totalConversations,
      activeConversations: entity.activeConversations,
      avgRating: entity.avgRating,
      ratedCount: entity.ratedCount,
      totalMessages: entity.totalMessages,
    );
  }

  ConversationOverview toEntity() {
    return ConversationOverview(
      totalConversations: totalConversations,
      activeConversations: activeConversations,
      avgRating: avgRating,
      ratedCount: ratedCount,
      totalMessages: totalMessages,
    );
  }
}

@JsonSerializable()
class ConversationBreakdownsModel extends ConversationBreakdowns {
  @override
  final List<ConversationTypeStatsModel> byType;

  @override
  final List<ConversationStatusStatsModel> byStatus;

  const ConversationBreakdownsModel({
    required this.byType,
    required this.byStatus,
  }) : super(byType: byType, byStatus: byStatus);

  factory ConversationBreakdownsModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationBreakdownsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationBreakdownsModelToJson(this);

  factory ConversationBreakdownsModel.fromEntity(ConversationBreakdowns entity) {
    return ConversationBreakdownsModel(
      byType: entity.byType.map((t) => ConversationTypeStatsModel.fromEntity(t)).toList(),
      byStatus: entity.byStatus.map((s) => ConversationStatusStatsModel.fromEntity(s)).toList(),
    );
  }

  ConversationBreakdowns toEntity() {
    return ConversationBreakdowns(
      byType: byType.map((t) => t.toEntity()).toList(),
      byStatus: byStatus.map((s) => s.toEntity()).toList(),
    );
  }
}

@JsonSerializable()
class ConversationTypeStatsModel extends ConversationTypeStats {
  const ConversationTypeStatsModel({
    required super.type,
    required super.count,
  });

  factory ConversationTypeStatsModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationTypeStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationTypeStatsModelToJson(this);

  factory ConversationTypeStatsModel.fromEntity(ConversationTypeStats entity) {
    return ConversationTypeStatsModel(
      type: entity.type,
      count: entity.count,
    );
  }

  ConversationTypeStats toEntity() {
    return ConversationTypeStats(
      type: type,
      count: count,
    );
  }
}

@JsonSerializable()
class ConversationStatusStatsModel extends ConversationStatusStats {
  const ConversationStatusStatsModel({
    required super.status,
    required super.count,
  });

  factory ConversationStatusStatsModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationStatusStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationStatusStatsModelToJson(this);

  factory ConversationStatusStatsModel.fromEntity(ConversationStatusStats entity) {
    return ConversationStatusStatsModel(
      status: entity.status,
      count: entity.count,
    );
  }

  ConversationStatusStats toEntity() {
    return ConversationStatusStats(
      status: status,
      count: count,
    );
  }
}

@JsonSerializable()
class SendMessageRequestModel extends SendMessageRequest {
  const SendMessageRequestModel({
    required super.content,
    super.contentType = 'text',
    super.metadata = const {},
  });

  factory SendMessageRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SendMessageRequestModelToJson(this);

  factory SendMessageRequestModel.fromEntity(SendMessageRequest entity) {
    return SendMessageRequestModel(
      content: entity.content,
      contentType: entity.contentType,
      metadata: entity.metadata,
    );
  }

  SendMessageRequest toEntity() {
    return SendMessageRequest(
      content: content,
      contentType: contentType,
      metadata: metadata,
    );
  }
}

@JsonSerializable()
class SendMessageResponseModel extends SendMessageResponse {
  @override
  final ConversationMessageModel userMessage;

  @override
  final ConversationMessageModel assistantMessage;

  @override
  final List<MessageSourceModel> sources;

  const SendMessageResponseModel({
    required this.userMessage,
    required this.assistantMessage,
    required this.sources,
    required super.processingTime,
  }) : super(
          userMessage: userMessage,
          assistantMessage: assistantMessage,
          sources: sources,
        );

  factory SendMessageResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SendMessageResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SendMessageResponseModelToJson(this);

  factory SendMessageResponseModel.fromEntity(SendMessageResponse entity) {
    return SendMessageResponseModel(
      userMessage: ConversationMessageModel.fromEntity(entity.userMessage),
      assistantMessage: ConversationMessageModel.fromEntity(entity.assistantMessage),
      sources: entity.sources.map((s) => MessageSourceModel.fromEntity(s)).toList(),
      processingTime: entity.processingTime,
    );
  }

  SendMessageResponse toEntity() {
    return SendMessageResponse(
      userMessage: userMessage.toEntity(),
      assistantMessage: assistantMessage.toEntity(),
      sources: sources.map((s) => s.toEntity()).toList(),
      processingTime: processingTime,
    );
  }
}

/// API响应包装模型
@JsonSerializable(genericArgumentFactories: true)
class ApiResponseModel<T> {
  const ApiResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  final bool success;
  final String message;
  final T? data;
  final String? error;

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseModelFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseModelToJson(this, toJsonT);
}

/// 分页响应模型
@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponseModel<T> {
  const PaginatedResponseModel({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  factory PaginatedResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedResponseModelFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PaginatedResponseModelToJson(this, toJsonT);

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
} 