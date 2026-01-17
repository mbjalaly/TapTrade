import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Services/NotificationService/notification_service.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Utills/soundManager.dart';

/// Controller managing app-level settings and preferences
class SettingsController extends GetxController {
  // Observable settings
  Rx<bool> isDarkMode = false.obs;
  Rx<bool> matchNotificationsEnabled = true.obs;
  Rx<bool> marketingNotificationsEnabled = false.obs;
  Rx<bool> soundEffectsEnabled = false.obs; // Sounds disabled by default

  // Persistence keys
  static const String PREF_DARK_MODE = 'PREF_DARK_MODE';
  static const String PREF_MATCH_NOTIFICATIONS = 'PREF_MATCH_NOTIFICATIONS';
  static const String PREF_MARKETING_NOTIFICATIONS = 'PREF_MARKETING_NOTIFICATIONS';
  static const String PREF_SOUND_EFFECTS = 'PREF_SOUND_EFFECTS';

  final _prefs = SharedPreferencesService();

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  /// Load all settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      // Load dark mode preference
      final darkModeStr = await _prefs.getString(PREF_DARK_MODE);
      isDarkMode.value = darkModeStr == 'true';

      // Load match notifications preference
      final matchNotifStr = await _prefs.getString(PREF_MATCH_NOTIFICATIONS);
      matchNotificationsEnabled.value = matchNotifStr != 'false'; // Default to true

      // Load marketing notifications preference
      final marketingNotifStr = await _prefs.getString(PREF_MARKETING_NOTIFICATIONS);
      marketingNotificationsEnabled.value = marketingNotifStr == 'true';

      // Load sound effects preference
      final soundStr = await _prefs.getString(PREF_SOUND_EFFECTS);
      soundEffectsEnabled.value = soundStr == 'true'; // Default to false (disabled)

      // Sync sound state with SoundManager
      SoundManager().setMuted(!soundEffectsEnabled.value);

      print('✅ Settings loaded successfully');
    } catch (e) {
      print('⚠️ Error loading settings: $e');
      // Continue with defaults
    }
  }

  /// Toggle dark mode - shows "coming soon" dialog
  Future<void> toggleDarkMode() async {
    await Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.dark_mode, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Dark Mode Coming Soon'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dark mode is in development. We\'re working to bring you a beautiful dark theme soon!',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Want to be notified when it\'s ready?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Notify Me'),
            onPressed: () async {
              try {
                await NotificationService.subscribeToMarketing();
                Get.back();

                Get.snackbar(
                  'Subscribed',
                  'We\'ll notify you when dark mode is available!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: Duration(seconds: 3),
                  icon: Icon(Icons.check_circle, color: Colors.white),
                );

                // Store subscription preference
                marketingNotificationsEnabled.value = true;
                await _prefs.setString(PREF_MARKETING_NOTIFICATIONS, 'true');
              } catch (e) {
                print('Error subscribing to marketing: $e');
                Get.back();
              }
            },
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  /// Toggle match notifications preference
  Future<void> toggleMatchNotifications() async {
    try {
      matchNotificationsEnabled.value = !matchNotificationsEnabled.value;
      await _prefs.setString(
        PREF_MATCH_NOTIFICATIONS,
        matchNotificationsEnabled.value.toString(),
      );

      Get.snackbar(
        'Match Notifications',
        matchNotificationsEnabled.value
            ? 'You will receive match notifications'
            : 'Match notifications silenced',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: matchNotificationsEnabled.value ? Colors.green : Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        icon: Icon(
          matchNotificationsEnabled.value ? Icons.notifications_active : Icons.notifications_off,
          color: Colors.white,
        ),
      );

      print('🔔 Match notifications: ${matchNotificationsEnabled.value}');
      update();
    } catch (e) {
      print('Error toggling match notifications: $e');
      // Revert on error
      matchNotificationsEnabled.value = !matchNotificationsEnabled.value;
    }
  }

  /// Toggle marketing notifications via FCM topic subscription
  Future<void> toggleMarketingNotifications() async {
    try {
      marketingNotificationsEnabled.value = !marketingNotificationsEnabled.value;

      if (marketingNotificationsEnabled.value) {
        await NotificationService.subscribeToMarketing();
        print('📧 Subscribed to marketing notifications');
      } else {
        await NotificationService.unsubscribeFromMarketing();
        print('📧 Unsubscribed from marketing notifications');
      }

      await _prefs.setString(
        PREF_MARKETING_NOTIFICATIONS,
        marketingNotificationsEnabled.value.toString(),
      );

      Get.snackbar(
        'Marketing Notifications',
        marketingNotificationsEnabled.value
            ? 'You will receive updates and offers'
            : 'You won\'t receive marketing emails',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: marketingNotificationsEnabled.value ? Colors.green : Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        icon: Icon(
          marketingNotificationsEnabled.value ? Icons.email : Icons.email_outlined,
          color: Colors.white,
        ),
      );

      update();
    } catch (e) {
      print('Error toggling marketing notifications: $e');
      // Revert on error
      marketingNotificationsEnabled.value = !marketingNotificationsEnabled.value;

      Get.snackbar(
        'Error',
        'Failed to update notification preferences',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  }

  /// Toggle sound effects
  Future<void> toggleSoundEffects() async {
    try {
      soundEffectsEnabled.value = !soundEffectsEnabled.value;

      // Update SoundManager
      SoundManager().setMuted(!soundEffectsEnabled.value);

      await _prefs.setString(
        PREF_SOUND_EFFECTS,
        soundEffectsEnabled.value.toString(),
      );

      Get.snackbar(
        'Sound Effects',
        soundEffectsEnabled.value ? 'Sound effects enabled' : 'Sound effects muted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: soundEffectsEnabled.value ? Colors.green : Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        icon: Icon(
          soundEffectsEnabled.value ? Icons.volume_up : Icons.volume_off,
          color: Colors.white,
        ),
      );

      print('🔊 Sound effects: ${soundEffectsEnabled.value}');
      update();
    } catch (e) {
      print('Error toggling sound effects: $e');
      // Revert on error
      soundEffectsEnabled.value = !soundEffectsEnabled.value;
      SoundManager().setMuted(!soundEffectsEnabled.value);
    }
  }

  /// Clear all settings (for logout)
  Future<void> clearSettings() async {
    try {
      await _prefs.remove(PREF_DARK_MODE);
      await _prefs.remove(PREF_MATCH_NOTIFICATIONS);
      await _prefs.remove(PREF_MARKETING_NOTIFICATIONS);
      await _prefs.remove(PREF_SOUND_EFFECTS);

      // Reset to defaults
      isDarkMode.value = false;
      matchNotificationsEnabled.value = true;
      marketingNotificationsEnabled.value = false;
      soundEffectsEnabled.value = true;

      print('🧹 Settings cleared');
    } catch (e) {
      print('Error clearing settings: $e');
    }
  }
}
