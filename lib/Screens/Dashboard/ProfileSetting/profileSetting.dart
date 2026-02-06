import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taptrade/Const/apiEndPoint.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/languageController.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Models/UserProfile/userProfile.dart';
import 'package:taptrade/Screens/Dashboard/Payment/paymentScreen.dart';
import 'package:taptrade/Services/ImageFileService/imageFileService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/NetworkImageProvider/networkImageProvider.dart';
import 'package:taptrade/Widgets/avatarSlider.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Services/NotificationService/notification_service.dart';
import 'AddBio/addBio.dart';
import 'ContactUs/contactUs.dart';
import 'LanguageSettings/languageSettings.dart';
import 'TradePreferences/tradePreferences.dart';
import 'package:taptrade/Screens/Dashboard/Chat/matchesListScreen.dart';

class ProfileSetting extends StatefulWidget {
  const ProfileSetting({super.key});

  @override
  State<ProfileSetting> createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {
  var userController = Get.find<UserController>();
  File? _image; // To store the selected image
  String avatarImage = '';
  bool isLoading = false;
  String? selectedOption;

  Future<void> _pickImage() async {
    showModalBottomSheet(
      backgroundColor: AppColors.contentBg(context),
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.person),
                title: Text(AppLocalizations.of(context)?.avatar ?? 'Avatar'),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet first
                  _openAvatarSlider(); // Open the avatar slider as a dialog
                },
              ),
              ListTile(
                leading: Icon(Icons.camera),
                title: Text(AppLocalizations.of(context)?.camera ?? 'Camera'),
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.camera);

                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                      avatarImage = '';
                    });
                  }
                  Navigator.pop(context);
                  updateProfileImage(_image!);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_album),
                title: Text(AppLocalizations.of(context)?.gallery ?? 'Gallery'),
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                      avatarImage = '';
                    });
                  }
                  Navigator.pop(context);
                  updateProfileImage(_image!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openAvatarSlider() async {
    final selectedAvatar = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20),
          child: AvatarSlider(),
        );
      },
    );

    if (selectedAvatar != null) {
      setState(() {
        avatarImage = selectedAvatar;
      });
      _image = await loadAssetAsFile(avatarImage);
      updateProfileImage(_image!);
    }
  }

  avatarSelection(BuildContext context, UserProfileResponseModel profileData) {
    if (_image != null) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(1000.0),
          clipBehavior: Clip.antiAlias,
          child: Image.file(
            _image!,
            fit: BoxFit.fill,
          ));
    } else if (avatarImage.isNotEmpty) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(1000.0),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            avatarImage,
            fit: BoxFit.fill,
          ));
    } else if (profileData.data?.image != null &&
        profileData.data!.image!.isNotEmpty) {
      String image = profileData.data?.image ?? '';
      return NetworkImageProvider(
        url: "${KeyConstants.imageUrl}$image",
        borderRadius: BorderRadius.circular(1000.0),
        fit: BoxFit.fill,
      );
      // ClipRRect(
      //   borderRadius: BorderRadius.circular(1000.0),
      //   clipBehavior: Clip.antiAlias, child: Image.network("${KeyConstants.imageUrl}$image",fit: BoxFit.fill,));
    } else {
      return Padding(
        padding: const EdgeInsets.all(60.0),
        child: SvgPicture.asset("assets/svgs/Camera.svg"),
      );
    }
  }

  Future<void> updateProfileImage(File imageFile) async {
    if (imageFile != null) {
      Map<String, dynamic> body = {
        'image': imageFile,
      };
      String id = userController.userProfile.value.data?.id ?? '';
      setState(() {
        isLoading = true;
      });
      final result =
          await ProfileService.instance.updateProfile(context, body, id);
      await ProfileService.instance.getProfile(context);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GetBuilder(
        init: UserController(),
        builder: (userController) {
          var profileData = userController.userProfile.value;
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: false,
              title: Text(AppLocalizations.of(context)?.settings ?? 'Settings', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkBlue)),
              actions: [
                Obx(() {
                  final langController = Get.find<LanguageController>();
                  return TextButton.icon(
                    onPressed: () => Get.to(() => const LanguageSettingsScreen()),
                    icon: Icon(Icons.language, color: AppColors.primaryText(context)),
                    label: Text(
                      langController.currentLanguageName,
                      style: TextStyle(color: AppColors.primaryText(context), fontWeight: FontWeight.w600),
                    ),
                  );
                }),
              ],
            ),
            body: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 30),
                  children: [
                    _buildHeader(size, profileData),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Column(
                        children: [
                          _SettingsItem(
                            icon: Icons.person_outline,
                            label: AppLocalizations.of(context)?.profileInformation ?? 'Profile information',
                            onTap: () => Get.to(() => AddBioScreen(profileData: profileData)),
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.filter_list,
                            label: AppLocalizations.of(context)?.tradePreferences ?? 'Trade preferences',
                            onTap: () => Get.to(() => TradePreferences(profileData: profileData)),
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.favorite_outline,
                            label: AppLocalizations.of(context)?.matchesAndChat ?? 'Matches & Chat',
                            onTap: () => Get.to(() => const MatchesListScreen()),
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.help_outline,
                            label: AppLocalizations.of(context)?.faqQuestions ?? 'FAQ questions',
                            onTap: () => NotificationService.info(title: AppLocalizations.of(context)?.comingSoon ?? 'Coming soon', message: AppLocalizations.of(context)?.faqComingSoon ?? 'FAQ page is coming soon'),
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.description_outlined,
                            label: AppLocalizations.of(context)?.termsAndPolicies ?? 'Terms and policies',
                            onTap: () => _openTermsBottomSheet(context),
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.mail_outline,
                            label: AppLocalizations.of(context)?.contactUs ?? 'Contact us',
                            onTap: () => Get.to(() => const ContactUs()),
                          ),
                          const Divider(),
                          _SettingsItem(
                            icon: Icons.language,
                            label: AppLocalizations.of(context)?.language ?? 'Language',
                            onTap: () => Get.to(() => const LanguageSettingsScreen()),
                          ),
                          const SizedBox(height: 8),
                          _SettingsItem(
                            icon: Icons.logout,
                            label: AppLocalizations.of(context)?.logOut ?? 'Log out',
                            isDestructive: true,
                            onTap: () => ShowMessage.showLogoutDialog(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryText(context),
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)?.processingPleaseWait ?? "Processing Please Wait",
                        style: TextStyle(
                            color: AppColors.primaryText(context),
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      )
                    ],
                  )
              ],
            ),
          );
        });
  }

  Widget _buildHeader(Size size, dynamic profileData) {
    // Get user initials from full name
    String fullName = profileData.data?.fullName ?? '';
    String initials = '';
    if (fullName.isNotEmpty) {
      List<String> nameParts = fullName.trim().split(' ');
      if (nameParts.length >= 2) {
        initials = '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      } else if (nameParts.isNotEmpty) {
        initials = nameParts[0][0].toUpperCase();
      }
    }
    
    return Container(
      width: size.width,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryText(context).withOpacity(0.85),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User initials avatar (no edit button)
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.9), width: 3),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
            child: Center(
              child: Text(
                initials.isNotEmpty ? initials : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Image.asset(
                'assets/images/ProfileSettingImages/verifyIcon.png',
                height: 26,
                width: 26,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Chip(
            backgroundColor: Colors.blue.withOpacity(0.15),
            shape: StadiumBorder(side: BorderSide(color: Colors.blue.withOpacity(0.4))),
            label: Text(
              "${(profileData.data?.getProfileCompletionPercentage() ?? 0.0).toStringAsFixed(0)}% COMPLETE",
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDestructiveButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  void _openTermsBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.contentBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(l10n?.termsOfService ?? 'Terms of Service', style: const TextStyle(fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(ctx);
                  NotificationService.info(title: l10n?.comingSoon ?? 'Coming soon', message: l10n?.termsComingSoon ?? 'Coming soon');
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n?.privacyPolicy ?? 'Privacy Policy', style: const TextStyle(fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(ctx);
                  NotificationService.info(title: l10n?.comingSoon ?? 'Coming soon', message: l10n?.privacyComingSoon ?? 'Coming soon');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Removed balance card per request

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsItem({Key? key, required this.icon, required this.label, required this.onTap, this.isDestructive = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color textColor = isDestructive ? Colors.red : Theme.of(context).colorScheme.onSurface;
    final Color iconColor = isDestructive ? Colors.red : AppColors.primaryText(context);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.surfaceVariantColor(context),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
      trailing: Icon(Icons.chevron_right, color: Theme.of(context).dividerColor),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({Key? key, required this.iconAsset, required this.label, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(iconAsset, height: 36, width: 36),
              const SizedBox(height: 10),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeumoAction extends StatelessWidget {
  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  const _NeumoAction({Key? key, required this.iconAsset, required this.label, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x11000000), offset: Offset(6, 6), blurRadius: 12),
            BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
          ],
          border: Border.all(color: AppColors.outlineColor(context)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(iconAsset, height: 36, width: 36),
            const SizedBox(height: 10),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
