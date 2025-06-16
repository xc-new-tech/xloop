import 'package:equatable/equatable.dart';

import '../../domain/entities/knowledge_base.dart';

/// 知识库事件
abstract class KnowledgeBaseEvent extends Equatable {
  const KnowledgeBaseEvent();

  @override
  List<Object?> get props => [];
}

/// 获取知识库列表事件
class GetKnowledgeBasesEvent extends KnowledgeBaseEvent {
  final int page;
  final int limit;
  final KnowledgeBaseStatus? status;
  final KnowledgeBaseType? type;
  final String? search;
  final List<String>? tags;
  final bool refresh;

  const GetKnowledgeBasesEvent({
    this.page = 1,
    this.limit = 20,
    this.status,
    this.type,
    this.search,
    this.tags,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, limit, status, type, search, tags, refresh];
}

/// 获取我的知识库列表事件
class GetMyKnowledgeBasesEvent extends KnowledgeBaseEvent {
  final int page;
  final int limit;
  final KnowledgeBaseStatus? status;
  final KnowledgeBaseType? type;
  final bool refresh;

  const GetMyKnowledgeBasesEvent({
    this.page = 1,
    this.limit = 20,
    this.status,
    this.type,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, limit, status, type, refresh];
}

/// 获取公开知识库列表事件
class GetPublicKnowledgeBasesEvent extends KnowledgeBaseEvent {
  final int page;
  final int limit;
  final String? search;
  final List<String>? tags;
  final bool refresh;

  const GetPublicKnowledgeBasesEvent({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.tags,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, limit, search, tags, refresh];
}

/// 获取知识库详情事件
class GetKnowledgeBaseEvent extends KnowledgeBaseEvent {
  final String id;

  const GetKnowledgeBaseEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// 获取知识库详情事件（用于详情页）
class GetKnowledgeBaseDetailEvent extends KnowledgeBaseEvent {
  final String id;

  const GetKnowledgeBaseDetailEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// 创建知识库事件
class CreateKnowledgeBaseEvent extends KnowledgeBaseEvent {
  final String name;
  final String? description;
  final String? coverImage;
  final KnowledgeBaseType type;
  final KnowledgeBaseContentType contentType; // 新增内容类型
  final Map<String, dynamic>? settings;
  final bool isPublic;
  final List<String>? tags;

  const CreateKnowledgeBaseEvent({
    required this.name,
    this.description,
    this.coverImage,
    required this.type,
    required this.contentType, // 新增必需参数
    this.settings,
    this.isPublic = false,
    this.tags,
  });

  @override
  List<Object?> get props => [name, description, coverImage, type, contentType, settings, isPublic, tags];
}

/// 更新知识库事件
class UpdateKnowledgeBaseEvent extends KnowledgeBaseEvent {
  final String id;
  final String? name;
  final String? description;
  final String? coverImage;
  final KnowledgeBaseType? type;
  final Map<String, dynamic>? settings;
  final bool? isPublic;
  final List<String>? tags;

  const UpdateKnowledgeBaseEvent({
    required this.id,
    this.name,
    this.description,
    this.coverImage,
    this.type,
    this.settings,
    this.isPublic,
    this.tags,
  });

  @override
  List<Object?> get props => [id, name, description, coverImage, type, settings, isPublic, tags];
}

/// 删除知识库事件
class DeleteKnowledgeBaseEvent extends KnowledgeBaseEvent {
  final String id;

  const DeleteKnowledgeBaseEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// 更新知识库状态事件
class UpdateKnowledgeBaseStatusEvent extends KnowledgeBaseEvent {
  final String id;
  final KnowledgeBaseStatus status;

  const UpdateKnowledgeBaseStatusEvent({
    required this.id,
    required this.status,
  });

  @override
  List<Object?> get props => [id, status];
}

/// 复制知识库事件
class DuplicateKnowledgeBaseEvent extends KnowledgeBaseEvent {
  final String id;
  final String newName;
  final String? newDescription;

  const DuplicateKnowledgeBaseEvent({
    required this.id,
    required this.newName,
    this.newDescription,
  });

  @override
  List<Object?> get props => [id, newName, newDescription];
}

/// 分享知识库事件
class ShareKnowledgeBaseEvent extends KnowledgeBaseEvent {
  final String id;
  final List<String> userIds;
  final String? message;

  const ShareKnowledgeBaseEvent({
    required this.id,
    required this.userIds,
    this.message,
  });

  @override
  List<Object?> get props => [id, userIds, message];
}

/// 导入知识库事件
class ImportKnowledgeBaseEvent extends KnowledgeBaseEvent {
  final String sourceId;
  final String? newName;
  final String? newDescription;

  const ImportKnowledgeBaseEvent({
    required this.sourceId,
    this.newName,
    this.newDescription,
  });

  @override
  List<Object?> get props => [sourceId, newName, newDescription];
}

/// 导出知识库事件
class ExportKnowledgeBaseEvent extends KnowledgeBaseEvent {
  final String id;
  final String format;

  const ExportKnowledgeBaseEvent({
    required this.id,
    this.format = 'json',
  });

  @override
  List<Object?> get props => [id, format];
}

/// 搜索知识库事件
class SearchKnowledgeBasesEvent extends KnowledgeBaseEvent {
  final String query;
  final int page;
  final int limit;
  final KnowledgeBaseType? type;
  final List<String>? tags;

  const SearchKnowledgeBasesEvent({
    required this.query,
    this.page = 1,
    this.limit = 20,
    this.type,
    this.tags,
  });

  @override
  List<Object?> get props => [query, page, limit, type, tags];
}

/// 获取知识库标签事件
class GetKnowledgeBaseTagsEvent extends KnowledgeBaseEvent {
  const GetKnowledgeBaseTagsEvent();
}

/// 获取知识库统计信息事件
class GetKnowledgeBaseStatsEvent extends KnowledgeBaseEvent {
  final String id;

  const GetKnowledgeBaseStatsEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// 批量删除知识库事件
class BatchDeleteKnowledgeBasesEvent extends KnowledgeBaseEvent {
  final List<String> ids;

  const BatchDeleteKnowledgeBasesEvent(this.ids);

  @override
  List<Object?> get props => [ids];
}

/// 批量更新知识库状态事件
class BatchUpdateKnowledgeBaseStatusEvent extends KnowledgeBaseEvent {
  final List<String> ids;
  final KnowledgeBaseStatus status;

  const BatchUpdateKnowledgeBaseStatusEvent({
    required this.ids,
    required this.status,
  });

  @override
  List<Object?> get props => [ids, status];
}

/// 加载更多事件
class LoadMoreKnowledgeBasesEvent extends KnowledgeBaseEvent {
  const LoadMoreKnowledgeBasesEvent();
}

/// 重置状态事件
class ResetKnowledgeBaseStateEvent extends KnowledgeBaseEvent {
  const ResetKnowledgeBaseStateEvent();
}

/// 加载知识库事件
class LoadKnowledgeBasesEvent extends KnowledgeBaseEvent {
  const LoadKnowledgeBasesEvent();

  @override
  List<Object?> get props => [];
}

/// 清除搜索事件
class ClearKnowledgeBaseSearchEvent extends KnowledgeBaseEvent {
  const ClearKnowledgeBaseSearchEvent();

  @override
  List<Object?> get props => [];
}

/// 筛选知识库事件
class FilterKnowledgeBasesEvent extends KnowledgeBaseEvent {
  final String? filter;

  const FilterKnowledgeBasesEvent({this.filter});

  @override
  List<Object?> get props => [filter];
}