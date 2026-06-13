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
      return Err(AuthException(e.message ?? 'Sign-in failed.', cause: e));
    } catch (e) {
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
      return Err(AuthException(e.message ?? 'Sign-up failed.', cause: e));
    } catch (e) {
      return Err(AuthException('Sign-up failed.', cause: e));
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
    } catch (e) {
      return Err(AuthException('Google sign-in failed.', cause: e));
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _google.signOut()]);
  }
}
