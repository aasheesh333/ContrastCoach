import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Abstract interface for authentication operations backed by Firebase Auth.
abstract class AuthRepository {
  /// Emits the current Firebase user, or null when signed out.
  Stream<User?> watchAuthState();

  /// Signs in with email + password.
  Future<Result<User, AppException>> signInWithEmail(
    String email,
    String password,
  );

  /// Creates a new account with email + password and seeds a user document.
  Future<Result<User, AppException>> signUpWithEmail(
    String email,
    String password,
  );

  /// Signs in using Google OAuth.
  Future<Result<User, AppException>> signInWithGoogle();

  /// Signs out from Firebase Auth and Google.
  Future<void> signOut();
}
