import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Screens/UserDetail/AddInterest/addInterest.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/ImageFileService/imageFileService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/avatarSlider.dart';
import 'package:taptrade/Widgets/customText.dart';

class AddProfileScreen extends StatefulWidget {
  const AddProfileScreen({super.key});

  @override
  State<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
  TextEditingController fullNameCon = TextEditingController();
  File? _image;
  String avatarImage = '';
  String imagePath = '';
  var userController = Get.find<UserController>();
  bool isLoading = false;

  Future<void> _pickImage() async {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.person),
                title: const Text('Avatar'),
                onTap: () {
                  Navigator.pop(context);
                  _openAvatarSlider();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Camera'),
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.camera);

                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                      imagePath = _image?.path ?? '';
                      avatarImage = '';
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_album),
                title: const Text('Gallery'),
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                      imagePath = _image?.path ?? '';
                      avatarImage = '';
                    });
                  }
                  Navigator.pop(context);
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
        imagePath = avatarImage;
        _image = null;
      });
    }
  }

  Widget avatarSelection(BuildContext context) {
    if (_image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(1000.0),
        clipBehavior: Clip.antiAlias,
        child: Image.file(_image!, fit: BoxFit.cover),
      );
    } else if (avatarImage.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(1000.0),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(avatarImage, fit: BoxFit.cover),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/svgs/Camera.svg",
            height: 60,
            width: 60,
          ),
          const SizedBox(height: 12),
          Text(
            'Add Photo',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '(Optional)',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      );
    }
  }

  Future<void> _continueWithImage() async {
    if (imagePath.isEmpty) {
      // No image selected, just skip to next screen
      Get.to(() => const AddInterestScreen());
      return;
    }

    setState(() => isLoading = true);

    File? imageFile;
    if (avatarImage.isNotEmpty) {
      imageFile = await loadAssetAsFile(avatarImage);
    } else if (_image != null) {
      imageFile = _image!;
    }

    String userId = userController.userProfile.value.data?.id ?? '';
    if (userId.isNotEmpty && imageFile != null) {
      Map<String, dynamic> body = {
        'image': imageFile,
      };

      final result = await ProfileService.instance.updateProfile(context, body, userId);

      setState(() => isLoading = false);

      if (result.status == Status.COMPLETED) {
        Get.to(() => const AddInterestScreen());
      } else {
        ShowMessage.error(context, result.message ?? "Failed to update profile");
      }
    } else {
      setState(() => isLoading = false);
      // If no image, just proceed
      Get.to(() => const AddInterestScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: Get.height * 0.02),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.grey,
                        size: 29,
                      ),
                    ),
                    // Skip button
                    GestureDetector(
                      onTap: () => Get.to(() => const AddInterestScreen()),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              AppText(
                text: "Congratulations!",
                fontSize: Get.width * 0.075,
                textcolor: AppColors.darkBlue,
                fontWeight: FontWeight.w500,
              ),

              Padding(
                padding: EdgeInsets.only(top: Get.height * 0.02),
                child: AppText(
                  text: "Add a profile photo (optional)",
                  fontSize: Get.width * 0.04,
                  textcolor: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              SizedBox(height: Get.height * 0.03),
              
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 280,
                  width: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: avatarSelection(context),
                ),
              ),
              
              SizedBox(height: Get.height * 0.04),
              
              // Continue button
              GestureDetector(
                onTap: isLoading ? null : _continueWithImage,
                child: Container(
                  height: Get.height * 0.065,
                  width: Get.width * 0.5,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: AppColors.themeColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.themeColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : AppText(
                          text: imagePath.isNotEmpty ? "Continue" : "Continue",
                          fontWeight: FontWeight.w600,
                          textcolor: Colors.white,
                          fontSize: Get.width * 0.042,
                        ),
                ),
              ),
              
              if (imagePath.isEmpty) ...[
                SizedBox(height: Get.height * 0.02),
                Text(
                  'You can add a photo later in settings',
                  style: TextStyle(
                    color: Colors.grey.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
