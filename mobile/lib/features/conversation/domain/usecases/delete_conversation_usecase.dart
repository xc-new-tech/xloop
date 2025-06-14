import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/conversation_repository.dart';

class DeleteConversationUseCase implements UseCase<void, DeleteConversationParams> {
  final ConversationRepository _repository;

  DeleteConversationUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteConversationParams params) async {
    return await _repository.deleteConversation(params.id);
  }
}

class DeleteConversationParams {
  final String id;

  const DeleteConversationParams({required this.id});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteConversationParams && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DeleteConversationParams(id: $id)';
}

class BulkDeleteConversationsUseCase implements UseCase<int, BulkDeleteConversationsParams> {
  final ConversationRepository _repository;

  BulkDeleteConversationsUseCase(this._repository);

  @override
  Future<Either<Failure, int>> call(BulkDeleteConversationsParams params) async {
    return await _repository.bulkDeleteConversations(params.ids);
  }
}

class BulkDeleteConversationsParams {
  final List<String> ids;

  const BulkDeleteConversationsParams({required this.ids});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BulkDeleteConversationsParams && _listEquals(other.ids, ids);
  }

  @override
  int get hashCode => ids.hashCode;

  @override
  String toString() => 'BulkDeleteConversationsParams(ids: $ids)';

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
} 