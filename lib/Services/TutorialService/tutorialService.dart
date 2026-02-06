import '../SharedPreferenceService/sharePreferenceService.dart';

class TutorialService {
  // Keys for SharedPreferences
  static const String _tutorialCompletedKey = "tutorial_completed";
  static const String _tutorialVersionKey = "tutorial_version";
  static const String _currentVersion = "1.0";

  /// Check if user has completed the tutorial
  static Future<bool> hasSeen() async {
    final completed = await SharedPreferencesService()
        .getString(_tutorialCompletedKey);
    final version = await SharedPreferencesService()
        .getString(_tutorialVersionKey);

    // If tutorial version changed, show again
    if (version != _currentVersion) {
      return false;
    }

    return completed == "true";
  }

  /// Mark tutorial as completed
  static Future<void> markAsSeen() async {
    await SharedPreferencesService()
        .setString(_tutorialCompletedKey, "true");
    await SharedPreferencesService()
        .setString(_tutorialVersionKey, _currentVersion);
  }

  /// Reset tutorial (for debugging or replay)
  static Future<void> reset() async {
    await SharedPreferencesService().remove(_tutorialCompletedKey);
    await SharedPreferencesService().remove(_tutorialVersionKey);
  }
}
