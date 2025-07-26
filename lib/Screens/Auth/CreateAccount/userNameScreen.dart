import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Screens/Auth/CreateAccount/createPasswordScreen.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';

class UserNameScreen extends StatefulWidget {
  const UserNameScreen({super.key});

  @override
  State<UserNameScreen> createState() => _UserNameScreenState();
}

class _UserNameScreenState extends State<UserNameScreen> {
  TextEditingController nameCon = TextEditingController();
  SignUpRequestModel requestModel = SignUpRequestModel();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: Get.height * 0.04,
              ),
              Container(
                height: 4,
                width: Get.width,
                color: Colors.grey.withOpacity(.40),
                child: Row(
                  children: [
                    Container(
                      height: 4,
                      width: Get.width * 0.25,
                      color: AppColors.themeColor,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 29,
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065, top: Get.height * 0.05),
                child: AppText(
                  text: "Username",
                  fontSize: Get.width * 0.065,
                  textcolor: AppColors.darkBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065,
                    top: Get.height * 0.0,
                    right: Get.width * 0.065),
                child: TextField(
                  controller: nameCon,
                  cursorColor: Colors.grey,
                  decoration: const InputDecoration(
                    border: InputBorder.none, // Remove the border
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.grey,
                          width: 3), // Grey color for the underline when focused
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.grey,
                          width:
                              3), // Grey color for the underline when not focused
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065, top: Get.height * 0.015),
                child: AppText(
                  text:
                      "This is how it will appear in TapTrade and you \nwill not be able to change it ",
                  fontSize: Get.width * 0.032,
                  textcolor: Colors.grey,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: Get.height * 0.06,
              ),
              Center(
                child: AppButton(
                  onPressed: () async {
                    if(nameCon.text.trim().isNotEmpty){
                      setState(() {
                        isLoading = true;
                      });
                      String checkUserName = "username=${nameCon.text.trim()}";
                     final result = await AuthService.instance.checkUserNameAndEmail(context,checkUserName);
                      setState(() {
                        isLoading = false;
                      });
                     if(result['success'] == false && result['code'] == 404){
                       setState(() {
                         requestModel.username = nameCon.text;
                       });
                       Get.to(() => PasswordScreen(requestModel: requestModel));
                     }else{
                       ShowMessage.notify(context, result['message']);
                      }
                    }else{
                      ShowMessage.notify(context, 'Please Add UserName');
                    }

                  },
                  isLoading: isLoading,
                  text: "CONTINUE",
                  fontSize: Get.width * 0.043,
                  width: Get.width * 0.88,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
