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

class _ProfileSettingState extends State<ProfileSetting> {
  var userController = Get.find<UserController>();
  File? _image; // To store the selected image
  String avatarImage = '';
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
                title: Text('Avatar'),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet first
                  _openAvatarSlider(); // Open the avatar slider as a dialog
                },
              ),
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Camera'),
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
                title: Text('Gallery'),
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GetBuilder(
        init: UserController(),
        builder: (userController) {
          var profileData = userController.userProfile.value;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                centerTitle: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      "assets/images/t.png",
                      height: 30,
                      width: 30,
                    ),
                    Row(
                      children: [
                        // Image.asset(
                        //   "assets/images/ProfileSettingImages/safety.png",
                        //   height: 30,
                        //   width: 30,
                        // ),
                        // const SizedBox(
                        //   width: 10,
                        // ),
                        GestureDetector(
                          onTap: () {
                            ShowMessage.showLogoutDialog(context);
                          },
                          child: Image.asset(
                            "assets/images/ProfileSettingImages/setting.png",
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ],
                    )
                  ],
                )),
            body: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: size.width,
                      height: size.height / 3.0, // Reduced from 2.6 to 3.0
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: size.height / 4.0, // Reduced from 3.5 to 4.0
                                width: size.height / 4.0, // Reduced from 4 to 4.0
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                              ),
                              Container(
                                height: size.height / 4.5, // Reduced from 4 to 4.5
                                width: size.height / 4.5, // Reduced from 4 to 4.5
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryColor,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryColor,
                                      AppColors.primaryTextColor
                                          .withAlpha((0.8 * 255).toInt())
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Container(
                                  height: size.height / 4.5, // Reduced from 4 to 4.5
                                  width: size.height / 4.5, // Reduced from 4 to 4.5
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primaryColor,
                                      border: Border.all(
                                          color: AppColors.whiteTextColor,
                                          width: 1)),
                                  child: avatarSelection(context, profileData),
                                ),
                              ),
                              Positioned(
                                right: 10,
                                top: 10,
                                child: GestureDetector(
                                  onTap: _pickImage, //
                                  child: Material(
                                    elevation: 4.5,
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(25.0),
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.edit,
                                        color: AppColors.greyTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                left: 10,
                                right: 10,
                                child: AppButton(
                                  onPressed: () {},
                                  width: size.width * 0.3,
                                  height: 35,
                                  text:
                                      "${(profileData.data?.getProfileCompletionPercentage() ?? 0.0).toStringAsFixed(0)}% COMPLETE",
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "${profileData.data?.fullName}  ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: size.width * 0.1,
                                    color: Colors.black),
                              ),
                              Image.asset(
                                'assets/images/ProfileSettingImages/verifyIcon.png',
                                height: 40,
                                width: 40,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: size.width,
                      height: size.height / 2.8, // Reduced from 2.4 to 2.8
                      color: Colors.black.withAlpha((0.1 * 255).toInt()),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () => Get.to(() => AddBioScreen(
                                      profileData: profileData,
                                    )),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: size.height * 0.15, // Reduced from 0.17 to 0.15
                                      width: size.width * 0.3,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12.0)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/ProfileSettingImages/boxProfile.png',
                                            height: 40,
                                            width: 40,
                                          ),
                                          Text(
                                            "Trader Info",
                                            style: TextStyle(
                                                color: AppColors.secondaryColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          // Text("( optional )",style: TextStyle(color: AppColors.secondaryColor.withOpacity(0.5),fontWeight: FontWeight.bold),)
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Image.asset(
                                          "assets/images/ProfileSettingImages/plusIcon.png",
                                          height: 25,
                                          width: 25,
                                        )),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Get.to(() => TradePreferences(
                                      profileData: profileData,
                                    )),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: size.height * 0.15, // Reduced from 0.17 to 0.15
                                      width: size.width * 0.3,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12.0)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/ProfileSettingImages/flash.png',
                                            height: 40,
                                            width: 40,
                                          ),
                                          const Text(
                                            "Trade\nPrefrences",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: AppColors.secondaryColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Image.asset(
                                          "assets/images/ProfileSettingImages/plusIcon.png",
                                          height: 25,
                                          width: 25,
                                        )),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () => Get.to(() => PaymentScreen(
                                      isDirect: false,
                                      likeData: null,
                                      matchData: null,
                                      tradeRequestData: null,
                                    )),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: size.height * 0.15, // Reduced from 0.17 to 0.15
                                      width: size.width * 0.3,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12.0)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/ProfileSettingImages/card.png',
                                            height: 40,
                                            width: 40,
                                          ),
                                          const Text(
                                            "Payment",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Color(0xff27AAE4),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Image.asset(
                                          "assets/images/ProfileSettingImages/plusIcon.png",
                                          height: 25,
                                          width: 25,
                                        )),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Get.to(() => const ContactUs()),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: size.height * 0.15, // Reduced from 0.17 to 0.15
                                      width: size.width * 0.3,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12.0)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/ProfileSettingImages/callIcon.png',
                                            height: 40,
                                            width: 40,
                                          ),
                                          Text(
                                            "Contact",
                                            style: TextStyle(
                                                color: AppColors.primaryColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Image.asset(
                                          "assets/images/ProfileSettingImages/plusIcon.png",
                                          height: 25,
                                          width: 25,
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                if (isLoading)
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      Text(
                        "Processing Please Wait",
                        style: TextStyle(
                            color: AppColors.primaryTextColor,
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
}
