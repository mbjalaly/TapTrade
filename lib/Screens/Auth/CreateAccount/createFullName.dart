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
  TextEditingController firstNameCon = TextEditingController();
  TextEditingController lastNameCon = TextEditingController();
  bool isFirstNameValid = false;
  bool isLastNameValid = false;

  @override
  void initState() {
    super.initState();
    firstNameCon.addListener(_validateFirstName);
    lastNameCon.addListener(_validateLastName);
  }

  void _validateFirstName() {
    setState(() {
      isFirstNameValid = firstNameCon.text.trim().isNotEmpty && 
                        firstNameCon.text.trim().length >= 2 &&
                        RegExp(r'^[a-zA-Z\s]+$').hasMatch(firstNameCon.text.trim());
    });
  }

  void _validateLastName() {
    setState(() {
      isLastNameValid = lastNameCon.text.trim().isNotEmpty && 
                       lastNameCon.text.trim().length >= 2 &&
                       RegExp(r'^[a-zA-Z\s]+$').hasMatch(lastNameCon.text.trim());
    });
  }

  String _getValidationMessage(String fieldName, bool isValid, String value) {
    if (value.isEmpty) return "$fieldName is required";
    if (value.length < 2) return "$fieldName must be at least 2 characters";
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) return "$fieldName can only contain letters";
    return "";
  }

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
                  text: "Your Name",
                  fontSize: Get.width * 0.065,
                  textcolor: AppColors.darkBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065, top: Get.height * 0.02),
                child: AppText(
                  text: "Tell us your name so we can personalize your experience",
                  fontSize: Get.width * 0.035,
                  textcolor: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: Get.height * 0.04),

              // First Name Field
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065,
                    right: Get.width * 0.065),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: "First Name",
                      fontSize: Get.width * 0.04,
                      textcolor: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: firstNameCon,
                      cursorColor: Colors.grey,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isFirstNameValid ? Colors.green : AppColors.themeColor, 
                            width: 2
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        hintText: "Enter your first name",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Icon(Icons.person_outline, color: Colors.grey.shade400),
                      ),
                    ),
                    if (firstNameCon.text.isNotEmpty && !isFirstNameValid)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: AppText(
                                text: _getValidationMessage("First name", isFirstNameValid, firstNameCon.text.trim()),
                                fontSize: Get.width * 0.032,
                                textcolor: Colors.red,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: Get.height * 0.03),

              // Last Name Field
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065,
                    right: Get.width * 0.065),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: "Last Name",
                      fontSize: Get.width * 0.04,
                      textcolor: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: lastNameCon,
                      cursorColor: Colors.grey,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isLastNameValid ? Colors.green : AppColors.themeColor, 
                            width: 2
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        hintText: "Enter your last name",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Icon(Icons.person_outline, color: Colors.grey.shade400),
                      ),
                    ),
                    if (lastNameCon.text.isNotEmpty && !isLastNameValid)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: AppText(
                                text: _getValidationMessage("Last name", isLastNameValid, lastNameCon.text.trim()),
                                fontSize: Get.width * 0.032,
                                textcolor: Colors.red,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: Get.height * 0.04),

              // Name Preview
              if (isFirstNameValid && isLastNameValid)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Get.width * 0.065),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: AppText(
                            text: "Your name will appear as: ${firstNameCon.text.trim()} ${lastNameCon.text.trim()}",
                            fontSize: Get.width * 0.035,
                            textcolor: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              Spacer(),

              Center(
                child: AppButton(
                  onPressed: (isFirstNameValid && isLastNameValid)
                      ? () { _handleContinue(); }
                      : null,
                  text: "CONTINUE",
                  fontSize: Get.width * 0.043,
                  width: Get.width * 0.88,
                ),
              ),
              
              SizedBox(height: Get.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    setState(() {
      widget.requestModel.firstName = firstNameCon.text.trim();
      widget.requestModel.lastName = lastNameCon.text.trim();
      widget.requestModel.fullName = "${firstNameCon.text.trim()} ${lastNameCon.text.trim()}";
    });
    Get.to(() => CreateEmailScreen(requestModel: widget.requestModel,));
  }

  @override
  void dispose() {
    firstNameCon.dispose();
    lastNameCon.dispose();
    super.dispose();
  }
}
