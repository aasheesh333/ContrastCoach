import 'package:contrast_coach/core/env/env_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase options built from `--dart-define` env vars (via [EnvConfig]).
///
/// On Android, the native `google-services.json` provides the API key to
/// the Firebase SDK at the platform level — the Dart-side `apiKey` here is
/// only used by the Firebase Dart plugin for REST calls. If it doesn't
/// match the Android key, you may see "API key not valid" errors.
///
/// **If you see "API key not valid":**
/// Make sure `FIREBASE_API_KEY` (set via `--dart-define` or CI secret) matches
/// the `api_key.current_key` value in `android/app/google-services.json`.
/// The easiest fix: don't pass `--dart-define=FIREBASE_API_KEY` at all and
/// let the native config handle it, or copy the key from your
/// `google-services.json`.
class FirebaseConfig {
  const FirebaseConfig._();

  static FirebaseOptions get currentPlatform {
    final apiKey = EnvConfig.firebaseApiKey;
    if (apiKey == null && kDebugMode) {
      debugPrint(
        '⚠️  FIREBASE_API_KEY not set. On Android, google-services.json '
        'provides the key natively, but the Dart plugin still needs it for '
        'REST calls. Set --dart-define=FIREBASE_API_KEY=<key from '
        'google-services.json>.',
      );
    }
    return FirebaseOptions(
      apiKey: apiKey ?? 'placeholder-api-key',
      appId: EnvConfig.firebaseAppId ??
          '1:0000000000:android:0000000000000000',
      messagingSenderId:
          EnvConfig.firebaseMessagingSenderId ?? '0000000000',
      projectId: EnvConfig.firebaseProjectId ?? 'contrast-coach-dev',
      storageBucket: EnvConfig.firebaseStorageBucket,
    );
  }
}
