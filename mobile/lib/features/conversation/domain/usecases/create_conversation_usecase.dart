import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/conversation_repository.dart';

class CreateConversationUseCase implements UseCase<Conversation, CreateConversationParams> {
  final ConversationRepository _repository;

  CreateConversationUseCase(this._repository);

  @override
  Future<Either<Failure, Conversation>> call(CreateConversationParams params) async {
    return await _repository.createConversation(
      knowledgeBaseId: params.knowledgeBaseId,
      title: params.title,
      type: params.type,
      settings: params.settings,
      tags: params.tags,
    );
  }
}

class CreateConversationParams {
  final String? knowledgeBaseId;
  final String? title;
  final ConversationType type;
  final Map<String, dynamic> settings;
  final List<String> tags;

  const CreateConversationParams({
    this.knowledgeBaseId,
    this.title,
    this.type = ConversationType.chat,
    this.settings = const {},
    this.tags = const [],
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreateConversationParams &&
        other.knowledgeBaseId == knowledgeBaseId &&
        other.title == title &&
        other.type == type &&
        _mapEquals(other.settings, settings) &&
        _listEquals(other.tags, tags);
  }

  @override
  int get hashCode {
    return knowledgeBaseId.hashCode ^
        title.hashCode ^
        type.hashCode ^
        settings.hashCode ^
        tags.hashCode;
  }

  @override
  String toString() {
    return 'CreateConversationParams(knowledgeBaseId: $knowledgeBaseId, title: $title, type: $type, settings: $settings, tags: $tags)';
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  bool _mapEquals<T, U>(Map<T, U>? a, Map<T, U>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final T key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) return false;
    }
    return true;
  }
} 