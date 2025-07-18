import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/file_entity.dart';
import '../repositories/file_repository.dart';

/// 获取文件列表用例
class GetFilesUseCase implements UseCase<List<FileEntity>, GetFilesParams> {
  final FileRepository repository;

  GetFilesUseCase(this.repository);

  @override
  Future<Either<Failure, List<FileEntity>>> call(GetFilesParams params) async {
    return await repository.getFiles(
      knowledgeBaseId: params.knowledgeBaseId,
      category: params.category,
      status: params.status,
      page: params.page,
      limit: params.limit,
      search: params.search,
    );
  }
}

/// 获取文件列表参数
class GetFilesParams {
  final String? knowledgeBaseId;
  final String? category;
  final String? status;
  final int page;
  final int limit;
  final String? search;

  const GetFilesParams({
    this.knowledgeBaseId,
    this.category,
    this.status,
    this.page = 1,
    this.limit = 20,
    this.search,
  });

  GetFilesParams copyWith({
    String? knowledgeBaseId,
    String? category,
    String? status,
    int? page,
    int? limit,
    String? search,
  }) {
    return GetFilesParams(
      knowledgeBaseId: knowledgeBaseId ?? this.knowledgeBaseId,
      category: category ?? this.category,
      status: status ?? this.status,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (knowledgeBaseId != null) 'knowledgeBaseId': knowledgeBaseId,
      if (category != null) 'category': category,
      if (status != null) 'status': status,
      'page': page,
      'limit': limit,
      if (search != null) 'search': search,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetFilesParams &&
        other.knowledgeBaseId == knowledgeBaseId &&
        other.category == category &&
        other.status == status &&
        other.page == page &&
        other.limit == limit &&
        other.search == search;
  }

  @override
  int get hashCode {
    return knowledgeBaseId.hashCode ^
        category.hashCode ^
        status.hashCode ^
        page.hashCode ^
        limit.hashCode ^
        search.hashCode;
  }

  @override
  String toString() {
    return 'GetFilesParams('
        'knowledgeBaseId: $knowledgeBaseId, '
        'category: $category, '
        'status: $status, '
        'page: $page, '
        'limit: $limit, '
        'search: $search'
        ')';
  }
} 