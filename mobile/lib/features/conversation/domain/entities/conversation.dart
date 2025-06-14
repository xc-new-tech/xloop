import 'package:equatable/equatable.dart';

/// 对话消息实体
class ConversationMessage extends Equatable {
  const ConversationMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.contentType,
    required this.timestamp,
    this.metadata = const {},
    this.sources = const [],
    this.tokens,
    this.processingTime,
    this.error,
  });

  final String id;
  final MessageRole role;
  final String content;
  final String contentType;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final List<MessageSource> sources;
  final TokenUsage? tokens;
  final int? processingTime;
  final MessageError? error;

  @override
  List<Object?> get props => [
        id,
        role,
        content,
        contentType,
        timestamp,
        metadata,
        sources,
        tokens,
        processingTime,
        error,
      ];

  ConversationMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    String? contentType,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    List<MessageSource>? sources,
    TokenUsage? tokens,
    int? processingTime,
    MessageError? error,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      sources: sources ?? this.sources,
      tokens: tokens ?? this.tokens,
      processingTime: processingTime ?? this.processingTime,
      error: error ?? this.error,
    );
  }
}

/// 消息角色枚举
enum MessageRole {
  user,
  assistant,
  system;

  String get value {
    switch (this) {
      case MessageRole.user:
        return 'user';
      case MessageRole.assistant:
        return 'assistant';
      case MessageRole.system:
        return 'system';
    }
  }

  static MessageRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'user':
        return MessageRole.user;
      case 'assistant':
        return MessageRole.assistant;
      case 'system':
        return MessageRole.system;
      default:
        throw ArgumentError('Invalid message role: $value');
    }
  }
}

/// 消息来源
class MessageSource extends Equatable {
  const MessageSource({
    required this.type,
    required this.id,
    required this.title,
    required this.content,
    required this.similarity,
  });

  final String type;
  final String id;
  final String title;
  final String content;
  final double similarity;

  @override
  List<Object> get props => [type, id, title, content, similarity];
}

/// Token使用统计
class TokenUsage extends Equatable {
  const TokenUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  @override
  List<Object> get props => [promptTokens, completionTokens, totalTokens];
}

/// 消息错误
class MessageError extends Equatable {
  const MessageError({
    required this.code,
    required this.message,
    this.details,
  });

  final String code;
  final String message;
  final Map<String, dynamic>? details;

  @override
  List<Object?> get props => [code, message, details];
}

/// 对话实体
class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.sessionId,
    this.userId,
    this.knowledgeBaseId,
    this.title,
    required this.type,
    required this.status,
    required this.messages,
    this.context = const {},
    this.settings = const {},
    this.tags = const [],
    this.rating,
    this.feedback,
    required this.messageCount,
    this.lastMessageAt,
    required this.startedAt,
    this.endedAt,
    this.clientInfo = const {},
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String sessionId;
  final String? userId;
  final String? knowledgeBaseId;
  final String? title;
  final ConversationType type;
  final ConversationStatus status;
  final List<ConversationMessage> messages;
  final Map<String, dynamic> context;
  final Map<String, dynamic> settings;
  final List<String> tags;
  final int? rating;
  final String? feedback;
  final int messageCount;
  final DateTime? lastMessageAt;
  final DateTime startedAt;
  final DateTime? endedAt;
  final Map<String, dynamic> clientInfo;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        sessionId,
        userId,
        knowledgeBaseId,
        title,
        type,
        status,
        messages,
        context,
        settings,
        tags,
        rating,
        feedback,
        messageCount,
        lastMessageAt,
        startedAt,
        endedAt,
        clientInfo,
        ipAddress,
        userAgent,
        createdAt,
        updatedAt,
      ];

  Conversation copyWith({
    String? id,
    String? sessionId,
    String? userId,
    String? knowledgeBaseId,
    String? title,
    ConversationType? type,
    ConversationStatus? status,
    List<ConversationMessage>? messages,
    Map<String, dynamic>? context,
    Map<String, dynamic>? settings,
    List<String>? tags,
    int? rating,
    String? feedback,
    int? messageCount,
    DateTime? lastMessageAt,
    DateTime? startedAt,
    DateTime? endedAt,
    Map<String, dynamic>? clientInfo,
    String? ipAddress,
    String? userAgent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      knowledgeBaseId: knowledgeBaseId ?? this.knowledgeBaseId,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      messages: messages ?? this.messages,
      context: context ?? this.context,
      settings: settings ?? this.settings,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      messageCount: messageCount ?? this.messageCount,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      clientInfo: clientInfo ?? this.clientInfo,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 获取最后一条消息
  ConversationMessage? get lastMessage {
    return messages.isNotEmpty ? messages.last : null;
  }

  /// 获取最后一条用户消息
  ConversationMessage? get lastUserMessage {
    return messages
        .where((message) => message.role == MessageRole.user)
        .lastOrNull;
  }

  /// 获取最后一条助手消息
  ConversationMessage? get lastAssistantMessage {
    return messages
        .where((message) => message.role == MessageRole.assistant)
        .lastOrNull;
  }

  /// 是否为活跃对话
  bool get isActive => status == ConversationStatus.active;

  /// 是否已结束
  bool get isEnded => status == ConversationStatus.ended;

  /// 是否已归档
  bool get isArchived => status == ConversationStatus.archived;

  /// 是否有评分
  bool get hasRating => rating != null;
}

/// 对话类型枚举
enum ConversationType {
  chat,
  search,
  qa,
  support;

  String get value {
    switch (this) {
      case ConversationType.chat:
        return 'chat';
      case ConversationType.search:
        return 'search';
      case ConversationType.qa:
        return 'qa';
      case ConversationType.support:
        return 'support';
    }
  }

  String get displayName {
    switch (this) {
      case ConversationType.chat:
        return '聊天';
      case ConversationType.search:
        return '搜索';
      case ConversationType.qa:
        return '问答';
      case ConversationType.support:
        return '支持';
    }
  }

  static ConversationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'chat':
        return ConversationType.chat;
      case 'search':
        return ConversationType.search;
      case 'qa':
        return ConversationType.qa;
      case 'support':
        return ConversationType.support;
      default:
        throw ArgumentError('Invalid conversation type: $value');
    }
  }
}

/// 对话状态枚举
enum ConversationStatus {
  active,
  ended,
  archived;

  String get value {
    switch (this) {
      case ConversationStatus.active:
        return 'active';
      case ConversationStatus.ended:
        return 'ended';
      case ConversationStatus.archived:
        return 'archived';
    }
  }

  String get displayName {
    switch (this) {
      case ConversationStatus.active:
        return '活跃';
      case ConversationStatus.ended:
        return '已结束';
      case ConversationStatus.archived:
        return '已归档';
    }
  }

  static ConversationStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return ConversationStatus.active;
      case 'ended':
        return ConversationStatus.ended;
      case 'archived':
        return ConversationStatus.archived;
      default:
        throw ArgumentError('Invalid conversation status: $value');
    }
  }
}

/// 对话统计
class ConversationStats extends Equatable {
  const ConversationStats({
    required this.overview,
    required this.breakdowns,
  });

  final ConversationOverview overview;
  final ConversationBreakdowns breakdowns;

  @override
  List<Object> get props => [overview, breakdowns];
}

/// 对话概览统计
class ConversationOverview extends Equatable {
  const ConversationOverview({
    required this.totalConversations,
    required this.activeConversations,
    required this.avgRating,
    required this.ratedCount,
    required this.totalMessages,
  });

  final int totalConversations;
  final int activeConversations;
  final double avgRating;
  final int ratedCount;
  final int totalMessages;

  @override
  List<Object> get props => [
        totalConversations,
        activeConversations,
        avgRating,
        ratedCount,
        totalMessages,
      ];
}

/// 对话分类统计
class ConversationBreakdowns extends Equatable {
  const ConversationBreakdowns({
    required this.byType,
    required this.byStatus,
  });

  final List<ConversationTypeStats> byType;
  final List<ConversationStatusStats> byStatus;

  @override
  List<Object> get props => [byType, byStatus];
}

/// 按类型统计
class ConversationTypeStats extends Equatable {
  const ConversationTypeStats({
    required this.type,
    required this.count,
  });

  final ConversationType type;
  final int count;

  @override
  List<Object> get props => [type, count];
}

/// 按状态统计
class ConversationStatusStats extends Equatable {
  const ConversationStatusStats({
    required this.status,
    required this.count,
  });

  final ConversationStatus status;
  final int count;

  @override
  List<Object> get props => [status, count];
}

/// 发送消息请求
class SendMessageRequest extends Equatable {
  const SendMessageRequest({
    required this.content,
    this.contentType = 'text',
    this.metadata = const {},
  });

  final String content;
  final String contentType;
  final Map<String, dynamic> metadata;

  @override
  List<Object> get props => [content, contentType, metadata];
}

/// 发送消息响应
class SendMessageResponse extends Equatable {
  const SendMessageResponse({
    required this.userMessage,
    required this.assistantMessage,
    required this.sources,
    required this.processingTime,
  });

  final ConversationMessage userMessage;
  final ConversationMessage assistantMessage;
  final List<MessageSource> sources;
  final int processingTime;

  @override
  List<Object> get props => [userMessage, assistantMessage, sources, processingTime];
}

extension on List<ConversationMessage> {
  ConversationMessage? get lastOrNull => isEmpty ? null : last;
} 