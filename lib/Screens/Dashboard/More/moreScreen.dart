import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/languageController.dart';
import 'package:taptrade/Controller/settingsController.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:taptrade/Screens/Dashboard/ProfileSetting/AddBio/addBio.dart';
import 'package:taptrade/Screens/Dashboard/ProfileSetting/ContactUs/contactUs.dart';
import 'package:taptrade/Screens/Dashboard/ProfileSetting/LanguageSettings/languageSettings.dart';
import 'package:taptrade/Screens/Dashboard/ProfileSetting/NotificationSettings/notificationSettings.dart';
import 'package:taptrade/Screens/Dashboard/ProfileSetting/TradePreferences/tradePreferences.dart';
import 'package:taptrade/Screens/Dashboard/ProfileSetting/profileSetting.dart';
import 'package:taptrade/Screens/Tutorial/introTutorialScreen.dart';
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          AppLocalizations.of(context)?.profile ?? 'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.darkPrimaryTextColor 
                : AppColors.darkBlue,
          ),
        ),
        elevation: 0,
        actions: [],
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
                        SettingsItem(
                          icon: Icons.person_outline,
                          label: AppLocalizations.of(context)?.profileInformation ?? 'Profile information',
                          onTap: () => Get.to(() => AddBioScreen(profileData: profileData)),
                        ),
                        Opacity(opacity: 0.375, child: const Divider()),
                        SettingsItem(
                          icon: Icons.filter_list,
                          label: AppLocalizations.of(context)?.tradePreferences ?? 'Trade preferences',
                          onTap: () => Get.to(() => TradePreferences(profileData: profileData)),
                        ),
                        Opacity(opacity: 0.375, child: const Divider()),
                        SettingsItem(
                          icon: Icons.notifications_outlined,
                          label: AppLocalizations.of(context)?.notificationSettings ?? 'Notification settings',
                          onTap: () => Get.to(() => const NotificationSettingsScreen()),
                        ),
                        Opacity(opacity: 0.375, child: const Divider()),
                        SettingsItem(
                          icon: Icons.play_circle_outline_rounded,
                          label: AppLocalizations.of(context)?.viewTutorial ?? 'View tutorial',
                          onTap: () => Get.to(() => const IntroTutorialScreen()),
                        ),
                        Opacity(opacity: 0.375, child: const Divider()),
                        SettingsItem(
                          icon: Icons.help_outline,
                          label: AppLocalizations.of(context)?.faqQuestions ?? 'FAQ questions',
                          onTap: () => NotificationService.info(
                            title: AppLocalizations.of(context)?.comingSoon ?? 'Coming soon',
                            message: AppLocalizations.of(context)?.faqComingSoon ?? 'FAQ page is coming soon',
                          ),
                        ),
                        Opacity(opacity: 0.375, child: const Divider()),
                        SettingsItem(
                          icon: Icons.description_outlined,
                          label: AppLocalizations.of(context)?.termsAndPolicies ?? 'Terms and policies',
                          onTap: () => _openTermsBottomSheet(context),
                        ),
                        Opacity(opacity: 0.375, child: const Divider()),
                        SettingsItem(
                          icon: Icons.mail_outline,
                          label: AppLocalizations.of(context)?.contactUs ?? 'Contact us',
                          onTap: () => Get.to(() => const ContactUs()),
                        ),
                        Opacity(opacity: 0.375, child: const Divider()),
                        SettingsItem(
                          icon: Icons.language,
                          label: AppLocalizations.of(context)?.language ?? 'Language',
                          onTap: () => Get.to(() => const LanguageSettingsScreen()),
                        ),
                        Opacity(opacity: 0.375, child: const Divider()),
                        SettingsItem(
                          icon: Icons.logout,
                          label: AppLocalizations.of(context)?.logOut ?? 'Log out',
                          isDestructive: true,
                          onTap: () => ShowMessage.showLogoutDialog(context),
                        ),

                        SizedBox(height: 20),

                        // App Version Footer
                        Center(
                          child: Text(
                            'TapTrade v2.0.3',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.greyText(context),
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

  /// Helper to get proper image URL
  String _getImageUrl(String image) {
    if (image.startsWith('http') || image.startsWith('data:')) {
      return image;
    }
    return '${KeyConstants.imageUrl}$image';
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
          colors: AppColors.isDark(context)
              ? [Color(0xFF1A2A2E), Color(0xFF2A2518)]
              : [Color(0xFFecfcff), Color(0xFFfff5db)],
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
                      url: _getImageUrl(image),
                      fit: BoxFit.cover,
                    )
                  : CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.surfaceVariantColor(context),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.greyText(context),
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
                    color: AppColors.primaryText(context),
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
                      color: AppColors.greyText(context),
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
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.contentBg(context),
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
                  color: AppColors.greyText(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                l10n?.termsAndPolicies ?? 'Terms & Policies',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText(context),
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.description, color: AppColors.primaryColor),
                title: Text(
                  l10n?.termsOfService ?? 'Terms of Service',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(l10n?.termsComingSoon ?? 'Coming soon'),
                onTap: () {
                  Get.back();
                  NotificationService.info(
                    title: l10n?.comingSoon ?? 'Coming soon',
                    message: l10n?.termsComingSoon ?? 'Terms of Service page is coming soon',
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.privacy_tip, color: AppColors.primaryColor),
                title: Text(
                  l10n?.privacyPolicy ?? 'Privacy Policy',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(l10n?.privacyComingSoon ?? 'Coming soon'),
                onTap: () {
                  Get.back();
                  NotificationService.info(
                    title: l10n?.comingSoon ?? 'Coming soon',
                    message: l10n?.privacyComingSoon ?? 'Privacy Policy page is coming soon',
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
