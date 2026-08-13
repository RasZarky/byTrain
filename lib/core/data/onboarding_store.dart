import 'package:shared_preferences/shared_preferences.dart';

/// Remembers whether the user has finished onboarding so the intro only shows
/// on the first launch of the app.
class OnboardingStore {
  static const String _key = 'onboarding_completed';

  Future<bool> hasCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
