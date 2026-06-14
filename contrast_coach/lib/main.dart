import 'package:contrast_coach/data/remote/crash/sentry_client.dart';

Future<void> main() async {
  await SentryBootstrap.runWithSentry();
}
