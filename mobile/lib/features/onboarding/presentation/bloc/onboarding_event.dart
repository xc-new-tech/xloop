part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class LoadOnboardingProgress extends OnboardingEvent {
  final String userId;

  const LoadOnboardingProgress({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateCurrentStep extends OnboardingEvent {
  final String stepId;

  const UpdateCurrentStep({required this.stepId});

  @override
  List<Object?> get props => [stepId];
}

class CompleteOnboardingStep extends OnboardingEvent {
  final String stepId;

  const CompleteOnboardingStep({required this.stepId});

  @override
  List<Object?> get props => [stepId];
}

class CompleteOnboardingFlow extends OnboardingEvent {
  const CompleteOnboardingFlow();
}

class SkipOnboarding extends OnboardingEvent {
  const SkipOnboarding();
} 