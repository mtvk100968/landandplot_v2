import 'package:firebase_analytics/firebase_analytics.dart';

class LogApiUsage {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> log(String apiType) async {
    await _analytics.logEvent(
      name: 'api_usage',
      parameters: {
        'api': apiType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
