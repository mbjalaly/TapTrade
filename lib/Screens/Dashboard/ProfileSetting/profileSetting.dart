import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taptrade/Const/globleKey.dart';
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
import 'AddBio/addBio.dart';
import 'ContactUs/contactUs.dart';
import 'TradePreferences/tradePreferences.dart';

class ProfileSetting extends StatefulWidget {
  const ProfileSetting({super.key});

  @override
  State<ProfileSetting> createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> with TickerProviderStateMixin {
  var userController = Get.find<UserController>();
  File? _image;
  String avatarImage = '';
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildUserHeader(UserProfileResponseModel profileData, Size size) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.secondaryColor.withOpacity(0.05),
            AppColors.darkBlue.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: _buildAvatarImage(profileData),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${profileData.data?.fullName ?? 'User'}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * 0.055,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/ProfileSettingImages/verifyIcon.png',
                      height: 20,
                      width: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primaryColor,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${(profileData.data?.getProfileCompletionPercentage() ?? 0.0).toStringAsFixed(0)}% Complete",
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(UserProfileResponseModel profileData) {
    if (_image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(1000.0),
        clipBehavior: Clip.antiAlias,
        child: Image.file(
          _image!,
          fit: BoxFit.fill,
        ),
      );
    } else if (avatarImage.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(1000.0),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          avatarImage,
          fit: BoxFit.fill,
        ),
      );
    } else if (profileData.data?.image != null && profileData.data!.image!.isNotEmpty) {
      String image = profileData.data?.image ?? '';
      return NetworkImageProvider(
        url: "${KeyConstants.imageUrl}$image",
        borderRadius: BorderRadius.circular(1000.0),
        fit: BoxFit.fill,
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(15.0),
        child: SvgPicture.asset("assets/svgs/Camera.svg"),
      );
    }
  }

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              'Account & Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
          ),
          _buildMenuCard(
            title: "Profile",
            subtitle: "Manage your personal information and preferences",
            icon: Icons.person_outline,
            iconColor: AppColors.primaryColor,
            onTap: () => _navigateToProfile(),
          ),
          _buildMenuCard(
            title: "Help Center",
            subtitle: "Get help and find answers to common questions",
            icon: Icons.help_outline,
            iconColor: AppColors.secondaryColor,
            onTap: () => _navigateToHelpCenter(),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              'Legal & Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
          ),
          _buildMenuCard(
            title: "Terms & Policies",
            subtitle: "Read our terms of service and privacy policy",
            icon: Icons.description_outlined,
            iconColor: AppColors.darkBlue,
            onTap: () => _navigateToTermsAndPolicies(),
          ),
          _buildMenuCard(
            title: "Contact Us",
            subtitle: "Get in touch with our support team",
            icon: Icons.support_agent,
            iconColor: AppColors.primaryColor,
            onTap: () => Get.to(() => const ContactUs()),
          ),
          const SizedBox(height: 24),
          _buildMenuCard(
            title: "Log Out",
            subtitle: "Sign out of your account",
            icon: Icons.logout,
            iconColor: Colors.red[600]!,
            onTap: () => _showLogoutDialog(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    bool showBadge = false,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDestructive ? Colors.red[50] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isDestructive ? Border.all(color: Colors.red[200]!) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDestructive ? Colors.red[700] : AppColors.darkBlue,
                              ),
                            ),
                          ),
                          if (showBadge)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isDestructive ? Colors.red[600] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDestructive ? Colors.red[400] : Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToProfile() {
    // Navigate to a comprehensive profile management screen
    Get.to(() => const ProfileManagementScreen());
  }

  void _navigateToHelpCenter() {
    // Navigate to help center screen
    Get.to(() => const HelpCenterScreen());
  }

  void _navigateToTermsAndPolicies() {
    // Navigate to terms and policies screen
    Get.to(() => const TermsAndPoliciesScreen());
  }

  void _showLogoutDialog() {
    ShowMessage.showLogoutDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GetBuilder(
      init: UserController(),
      builder: (userController) {
        var profileData = userController.userProfile.value;
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    "assets/images/t.png",
                    height: 24,
                    width: 24,
                  ),
                ),
                const Text(
                  "More",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(width: 40), // Balance the layout
              ],
            ),
          ),
          body: Stack(
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildUserHeader(profileData, size),
                        const SizedBox(height: 8),
                        _buildMenuSection(),
                        const SizedBox(height: 150), // Increased bottom padding to avoid FAB overlap
                      ],
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primaryColor,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Loading...",
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }
}

// Placeholder screens for navigation
class ProfileManagementScreen extends StatelessWidget {
  const ProfileManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Management'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Profile Management Screen - Coming Soon'),
      ),
    );
  }
}

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Help Center Screen - Coming Soon'),
      ),
    );
  }
}

class TermsAndPoliciesScreen extends StatelessWidget {
  const TermsAndPoliciesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Policies'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Terms & Policies Screen - Coming Soon'),
      ),
    );
  }
}
