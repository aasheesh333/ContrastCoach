import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Profile data returned to the UI. Real data sourced from FirebaseAuth
/// (displayName, email, photoURL) and Firestore (createdAt, subscriptionStatus).
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.initials,
    required this.photoURL,
    required this.subscriptionStatus,
    required this.createdAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final String initials;
  final String? photoURL;
  final String subscriptionStatus;
  final DateTime? createdAt;

  String get firstName => displayName.split(' ').first;

  static String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  static String _initialsFromEmail(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return '?';
    return local[0].toUpperCase();
  }
}

class UserProfileService {
  UserProfileService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Read the current user, falling back to a local-only stub if signed out
  /// (so screens can still render the UI chrome in tests / previews).
  Future<Result<UserProfile, AppException>> current() async {
    final user = _auth.currentUser;
    if (user == null) {
      return const Ok(UserProfile(
        uid: 'local',
        email: '',
        displayName: '',
        initials: 'C',
        photoURL: null,
        subscriptionStatus: 'free',
        createdAt: null,
      ));
    }

    String sub = 'free';
    DateTime? createdAt;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        sub = (data['subscriptionStatus'] as String?) ?? 'free';
        final ts = data['createdAt'];
        if (ts is Timestamp) createdAt = ts.toDate();
      }
    } catch (_) {
      // Best-effort — fall through with defaults.
    }

    final displayName = (user.displayName?.isNotEmpty == true)
        ? user.displayName!
        : (user.email?.split('@').first ?? '');
    final initials = (user.displayName?.isNotEmpty == true)
        ? UserProfile._initialsFromName(user.displayName!)
        : (user.email != null ? UserProfile._initialsFromEmail(user.email!) : '?');

    return Ok(UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName,
      initials: initials,
      photoURL: user.photoURL,
      subscriptionStatus: sub,
      createdAt: createdAt,
    ));
  }
}
