import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: androidSettings, iOS: iosSettings));
  }

  Future<void> showStreakReminder({required int streakDays}) async {
    await _plugin.show(
      1,
      'Keep your streak',
      'Day $streakDays. Do a quick session today.',
      const NotificationDetails(
        android: AndroidNotificationDetails('streak', 'Streak', importance: Importance.defaultImportance),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
