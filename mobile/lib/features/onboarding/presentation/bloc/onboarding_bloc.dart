import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/onboarding_progress.dart';
import '../../domain/entities/onboarding_step.dart';
import '../../domain/usecases/get_onboarding_progress.dart';
import '../../domain/usecases/update_onboarding_progress.dart';
import '../../domain/usecases/complete_onboarding.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetOnboardingProgress getOnboardingProgress;
  final UpdateOnboardingProgress updateOnboardingProgress;
  final CompleteOnboarding completeOnboarding;

  OnboardingBloc({
    required this.getOnboardingProgress,
    required this.updateOnboardingProgress,
    required this.completeOnboarding,
  }) : super(OnboardingInitial()) {
    on<LoadOnboardingProgress>(_onLoadOnboardingProgress);
    on<UpdateCurrentStep>(_onUpdateCurrentStep);
    on<CompleteOnboardingStep>(_onCompleteOnboardingStep);
    on<CompleteOnboardingFlow>(_onCompleteOnboardingFlow);
    on<SkipOnboarding>(_onSkipOnboarding);
  }

  Future<void> _onLoadOnboardingProgress(
    LoadOnboardingProgress event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());
    
    try {
      final progress = await getOnboardingProgress(event.userId);
      emit(OnboardingLoaded(progress: progress));
    } catch (error) {
      emit(OnboardingError(message: error.toString()));
    }
  }

  Future<void> _onUpdateCurrentStep(
    UpdateCurrentStep event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingLoaded) {
      final currentState = state as OnboardingLoaded;
      final updatedProgress = currentState.progress.copyWith(
        currentStepId: event.stepId,
        updatedAt: DateTime.now(),
      );
      
      try {
        await updateOnboardingProgress(updatedProgress);
        emit(OnboardingLoaded(progress: updatedProgress));
      } catch (error) {
        emit(OnboardingError(message: error.toString()));
      }
    }
  }

  Future<void> _onCompleteOnboardingStep(
    CompleteOnboardingStep event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingLoaded) {
      final currentState = state as OnboardingLoaded;
      final updatedProgress = currentState.progress.markStepCompleted(event.stepId);
      
      try {
        await updateOnboardingProgress(updatedProgress);
        emit(OnboardingLoaded(progress: updatedProgress));
      } catch (error) {
        emit(OnboardingError(message: error.toString()));
      }
    }
  }

  Future<void> _onCompleteOnboardingFlow(
    CompleteOnboardingFlow event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingLoaded) {
      final currentState = state as OnboardingLoaded;
      
      try {
        final completedProgress = await completeOnboarding(currentState.progress);
        emit(OnboardingCompleted(progress: completedProgress));
      } catch (error) {
        emit(OnboardingError(message: error.toString()));
      }
    }
  }

  Future<void> _onSkipOnboarding(
    SkipOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingLoaded) {
      final currentState = state as OnboardingLoaded;
      
      try {
        final skippedProgress = await completeOnboarding(currentState.progress);
        emit(OnboardingSkipped(progress: skippedProgress));
      } catch (error) {
        emit(OnboardingError(message: error.toString()));
      }
    }
  }
} 