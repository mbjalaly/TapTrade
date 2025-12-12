import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Screens/Auth/SsoAccount/phoneNumberSignIn.dart';
import 'package:taptrade/Screens/Auth/createAccount/createFullName.dart';
import 'package:taptrade/Screens/UserDetail/AddProfile/addProfile.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';

class CreateEmailScreen extends StatefulWidget {
  CreateEmailScreen({Key? key, required this.requestModel}) : super(key: key);
  SignUpRequestModel requestModel;
  @override
  State<CreateEmailScreen> createState() => _CreateEmailScreenState();
}

class _CreateEmailScreenState extends State<CreateEmailScreen> {
  TextEditingController emailCon = TextEditingController();
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
                      width: Get.width,
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
                      Icons.arrow_back_ios_new,
                      color: Colors.grey,
                      size: 29,
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065, top: Get.height * 0.05),
                child: AppText(
                  text: "Email",
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
                child: TextFormField(
                  controller: emailCon,
                  cursorColor: Colors.grey,
                  keyboardType: TextInputType.emailAddress,
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
                  text: "Enter your email address",
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
                    if(emailCon.text.trim().isNotEmpty){
                      String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                      RegExp regex = RegExp(pattern);
                      if(regex.hasMatch(emailCon.text.trim())){

                        setState(() {
                          isLoading = true;
                        });
                        String checkUserName = "email=${emailCon.text.trim()}";
                        final result = await AuthService.instance.checkUserNameAndEmail(context,checkUserName);
                        setState(() {
                          isLoading = false;
                        });
                        if(result['success'] == false && result['code'] == 404){
                          setState(() {
                            widget.requestModel.email = emailCon.text;
                          });
                          Get.to( () =>  PhoneSignInScreen(requestModel: widget.requestModel,));
                        }else{
                          ShowMessage.notify(context, result['message']);
                        }
                      }else{
                        ShowMessage.notify(context, "Please Enter a Valid Email");
                      }
                    }else{
                      ShowMessage.notify(context, "Please Add Your Email");
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
