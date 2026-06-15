import 'package:contrast_coach/app.dart';
import 'package:contrast_coach/core/env/env_config.dart';
import 'package:contrast_coach/data/notifications/notification_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.init();
  await NotificationService().init();
  runApp(const ContrastCoachApp());
}
