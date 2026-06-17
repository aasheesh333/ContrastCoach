import 'package:firebase_auth/firebase_auth.dart' as fb;

/// `FirebaseAuth.instance` proxy so tests can swap it out cleanly.
class FirebaseAuthNullableProxy {
  static fb.FirebaseAuth? tryGet() {
    try {
      return fb.FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  static fb.FirebaseAuth get auth {
    final a = tryGet();
    if (a == null) {
      throw StateError('Firebase not initialized');
    }
    return a;
  }
}
