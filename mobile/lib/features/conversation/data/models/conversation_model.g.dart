// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationMessageModel _$ConversationMessageModelFromJson(
        Map<String, dynamic> json) =>
    ConversationMessageModel(
      id: json['id'] as String,
      role: $enumDecode(_$MessageRoleEnumMap, json['role']),
      content: json['content'] as String,
      contentType: json['contentType'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      sources: (json['sources'] as List<dynamic>?)
              ?.map(
                  (e) => MessageSourceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tokens: ConversationMessageModel._tokenUsageFromJson(
          json['tokens'] as Map<String, dynamic>?),
      processingTime: (json['processingTime'] as num?)?.toInt(),
      error: ConversationMessageModel._messageErrorFromJson(
          json['error'] as Map<String, dynamic>?),
    );

Map<String, dynamic> _$ConversationMessageModelToJson(
        ConversationMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$MessageRoleEnumMap[instance.role]!,
      'content': instance.content,
      'contentType': instance.contentType,
      'timestamp': instance.timestamp.toIso8601String(),
      'metadata': instance.metadata,
      'processingTime': instance.processingTime,
      'sources': instance.sources,
      'tokens': ConversationMessageModel._tokenUsageToJson(instance.tokens),
      'error': ConversationMessageModel._messageErrorToJson(instance.error),
    };

const _$MessageRoleEnumMap = {
  MessageRole.user: 'user',
  MessageRole.assistant: 'assistant',
  MessageRole.system: 'system',
};

MessageSourceModel _$MessageSourceModelFromJson(Map<String, dynamic> json) =>
    MessageSourceModel(
      type: json['type'] as String,
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      similarity: (json['similarity'] as num).toDouble(),
    );

Map<String, dynamic> _$MessageSourceModelToJson(MessageSourceModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'similarity': instance.similarity,
    };

TokenUsageModel _$TokenUsageModelFromJson(Map<String, dynamic> json) =>
    TokenUsageModel(
      promptTokens: (json['promptTokens'] as num).toInt(),
      completionTokens: (json['completionTokens'] as num).toInt(),
      totalTokens: (json['totalTokens'] as num).toInt(),
    );

Map<String, dynamic> _$TokenUsageModelToJson(TokenUsageModel instance) =>
    <String, dynamic>{
      'promptTokens': instance.promptTokens,
      'completionTokens': instance.completionTokens,
      'totalTokens': instance.totalTokens,
    };

MessageErrorModel _$MessageErrorModelFromJson(Map<String, dynamic> json) =>
    MessageErrorModel(
      code: json['code'] as String,
      message: json['message'] as String,
      details: json['details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MessageErrorModelToJson(MessageErrorModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'details': instance.details,
    };

ConversationModel _$ConversationModelFromJson(Map<String, dynamic> json) =>
    ConversationModel(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      userId: json['userId'] as String?,
      knowledgeBaseId: json['knowledgeBaseId'] as String?,
      title: json['title'] as String?,
      type: $enumDecode(_$ConversationTypeEnumMap, json['type']),
      status: $enumDecode(_$ConversationStatusEnumMap, json['status']),
      messages: (json['messages'] as List<dynamic>)
          .map((e) =>
              ConversationMessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      context: json['context'] as Map<String, dynamic>? ?? const {},
      settings: json['settings'] as Map<String, dynamic>? ?? const {},
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      rating: (json['rating'] as num?)?.toInt(),
      feedback: json['feedback'] as String?,
      messageCount: (json['messageCount'] as num).toInt(),
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String),
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      clientInfo: json['clientInfo'] as Map<String, dynamic>? ?? const {},
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ConversationModelToJson(ConversationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'userId': instance.userId,
      'knowledgeBaseId': instance.knowledgeBaseId,
      'title': instance.title,
      'type': _$ConversationTypeEnumMap[instance.type]!,
      'status': _$ConversationStatusEnumMap[instance.status]!,
      'context': instance.context,
      'settings': instance.settings,
      'tags': instance.tags,
      'rating': instance.rating,
      'feedback': instance.feedback,
      'messageCount': instance.messageCount,
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'clientInfo': instance.clientInfo,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'messages': instance.messages,
    };

const _$ConversationTypeEnumMap = {
  ConversationType.chat: 'chat',
  ConversationType.search: 'search',
  ConversationType.qa: 'qa',
  ConversationType.support: 'support',
};

const _$ConversationStatusEnumMap = {
  ConversationStatus.active: 'active',
  ConversationStatus.ended: 'ended',
  ConversationStatus.archived: 'archived',
};

ConversationStatsModel _$ConversationStatsModelFromJson(
        Map<String, dynamic> json) =>
    ConversationStatsModel(
      overview: ConversationStatsModel._overviewFromJson(
          json['overview'] as Map<String, dynamic>),
      breakdowns: ConversationStatsModel._breakdownsFromJson(
          json['breakdowns'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ConversationStatsModelToJson(
        ConversationStatsModel instance) =>
    <String, dynamic>{
      'overview': ConversationStatsModel._overviewToJson(instance.overview),
      'breakdowns':
          ConversationStatsModel._breakdownsToJson(instance.breakdowns),
    };

ConversationOverviewModel _$ConversationOverviewModelFromJson(
        Map<String, dynamic> json) =>
    ConversationOverviewModel(
      totalConversations: (json['totalConversations'] as num).toInt(),
      activeConversations: (json['activeConversations'] as num).toInt(),
      avgRating: (json['avgRating'] as num).toDouble(),
      ratedCount: (json['ratedCount'] as num).toInt(),
      totalMessages: (json['totalMessages'] as num).toInt(),
    );

Map<String, dynamic> _$ConversationOverviewModelToJson(
        ConversationOverviewModel instance) =>
    <String, dynamic>{
      'totalConversations': instance.totalConversations,
      'activeConversations': instance.activeConversations,
      'avgRating': instance.avgRating,
      'ratedCount': instance.ratedCount,
      'totalMessages': instance.totalMessages,
    };

ConversationBreakdownsModel _$ConversationBreakdownsModelFromJson(
        Map<String, dynamic> json) =>
    ConversationBreakdownsModel(
      byType: (json['byType'] as List<dynamic>)
          .map((e) =>
              ConversationTypeStatsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      byStatus: (json['byStatus'] as List<dynamic>)
          .map((e) =>
              ConversationStatusStatsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ConversationBreakdownsModelToJson(
        ConversationBreakdownsModel instance) =>
    <String, dynamic>{
      'byType': instance.byType,
      'byStatus': instance.byStatus,
    };

ConversationTypeStatsModel _$ConversationTypeStatsModelFromJson(
        Map<String, dynamic> json) =>
    ConversationTypeStatsModel(
      type: $enumDecode(_$ConversationTypeEnumMap, json['type']),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$ConversationTypeStatsModelToJson(
        ConversationTypeStatsModel instance) =>
    <String, dynamic>{
      'type': _$ConversationTypeEnumMap[instance.type]!,
      'count': instance.count,
    };

ConversationStatusStatsModel _$ConversationStatusStatsModelFromJson(
        Map<String, dynamic> json) =>
    ConversationStatusStatsModel(
      status: $enumDecode(_$ConversationStatusEnumMap, json['status']),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$ConversationStatusStatsModelToJson(
        ConversationStatusStatsModel instance) =>
    <String, dynamic>{
      'status': _$ConversationStatusEnumMap[instance.status]!,
      'count': instance.count,
    };

SendMessageRequestModel _$SendMessageRequestModelFromJson(
        Map<String, dynamic> json) =>
    SendMessageRequestModel(
      content: json['content'] as String,
      contentType: json['contentType'] as String? ?? 'text',
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$SendMessageRequestModelToJson(
        SendMessageRequestModel instance) =>
    <String, dynamic>{
      'content': instance.content,
      'contentType': instance.contentType,
      'metadata': instance.metadata,
    };

SendMessageResponseModel _$SendMessageResponseModelFromJson(
        Map<String, dynamic> json) =>
    SendMessageResponseModel(
      userMessage: ConversationMessageModel.fromJson(
          json['userMessage'] as Map<String, dynamic>),
      assistantMessage: ConversationMessageModel.fromJson(
          json['assistantMessage'] as Map<String, dynamic>),
      sources: (json['sources'] as List<dynamic>)
          .map((e) => MessageSourceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      processingTime: (json['processingTime'] as num).toInt(),
    );

Map<String, dynamic> _$SendMessageResponseModelToJson(
        SendMessageResponseModel instance) =>
    <String, dynamic>{
      'processingTime': instance.processingTime,
      'userMessage': instance.userMessage,
      'assistantMessage': instance.assistantMessage,
      'sources': instance.sources,
    };

ApiResponseModel<T> _$ApiResponseModelFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    ApiResponseModel<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$ApiResponseModelToJson<T>(
  ApiResponseModel<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': _$nullableGenericToJson(instance.data, toJsonT),
      'error': instance.error,
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);

PaginatedResponseModel<T> _$PaginatedResponseModelFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    PaginatedResponseModel<T>(
      items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$PaginatedResponseModelToJson<T>(
  PaginatedResponseModel<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'items': instance.items.map(toJsonT).toList(),
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
    };
