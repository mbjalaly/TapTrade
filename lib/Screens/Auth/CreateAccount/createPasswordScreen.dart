import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';

import 'createFullName.dart';

class PasswordScreen extends StatefulWidget {
  PasswordScreen({Key? key, required this.requestModel}) : super(key: key);
  SignUpRequestModel requestModel;
  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  TextEditingController passCon = TextEditingController();
  bool obscureText = true;

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
                      width: Get.width * 0.5,
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
                  text: "Password",
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
                  controller: passCon,
                  cursorColor: Colors.grey,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                      child: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.silverEyeColor,
                      ),
                    ),
                    border: InputBorder.none, // Remove the border
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.grey,
                          width: 3), // Grey color for the underline when focused
                    ),
                    enabledBorder: const UnderlineInputBorder(
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
                  text: "Password should be between 0-6 characters. ",
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
                  onPressed: () {
                    if(passCon.text.isNotEmpty){
                      widget.requestModel.password = passCon.text;
                      widget.requestModel.password2 = passCon.text;
                      Get.to(() => FullNameScreen(requestModel: widget.requestModel,));
                    }else{
                      ShowMessage.notify(context, "Please Add Password");
                    }
                  },
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
