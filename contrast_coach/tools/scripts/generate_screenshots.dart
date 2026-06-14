// generate_screenshots.dart
//
// TODO: Implement Play Store screenshot generation.
//
// Full screenshot generation is post-launch. This script is a stub that
// enumerates the screens we plan to capture and the resolutions required by
// the Play Store.
//
// Once we are ready to generate screenshots:
//
// 1. Add `integration_test` and `golden_toolkit` (or `screenshot`) to
//    `pubspec.yaml` under `dev_dependencies`.
// 2. Create an `integration_test/screens/` suite that drives the app to
//    each of the 8 main screens and captures a screenshot per language
//    (en, es, de, fr, ja, zh-CN, zh-TW, ko, pt-BR, ru).
// 3. Use `adb shell screencap` (or `flutter screenshot`) at the device
//    resolutions Google Play expects (phone: 1080x1920, 7" tablet: 1200x1920,
//    10" tablet: 1920x1200, feature graphic: 1024x500).
// 4. Commit the resulting PNGs under `fastlane/metadata/android/screenshots/`
//    (or whichever directory your `fastlane supply` config expects).
//
// Reference:
//   https://support.google.com/googleplay/android-developer/answer/9866151
//
// Until that work is done, this file is intentionally a no-op so the
// `tools/scripts/` directory is reserved and discoverable in git.

void main() async {
  // Intentionally empty — see TODO above.
  // Run with: dart run tools/scripts/generate_screenshots.dart
  print(
    'Screenshot generation is a post-launch task. '
    'See TODO comments in this file for the planned workflow.',
  );
}
