import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';

/// Authentication repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;
  final Logger _logger;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
    required Logger logger,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage,
        _logger = logger;

  @override
  Future<Either<Failure, LoginResult>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      _logger.i('Starting login request: $email');
      
      final request = LoginRequest(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      final response = await _remoteDataSource.login(request);
      
      // Save tokens
      await _setTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiresAt: response.expiresAt ?? DateTime.now().add(const Duration(hours: 1)),
      );

      // Save user info
      final user = response.user.toEntity();
      await _setCachedUser(user);

      // Save remember me status
      if (rememberMe) {
        await _tokenStorage.saveUserCredentials(email: email, password: password);
      }

      _logger.i('Login successful: ${user.username}');
      
      return Right(LoginResult(
        user: user,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        requiresEmailVerification: !user.isEmailVerified,
      ));
    } on NetworkException catch (e) {
      _logger.e('Login network exception: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      _logger.e('Login auth exception: ${e.message}');
      return Left(AuthFailure(message: e.message));
    } on ValidationException catch (e) {
      _logger.e('Login validation exception: ${e.message}');
      return Left(ValidationFailure(message: e.message));
    } on Exception catch (e) {
      _logger.e('Login unknown exception: $e');
      return Left(ServerFailure(message: 'Login failed: $e'));
    }
  }

  @override
  Future<Either<Failure, RegisterResult>> register({
    required String email,
    required String username,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      _logger.i('Starting register request: $email');
      
      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
        confirmPassword: password, // For API compatibility
        firstName: firstName,
        lastName: lastName,
        agreeToTerms: true, // Default to true for simplified interface
      );

      final response = await _remoteDataSource.register(request);
      
      _logger.i('Registration successful: $username');
      
      return Right(RegisterResult(
        message: response.message,
        requiresEmailVerification: false,
        userId: response.data,
      ));
    } on NetworkException catch (e) {
      _logger.e('Register network exception: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      _logger.e('Register validation exception: ${e.message}');
      return Left(ValidationFailure(message: e.message));
    } on Exception catch (e) {
      _logger.e('Register unknown exception: $e');
      return Left(ServerFailure(message: 'Registration failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      _logger.i('Starting logout request');
      
      final request = LogoutRequest(clearAllSessions: false);
      await _remoteDataSource.logout(request);
      
      // Clear local data
      await clearAuthData();
      
      _logger.i('Logout successful');
      return const Right(null);
    } on NetworkException catch (e) {
      _logger.e('Logout network exception: ${e.message}');
      // Clear local data even if network fails
      await clearAuthData();
      return Left(NetworkFailure(message: e.message));
    } on Exception catch (e) {
      _logger.e('Logout unknown exception: $e');
      // Clear local data even if exception occurs
      await clearAuthData();
      return Left(ServerFailure(message: 'Logout failed: $e'));
    }
  }

  @override
  Future<Either<Failure, TokenResult>> refreshToken() async {
    try {
      _logger.i('Starting token refresh');
      
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) {
        _logger.e('Refresh token is null');
        return Left(AuthFailure(message: 'No refresh token found'));
      }

      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await _remoteDataSource.refreshToken(request);
      
      // Save new tokens
      await _setTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken ?? refreshToken,
        expiresAt: response.expiresAt ?? DateTime.now().add(const Duration(hours: 1)),
      );
      
      _logger.i('Token refresh successful');
      
      return Right(TokenResult(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken ?? refreshToken,
        expiresAt: response.expiresAt ?? DateTime.now().add(const Duration(hours: 1)),
      ));
    } on NetworkException catch (e) {
      _logger.e('Token refresh network exception: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      _logger.e('Token refresh auth exception: ${e.message}');
      // Clear local data when token is invalid
      await clearAuthData();
      return Left(AuthFailure(message: e.message));
    } on Exception catch (e) {
      _logger.e('Token refresh unknown exception: $e');
      return Left(ServerFailure(message: 'Token refresh failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      _logger.i('Starting forgot password request: $email');
      
      final request = ForgotPasswordRequest(email: email);
      await _remoteDataSource.forgotPassword(request);
      
      _logger.i('Forgot password request successful');
      return const Right(null);
    } on NetworkException catch (e) {
      _logger.e('Forgot password network exception: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      _logger.e('Forgot password validation exception: ${e.message}');
      return Left(ValidationFailure(message: e.message));
    } on Exception catch (e) {
      _logger.e('Forgot password unknown exception: $e');
      return Left(ServerFailure(message: 'Forgot password request failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      _logger.i('Starting reset password request');
      
      final request = ResetPasswordRequest(
        token: token,
        newPassword: newPassword,
        confirmPassword: newPassword, // For API compatibility
      );

      await _remoteDataSource.resetPassword(request);
      
      _logger.i('Reset password successful');
      return const Right(null);
    } on NetworkException catch (e) {
      _logger.e('Reset password network exception: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      _logger.e('Reset password validation exception: ${e.message}');
      return Left(ValidationFailure(message: e.message));
    } on Exception catch (e) {
      _logger.e('Reset password unknown exception: $e');
      return Left(ServerFailure(message: 'Reset password failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _logger.i('Starting change password request');
      
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: newPassword, // For API compatibility
      );

      await _remoteDataSource.changePassword(request);
      
      _logger.i('Change password successful');
      return const Right(null);
    } on NetworkException catch (e) {
      _logger.e('Change password network exception: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      _logger.e('Change password validation exception: ${e.message}');
      return Left(ValidationFailure(message: e.message));
    } on Exception catch (e) {
      _logger.e('Change password unknown exception: $e');
      return Left(ServerFailure(message: 'Change password failed: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      _logger.i('Getting current user');
      
      // Try to get cached user first
      final cachedUser = await _getCachedUser();
      if (cachedUser != null) {
        _logger.i('Returning cached user: ${cachedUser.username}');
        return Right(cachedUser);
      }

      // If no cached user, fetch from remote
      final response = await _remoteDataSource.getCurrentUser();
      final user = response.toEntity();
      
      // Cache the user
      await _setCachedUser(user);
      
      _logger.i('Current user fetched: ${user.username}');
      return Right(user);
    } on NetworkException catch (e) {
      _logger.e('Get current user network exception: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      _logger.e('Get current user auth exception: ${e.message}');
      await clearAuthData();
      return Left(AuthFailure(message: e.message));
    } on Exception catch (e) {
      _logger.e('Get current user unknown exception: $e');
      return Left(ServerFailure(message: 'Get current user failed: $e'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) return false;
      
      // Check if token is valid
      return await validateToken();
    } catch (e) {
      _logger.e('Error checking authentication: $e');
      return false;
    }
  }

  @override
  Future<Either<Failure, void>> resendVerificationEmail() async {
    try {
      _logger.i('Resending verification email');
      
      await _remoteDataSource.resendVerificationEmail();
      
      _logger.i('Verification email sent successfully');
      return const Right(null);
    } on NetworkException catch (e) {
      _logger.e('Resend verification email network exception: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } on Exception catch (e) {
      _logger.e('Resend verification email unknown exception: $e');
      return Left(ServerFailure(message: 'Resend verification email failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmail(String token) async {
    try {
      _logger.i('Verifying email with token');
      
      final request = VerifyEmailRequest(token: token);
      await _remoteDataSource.verifyEmail(request);
      
      _logger.i('Email verification successful');
      return const Right(null);
    } on NetworkException catch (e) {
      _logger.e('Verify email network exception: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      _logger.e('Verify email validation exception: ${e.message}');
      return Left(ValidationFailure(message: e.message));
    } on Exception catch (e) {
      _logger.e('Verify email unknown exception: $e');
      return Left(ServerFailure(message: 'Email verification failed: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? email,
  }) async {
    try {
      _logger.i('Updating user profile');
      
      final request = UpdateProfileRequest(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
      );

      final response = await _remoteDataSource.updateProfile(request);
      final user = response.toEntity();
      
      // Update cached user
      await _setCachedUser(user);
      
      _logger.i('Profile update successful: ${user.username}');
      return Right(user);
    } on NetworkException catch (e) {
      _logger.e('Update profile network exception: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      _logger.e('Update profile validation exception: ${e.message}');
      return Left(ValidationFailure(message: e.message));
    } on Exception catch (e) {
      _logger.e('Update profile unknown exception: $e');
      return Left(ServerFailure(message: 'Profile update failed: $e'));
    }
  }

  // Additional methods required by interface
  @override
  bool isLoggedIn() {
    try {
      // Synchronous check - just check if we have tokens
      return _tokenStorage.hasTokens();
    } catch (e) {
      _logger.e('Error checking login status: $e');
      return false;
    }
  }

  @override
  Future<bool> validateToken() async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) return false;
      
      // Try to get current user to validate token
      await _remoteDataSource.getCurrentUser();
      return true;
    } catch (e) {
      _logger.e('Token validation failed: $e');
      return false;
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await _tokenStorage.clearAll();
      _logger.i('Auth data cleared');
    } catch (e) {
      _logger.e('Error clearing auth data: $e');
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    return resendVerificationEmail();
  }

  @override
  Future<Either<Failure, void>> verifyEmailToken(String token) async {
    return verifyEmail(token);
  }

  @override
  Future<Either<Failure, User>> updateUser(Map<String, dynamic> data) async {
    return updateProfile(
      firstName: data['firstName'],
      lastName: data['lastName'],
      username: data['username'],
      email: data['email'],
    );
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      _logger.i('Deleting user account');
      
      final request = DeleteAccountRequest(
        password: '', // 这里可能需要从参数传入，暂时留空
        reason: 'User requested deletion',
      );
      
      await _remoteDataSource.deleteAccount(request);
      await clearAuthData();
      
      _logger.i('Account deletion successful');
      return const Right(null);
    } on NetworkException catch (e) {
      _logger.e('Delete account network exception: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } on Exception catch (e) {
      _logger.e('Delete account unknown exception: $e');
      return Left(ServerFailure(message: 'Account deletion failed: $e'));
    }
  }

  // Private helper methods
  Future<String?> _getAccessToken() async {
    return _tokenStorage.getAccessToken();
  }

  Future<String?> _getRefreshToken() async {
    return _tokenStorage.getRefreshToken();
  }

  Future<void> _setTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    await _tokenStorage.saveAccessToken(accessToken);
    await _tokenStorage.saveRefreshToken(refreshToken);
    await _tokenStorage.saveTokenExpiry(expiresAt);
  }

  Future<User?> _getCachedUser() async {
    try {
      final userJson = await _tokenStorage.getCachedUser();
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap).toEntity();
      }
      return null;
    } catch (e) {
      _logger.e('Error getting cached user: $e');
      return null;
    }
  }

  Future<void> _setCachedUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final userJson = json.encode(userModel.toJson());
      await _tokenStorage.setCachedUser(userJson);
    } catch (e) {
      _logger.e('Error setting cached user: $e');
    }
  }
} 