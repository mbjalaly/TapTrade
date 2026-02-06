import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Controller/settingsController.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:taptrade/Utills/appColors.dart';

/// Notification Settings screen where users can control their notification preferences
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.notificationSettingsTitle ?? 'Notification Settings',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkPrimaryTextColor : AppColors.darkBlue,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkPrimaryTextColor : AppColors.darkBlue,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : AppColors.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active_outlined,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)?.chooseNotifications ?? 'Choose which notifications you want to receive',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark 
                            ? Colors.white70 
                            : AppColors.primaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Push Notifications Section
            _buildSectionHeader(context, AppLocalizations.of(context)?.pushNotifications ?? 'Push Notifications', isDark),
            const SizedBox(height: 12),

            Obx(() => _NotificationToggleTile(
              icon: Icons.favorite_border_rounded,
              iconColor: const Color(0xFFE91E63),
              title: AppLocalizations.of(context)?.matchNotifications ?? 'Match Notifications',
              value: settingsController.matchNotificationsEnabled.value,
              onChanged: (_) => settingsController.toggleMatchNotifications(),
              isDark: isDark,
            )),

            const Divider(height: 1),

            Obx(() => _NotificationToggleTile(
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: const Color(0xFF2196F3),
              title: AppLocalizations.of(context)?.messageNotifications ?? 'Message Notifications',
              value: settingsController.messageNotificationsEnabled.value,
              onChanged: (_) => settingsController.toggleMessageNotifications(),
              isDark: isDark,
            )),

            const Divider(height: 1),

            Obx(() => _NotificationToggleTile(
              icon: Icons.swap_horiz_rounded,
              iconColor: const Color(0xFF4CAF50),
              title: AppLocalizations.of(context)?.tradeUpdates ?? 'Trade Updates',
              value: settingsController.tradeUpdatesEnabled.value,
              onChanged: (_) => settingsController.toggleTradeUpdates(),
              isDark: isDark,
            )),

            const SizedBox(height: 24),

            // Marketing Section
            _buildSectionHeader(context, AppLocalizations.of(context)?.marketingPromotions ?? 'Marketing & Promotions', isDark),
            const SizedBox(height: 12),

            Obx(() => _NotificationToggleTile(
              icon: Icons.local_offer_outlined,
              iconColor: const Color(0xFFFF9800),
              title: AppLocalizations.of(context)?.promotionalOffers ?? 'Promotional Offers',
              value: settingsController.marketingNotificationsEnabled.value,
              onChanged: (_) => settingsController.toggleMarketingNotifications(),
              isDark: isDark,
            )),

            const SizedBox(height: 24),

            // Sound Section
            _buildSectionHeader(context, AppLocalizations.of(context)?.soundHaptics ?? 'Sound & Haptics', isDark),
            const SizedBox(height: 12),

            Obx(() => _NotificationToggleTile(
              icon: Icons.volume_up_rounded,
              iconColor: const Color(0xFF9C27B0),
              title: AppLocalizations.of(context)?.soundEffects ?? 'Sound Effects',
              value: settingsController.soundEffectsEnabled.value,
              onChanged: (_) => settingsController.toggleSoundEffects(),
              isDark: isDark,
            )),

            const SizedBox(height: 32),

            // Info footer
            Center(
              child: Text(
                AppLocalizations.of(context)?.canChangeAnytime ?? 'You can change these settings at any time',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.greyText(context),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white60 : AppColors.primaryTextColor,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Individual notification toggle tile
class _NotificationToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _NotificationToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          // Text content
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.primaryTextColor,
              ),
            ),
          ),

          // Switch
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
            activeTrackColor: AppColors.primaryColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
