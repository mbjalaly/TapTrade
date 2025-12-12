import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';

import 'createEmail.dart';

class FullNameScreen extends StatefulWidget {
  FullNameScreen({Key? key, required this.requestModel}) : super(key: key);
  SignUpRequestModel requestModel;
  @override
  State<FullNameScreen> createState() => _FullNameScreenState();
}

class _FullNameScreenState extends State<FullNameScreen> {
  TextEditingController fullNameCon = TextEditingController();

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
                      width: Get.width * 0.75,
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
                  text: "Full Name",
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
                  controller: fullNameCon,
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
                  text: "Enter you First and Last name.",
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
                    if(fullNameCon.text.trim().isNotEmpty){
                      setState(() {
                        widget.requestModel.firstName = fullNameCon.text;
                        widget.requestModel.lastName = fullNameCon.text;
                        widget.requestModel.fullName = fullNameCon.text;
                      });
                      Get.to(() => CreateEmailScreen(requestModel: widget.requestModel,));
                    }else{
                      ShowMessage.notify(context, "Please Add Your FullName");
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
