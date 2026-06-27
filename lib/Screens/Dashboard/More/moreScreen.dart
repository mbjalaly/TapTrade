import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
import 'package:taptrade/Screens/Tutorial/introTutorialScreen.dart';
import 'package:taptrade/Services/ImageFileService/imageFileService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Services/NotificationService/notification_service.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/NetworkImageProvider/networkImageProvider.dart';
import 'package:taptrade/Widgets/avatarSlider.dart';
import 'package:taptrade/Widgets/settingsItems.dart';

/// More tab screen containing app settings and user profile management
class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  late SettingsController _settingsController;
  File? _image;
  String _avatarImage = '';

  @override
  void initState() {
    super.initState();
    try {
      _settingsController = Get.find<SettingsController>();
    } catch (e) {
      _settingsController = Get.put(SettingsController());
    }
  }

  Future<void> _pickImage() async {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.contentBg(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(
                    AppLocalizations.of(context)?.avatar ?? 'Avatar'),
                onTap: () {
                  Get.back();
                  _openAvatarSlider();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(
                    AppLocalizations.of(context)?.camera ?? 'Camera'),
                onTap: () async {
                  Get.back();
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                      source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                      _avatarImage = '';
                    });
                    await updateProfileImage(_image!);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_album),
                title: Text(
                    AppLocalizations.of(context)?.gallery ?? 'Gallery'),
                onTap: () async {
                  Get.back();
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                      _avatarImage = '';
                    });
                    await updateProfileImage(_image!);
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  void _openAvatarSlider() async {
    final selectedAvatar = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20),
          child: AvatarSlider(),
        );
      },
    );
    if (selectedAvatar != null) {
      setState(() {
        _avatarImage = selectedAvatar;
        _image = null;
      });
      final imgFile = await loadAssetAsFile(_avatarImage);
      await updateProfileImage(imgFile);
    }
  }

  Future<void> updateProfileImage(File imageFile) async {
    final uc = Get.find<UserController>();
    final id = uc.userProfile.value.data?.id ?? '';
    if (id.isEmpty) return;
    await ProfileService.instance
        .updateProfile(context, {'image': imageFile}, id);
    await ProfileService.instance.getProfile(context);
    if (mounted) setState(() {});
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
        actions: const [],
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
                  _buildMiniProfileHeader(size, userData),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SettingsItem(
                          icon: Icons.person_outline,
                          label: AppLocalizations.of(context)
                              ?.profileInformation ??
                              'Profile information',
                          onTap: () => Get.to(() =>
                              AddBioScreen(profileData: profileData)),
                        ),
                        Opacity(
                            opacity: 0.375,
                            child: const Divider()),
                        SettingsItem(
                          icon: Icons.filter_list,
                          label: AppLocalizations.of(context)
                              ?.tradePreferences ??
                              'Trade preferences',
                          onTap: () => Get.to(() => TradePreferences(
                              profileData: profileData)),
                        ),
                        Opacity(
                            opacity: 0.375,
                            child: const Divider()),
                        SettingsItem(
                          icon: Icons.notifications_outlined,
                          label: AppLocalizations.of(context)
                              ?.notificationSettings ??
                              'Notification settings',
                          onTap: () => Get.to(
                                  () => const NotificationSettingsScreen()),
                        ),
                        Opacity(
                            opacity: 0.375,
                            child: const Divider()),
                        SettingsItem(
                          icon: Icons.play_circle_outline_rounded,
                          label: AppLocalizations.of(context)
                              ?.viewTutorial ??
                              'View tutorial',
                          onTap: () => Get.to(
                                  () => const IntroTutorialScreen()),
                        ),
                        Opacity(
                            opacity: 0.375,
                            child: const Divider()),
                        SettingsItem(
                          icon: Icons.help_outline,
                          label: AppLocalizations.of(context)
                              ?.faqQuestions ??
                              'FAQ questions',
                          onTap: () => NotificationService.info(
                            title: AppLocalizations.of(context)
                                ?.comingSoon ??
                                'Coming soon',
                            message: AppLocalizations.of(context)
                                ?.faqComingSoon ??
                                'FAQ page is coming soon',
                          ),
                        ),
                        Opacity(
                            opacity: 0.375,
                            child: const Divider()),
                        SettingsItem(
                          icon: Icons.description_outlined,
                          label: AppLocalizations.of(context)
                              ?.termsAndPolicies ??
                              'Terms and policies',
                          onTap: () =>
                              _openTermsBottomSheet(context),
                        ),
                        Opacity(
                            opacity: 0.375,
                            child: const Divider()),
                        SettingsItem(
                          icon: Icons.mail_outline,
                          label: AppLocalizations.of(context)
                              ?.contactUs ??
                              'Contact us',
                          onTap: () =>
                              Get.to(() => const ContactUs()),
                        ),
                        Opacity(
                            opacity: 0.375,
                            child: const Divider()),
                        SettingsItem(
                          icon: Icons.language,
                          label: AppLocalizations.of(context)
                              ?.language ??
                              'Language',
                          onTap: () => Get.to(
                                  () => const LanguageSettingsScreen()),
                        ),
                        Opacity(
                            opacity: 0.375,
                            child: const Divider()),
                        SettingsItem(
                          icon: Icons.logout,
                          label: AppLocalizations.of(context)
                              ?.logOut ??
                              'Log out',
                          isDestructive: true,
                          onTap: () =>
                              ShowMessage.showLogoutDialog(context),
                        ),
                        const SizedBox(height: 20),
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

  /// Renders the avatar image — handles locally-picked files,
  /// asset avatars, base64 data-URIs, and network URLs.
  Widget _buildAvatarImage(String imageFromServer) {
    if (_image != null) {
      return Image.file(_image!, fit: BoxFit.cover);
    }
    if (_avatarImage.isNotEmpty) {
      return Image.asset(_avatarImage, fit: BoxFit.cover);
    }
    if (imageFromServer.isNotEmpty) {
      // Backend stores images as data URIs — decode and render directly
      if (imageFromServer.startsWith('data:')) {
        try {
          final comma = imageFromServer.indexOf(',');
          final bytes =
          base64Decode(imageFromServer.substring(comma + 1));
          return Image.memory(bytes, fit: BoxFit.cover);
        } catch (_) {}
      }
      // Fall through to network image for regular URLs
      return NetworkImageProvider(
        url: imageFromServer,
        fit: BoxFit.cover,
      );
    }
    return Icon(
      Icons.person,
      size: 40,
      color: AppColors.greyText(context),
    );
  }

  /// Helper to get proper image URL (kept for NetworkImageProvider calls)
  String _getImageUrl(String image) {
    if (image.startsWith('http') || image.startsWith('data:')) {
      return image;
    }
    return '${KeyConstants.imageUrl}$image';
  }

  /// Mini profile header with tappable avatar and name
  Widget _buildMiniProfileHeader(Size size, dynamic userData) {
    final name =
        userData?.fullName ?? userData?.username ?? 'User';
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
              ? [const Color(0xFF1A2A2E), const Color(0xFF2A2518)]
              : [const Color(0xFFecfcff), const Color(0xFFfff5db)],
        ),
      ),
      child: Row(
        children: [
          // Tappable avatar with edit badge
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _pickImage,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // solid background so hit-testing always works
                    color: AppColors.primaryColor,
                    border: Border.all(
                      color: AppColors.primaryColor,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: _buildAvatarImage(image),
                  ),
                ),
                // Edit badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      border:
                      Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.edit,
                        color: Colors.white, size: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

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
                const SizedBox(height: 4),
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
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
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
                  color: AppColors.greyText(context)
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n?.termsAndPolicies ?? 'Terms & Policies',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText(context),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.description,
                    color: AppColors.primaryColor),
                title: Text(
                  l10n?.termsOfService ?? 'Terms of Service',
                  style:
                  const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                    l10n?.termsComingSoon ?? 'Coming soon'),
                onTap: () {
                  Get.back();
                  NotificationService.info(
                    title:
                    l10n?.comingSoon ?? 'Coming soon',
                    message: l10n?.termsComingSoon ??
                        'Terms of Service page is coming soon',
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.privacy_tip,
                    color: AppColors.primaryColor),
                title: Text(
                  l10n?.privacyPolicy ?? 'Privacy Policy',
                  style:
                  const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                    l10n?.privacyComingSoon ?? 'Coming soon'),
                onTap: () {
                  Get.back();
                  NotificationService.info(
                    title:
                    l10n?.comingSoon ?? 'Coming soon',
                    message: l10n?.privacyComingSoon ??
                        'Privacy Policy page is coming soon',
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}