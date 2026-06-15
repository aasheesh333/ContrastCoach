import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsApi {
  AnalyticsApi(this._analytics);
  final FirebaseAnalytics _analytics;

  Future<void> track(String eventName, {Map<String, Object>? params}) async {
    try {
      await _analytics.logEvent(name: eventName, parameters: params);
    } catch (_) {
      // Never crash on analytics
    }
  }

  Future<void> trackSessionStarted(String protocolId) =>
      track('session_started', params: <String, Object>{'protocol_id': protocolId});

  Future<void> trackSessionCompleted(String protocolId, double score) =>
      track(
        'session_completed',
        params: <String, Object>{
          'protocol_id': protocolId,
          'score': score.round(),
        },
      );

  Future<void> trackPaywallViewed() => track('paywall_viewed');

  Future<void> trackSubscriptionStarted(String plan) =>
      track('subscription_started', params: <String, Object>{'plan': plan});

  Future<void> trackFeatureUsed(String feature) =>
      track('feature_used', params: <String, Object>{'feature': feature});
}
