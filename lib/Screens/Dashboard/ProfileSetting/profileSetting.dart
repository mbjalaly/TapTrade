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
class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProfileManagementScreen> createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> with TickerProviderStateMixin {
  var userController = Get.find<UserController>();
  File? _image;
  String avatarImage = '';
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Update Profile Picture',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 24),
                _buildImageOption(
                  icon: Icons.person,
                  title: 'Choose Avatar',
                  subtitle: 'Select from predefined avatars',
                  color: AppColors.primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                    _openAvatarSlider();
                  },
                ),
                _buildImageOption(
                  icon: Icons.camera_alt,
                  title: 'Take Photo',
                  subtitle: 'Use camera to take a new photo',
                  color: AppColors.secondaryColor,
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.camera);

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
                _buildImageOption(
                  icon: Icons.photo_library,
                  title: 'Choose from Gallery',
                  subtitle: 'Select from your photo library',
                  color: AppColors.darkBlue,
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

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
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
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

  Future<void> updateProfileImage(File imageFile) async {
    Map<String, dynamic> body = {
      'image': imageFile,
    };
    String id = userController.userProfile.value.data?.id ?? '';
    setState(() {
      isLoading = true;
    });
    await ProfileService.instance.updateProfile(context, body, id);
    await ProfileService.instance.getProfile(context);
    setState(() {
      isLoading = false;
    });
  }

  Widget _buildProfileHeader(UserProfileResponseModel profileData, Size size) {
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
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
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
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: _buildAvatarImage(profileData),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${profileData.data?.fullName}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.065,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(width: 8),
              Image.asset(
                'assets/images/ProfileSettingImages/verifyIcon.png',
                height: 28,
                width: 28,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  "${(profileData.data?.getProfileCompletionPercentage() ?? 0.0).toStringAsFixed(0)}% Complete",
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
              'Profile Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
          ),
          _buildMenuCard(
            title: "Trader Information",
            subtitle: "Update your personal details and bio",
            icon: Icons.person_outline,
            iconColor: AppColors.secondaryColor,
            onTap: () => Get.to(() => AddBioScreen(profileData: userController.userProfile.value)),
          ),
          _buildMenuCard(
            title: "Trade Preferences",
            subtitle: "Set your trading interests and preferences",
            icon: Icons.flash_on,
            iconColor: AppColors.primaryColor,
            onTap: () => Get.to(() => TradePreferences(profileData: userController.userProfile.value)),
          ),
          _buildMenuCard(
            title: "Payment Methods",
            subtitle: "Manage your payment options and billing",
            icon: Icons.payment,
            iconColor: AppColors.darkBlue,
            onTap: () => Get.to(() => PaymentScreen(
              isDirect: false,
              likeData: null,
              matchData: null,
              tradeRequestData: null,
            )),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.darkBlue,
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
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text('Profile Management'),
          ),
          body: Stack(
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileHeader(profileData, size),
                      const SizedBox(height: 8),
                      _buildMenuSection(),
                      const SizedBox(height: 30),
                    ],
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
                          "Updating Profile...",
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

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildHelpSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
          ),
          _buildHelpCard(
            title: "How to Trade?",
            subtitle: "Learn the basics of trading on our platform",
            icon: Icons.swap_horiz,
            iconColor: AppColors.primaryColor,
            onTap: () => _showHelpDialog("How to Trade", "Trading on our platform is simple..."),
          ),
          _buildHelpCard(
            title: "Payment Issues",
            subtitle: "Resolve payment and billing problems",
            icon: Icons.payment,
            iconColor: AppColors.secondaryColor,
            onTap: () => _showHelpDialog("Payment Issues", "If you're experiencing payment issues..."),
          ),
          _buildHelpCard(
            title: "Account Security",
            subtitle: "Keep your account safe and secure",
            icon: Icons.security,
            iconColor: AppColors.darkBlue,
            onTap: () => _showHelpDialog("Account Security", "Your account security is our priority..."),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
          ),
          _buildHelpCard(
            title: "Live Chat",
            subtitle: "Chat with our support team in real-time",
            icon: Icons.chat,
            iconColor: AppColors.primaryColor,
            onTap: () => _showHelpDialog("Live Chat", "Our live chat is available 24/7..."),
          ),
          _buildHelpCard(
            title: "Email Support",
            subtitle: "Send us an email for detailed assistance",
            icon: Icons.email,
            iconColor: AppColors.secondaryColor,
            onTap: () => _showHelpDialog("Email Support", "Send your questions to support@taptrade.com..."),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          content: Text(
            content,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Help Center'),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withOpacity(0.1),
                      AppColors.secondaryColor.withOpacity(0.05),
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
                child: Column(
                  children: [
                    Icon(
                      Icons.help_outline,
                      size: 60,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'How can we help you?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find answers to common questions and get support when you need it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildHelpSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class TermsAndPoliciesScreen extends StatefulWidget {
  const TermsAndPoliciesScreen({Key? key}) : super(key: key);

  @override
  State<TermsAndPoliciesScreen> createState() => _TermsAndPoliciesScreenState();
}

class _TermsAndPoliciesScreenState extends State<TermsAndPoliciesScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildLegalSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              'Legal Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
          ),
          _buildLegalCard(
            title: "Terms of Service",
            subtitle: "Read our terms and conditions",
            icon: Icons.description,
            iconColor: AppColors.primaryColor,
            onTap: () => _showLegalDialog("Terms of Service", "By using our service, you agree to..."),
          ),
          _buildLegalCard(
            title: "Privacy Policy",
            subtitle: "How we protect your data",
            icon: Icons.privacy_tip,
            iconColor: AppColors.secondaryColor,
            onTap: () => _showLegalDialog("Privacy Policy", "We are committed to protecting your privacy..."),
          ),
          _buildLegalCard(
            title: "Cookie Policy",
            subtitle: "How we use cookies",
            icon: Icons.cookie,
            iconColor: AppColors.darkBlue,
            onTap: () => _showLegalDialog("Cookie Policy", "We use cookies to improve your experience..."),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              'Additional Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
          ),
          _buildLegalCard(
            title: "Data Protection",
            subtitle: "Your rights and our obligations",
            icon: Icons.security,
            iconColor: AppColors.primaryColor,
            onTap: () => _showLegalDialog("Data Protection", "We implement appropriate security measures..."),
          ),
          _buildLegalCard(
            title: "User Agreement",
            subtitle: "Rules for using our platform",
            icon: Icons.people,
            iconColor: AppColors.secondaryColor,
            onTap: () => _showLegalDialog("User Agreement", "As a user of our platform, you agree to..."),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLegalDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Terms & Policies'),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withOpacity(0.1),
                      AppColors.secondaryColor.withOpacity(0.05),
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
                child: Column(
                  children: [
                    Icon(
                      Icons.gavel,
                      size: 60,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Legal Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Read our terms, policies, and legal documents to understand your rights and our obligations.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildLegalSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
