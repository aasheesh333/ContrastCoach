import 'package:firebase_auth/firebase_auth.dart' as fb;

/// `FirebaseAuth.instance` proxy so tests can swap it out cleanly.
class FirebaseAuthNullableProxy {
  static fb.FirebaseAuth auth = fb.FirebaseAuth.instance;
}
