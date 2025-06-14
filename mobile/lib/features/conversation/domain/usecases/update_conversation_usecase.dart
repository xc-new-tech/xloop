import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/conversation_repository.dart';

class UpdateConversationUseCase implements UseCase<Conversation, UpdateConversationParams> {
  final ConversationRepository _repository;

  UpdateConversationUseCase(this._repository);

  @override
  Future<Either<Failure, Conversation>> call(UpdateConversationParams params) async {
    return await _repository.updateConversation(
      id: params.id,
      title: params.title,
      tags: params.tags,
      settings: params.settings,
      status: params.status,
    );
  }
}

class UpdateConversationParams {
  final String id;
  final String? title;
  final List<String>? tags;
  final Map<String, dynamic>? settings;
  final ConversationStatus? status;

  const UpdateConversationParams({
    required this.id,
    this.title,
    this.tags,
    this.settings,
    this.status,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateConversationParams &&
        other.id == id &&
        other.title == title &&
        _listEquals(other.tags, tags) &&
        _mapEquals(other.settings, settings) &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        tags.hashCode ^
        settings.hashCode ^
        status.hashCode;
  }

  @override
  String toString() {
    return 'UpdateConversationParams(id: $id, title: $title, tags: $tags, settings: $settings, status: $status)';
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