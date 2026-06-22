import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase-backed [AuthRepository] implementation.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates an [AuthRepositoryImpl] with the supplied collaborators.
  AuthRepositoryImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _google = googleSignIn;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _google;

  @override
  Stream<User?> watchAuthState() => _auth.authStateChanges();

  @override
  Future<Result<User, AppException>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        return const Err(AuthException('No user returned from sign-in.'));
      }
      return Ok(user);
    } on FirebaseAuthException catch (e) {
      final friendly = _friendlyAuthMessage(e);
      return Err(AuthException(friendly, cause: e));
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('API key') || msg.contains('api_key')) {
        return Err(AuthException(
          'Firebase API key mismatch. Make sure --dart-define=FIREBASE_API_KEY '
          'matches the key in google-services.json.',
          cause: e is Exception ? e : Exception(msg),
        ));
      }
      return Err(AuthException('Sign-in failed.', cause: e));
    }
  }

  @override
  Future<Result<User, AppException>> signUpWithEmail(
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        return const Err(AuthException('No user returned from sign-up.'));
      }
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'subscriptionStatus': 'free',
      });
      return Ok(user);
    } on FirebaseAuthException catch (e) {
      final friendly = _friendlyAuthMessage(e);
      return Err(AuthException(friendly, cause: e));
    } catch (e) {
      return Err(AuthException('Sign-up failed.', cause: e));
    }
  }

  String _friendlyAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-api-key':
      case 'INVALID_API_KEY':
        return 'Firebase API key is invalid. Check your google-services.json '
            'and --dart-define=FIREBASE_API_KEY.';
      case 'invalid-credential':
      case 'wrong-password':
        return 'Wrong email or password. Please try again.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  @override
  Future<Result<User, AppException>> signInWithGoogle() async {
    try {
      final account = await _google.signIn();
      if (account == null) {
        return const Err(AuthException('Google sign-in cancelled.'));
      }
      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: auth.accessToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      final user = cred.user;
      if (user == null) {
        return const Err(
          AuthException('No user returned from Google sign-in.'),
        );
      }
      await _firestore.collection('users').doc(user.uid).set(
        {
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'subscriptionStatus': 'free',
        },
        SetOptions(merge: true),
      );
      return Ok(user);
    } on FirebaseAuthException catch (e) {
      return Err(AuthException(
        e.message ?? 'Google sign-in failed.',
        cause: e,
      ));
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('API key') || msg.contains('api_key')) {
        return Err(AuthException(
          'Firebase API key mismatch. Make sure --dart-define=FIREBASE_API_KEY '
          'matches the key in google-services.json.',
          cause: e is Exception ? e : Exception(e.toString()),
        ));
      }
      if (msg.contains('network') || msg.contains('NETWORK_ERROR')) {
        return Err(AuthException(
          'Network error. Check your internet connection and try again.',
          cause: e is Exception ? e : Exception(e.toString()),
        ));
      }
      return Err(AuthException(
        'Google sign-in failed. If this is a new install, make sure your '
        'device SHA-1 is registered in the Firebase console.',
        cause: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _google.signOut()]);
  }
}
