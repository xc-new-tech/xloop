import 'package:equatable/equatable.dart';

import '../../domain/entities/faq_entity.dart';

abstract class FaqEvent extends Equatable {
  const FaqEvent();

  @override
  List<Object?> get props => [];
}

/// 获取FAQ列表
class GetFaqsEvent extends FaqEvent {
  final String? search;
  final String? category;
  final FaqStatus? status;
  final String? knowledgeBaseId;
  final bool? isPublic;
  final FaqSort? sort;
  final List<String>? tags;
  final int page;
  final int limit;
  final bool isRefresh;

  const GetFaqsEvent({
    this.search,
    this.category,
    this.status,
    this.knowledgeBaseId,
    this.isPublic,
    this.sort,
    this.tags,
    this.page = 1,
    this.limit = 20,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [
        search,
        category,
        status,
        knowledgeBaseId,
        isPublic,
        sort,
        tags,
        page,
        limit,
        isRefresh,
      ];
}

/// 搜索FAQ
class SearchFaqsEvent extends FaqEvent {
  final FaqFilter filter;
  final FaqSort sort;
  final int page;
  final int limit;
  final bool isRefresh;

  const SearchFaqsEvent({
    required this.filter,
    required this.sort,
    this.page = 1,
    this.limit = 20,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [filter, sort, page, limit, isRefresh];
}

/// 获取FAQ详情
class GetFaqByIdEvent extends FaqEvent {
  final String id;

  const GetFaqByIdEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

/// 创建FAQ
class CreateFaqEvent extends FaqEvent {
  final FaqEntity faq;

  const CreateFaqEvent({required this.faq});

  @override
  List<Object?> get props => [faq];
}

/// 更新FAQ
class UpdateFaqEvent extends FaqEvent {
  final FaqEntity faq;

  const UpdateFaqEvent({required this.faq});

  @override
  List<Object?> get props => [faq];
}

/// 删除FAQ
class DeleteFaqEvent extends FaqEvent {
  final String id;

  const DeleteFaqEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

/// 批量删除FAQ
class BulkDeleteFaqsEvent extends FaqEvent {
  final List<String> ids;

  const BulkDeleteFaqsEvent({required this.ids});

  @override
  List<Object?> get props => [ids];
}

/// 获取FAQ分类
class GetCategoriesEvent extends FaqEvent {
  const GetCategoriesEvent();
}

/// 获取热门FAQ
class GetPopularFaqsEvent extends FaqEvent {
  final int limit;

  const GetPopularFaqsEvent({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// 点赞FAQ
class LikeFaqEvent extends FaqEvent {
  final String id;

  const LikeFaqEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

/// 点踩FAQ
class DislikeFaqEvent extends FaqEvent {
  final String id;

  const DislikeFaqEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

/// 切换FAQ状态
class ToggleFaqStatusEvent extends FaqEvent {
  final String id;

  const ToggleFaqStatusEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

/// 设置筛选器
class SetFilterEvent extends FaqEvent {
  final FaqFilter filter;

  const SetFilterEvent({required this.filter});

  @override
  List<Object?> get props => [filter];
}

/// 设置排序
class SetSortEvent extends FaqEvent {
  final FaqSort sort;

  const SetSortEvent({required this.sort});

  @override
  List<Object?> get props => [sort];
}

/// 清除搜索
class ClearSearchEvent extends FaqEvent {
  const ClearSearchEvent();
}

/// 重置状态
class ResetFaqStateEvent extends FaqEvent {
  const ResetFaqStateEvent();
}

/// 选择FAQ
class SelectFaqEvent extends FaqEvent {
  final String id;

  const SelectFaqEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

/// 取消选择FAQ
class UnselectFaqEvent extends FaqEvent {
  final String id;

  const UnselectFaqEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

/// 全选FAQ
class SelectAllFaqsEvent extends FaqEvent {
  const SelectAllFaqsEvent();
}

/// 取消全选FAQ
class UnselectAllFaqsEvent extends FaqEvent {
  const UnselectAllFaqsEvent();
}

/// 切换选择模式
class ToggleSelectionModeEvent extends FaqEvent {
  const ToggleSelectionModeEvent();
}

/// 进入选择模式
class EnterSelectionModeEvent extends FaqEvent {
  const EnterSelectionModeEvent();
}

/// 退出选择模式
class ExitSelectionModeEvent extends FaqEvent {
  const ExitSelectionModeEvent();
}

/// 加载更多FAQ
class LoadMoreFaqsEvent extends FaqEvent {
  const LoadMoreFaqsEvent();
}

/// 刷新FAQ列表
class RefreshFaqsEvent extends FaqEvent {
  const RefreshFaqsEvent();
} 