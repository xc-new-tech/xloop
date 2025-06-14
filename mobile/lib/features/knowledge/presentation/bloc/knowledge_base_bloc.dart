import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/localization/localization_manager.dart';
import '../../domain/entities/knowledge_base.dart';
import '../../domain/usecases/create_knowledge_base.dart';
import '../../domain/usecases/delete_knowledge_base.dart';
import '../../domain/usecases/get_knowledge_base.dart';
import '../../domain/usecases/get_knowledge_bases.dart';
import '../../domain/usecases/get_knowledge_bases_params.dart';
import '../../domain/usecases/update_knowledge_base.dart';
import 'knowledge_base_event.dart';
import 'knowledge_base_state.dart';

/// 知识库BLoC
class KnowledgeBaseBloc extends Bloc<KnowledgeBaseEvent, KnowledgeBaseState> {
  final GetKnowledgeBases _getKnowledgeBases;
  final GetKnowledgeBase _getKnowledgeBase;
  final CreateKnowledgeBase _createKnowledgeBase;
  final UpdateKnowledgeBase _updateKnowledgeBase;
  final DeleteKnowledgeBase _deleteKnowledgeBase;
  final LocalizationManager _localizationManager;
  final Logger _logger;

  // 内部状态管理
  List<KnowledgeBase> _currentKnowledgeBases = [];
  List<KnowledgeBase> _searchResults = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _currentSearchQuery;

  KnowledgeBaseBloc({
    required GetKnowledgeBases getKnowledgeBases,
    required GetKnowledgeBase getKnowledgeBase,
    required CreateKnowledgeBase createKnowledgeBase,
    required UpdateKnowledgeBase updateKnowledgeBase,
    required DeleteKnowledgeBase deleteKnowledgeBase,
    required LocalizationManager localizationManager,
    required Logger logger,
  })  : _getKnowledgeBases = getKnowledgeBases,
        _getKnowledgeBase = getKnowledgeBase,
        _createKnowledgeBase = createKnowledgeBase,
        _updateKnowledgeBase = updateKnowledgeBase,
        _deleteKnowledgeBase = deleteKnowledgeBase,
        _localizationManager = localizationManager,
        _logger = logger,
        super(const KnowledgeBaseInitial()) {
    on<GetKnowledgeBasesEvent>(_onGetKnowledgeBases);
    on<GetMyKnowledgeBasesEvent>(_onGetMyKnowledgeBases);
    on<GetPublicKnowledgeBasesEvent>(_onGetPublicKnowledgeBases);
    on<GetKnowledgeBaseEvent>(_onGetKnowledgeBase);
    on<GetKnowledgeBaseDetailEvent>(_onGetKnowledgeBaseDetail);
    on<CreateKnowledgeBaseEvent>(_onCreateKnowledgeBase);
    on<UpdateKnowledgeBaseEvent>(_onUpdateKnowledgeBase);
    on<DeleteKnowledgeBaseEvent>(_onDeleteKnowledgeBase);
    on<UpdateKnowledgeBaseStatusEvent>(_onUpdateKnowledgeBaseStatus);
    on<DuplicateKnowledgeBaseEvent>(_onDuplicateKnowledgeBase);
    on<ShareKnowledgeBaseEvent>(_onShareKnowledgeBase);
    on<ImportKnowledgeBaseEvent>(_onImportKnowledgeBase);
    on<ExportKnowledgeBaseEvent>(_onExportKnowledgeBase);
    on<SearchKnowledgeBasesEvent>(_onSearchKnowledgeBases);
    on<GetKnowledgeBaseTagsEvent>(_onGetKnowledgeBaseTags);
    on<GetKnowledgeBaseStatsEvent>(_onGetKnowledgeBaseStats);
    on<BatchDeleteKnowledgeBasesEvent>(_onBatchDeleteKnowledgeBases);
    on<BatchUpdateKnowledgeBaseStatusEvent>(_onBatchUpdateKnowledgeBaseStatus);
    on<LoadMoreKnowledgeBasesEvent>(_onLoadMoreKnowledgeBases);
    on<ResetKnowledgeBaseStateEvent>(_onResetKnowledgeBaseState);
  }

  /// 获取知识库列表
  Future<void> _onGetKnowledgeBases(
    GetKnowledgeBasesEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    try {
      _logger.d('获取知识库列表 - page: ${event.page}, refresh: ${event.refresh}');

      if (event.refresh || event.page == 1) {
        emit(const KnowledgeBaseLoading());
        _currentPage = 1;
        _hasMore = true;
        _currentKnowledgeBases.clear();
      }

      final params = GetKnowledgeBasesParams(
        page: event.page,
        limit: event.limit,
        status: event.status,
        type: event.type,
        search: event.search,
        tags: event.tags,
      );

      final result = await _getKnowledgeBases(params);

      result.fold(
        (failure) {
          _logger.e('获取知识库列表失败', error: failure);
          emit(_mapFailureToState(failure));
        },
        (knowledgeBases) {
          _logger.d('获取知识库列表成功 - 数量: ${knowledgeBases.length}');

          if (event.page == 1) {
            _currentKnowledgeBases = knowledgeBases;
          } else {
            _currentKnowledgeBases.addAll(knowledgeBases);
          }

          _currentPage = event.page;
          _hasMore = knowledgeBases.length >= event.limit;

          if (_currentKnowledgeBases.isEmpty) {
            emit(KnowledgeBaseEmpty(_localizationManager.getString('knowledge_base.empty')));
          } else {
            emit(KnowledgeBaseListLoaded(
              knowledgeBases: List.from(_currentKnowledgeBases),
              hasMore: _hasMore,
              currentPage: _currentPage,
            ));
          }
        },
      );
    } catch (e) {
      _logger.e('获取知识库列表异常', error: e);
      emit(KnowledgeBaseError(message: _localizationManager.getString('common.unknown_error')));
    }
  }

  /// 获取我的知识库列表
  Future<void> _onGetMyKnowledgeBases(
    GetMyKnowledgeBasesEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    try {
      _logger.d('获取我的知识库列表 - page: ${event.page}, refresh: ${event.refresh}');

      if (event.refresh || event.page == 1) {
        emit(const KnowledgeBaseLoading());
        _currentPage = 1;
        _hasMore = true;
        _currentKnowledgeBases.clear();
      }

      final params = GetMyKnowledgeBasesParams(
        page: event.page,
        limit: event.limit,
        status: event.status,
        type: event.type,
      );

      final result = await _getKnowledgeBases.getMyKnowledgeBases(params);

      result.fold(
        (failure) {
          _logger.e('获取我的知识库列表失败', error: failure);
          emit(_mapFailureToState(failure));
        },
        (knowledgeBases) {
          _logger.d('获取我的知识库列表成功 - 数量: ${knowledgeBases.length}');

          if (event.page == 1) {
            _currentKnowledgeBases = knowledgeBases;
          } else {
            _currentKnowledgeBases.addAll(knowledgeBases);
          }

          _currentPage = event.page;
          _hasMore = knowledgeBases.length >= event.limit;

          if (_currentKnowledgeBases.isEmpty) {
            emit(KnowledgeBaseEmpty(_localizationManager.getString('knowledge_base.my_empty')));
          } else {
            emit(KnowledgeBaseListLoaded(
              knowledgeBases: List.from(_currentKnowledgeBases),
              hasMore: _hasMore,
              currentPage: _currentPage,
            ));
          }
        },
      );
    } catch (e) {
      _logger.e('获取我的知识库列表异常', error: e);
      emit(KnowledgeBaseError(message: _localizationManager.getString('common.unknown_error')));
    }
  }

  /// 获取公开知识库列表
  Future<void> _onGetPublicKnowledgeBases(
    GetPublicKnowledgeBasesEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    try {
      _logger.d('获取公开知识库列表 - page: ${event.page}, refresh: ${event.refresh}');

      if (event.refresh || event.page == 1) {
        emit(const KnowledgeBaseLoading());
        _currentPage = 1;
        _hasMore = true;
        _currentKnowledgeBases.clear();
      }

      final params = GetPublicKnowledgeBasesParams(
        page: event.page,
        limit: event.limit,
        search: event.search,
        tags: event.tags,
      );

      final result = await _getKnowledgeBases.getPublicKnowledgeBases(params);

      result.fold(
        (failure) {
          _logger.e('获取公开知识库列表失败', error: failure);
          emit(_mapFailureToState(failure));
        },
        (knowledgeBases) {
          _logger.d('获取公开知识库列表成功 - 数量: ${knowledgeBases.length}');

          if (event.page == 1) {
            _currentKnowledgeBases = knowledgeBases;
          } else {
            _currentKnowledgeBases.addAll(knowledgeBases);
          }

          _currentPage = event.page;
          _hasMore = knowledgeBases.length >= event.limit;

          if (_currentKnowledgeBases.isEmpty) {
            emit(KnowledgeBaseEmpty(_localizationManager.getString('knowledge_base.public_empty')));
          } else {
            emit(KnowledgeBaseListLoaded(
              knowledgeBases: List.from(_currentKnowledgeBases),
              hasMore: _hasMore,
              currentPage: _currentPage,
            ));
          }
        },
      );
    } catch (e) {
      _logger.e('获取公开知识库列表异常', error: e);
      emit(KnowledgeBaseError(message: _localizationManager.getString('common.unknown_error')));
    }
  }

  /// 获取知识库详情
  Future<void> _onGetKnowledgeBase(
    GetKnowledgeBaseEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    try {
      _logger.d('获取知识库详情 - id: ${event.id}');

      emit(const KnowledgeBaseLoading());

      final result = await _getKnowledgeBase(GetKnowledgeBaseParams(id: event.id));

      result.fold(
        (failure) {
          _logger.e('获取知识库详情失败', error: failure);
          emit(_mapFailureToState(failure));
        },
        (knowledgeBase) {
          _logger.d('获取知识库详情成功 - name: ${knowledgeBase.name}');
          emit(KnowledgeBaseDetailLoaded(knowledgeBase: knowledgeBase));
        },
      );
    } catch (e) {
      _logger.e('获取知识库详情异常', error: e);
      emit(KnowledgeBaseError(message: _localizationManager.getString('common.unknown_error')));
    }
  }

  /// 获取知识库详情（用于详情页）
  Future<void> _onGetKnowledgeBaseDetail(
    GetKnowledgeBaseDetailEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    try {
      _logger.d('获取知识库详情（详情页） - id: ${event.id}');

      emit(const KnowledgeBaseLoading());

      final result = await _getKnowledgeBase(GetKnowledgeBaseParams(id: event.id));

      result.fold(
        (failure) {
          _logger.e('获取知识库详情失败', error: failure);
          emit(_mapFailureToState(failure));
        },
        (knowledgeBase) {
          _logger.d('获取知识库详情成功 - name: ${knowledgeBase.name}');
          emit(KnowledgeBaseDetailLoaded(knowledgeBase: knowledgeBase));
        },
      );
    } catch (e) {
      _logger.e('获取知识库详情异常', error: e);
      emit(KnowledgeBaseError(message: _localizationManager.getString('common.unknown_error')));
    }
  }

  /// 创建知识库
  Future<void> _onCreateKnowledgeBase(
    CreateKnowledgeBaseEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    try {
      _logger.d('创建知识库 - name: ${event.name}');

      emit(const KnowledgeBaseLoading());

      final params = CreateKnowledgeBaseParams(
        name: event.name,
        description: event.description,
        coverImage: event.coverImage,
        type: event.type,
        settings: event.settings,
        isPublic: event.isPublic,
        tags: event.tags,
      );

      final result = await _createKnowledgeBase(params);

      result.fold(
        (failure) {
          _logger.e('创建知识库失败', error: failure);
          emit(_mapFailureToState(failure));
        },
        (knowledgeBase) {
          _logger.d('创建知识库成功 - id: ${knowledgeBase.id}');
          
          // 更新本地列表
          _currentKnowledgeBases.insert(0, knowledgeBase);
          
          emit(KnowledgeBaseOperationSuccess(
            knowledgeBase: knowledgeBase,
            message: _localizationManager.getString('knowledge_base.create_success'),
          ));
        },
      );
    } catch (e) {
      _logger.e('创建知识库异常', error: e);
      emit(KnowledgeBaseError(message: _localizationManager.getString('common.unknown_error')));
    }
  }

  /// 更新知识库
  Future<void> _onUpdateKnowledgeBase(
    UpdateKnowledgeBaseEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    try {
      _logger.d('更新知识库 - id: ${event.id}');

      emit(const KnowledgeBaseLoading());

      final params = UpdateKnowledgeBaseParams(
        id: event.id,
        name: event.name,
        description: event.description,
        coverImage: event.coverImage,
        type: event.type,
        settings: event.settings,
        isPublic: event.isPublic,
        tags: event.tags,
      );

      final result = await _updateKnowledgeBase(params);

      result.fold(
        (failure) {
          _logger.e('更新知识库失败', error: failure);
          emit(_mapFailureToState(failure));
        },
        (knowledgeBase) {
          _logger.d('更新知识库成功 - id: ${knowledgeBase.id}');
          
          // 更新本地列表
          final index = _currentKnowledgeBases.indexWhere((kb) => kb.id == knowledgeBase.id);
          if (index != -1) {
            _currentKnowledgeBases[index] = knowledgeBase;
          }
          
          emit(KnowledgeBaseOperationSuccess(
            knowledgeBase: knowledgeBase,
            message: _localizationManager.getString('knowledge_base.update_success'),
          ));
        },
      );
    } catch (e) {
      _logger.e('更新知识库异常', error: e);
      emit(KnowledgeBaseError(message: _localizationManager.getString('common.unknown_error')));
    }
  }

  /// 删除知识库
  Future<void> _onDeleteKnowledgeBase(
    DeleteKnowledgeBaseEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    try {
      _logger.d('删除知识库 - id: ${event.id}');

      emit(const KnowledgeBaseLoading());

      final result = await _deleteKnowledgeBase(DeleteKnowledgeBaseParams(id: event.id));

      result.fold(
        (failure) {
          _logger.e('删除知识库失败', error: failure);
          emit(_mapFailureToState(failure));
        },
        (_) {
          _logger.d('删除知识库成功 - id: ${event.id}');
          
          // 从本地列表移除
          _currentKnowledgeBases.removeWhere((kb) => kb.id == event.id);
          
          emit(KnowledgeBaseDeleteSuccess(
            _localizationManager.getString('knowledge_base.delete_success'),
          ));
        },
      );
    } catch (e) {
      _logger.e('删除知识库异常', error: e);
      emit(KnowledgeBaseError(message: _localizationManager.getString('common.unknown_error')));
    }
  }

  /// 更新知识库状态
  Future<void> _onUpdateKnowledgeBaseStatus(
    UpdateKnowledgeBaseStatusEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    try {
      _logger.d('更新知识库状态 - id: ${event.id}, status: ${event.status}');

      emit(const KnowledgeBaseLoading());

      final params = UpdateKnowledgeBaseStatusParams(
        id: event.id,
        status: event.status,
      );

      final result = await _updateKnowledgeBase.updateStatus(params);

      result.fold(
        (failure) {
          _logger.e('更新知识库状态失败', error: failure);
          emit(_mapFailureToState(failure));
        },
        (knowledgeBase) {
          _logger.d('更新知识库状态成功 - id: ${knowledgeBase.id}');
          
          // 更新本地列表
          final index = _currentKnowledgeBases.indexWhere((kb) => kb.id == knowledgeBase.id);
          if (index != -1) {
            _currentKnowledgeBases[index] = knowledgeBase;
          }
          
          emit(KnowledgeBaseOperationSuccess(
            knowledgeBase: knowledgeBase,
            message: _localizationManager.getString('knowledge_base.status_update_success'),
          ));
        },
      );
    } catch (e) {
      _logger.e('更新知识库状态异常', error: e);
      emit(KnowledgeBaseError(message: _localizationManager.getString('common.unknown_error')));
    }
  }

  /// 复制知识库
  Future<void> _onDuplicateKnowledgeBase(
    DuplicateKnowledgeBaseEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    try {
      _logger.d('复制知识库 - id: ${event.id}, newName: ${event.newName}');

      emit(const KnowledgeBaseLoading());

      final params = DuplicateKnowledgeBaseParams(
        id: event.id,
        newName: event.newName,
      );

      final result = await _updateKnowledgeBase.duplicate(params);

      result.fold(
        (failure) {
          _logger.e('复制知识库失败', error: failure);
          emit(_mapFailureToState(failure));
        },
        (knowledgeBase) {
          _logger.d('复制知识库成功 - id: ${knowledgeBase.id}');
          
          // 添加到本地列表
          _currentKnowledgeBases.insert(0, knowledgeBase);
          
          emit(KnowledgeBaseOperationSuccess(
            knowledgeBase: knowledgeBase,
            message: _localizationManager.getString('knowledge_base.duplicate_success'),
          ));
        },
      );
    } catch (e) {
      _logger.e('复制知识库异常', error: e);
      emit(KnowledgeBaseError(message: _localizationManager.getString('common.unknown_error')));
    }
  }

  /// 分享知识库
  Future<void> _onShareKnowledgeBase(
    ShareKnowledgeBaseEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    try {
      emit(KnowledgeBaseLoading());
      // TODO: 实现分享知识库功能 - 暂时注释
      // _logger.d('分享知识库 - id: ${event.id}, isPublic: ${event.isPublic}');

      // final shareUrl = await _shareKnowledgeBase(
      //   id: event.id,
      //   userIds: event.userIds,
      //   message: event.message,
      // );

      // if (shareUrl != null) {
      //   _logger.d('分享知识库成功 - shareUrl: $shareUrl');
      //   emit(KnowledgeBaseShareSuccess(
      //     shareUrl: shareUrl,
      //   ));
      // } else {
      //   emit(const KnowledgeBaseError('分享失败'));
      // }

              // 暂时返回成功状态
        emit(const KnowledgeBaseShareSuccess(
          shareUrl: 'temp_share_url',
          message: '分享成功',
        ));
    } catch (e) {
      _logger.e('分享知识库失败', error: e);
      emit(KnowledgeBaseError(message: e.toString()));
    }
  }

  /// 导入知识库
  Future<void> _onImportKnowledgeBase(
    ImportKnowledgeBaseEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    try {
      emit(KnowledgeBaseLoading());
      
      // TODO: 实现导入知识库功能 - 暂时注释
      // final result = await _importKnowledgeBase(
      //   filePath: event.filePath,
      //   name: event.name,
      //   description: event.description,
      //   type: event.type,
      // );

      // 暂时返回成功状态
      emit(const KnowledgeBaseImportSuccess());
    } catch (e) {
      _logger.e('导入知识库失败', error: e);
      emit(KnowledgeBaseError(message: e.toString()));
    }
  }

  /// 导出知识库
  Future<void> _onExportKnowledgeBase(
    ExportKnowledgeBaseEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    try {
      _logger.d('导出知识库 - id: ${event.id}, format: ${event.format}');

      emit(const KnowledgeBaseLoading());

      final params = ExportKnowledgeBaseParams(
        id: event.id,
        format: event.format,
      );

      final result = await _updateKnowledgeBase.export(params);

      result.fold(
        (failure) {
          _logger.e('导出知识库失败', error: failure);
          emit(_mapFailureToState(failure));
        },
        (downloadUrl) {
          _logger.d('导出知识库成功 - downloadUrl: $downloadUrl');
          
          emit(KnowledgeBaseExportSuccess(
            downloadUrl: downloadUrl,
            message: _localizationManager.getString('knowledge_base.export_success'),
          ));
        },
      );
    } catch (e) {
      _logger.e('导出知识库异常', error: e);
      emit(KnowledgeBaseError(message: _localizationManager.getString('common.unknown_error')));
    }
  }

  /// 搜索知识库
  Future<void> _onSearchKnowledgeBases(
    SearchKnowledgeBasesEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    try {
      _logger.d('搜索知识库 - query: ${event.query}, page: ${event.page}');

      if (event.page == 1 || _currentSearchQuery != event.query) {
        emit(const KnowledgeBaseLoading());
        _searchResults.clear();
        _currentSearchQuery = event.query;
      }

      final params = SearchKnowledgeBasesParams(
        query: event.query,
        page: event.page,
        limit: event.limit,
        type: event.type,
        tags: event.tags,
      );

      final result = await _getKnowledgeBases.search(params);

      result.fold(
        (failure) {
          _logger.e('搜索知识库失败', error: failure);
          emit(_mapFailureToState(failure));
        },
        (knowledgeBases) {
          _logger.d('搜索知识库成功 - 数量: ${knowledgeBases.length}');

          if (event.page == 1) {
            _searchResults = knowledgeBases;
          } else {
            _searchResults.addAll(knowledgeBases);
          }

          final hasMore = knowledgeBases.length >= event.limit;

          if (_searchResults.isEmpty) {
            emit(KnowledgeBaseEmpty(_localizationManager.getString('knowledge_base.search_empty')));
          } else {
            emit(KnowledgeBaseSearchLoaded(
              searchResults: List.from(_searchResults),
              query: event.query,
              hasMore: hasMore,
              currentPage: event.page,
            ));
          }
        },
      );
    } catch (e) {
      _logger.e('搜索知识库异常', error: e);
      emit(KnowledgeBaseError(message: _localizationManager.getString('common.unknown_error')));
    }
  }

  /// 获取知识库标签
  Future<void> _onGetKnowledgeBaseTags(
    GetKnowledgeBaseTagsEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    try {
      _logger.d('获取知识库标签');

      final result = await _getKnowledgeBases.getTags();

      result.fold(
        (failure) {
          _logger.e('获取知识库标签失败', error: failure);
          emit(_mapFailureToState(failure));
        },
        (tags) {
          _logger.d('获取知识库标签成功 - 数量: ${tags.length}');
          emit(KnowledgeBaseTagsLoaded(tags));
        },
      );
    } catch (e) {
      _logger.e('获取知识库标签异常', error: e);
      emit(KnowledgeBaseError(message: _localizationManager.getString('common.unknown_error')));
    }
  }

  /// 获取知识库统计信息
  Future<void> _onGetKnowledgeBaseStats(
    GetKnowledgeBaseStatsEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    try {
      emit(KnowledgeBaseLoading());
      
      // TODO: 实现获取知识库统计功能 - 暂时注释
      // final stats = await _getKnowledgeBaseStats(
      //   userId: event.userId,
      //   startDate: event.startDate,
      //   endDate: event.endDate,
      // );

      // 暂时返回模拟数据
      emit(const KnowledgeBaseStatsLoaded({}));
    } catch (e) {
      _logger.e('获取知识库统计失败', error: e);
      emit(KnowledgeBaseError(message: e.toString()));
    }
  }

  /// 批量删除知识库
  Future<void> _onBatchDeleteKnowledgeBases(
    BatchDeleteKnowledgeBasesEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    try {
      _logger.d('批量删除知识库 - ids: ${event.ids}');

      emit(const KnowledgeBaseLoading());

      final result = await _deleteKnowledgeBase.batchDelete(BatchDeleteKnowledgeBasesParams(ids: event.ids));

      result.fold(
        (failure) {
          _logger.e('批量删除知识库失败', error: failure);
          emit(_mapFailureToState(failure));
        },
        (_) {
          _logger.d('批量删除知识库成功 - ids: ${event.ids}');
          
          // 从本地列表移除
          _currentKnowledgeBases.removeWhere((kb) => event.ids.contains(kb.id));
          
          emit(KnowledgeBaseBatchOperationSuccess(
            message: _localizationManager.getString('knowledge_base.batch_delete_success'),
          ));
        },
      );
    } catch (e) {
      _logger.e('批量删除知识库异常', error: e);
      emit(KnowledgeBaseError(message: _localizationManager.getString('common.unknown_error')));
    }
  }

  /// 批量更新知识库状态
  Future<void> _onBatchUpdateKnowledgeBaseStatus(
    BatchUpdateKnowledgeBaseStatusEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    try {
      _logger.d('批量更新知识库状态 - ids: ${event.ids}, status: ${event.status}');

      emit(const KnowledgeBaseLoading());

      final params = BatchUpdateKnowledgeBaseStatusParams(
        ids: event.ids,
        status: event.status,
      );

      final result = await _updateKnowledgeBase.batchUpdateStatus(params);

      result.fold(
        (failure) {
          _logger.e('批量更新知识库状态失败', error: failure);
          emit(_mapFailureToState(failure));
        },
        (updatedKnowledgeBases) {
          _logger.d('批量更新知识库状态成功 - 数量: ${updatedKnowledgeBases.length}');
          
          // 更新本地列表
          for (final updatedKb in updatedKnowledgeBases) {
            final index = _currentKnowledgeBases.indexWhere((kb) => kb.id == updatedKb.id);
            if (index != -1) {
              _currentKnowledgeBases[index] = updatedKb;
            }
          }
          
          emit(KnowledgeBaseBatchOperationSuccess(
            updatedKnowledgeBases: updatedKnowledgeBases,
            message: _localizationManager.getString('knowledge_base.batch_status_update_success'),
          ));
        },
      );
    } catch (e) {
      _logger.e('批量更新知识库状态异常', error: e);
      emit(KnowledgeBaseError(message: _localizationManager.getString('common.unknown_error')));
    }
  }

  /// 加载更多知识库
  Future<void> _onLoadMoreKnowledgeBases(
    LoadMoreKnowledgeBasesEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) async {
    if (!_hasMore || _isLoadingMore) return;

    try {
      _logger.d('加载更多知识库 - currentPage: $_currentPage');

      _isLoadingMore = true;
      
      if (state is KnowledgeBaseListLoaded) {
        final currentState = state as KnowledgeBaseListLoaded;
        emit(currentState.copyWith(isLoadingMore: true));
      }

      final nextPage = _currentPage + 1;
      
      // 根据当前状态决定加载哪种类型的数据
      if (state is KnowledgeBaseSearchLoaded) {
        final searchState = state as KnowledgeBaseSearchLoaded;
        add(SearchKnowledgeBasesEvent(
          query: searchState.query,
          page: nextPage,
        ));
      } else {
        add(GetKnowledgeBasesEvent(page: nextPage));
      }
    } catch (e) {
      _logger.e('加载更多知识库异常', error: e);
      emit(KnowledgeBaseError(message: _localizationManager.getString('common.unknown_error')));
    } finally {
      _isLoadingMore = false;
    }
  }

  /// 重置状态
  void _onResetKnowledgeBaseState(
    ResetKnowledgeBaseStateEvent event,
    Emitter<KnowledgeBaseState> emit,
  ) {
    _logger.d('重置知识库状态');
    
    _currentKnowledgeBases.clear();
    _searchResults.clear();
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _currentSearchQuery = null;
    
    emit(const KnowledgeBaseInitial());
  }

  /// 将失败映射到状态
  KnowledgeBaseState _mapFailureToState(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return KnowledgeBaseNetworkError(failure.message);
      case AuthFailure:
        return KnowledgeBaseAuthError(failure.message);
      case ValidationFailure:
        return KnowledgeBaseValidationError(message: failure.message);
      case ServerFailure:
        final serverFailure = failure as ServerFailure;
        return KnowledgeBaseError(
          message: failure.message,
          errorCode: serverFailure.statusCode?.toString(),
        );
      default:
        return KnowledgeBaseError(message: failure.message);
    }
  }
} 