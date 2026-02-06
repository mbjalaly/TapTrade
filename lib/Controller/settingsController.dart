import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Services/NotificationService/notification_service.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/soundManager.dart';

/// Controller managing app-level settings and preferences
class SettingsController extends GetxController {
  // Observable settings
  Rx<bool> isDarkMode = false.obs;
  Rx<String> currentThemeMode = 'light'.obs; // 'system', 'light', or 'dark'
  Rx<bool> matchNotificationsEnabled = true.obs;
  Rx<bool> messageNotificationsEnabled = true.obs;
  Rx<bool> tradeUpdatesEnabled = true.obs;
  Rx<bool> marketingNotificationsEnabled = false.obs;
  Rx<bool> soundEffectsEnabled = false.obs; // Sounds disabled by default

  // Persistence keys
  static const String PREF_DARK_MODE = 'PREF_DARK_MODE';
  static const String PREF_MATCH_NOTIFICATIONS = 'PREF_MATCH_NOTIFICATIONS';
  static const String PREF_MESSAGE_NOTIFICATIONS = 'PREF_MESSAGE_NOTIFICATIONS';
  static const String PREF_TRADE_UPDATES = 'PREF_TRADE_UPDATES';
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
      // Load dark mode preference and apply theme
      final darkModeStr = await _prefs.getString(PREF_DARK_MODE);
      if (darkModeStr == 'dark') {
        isDarkMode.value = true;
        currentThemeMode.value = 'dark';
        Get.changeThemeMode(ThemeMode.dark);
      } else if (darkModeStr == 'light') {
        isDarkMode.value = false;
        currentThemeMode.value = 'light';
        Get.changeThemeMode(ThemeMode.light);
      } else {
        // Default to light mode
        isDarkMode.value = false;
        currentThemeMode.value = 'light';
        Get.changeThemeMode(ThemeMode.light);
      }

      // Load match notifications preference
      final matchNotifStr = await _prefs.getString(PREF_MATCH_NOTIFICATIONS);
      matchNotificationsEnabled.value = matchNotifStr != 'false'; // Default to true

      // Load message notifications preference
      final messageNotifStr = await _prefs.getString(PREF_MESSAGE_NOTIFICATIONS);
      messageNotificationsEnabled.value = messageNotifStr != 'false'; // Default to true

      // Load trade updates preference
      final tradeUpdatesStr = await _prefs.getString(PREF_TRADE_UPDATES);
      tradeUpdatesEnabled.value = tradeUpdatesStr != 'false'; // Default to true

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

  /// Show theme selector bottom sheet
  void showThemeSelector() {
    Get.bottomSheet(
      _ThemeSelectorSheet(
        currentMode: currentThemeMode.value,
        onThemeSelected: (mode) => _applyTheme(mode),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  /// Apply selected theme with a brief transition effect
  Future<void> _applyTheme(String mode) async {
    try {
      Get.back(); // Close bottom sheet
      
      ThemeMode newMode;
      
      switch (mode) {
        case 'light':
          newMode = ThemeMode.light;
          isDarkMode.value = false;
          break;
        case 'dark':
          newMode = ThemeMode.dark;
          isDarkMode.value = true;
          break;
        default:
          newMode = ThemeMode.system;
          isDarkMode.value = Get.isPlatformDarkMode;
      }
      
      currentThemeMode.value = mode;
      
      // Persist preference
      await _prefs.setString(PREF_DARK_MODE, mode);
      
      // Apply theme change with smooth transition
      Get.changeThemeMode(newMode);
      
      // Brief visual feedback
      await Future.delayed(Duration(milliseconds: 100));
      
      // Force rebuild to apply theme immediately
      Get.forceAppUpdate();
      
      print('🌓 Theme mode changed to: $mode');
      update();
    } catch (e) {
      print('Error applying theme: $e');
    }
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

  /// Toggle message notifications preference
  Future<void> toggleMessageNotifications() async {
    try {
      messageNotificationsEnabled.value = !messageNotificationsEnabled.value;
      await _prefs.setString(
        PREF_MESSAGE_NOTIFICATIONS,
        messageNotificationsEnabled.value.toString(),
      );

      Get.snackbar(
        'Message Notifications',
        messageNotificationsEnabled.value
            ? 'You will receive message notifications'
            : 'Message notifications silenced',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: messageNotificationsEnabled.value ? Colors.green : Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        icon: Icon(
          messageNotificationsEnabled.value ? Icons.chat_bubble : Icons.chat_bubble_outline,
          color: Colors.white,
        ),
      );

      print('💬 Message notifications: ${messageNotificationsEnabled.value}');
      update();
    } catch (e) {
      print('Error toggling message notifications: $e');
      messageNotificationsEnabled.value = !messageNotificationsEnabled.value;
    }
  }

  /// Toggle trade updates preference
  Future<void> toggleTradeUpdates() async {
    try {
      tradeUpdatesEnabled.value = !tradeUpdatesEnabled.value;
      await _prefs.setString(
        PREF_TRADE_UPDATES,
        tradeUpdatesEnabled.value.toString(),
      );

      Get.snackbar(
        'Trade Updates',
        tradeUpdatesEnabled.value
            ? 'You will receive trade update notifications'
            : 'Trade update notifications silenced',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: tradeUpdatesEnabled.value ? Colors.green : Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        icon: Icon(
          tradeUpdatesEnabled.value ? Icons.swap_horiz : Icons.swap_horiz,
          color: Colors.white,
        ),
      );

      print('🔄 Trade updates: ${tradeUpdatesEnabled.value}');
      update();
    } catch (e) {
      print('Error toggling trade updates: $e');
      tradeUpdatesEnabled.value = !tradeUpdatesEnabled.value;
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
      await _prefs.remove(PREF_MESSAGE_NOTIFICATIONS);
      await _prefs.remove(PREF_TRADE_UPDATES);
      await _prefs.remove(PREF_MARKETING_NOTIFICATIONS);
      await _prefs.remove(PREF_SOUND_EFFECTS);

      // Reset to defaults
      isDarkMode.value = false;
      matchNotificationsEnabled.value = true;
      messageNotificationsEnabled.value = true;
      tradeUpdatesEnabled.value = true;
      marketingNotificationsEnabled.value = false;
      soundEffectsEnabled.value = true;

      print('🧹 Settings cleared');
    } catch (e) {
      print('Error clearing settings: $e');
    }
  }
}

/// Beautiful theme selector bottom sheet
class _ThemeSelectorSheet extends StatelessWidget {
  final String currentMode;
  final Function(String) onThemeSelected;

  const _ThemeSelectorSheet({
    required this.currentMode,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.palette_outlined, color: Colors.black, size: 24),
                ),
                SizedBox(width: 16),
                Text(
                  'Choose Theme',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Select your preferred appearance',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Theme options
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _ThemeOption(
                  icon: Icons.brightness_auto_rounded,
                  title: 'System Default',
                  subtitle: 'Match device settings',
                  isSelected: currentMode == 'system',
                  onTap: () => onThemeSelected('system'),
                  gradientColors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  isDark: isDark,
                ),
                SizedBox(height: 12),
                _ThemeOption(
                  icon: Icons.light_mode_rounded,
                  title: 'Light Mode',
                  subtitle: 'Bright and clean look',
                  isSelected: currentMode == 'light',
                  onTap: () => onThemeSelected('light'),
                  gradientColors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                  isDark: isDark,
                ),
                SizedBox(height: 12),
                _ThemeOption(
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Mode',
                  subtitle: 'Easy on the eyes',
                  isSelected: currentMode == 'dark',
                  onTap: () => onThemeSelected('dark'),
                  gradientColors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                  isDark: isDark,
                ),
              ],
            ),
          ),
          
          SizedBox(height: 32),
          SafeArea(child: SizedBox(height: 8)),
        ],
      ),
    );
  }
}

/// Individual theme option tile
class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final List<Color> gradientColors;
  final bool isDark;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.gradientColors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? (isDark ? AppColors.primaryColor.withValues(alpha: 0.15) : AppColors.primaryColor.withValues(alpha: 0.1))
                : (isDark ? Color(0xFF2A2A2A) : Colors.grey[100]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Icon with gradient background
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              
              SizedBox(width: 16),
              
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Checkmark
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                    width: 2,
                  ),
                ),
                child: isSelected 
                    ? Icon(Icons.check, color: Colors.black, size: 18)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
