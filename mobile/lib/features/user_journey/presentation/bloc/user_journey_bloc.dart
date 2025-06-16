import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_journey.dart';
import '../../domain/entities/user_journey_step.dart';
import '../../domain/usecases/get_current_journey_usecase.dart';
import '../../domain/usecases/update_step_usecase.dart';
import '../../domain/repositories/user_journey_repository.dart';
import 'user_journey_event.dart';
import 'user_journey_state.dart';

class UserJourneyBloc extends Bloc<UserJourneyEvent, UserJourneyState> {
  final GetCurrentJourneyUseCase getCurrentJourneyUseCase;
  final UpdateStepUseCase updateStepUseCase;
  final UserJourneyRepository repository;

  UserJourneyBloc({
    required this.getCurrentJourneyUseCase,
    required this.updateStepUseCase,
    required this.repository,
  }) : super(UserJourneyInitial()) {
    on<LoadCurrentJourneyEvent>(_onLoadCurrentJourney);
    on<CreateJourneyEvent>(_onCreateJourney);
    on<StartJourneyEvent>(_onStartJourney);
    on<StartStepEvent>(_onStartStep);
    on<CompleteStepEvent>(_onCompleteStep);
    on<SkipStepEvent>(_onSkipStep);
    on<FailStepEvent>(_onFailStep);
    on<UpdateStepProgressEvent>(_onUpdateStepProgress);
    on<PauseJourneyEvent>(_onPauseJourney);
    on<ResumeJourneyEvent>(_onResumeJourney);
    on<CompleteJourneyEvent>(_onCompleteJourney);
    on<SaveProgressEvent>(_onSaveProgress);
    on<RestoreProgressEvent>(_onRestoreProgress);
    on<LoadJourneyHistoryEvent>(_onLoadJourneyHistory);
    on<DeleteJourneyEvent>(_onDeleteJourney);
    on<LoadJourneyStatsEvent>(_onLoadJourneyStats);
  }

  Future<void> _onLoadCurrentJourney(
    LoadCurrentJourneyEvent event,
    Emitter<UserJourneyState> emit,
  ) async {
    try {
      emit(UserJourneyLoading());
      
      final journey = await getCurrentJourneyUseCase(event.userId);
      final history = await repository.getJourneyHistory(event.userId);
      final stats = await repository.getJourneyStats(event.userId);
      
      emit(UserJourneyLoaded(
        currentJourney: journey,
        journeyHistory: history,
        journeyStats: stats,
      ));
    } catch (e) {
      emit(UserJourneyError(message: '加载旅程失败: ${e.toString()}'));
    }
  }

  Future<void> _onCreateJourney(
    CreateJourneyEvent event,
    Emitter<UserJourneyState> emit,
  ) async {
    try {
      emit(UserJourneyLoading());
      
      final journey = await repository.createJourney(event.userId, event.journeyType);
      
      emit(UserJourneyUpdated(
        journey: journey,
        message: '旅程创建成功',
      ));
      
      // 重新加载当前状态
      add(LoadCurrentJourneyEvent(event.userId));
    } catch (e) {
      emit(UserJourneyError(message: '创建旅程失败: ${e.toString()}'));
    }
  }

  Future<void> _onStartJourney(
    StartJourneyEvent event,
    Emitter<UserJourneyState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is UserJourneyLoaded && currentState.currentJourney != null) {
        final journey = currentState.currentJourney!;
        final updatedJourney = journey.copyWith(
          status: UserJourneyStatus.inProgress,
          startedAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
        );
        
        await repository.updateJourney(updatedJourney);
        
        emit(UserJourneyUpdated(
          journey: updatedJourney,
          message: '旅程已开始',
        ));
      }
    } catch (e) {
      emit(UserJourneyError(message: '开始旅程失败: ${e.toString()}'));
    }
  }

  Future<void> _onStartStep(
    StartStepEvent event,
    Emitter<UserJourneyState> emit,
  ) async {
    try {
      final step = await repository.startStep(event.journeyId, event.stepId);
      
      // 获取更新后的旅程
      final currentState = state;
      if (currentState is UserJourneyLoaded && currentState.currentJourney != null) {
        final journey = currentState.currentJourney!;
        final updatedSteps = journey.steps.map((s) => s.id == step.id ? step : s).toList();
        final updatedJourney = journey.copyWith(
          steps: updatedSteps,
          currentStepId: step.id,
          lastActiveAt: DateTime.now(),
        );
        
        emit(UserJourneyStepUpdated(
          journey: updatedJourney,
          stepId: step.id,
          message: '步骤已开始: ${step.title}',
        ));
      }
    } catch (e) {
      emit(UserJourneyError(message: '开始步骤失败: ${e.toString()}'));
    }
  }

  Future<void> _onCompleteStep(
    CompleteStepEvent event,
    Emitter<UserJourneyState> emit,
  ) async {
    try {
      final step = await repository.completeStep(
        event.journeyId,
        event.stepId,
        metadata: event.metadata,
      );
      
      // 获取更新后的旅程
      final currentState = state;
      if (currentState is UserJourneyLoaded && currentState.currentJourney != null) {
        final journey = currentState.currentJourney!;
        final updatedSteps = journey.steps.map((s) => s.id == step.id ? step : s).toList();
        
        // 检查是否所有步骤都已完成
        final allCompleted = updatedSteps.every((s) => s.status == UserJourneyStepStatus.completed);
        final updatedJourney = journey.copyWith(
          steps: updatedSteps,
          status: allCompleted ? UserJourneyStatus.completed : journey.status,
          completedAt: allCompleted ? DateTime.now() : journey.completedAt,
          lastActiveAt: DateTime.now(),
        );
        
        if (allCompleted) {
          await repository.updateJourney(updatedJourney);
        }
        
        emit(UserJourneyStepUpdated(
          journey: updatedJourney,
          stepId: step.id,
          message: allCompleted ? '恭喜！旅程已完成' : '步骤已完成: ${step.title}',
        ));
      }
    } catch (e) {
      emit(UserJourneyError(message: '完成步骤失败: ${e.toString()}'));
    }
  }

  Future<void> _onSkipStep(
    SkipStepEvent event,
    Emitter<UserJourneyState> emit,
  ) async {
    try {
      final step = await repository.skipStep(
        event.journeyId,
        event.stepId,
        reason: event.reason,
      );
      
      // 获取更新后的旅程
      final currentState = state;
      if (currentState is UserJourneyLoaded && currentState.currentJourney != null) {
        final journey = currentState.currentJourney!;
        final updatedSteps = journey.steps.map((s) => s.id == step.id ? step : s).toList();
        final updatedJourney = journey.copyWith(
          steps: updatedSteps,
          lastActiveAt: DateTime.now(),
        );
        
        emit(UserJourneyStepUpdated(
          journey: updatedJourney,
          stepId: step.id,
          message: '步骤已跳过: ${step.title}',
        ));
      }
    } catch (e) {
      emit(UserJourneyError(message: '跳过步骤失败: ${e.toString()}'));
    }
  }

  Future<void> _onFailStep(
    FailStepEvent event,
    Emitter<UserJourneyState> emit,
  ) async {
    try {
      final step = await repository.failStep(
        event.journeyId,
        event.stepId,
        event.errorMessage,
      );
      
      // 获取更新后的旅程
      final currentState = state;
      if (currentState is UserJourneyLoaded && currentState.currentJourney != null) {
        final journey = currentState.currentJourney!;
        final updatedSteps = journey.steps.map((s) => s.id == step.id ? step : s).toList();
        final updatedJourney = journey.copyWith(
          steps: updatedSteps,
          status: UserJourneyStatus.failed,
          lastActiveAt: DateTime.now(),
        );
        
        await repository.updateJourney(updatedJourney);
        
        emit(UserJourneyStepUpdated(
          journey: updatedJourney,
          stepId: step.id,
          message: '步骤失败: ${step.title}',
        ));
      }
    } catch (e) {
      emit(UserJourneyError(message: '标记步骤失败时出错: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateStepProgress(
    UpdateStepProgressEvent event,
    Emitter<UserJourneyState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is UserJourneyLoaded && currentState.currentJourney != null) {
        final journey = currentState.currentJourney!;
        final step = journey.steps.firstWhere((s) => s.id == event.stepId);
        final updatedStep = step.copyWith(progress: event.progress);
        
        await repository.updateStep(event.journeyId, updatedStep);
        
        final updatedSteps = journey.steps.map((s) => s.id == updatedStep.id ? updatedStep : s).toList();
        final updatedJourney = journey.copyWith(
          steps: updatedSteps,
          lastActiveAt: DateTime.now(),
        );
        
        emit(UserJourneyStepUpdated(
          journey: updatedJourney,
          stepId: updatedStep.id,
          message: '进度已更新: ${(event.progress * 100).toInt()}%',
        ));
      }
    } catch (e) {
      emit(UserJourneyError(message: '更新进度失败: ${e.toString()}'));
    }
  }

  Future<void> _onPauseJourney(
    PauseJourneyEvent event,
    Emitter<UserJourneyState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is UserJourneyLoaded && currentState.currentJourney != null) {
        final journey = currentState.currentJourney!;
        final updatedJourney = journey.copyWith(
          status: UserJourneyStatus.paused,
          lastActiveAt: DateTime.now(),
        );
        
        await repository.updateJourney(updatedJourney);
        
        emit(UserJourneyUpdated(
          journey: updatedJourney,
          message: '旅程已暂停',
        ));
      }
    } catch (e) {
      emit(UserJourneyError(message: '暂停旅程失败: ${e.toString()}'));
    }
  }

  Future<void> _onResumeJourney(
    ResumeJourneyEvent event,
    Emitter<UserJourneyState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is UserJourneyLoaded && currentState.currentJourney != null) {
        final journey = currentState.currentJourney!;
        final updatedJourney = journey.copyWith(
          status: UserJourneyStatus.inProgress,
          lastActiveAt: DateTime.now(),
        );
        
        await repository.updateJourney(updatedJourney);
        
        emit(UserJourneyUpdated(
          journey: updatedJourney,
          message: '旅程已恢复',
        ));
      }
    } catch (e) {
      emit(UserJourneyError(message: '恢复旅程失败: ${e.toString()}'));
    }
  }

  Future<void> _onCompleteJourney(
    CompleteJourneyEvent event,
    Emitter<UserJourneyState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is UserJourneyLoaded && currentState.currentJourney != null) {
        final journey = currentState.currentJourney!;
        final updatedJourney = journey.copyWith(
          status: UserJourneyStatus.completed,
          completedAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
        );
        
        await repository.updateJourney(updatedJourney);
        
        emit(UserJourneyUpdated(
          journey: updatedJourney,
          message: '恭喜！旅程已完成',
        ));
      }
    } catch (e) {
      emit(UserJourneyError(message: '完成旅程失败: ${e.toString()}'));
    }
  }

  Future<void> _onSaveProgress(
    SaveProgressEvent event,
    Emitter<UserJourneyState> emit,
  ) async {
    try {
      await repository.saveProgress(event.journeyId, event.progressData);
      
      emit(UserJourneyProgressSaved(
        journeyId: event.journeyId,
        message: '进度已保存',
      ));
    } catch (e) {
      emit(UserJourneyError(message: '保存进度失败: ${e.toString()}'));
    }
  }

  Future<void> _onRestoreProgress(
    RestoreProgressEvent event,
    Emitter<UserJourneyState> emit,
  ) async {
    try {
      final progressData = await repository.restoreProgress(event.journeyId);
      
      if (progressData != null) {
        emit(UserJourneyProgressRestored(
          journeyId: event.journeyId,
          progressData: progressData,
          message: '进度已恢复',
        ));
      } else {
        emit(UserJourneyError(message: '未找到保存的进度'));
      }
    } catch (e) {
      emit(UserJourneyError(message: '恢复进度失败: ${e.toString()}'));
    }
  }

  Future<void> _onLoadJourneyHistory(
    LoadJourneyHistoryEvent event,
    Emitter<UserJourneyState> emit,
  ) async {
    try {
      final history = await repository.getJourneyHistory(event.userId);
      
      final currentState = state;
      if (currentState is UserJourneyLoaded) {
        emit(currentState.copyWith(journeyHistory: history));
      } else {
        emit(UserJourneyLoaded(journeyHistory: history));
      }
    } catch (e) {
      emit(UserJourneyError(message: '加载历史记录失败: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteJourney(
    DeleteJourneyEvent event,
    Emitter<UserJourneyState> emit,
  ) async {
    try {
      await repository.deleteJourney(event.journeyId);
      
      emit(UserJourneyDeleted(
        journeyId: event.journeyId,
        message: '旅程已删除',
      ));
    } catch (e) {
      emit(UserJourneyError(message: '删除旅程失败: ${e.toString()}'));
    }
  }

  Future<void> _onLoadJourneyStats(
    LoadJourneyStatsEvent event,
    Emitter<UserJourneyState> emit,
  ) async {
    try {
      final stats = await repository.getJourneyStats(event.userId);
      
      final currentState = state;
      if (currentState is UserJourneyLoaded) {
        emit(currentState.copyWith(journeyStats: stats));
      } else {
        emit(UserJourneyLoaded(journeyStats: stats));
      }
    } catch (e) {
      emit(UserJourneyError(message: '加载统计数据失败: ${e.toString()}'));
    }
  }
} 