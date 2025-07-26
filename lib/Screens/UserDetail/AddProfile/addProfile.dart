import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taptrade/Screens/UserDetail/AddLocation/addLocation.dart';
import 'package:taptrade/Services/ImageFileService/imageFileService.dart';
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
  File? _image; // To store the selected image
  String avatarImage = '';
  String imagePath = '';

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
                  Navigator.pop(context);  // Close the bottom sheet first
                  _openAvatarSlider();      // Open the avatar slider as a dialog
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

  avatarSelection(BuildContext context){
    if(_image != null){
      return ClipRRect(
          borderRadius: BorderRadius.circular(1000.0),
          clipBehavior: Clip.antiAlias, child: Image.file(_image!,fit: BoxFit.cover,));
    }else if(avatarImage.isNotEmpty){
      return ClipRRect(
        borderRadius: BorderRadius.circular(1000.0),
        clipBehavior: Clip.antiAlias, child: Image.asset(avatarImage,fit: BoxFit.cover,));
    }else{
      return Padding(
        padding: const EdgeInsets.all(90.0),
        child: SvgPicture.asset("assets/svgs/Camera.svg"),
      );
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
              SizedBox(height: Get.height*0.02,),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                    onTap: (){
                      Get.back();
                    },
                    child: const Align(
                        alignment: Alignment.topLeft,
                        child: Icon(Icons.arrow_back_ios_new,color: Colors.grey,size: 29,))),
              ),
              AppText(text: "Congratulations!",
                fontSize: Get.width*0.075,
                textcolor: AppColors.darkBlue,
                fontWeight: FontWeight.w500,
              ),

              Padding(
                padding:  EdgeInsets.only(top: Get.height*0.02),
                child: AppText(text: "Lets Build Your Profile.",
                  fontSize: Get.width*0.04,
                  textcolor: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: Get.height*0.03,),
              GestureDetector(
                onTap: _pickImage, // Call the function to pick an image
                child: Container(
                  height: 330,
                  width: 330,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor,
                  ),
                  child: avatarSelection(context),
                ),
              ),
              SizedBox(height: Get.height*0.06,),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    if(imagePath.isNotEmpty){
                      File? imageFile;
                      if(avatarImage.isNotEmpty){
                        imageFile = await loadAssetAsFile(avatarImage);
                      }else if(_image!=null){
                        imageFile = _image!;
                      }
                      Get.to( () => AddLocationScreen(imageFile: imageFile,));
                    }else{
                      // ShowMessage.notify(context, "Please Add Avatar");
                      _pickImage();
                    }

                  },
                  child: Container(
                    height: Get.height*0.065,
                    width: Get.width*0.4,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: AppColors.themeColor
                    ),
                    child: AppText(
                      text: "Add Avatar",
                      fontWeight: FontWeight.w600,
                      textcolor: Colors.white,
                      fontSize: Get.width*0.042,
                    )
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


