part of 'onboarding_bloc.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingLoaded extends OnboardingState {
  final OnboardingProgress progress;

  const OnboardingLoaded({required this.progress});

  @override
  List<Object?> get props => [progress];
}

class OnboardingCompleted extends OnboardingState {
  final OnboardingProgress progress;

  const OnboardingCompleted({required this.progress});

  @override
  List<Object?> get props => [progress];
}

class OnboardingSkipped extends OnboardingState {
  final OnboardingProgress progress;

  const OnboardingSkipped({required this.progress});

  @override
  List<Object?> get props => [progress];
}

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError({required this.message});

  @override
  List<Object?> get props => [message];
} 