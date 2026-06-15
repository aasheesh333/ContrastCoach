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

  Future<void> showOptimalTiming({required String timeOfDay}) async {
    await _plugin.show(
      2,
      'Optimal time for a session',
      'Your recovery data suggests $timeOfDay is ideal today.',
      const NotificationDetails(
        android: AndroidNotificationDetails('timing', 'Optimal Timing', importance: Importance.defaultImportance),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showSleepInsight({required String insight}) async {
    await _plugin.show(
      3,
      'Sleep insight',
      insight,
      const NotificationDetails(
        android: AndroidNotificationDetails('insight', 'Sleep Insights', importance: Importance.defaultImportance),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showSubscriptionRenewal({required String plan, required int daysRemaining}) async {
    await _plugin.show(
      4,
      'Subscription renewing soon',
      'Your $plan plan renews in $daysRemaining days.',
      const NotificationDetails(
        android: AndroidNotificationDetails('subscription', 'Subscription', importance: Importance.high),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showHealthConnectRevoked() async {
    await _plugin.show(
      5,
      'Health Connect disconnected',
      'Permissions were revoked. Reconnect in settings to keep tracking.',
      const NotificationDetails(
        android: AndroidNotificationDetails('health', 'Health Connect', importance: Importance.defaultImportance),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
