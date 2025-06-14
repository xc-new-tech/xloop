import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../entities/auth_result.dart';

/// 认证仓库接口
abstract class AuthRepository {
  /// Authenticate user with email and password
  Future<Either<Failure, LoginResult>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  /// Register new user account
  Future<Either<Failure, RegisterResult>> register({
    required String email,
    required String username,
    required String password,
    String? firstName,
    String? lastName,
  });

  /// Sign out current user
  Future<Either<Failure, void>> logout();

  /// Refresh authentication token
  Future<Either<Failure, TokenResult>> refreshToken();

  /// Send password reset email
  Future<Either<Failure, void>> forgotPassword(String email);

  /// Reset password with token
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Change user password
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Get current authenticated user
  Future<Either<Failure, User>> getCurrentUser();

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated();

  /// Send email verification
  Future<Either<Failure, void>> resendVerificationEmail();

  /// Verify email with token
  Future<Either<Failure, void>> verifyEmail(String token);

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? email,
  });

  /// Check if user is logged in (synchronous)
  bool isLoggedIn();

  /// Validate current token
  Future<bool> validateToken();

  /// Clear all authentication data
  Future<void> clearAuthData();

  /// Send email verification
  Future<Either<Failure, void>> sendEmailVerification();

  /// Verify email with token
  Future<Either<Failure, void>> verifyEmailToken(String token);

  /// Update user
  Future<Either<Failure, User>> updateUser(Map<String, dynamic> data);

  /// Delete user account
  Future<Either<Failure, void>> deleteAccount();
}

 