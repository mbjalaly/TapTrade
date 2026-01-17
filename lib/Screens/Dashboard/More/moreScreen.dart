import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/settingsController.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Screens/Dashboard/ProfileSetting/AddBio/addBio.dart';
import 'package:taptrade/Screens/Dashboard/ProfileSetting/ContactUs/contactUs.dart';
import 'package:taptrade/Screens/Dashboard/ProfileSetting/TradePreferences/tradePreferences.dart';
import 'package:taptrade/Screens/Dashboard/ProfileSetting/profileSetting.dart';
import 'package:taptrade/Services/NotificationService/notification_service.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/NetworkImageProvider/networkImageProvider.dart';
import 'package:taptrade/Widgets/settingsItems.dart';

/// More tab screen containing app settings and user profile management
class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  late SettingsController _settingsController;

  @override
  void initState() {
    super.initState();
    // Safely get or create the controller
    try {
      _settingsController = Get.find<SettingsController>();
    } catch (e) {
      _settingsController = Get.put(SettingsController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          'More',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.darkBlue,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              _settingsController.isDarkMode.value
                  ? Icons.dark_mode
                  : Icons.light_mode_outlined,
              color: AppColors.primaryColor,
            ),
            onPressed: () => _settingsController.toggleDarkMode(),
            tooltip: 'Dark mode (coming soon)',
          )),
        ],
      ),
      body: SafeArea(
        child: GetBuilder<UserController>(
          builder: (userController) {
            final profileData = userController.userProfile.value;
            final userData = profileData.data;

            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mini Profile Header
                  _buildMiniProfileHeader(size, userData),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Account Settings Section
                        SettingsSectionHeader(title: 'Account'),
                        SettingsItem(
                          icon: Icons.person_outline,
                          label: 'Profile information',
                          onTap: () => Get.to(() => AddBioScreen(profileData: profileData)),
                        ),
                        const Divider(),
                        SettingsItem(
                          icon: Icons.tune,
                          label: 'Trade preferences',
                          onTap: () => Get.to(() => TradePreferences(profileData: profileData)),
                        ),

                        // Notifications Section
                        SettingsSectionHeader(title: 'Notifications'),
                        Obx(() => SwitchSettingsItem(
                          icon: Icons.notifications_outlined,
                          label: 'Match notifications',
                          value: _settingsController.matchNotificationsEnabled.value,
                          onChanged: (_) => _settingsController.toggleMatchNotifications(),
                        )),

                        // Help & Support Section
                        SettingsSectionHeader(title: 'Help & Support'),
                        SettingsItem(
                          icon: Icons.help_outline,
                          label: 'FAQ questions',
                          onTap: () => NotificationService.info(
                            title: 'Coming soon',
                            message: 'FAQ page is coming soon',
                          ),
                        ),
                        const Divider(),
                        SettingsItem(
                          icon: Icons.description_outlined,
                          label: 'Terms and policies',
                          onTap: () => _openTermsBottomSheet(context),
                        ),
                        const Divider(),
                        SettingsItem(
                          icon: Icons.mail_outline,
                          label: 'Contact us',
                          onTap: () => Get.to(() => const ContactUs()),
                        ),

                        // Account Actions Section
                        SettingsSectionHeader(title: 'Account'),
                        SettingsItem(
                          icon: Icons.logout,
                          label: 'Log out',
                          isDestructive: true,
                          onTap: () => ShowMessage.showLogoutDialog(context),
                        ),

                        SizedBox(height: 20),

                        // App Version Footer
                        Center(
                          child: Text(
                            'TapTrade v1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.greyTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Mini profile header with avatar and name
  Widget _buildMiniProfileHeader(Size size, dynamic userData) {
    final name = userData?.fullName ?? userData?.username ?? 'User';
    final image = userData?.image ?? '';

    return Container(
      width: size.width,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFecfcff),
            Color(0xFFfff5db),
          ],
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryColor,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: image.isNotEmpty
                  ? NetworkImageProvider(
                      url: "${KeyConstants.imageUrl}$image",
                      fit: BoxFit.cover,
                    )
                  : CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.surfaceVariant,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.greyTextColor,
                      ),
                    ),
            ),
          ),

          SizedBox(width: 16),

          // Name and username
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                if (userData?.username != null)
                  Text(
                    '@${userData!.username}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.greyTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Show terms and policies bottom sheet
  void _openTermsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyTextColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Terms & Policies',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTextColor,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.description, color: AppColors.primaryColor),
                title: Text(
                  'Terms of Service',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Coming soon'),
                onTap: () {
                  Get.back();
                  NotificationService.info(
                    title: 'Coming soon',
                    message: 'Terms of Service page is coming soon',
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.privacy_tip, color: AppColors.primaryColor),
                title: Text(
                  'Privacy Policy',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Coming soon'),
                onTap: () {
                  Get.back();
                  NotificationService.info(
                    title: 'Coming soon',
                    message: 'Privacy Policy page is coming soon',
                  );
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
