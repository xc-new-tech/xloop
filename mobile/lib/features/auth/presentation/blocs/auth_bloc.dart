import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication business logic controller
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final Logger _logger;
  Timer? _tokenRefreshTimer;

  AuthBloc({
    required AuthRepository authRepository,
    required Logger logger,
  }) : 
    _authRepository = authRepository,
    _logger = logger,
    super(const AuthInitial()) {
    
    // Register event handlers
    on<AuthAppStarted>(_onAppStarted);
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthTokenRefreshRequested>(_onTokenRefreshRequested);
    on<AuthEmailVerificationRequested>(_onEmailVerificationRequested);
    on<AuthVerifyEmailToken>(_onVerifyEmailToken);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthResetPassword>(_onResetPassword);
    on<AuthChangePasswordRequested>(_onChangePasswordRequested);
    on<AuthUpdateUserRequested>(_onUpdateUserRequested);
    on<AuthDeleteAccountRequested>(_onDeleteAccountRequested);
    on<AuthClearError>(_onClearError);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthSocialLoginRequested>(_onSocialLoginRequested);
  }

  @override
  Future<void> close() {
    _tokenRefreshTimer?.cancel();
    return super.close();
  }

  /// Check authentication status when app starts
  Future<void> _onAppStarted(AuthAppStarted event, Emitter<AuthState> emit) async {
    try {
      _logger.d('AuthBloc: Checking authentication status on app start');
      emit(const AuthLoading(message: 'Checking login status...'));

      // Check if user is logged in
      final isLoggedIn = _authRepository.isLoggedIn();
      if (!isLoggedIn) {
        _logger.d('AuthBloc: User not logged in');
        emit(const AuthUnauthenticated(message: 'Not logged in'));
        return;
      }

      // Validate token and get user info
      final isValidToken = await _authRepository.validateToken();
      if (!isValidToken) {
        _logger.e('AuthBloc: Token validation failed');
        await _authRepository.clearAuthData();
        emit(const AuthUnauthenticated(message: 'Token expired, please login again'));
        return;
      }

      // Get current user
      final result = await _authRepository.getCurrentUser();
      result.fold(
        (failure) async {
          _logger.e('AuthBloc: Get current user failed - ${failure.message}');
          await _authRepository.clearAuthData();
          emit(const AuthUnauthenticated(message: 'Session expired, please login again'));
        },
        (user) {
          _logger.d('AuthBloc: Authentication successful - ${user.username}');
          emit(AuthAuthenticated(
            user: user,
            accessToken: '', // Token managed by repository
            refreshToken: '',
            tokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          ));
          _startTokenRefreshTimer();
        },
      );

    } catch (e, stackTrace) {
      _logger.e('AuthBloc: Check authentication status failed', error: e, stackTrace: stackTrace);
      emit(AuthError(
        message: 'Check login status failed',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Check authentication status
  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    await _onAppStarted(AuthAppStarted(), emit);
  }

  /// Handle login request
  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    try {
      _logger.d('AuthBloc: Processing login request - ${event.email}');
      emit(const AuthLoading(message: 'Logging in...'));

      final result = await _authRepository.login(
        email: event.email,
        password: event.password,
        rememberMe: event.rememberMe,
      );

      result.fold(
        (failure) {
          _logger.e('AuthBloc: Login failed - ${failure.message}');
          emit(AuthError(message: _getFailureMessage(failure)));
        },
        (loginResult) {
          _logger.d('AuthBloc: Login successful - ${loginResult.user.username}');
          emit(AuthLoginSuccess(
            user: loginResult.user,
            accessToken: loginResult.accessToken,
            refreshToken: loginResult.refreshToken,
            tokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
            isFirstLogin: false,
            welcomeMessage: 'Welcome back, ${loginResult.user.displayName}!',
          ));
          _startTokenRefreshTimer();
        },
      );

    } catch (e, stackTrace) {
      _logger.e('AuthBloc: Login exception', error: e, stackTrace: stackTrace);
      emit(AuthError(
        message: 'Login failed, please try again',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle registration request
  Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    try {
      _logger.d('AuthBloc: Processing registration request - ${event.email}');
      emit(const AuthLoading(message: 'Registering...'));

      final result = await _authRepository.register(
        email: event.email,
        username: event.username,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      );

      result.fold(
        (failure) {
          _logger.e('AuthBloc: Registration failed - ${failure.message}');
          emit(AuthError(message: _getFailureMessage(failure)));
        },
        (registerResult) {
          _logger.d('AuthBloc: Registration successful');
          emit(AuthRegisterSuccess(
            message: registerResult.message,
            email: event.email,
            requiresEmailVerification: registerResult.requiresEmailVerification,
          ));
        },
      );

    } catch (e, stackTrace) {
      _logger.e('AuthBloc: Registration exception', error: e, stackTrace: stackTrace);
      emit(AuthError(
        message: 'Registration failed, please try again',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle logout request
  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    try {
      _logger.d('AuthBloc: Processing logout request');
      emit(const AuthLoading(message: 'Logging out...'));

      final result = await _authRepository.logout();

      result.fold(
        (failure) {
          _logger.e('AuthBloc: Logout failed - ${failure.message}');
          // Clear local state even if logout fails
          _tokenRefreshTimer?.cancel();
          emit(const AuthUnauthenticated(message: 'Logged out'));
        },
        (_) {
          _logger.d('AuthBloc: Logout successful');
          _tokenRefreshTimer?.cancel();
          emit(const AuthLogoutSuccess(
            message: 'Successfully logged out',
            
          ));
        },
      );

    } catch (e, stackTrace) {
      _logger.e('AuthBloc: Logout exception', error: e, stackTrace: stackTrace);
      // Clear local state even on exception
      _tokenRefreshTimer?.cancel();
      emit(const AuthUnauthenticated(message: 'Logged out'));
    }
  }

  /// Handle token refresh request
  Future<void> _onTokenRefreshRequested(AuthTokenRefreshRequested event, Emitter<AuthState> emit) async {
    try {
      _logger.d('AuthBloc: Processing token refresh request');

      final result = await _authRepository.refreshToken();

      result.fold(
        (failure) {
          _logger.e('AuthBloc: Token refresh failed - ${failure.message}');
          // Clear auth data and redirect to login
          _authRepository.clearAuthData();
          _tokenRefreshTimer?.cancel();
          emit(const AuthUnauthenticated(message: 'Session expired, please login again'));
        },
        (tokenResult) {
          _logger.d('AuthBloc: Token refresh successful');
          // Update current state with new tokens if in authenticated state
          if (state is AuthAuthenticated) {
            final currentState = state as AuthAuthenticated;
            emit(AuthAuthenticated(
              user: currentState.user,
              accessToken: tokenResult.accessToken,
              refreshToken: tokenResult.refreshToken,
              tokenExpiresAt: tokenResult.expiresAt,
            ));
          }
          _startTokenRefreshTimer();
        },
      );

    } catch (e, stackTrace) {
      _logger.e('AuthBloc: Token refresh exception', error: e, stackTrace: stackTrace);
      await _authRepository.clearAuthData();
      _tokenRefreshTimer?.cancel();
      emit(const AuthUnauthenticated(message: 'Session expired, please login again'));
    }
  }

  /// Handle email verification request
  Future<void> _onEmailVerificationRequested(AuthEmailVerificationRequested event, Emitter<AuthState> emit) async {
    try {
      _logger.d('AuthBloc: Processing email verification request');
      emit(const AuthLoading(message: 'Sending verification email...'));

      final result = await _authRepository.sendEmailVerification();

      result.fold(
        (failure) {
          _logger.e('AuthBloc: Email verification failed - ${failure.message}');
          emit(AuthError(message: _getFailureMessage(failure)));
        },
        (_) {
          _logger.d('AuthBloc: Email verification sent successfully');
          emit(const AuthEmailVerificationSent(
            message: 'Verification email sent successfully',
            email: '',
          ));
        },
      );

    } catch (e, stackTrace) {
      _logger.e('AuthBloc: Email verification exception', error: e, stackTrace: stackTrace);
      emit(AuthError(
        message: 'Send verification email failed',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle email token verification
  Future<void> _onVerifyEmailToken(AuthVerifyEmailToken event, Emitter<AuthState> emit) async {
    try {
      _logger.d('AuthBloc: Processing email token verification');
      emit(const AuthLoading(message: 'Verifying email...'));

      final result = await _authRepository.verifyEmailToken(event.token);

      result.fold(
        (failure) {
          _logger.e('AuthBloc: Email verification failed - ${failure.message}');
          emit(AuthError(message: _getFailureMessage(failure)));
        },
        (_) {
          _logger.d('AuthBloc: Email verification successful');
          emit(const AuthEmailVerified(
            message: 'Email verified successfully',
          ));
        },
      );

    } catch (e, stackTrace) {
      _logger.e('AuthBloc: Email verification exception', error: e, stackTrace: stackTrace);
      emit(AuthError(
        message: 'Email verification failed',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle password reset request
  Future<void> _onPasswordResetRequested(AuthPasswordResetRequested event, Emitter<AuthState> emit) async {
    try {
      _logger.d('AuthBloc: Processing password reset request - ${event.email}');
      emit(const AuthLoading(message: 'Sending reset email...'));

      final result = await _authRepository.forgotPassword(event.email);

      result.fold(
        (failure) {
          _logger.e('AuthBloc: Password reset failed - ${failure.message}');
          emit(AuthError(message: _getFailureMessage(failure)));
        },
        (_) {
          _logger.d('AuthBloc: Password reset email sent successfully');
          emit(AuthPasswordResetSent(
            message: 'Password reset email sent successfully',
            email: event.email,
          ));
        },
      );

    } catch (e, stackTrace) {
      _logger.e('AuthBloc: Password reset exception', error: e, stackTrace: stackTrace);
      emit(AuthError(
        message: 'Send reset email failed',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle password reset
  Future<void> _onResetPassword(AuthResetPassword event, Emitter<AuthState> emit) async {
    try {
      _logger.d('AuthBloc: Processing password reset');
      emit(const AuthLoading(message: 'Resetting password...'));

      final result = await _authRepository.resetPassword(
        token: event.token,
        newPassword: event.newPassword,
      );

      result.fold(
        (failure) {
          _logger.e('AuthBloc: Password reset failed - ${failure.message}');
          emit(AuthError(message: _getFailureMessage(failure)));
        },
        (_) {
          _logger.d('AuthBloc: Password reset successful');
          emit(const AuthPasswordResetSuccess(
            message: 'Password reset successfully',
            
          ));
        },
      );

    } catch (e, stackTrace) {
      _logger.e('AuthBloc: Password reset exception', error: e, stackTrace: stackTrace);
      emit(AuthError(
        message: 'Password reset failed',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle change password request
  Future<void> _onChangePasswordRequested(AuthChangePasswordRequested event, Emitter<AuthState> emit) async {
    try {
      _logger.d('AuthBloc: Processing change password request');
      emit(const AuthLoading(message: 'Changing password...'));

      final result = await _authRepository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );

      result.fold(
        (failure) {
          _logger.e('AuthBloc: Change password failed - ${failure.message}');
          emit(AuthError(message: _getFailureMessage(failure)));
        },
        (_) {
          _logger.d('AuthBloc: Change password successful');
          emit(const AuthPasswordChangeSuccess(
            message: 'Password changed successfully',
          ));
        },
      );

    } catch (e, stackTrace) {
      _logger.e('AuthBloc: Change password exception', error: e, stackTrace: stackTrace);
      emit(AuthError(
        message: 'Password change failed',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle update user request
  Future<void> _onUpdateUserRequested(AuthUpdateUserRequested event, Emitter<AuthState> emit) async {
    try {
      _logger.d('AuthBloc: Processing update user request');
      emit(const AuthLoading(message: 'Updating profile...'));

      final result = await _authRepository.updateUser(event.userData ?? {});

      result.fold(
        (failure) {
          _logger.e('AuthBloc: Update user failed - ${failure.message}');
          emit(AuthError(message: _getFailureMessage(failure)));
        },
        (user) {
          _logger.d('AuthBloc: Update user successful - ${user.username}');
          // Update current authenticated state with new user data
          if (state is AuthAuthenticated) {
            final currentState = state as AuthAuthenticated;
            emit(AuthAuthenticated(
              user: user,
              accessToken: currentState.accessToken,
              refreshToken: currentState.refreshToken,
              tokenExpiresAt: currentState.tokenExpiresAt,
            ));
          }
          emit(AuthUserUpdateSuccess(
            user: user,
            message: 'Profile updated successfully',
          ));
        },
      );

    } catch (e, stackTrace) {
      _logger.e('AuthBloc: Update user exception', error: e, stackTrace: stackTrace);
      emit(AuthError(
        message: 'Profile update failed',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle delete account request
  Future<void> _onDeleteAccountRequested(AuthDeleteAccountRequested event, Emitter<AuthState> emit) async {
    try {
      _logger.d('AuthBloc: Processing delete account request');
      emit(const AuthLoading(message: 'Deleting account...'));

      final result = await _authRepository.deleteAccount();

      result.fold(
        (failure) {
          _logger.e('AuthBloc: Delete account failed - ${failure.message}');
          emit(AuthError(message: _getFailureMessage(failure)));
        },
        (_) {
          _logger.d('AuthBloc: Delete account successful');
          _tokenRefreshTimer?.cancel();
          emit(const AuthAccountDeleted(
            message: 'Account deleted successfully',
            
          ));
        },
      );

    } catch (e, stackTrace) {
      _logger.e('AuthBloc: Delete account exception', error: e, stackTrace: stackTrace);
      emit(AuthError(
        message: 'Account deletion failed',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle clear error
  void _onClearError(AuthClearError event, Emitter<AuthState> emit) {
    if (state is AuthError) {
      final isAuthenticated = _authRepository.isLoggedIn();
      if (isAuthenticated) {
        // Try to get current user and restore authenticated state
        _authRepository.getCurrentUser().then((result) {
          result.fold(
            (failure) => emit(const AuthUnauthenticated(message: 'Session expired')),
            (user) => emit(AuthAuthenticated(
              user: user,
              accessToken: '',
              refreshToken: '',
              tokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
            )),
          );
        });
      } else {
        emit(const AuthUnauthenticated(message: 'Not logged in'));
      }
    }
  }

  /// Handle check status
  Future<void> _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) async {
    final isAuthenticated = await _authRepository.isAuthenticated();
    if (isAuthenticated) {
      final result = await _authRepository.getCurrentUser();
      result.fold(
        (failure) => emit(const AuthUnauthenticated(message: 'Session expired')),
        (user) => emit(AuthAuthenticated(
          user: user,
          accessToken: '',
          refreshToken: '',
          tokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
        )),
      );
    } else {
      emit(const AuthUnauthenticated(message: 'Not logged in'));
    }
  }

  /// Handle social login request
  Future<void> _onSocialLoginRequested(AuthSocialLoginRequested event, Emitter<AuthState> emit) async {
    // TODO: Implement social login
    emit(const AuthError(message: 'Social login not implemented yet'));
  }

  /// Start token refresh timer
  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = Timer.periodic(
      const Duration(minutes: 45), // Refresh every 45 minutes
      (timer) {
        if (state is AuthAuthenticated) {
          add(AuthTokenRefreshRequested(refreshToken: ''));
        } else {
          timer.cancel();
        }
      },
    );
  }

  /// Get failure message
  String _getFailureMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'Network connection failed, please check your internet';
      case AuthFailure:
        return failure.message;
      case ValidationFailure:
        return failure.message;
      case ServerFailure:
        return 'Server error, please try again later';
      default:
        return 'Unknown error occurred';
    }
  }
} 