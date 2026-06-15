import 'package:contrast_coach/core/env/env_config.dart';
import 'package:firebase_core/firebase_core.dart';

/// Placeholder Firebase options for v0.x. Real values are injected via
/// `--dart-define` (or `.env`) at build time. The fallback strings let the
/// Dart code compile and the app boot to onboarding without a real
/// Firebase project — only sign-in / Firestore calls will fail.
///
/// To enable Firebase end-to-end, run `flutterfire configure` (or copy a
/// real `google-services.json` to `android/app/`) and provide the matching
/// env values.
class FirebaseConfig {
  const FirebaseConfig._();

  /// Returns the runtime Firebase options for the current platform.
  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
      apiKey: EnvConfig.firebaseApiKey ?? 'placeholder-api-key',
      appId: EnvConfig.firebaseAppId ??
          '1:0000000000:android:0000000000000000',
      messagingSenderId:
          EnvConfig.firebaseMessagingSenderId ?? '0000000000',
      projectId: EnvConfig.firebaseProjectId ?? 'contrast-coach-dev',
      storageBucket: EnvConfig.firebaseStorageBucket,
    );
  }
}
