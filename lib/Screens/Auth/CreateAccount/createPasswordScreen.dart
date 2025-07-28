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
  TextEditingController confirmPassCon = TextEditingController();
  bool obscureText = true;
  bool obscureConfirmText = true;
  bool isPasswordValid = false;
  bool isConfirmPasswordValid = false;
  bool isPasswordStrong = false;

  // Password strength indicators
  bool hasMinLength = false;
  bool hasUpperCase = false;
  bool hasLowerCase = false;
  bool hasNumbers = false;
  bool hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    passCon.addListener(_validatePassword);
    confirmPassCon.addListener(_validateConfirmPassword);
  }

  void _validatePassword() {
    final password = passCon.text;
    
    setState(() {
      hasMinLength = password.length >= 8;
      hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      hasLowerCase = password.contains(RegExp(r'[a-z]'));
      hasNumbers = password.contains(RegExp(r'[0-9]'));
      hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      
      isPasswordValid = hasMinLength && hasUpperCase && hasLowerCase && hasNumbers && hasSpecialChar;
      isPasswordStrong = isPasswordValid;
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      isConfirmPasswordValid = confirmPassCon.text.isNotEmpty && 
                              confirmPassCon.text == passCon.text;
    });
  }

  Color _getStrengthColor() {
    int strength = 0;
    if (hasMinLength) strength++;
    if (hasUpperCase) strength++;
    if (hasLowerCase) strength++;
    if (hasNumbers) strength++;
    if (hasSpecialChar) strength++;

    switch (strength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStrengthText() {
    int strength = 0;
    if (hasMinLength) strength++;
    if (hasUpperCase) strength++;
    if (hasLowerCase) strength++;
    if (hasNumbers) strength++;
    if (hasSpecialChar) strength++;

    switch (strength) {
      case 0:
      case 1:
        return "Very Weak";
      case 2:
        return "Weak";
      case 3:
        return "Fair";
      case 4:
        return "Good";
      case 5:
        return "Strong";
      default:
        return "";
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
                  text: "Create Password",
                  fontSize: Get.width * 0.065,
                  textcolor: AppColors.darkBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065, top: Get.height * 0.02),
                child: AppText(
                  text: "Create a strong password to secure your account",
                  fontSize: Get.width * 0.035,
                  textcolor: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: Get.height * 0.03),
              
              // Password Field
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065,
                    right: Get.width * 0.065),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: "Password",
                      fontSize: Get.width * 0.04,
                      textcolor: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.themeColor, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        hintText: "Enter your password",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ],
                ),
              ),

              // Password Strength Indicator
              if (passCon.text.isNotEmpty) ...[
                SizedBox(height: Get.height * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Get.width * 0.065),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppText(
                            text: "Password Strength: ",
                            fontSize: Get.width * 0.035,
                            textcolor: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          AppText(
                            text: _getStrengthText(),
                            fontSize: Get.width * 0.035,
                            textcolor: _getStrengthColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: [
                          hasMinLength,
                          hasUpperCase,
                          hasLowerCase,
                          hasNumbers,
                          hasSpecialChar
                        ].where((e) => e).length / 5,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor()),
                      ),
                      SizedBox(height: 12),
                      _buildRequirementItem("At least 8 characters", hasMinLength),
                      _buildRequirementItem("One uppercase letter", hasUpperCase),
                      _buildRequirementItem("One lowercase letter", hasLowerCase),
                      _buildRequirementItem("One number", hasNumbers),
                      _buildRequirementItem("One special character", hasSpecialChar),
                    ],
                  ),
                ),
              ],

              SizedBox(height: Get.height * 0.03),

              // Confirm Password Field
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065,
                    right: Get.width * 0.065),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: "Confirm Password",
                      fontSize: Get.width * 0.04,
                      textcolor: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: confirmPassCon,
                      cursorColor: Colors.grey,
                      obscureText: obscureConfirmText,
                      decoration: InputDecoration(
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              obscureConfirmText = !obscureConfirmText;
                            });
                          },
                          child: Icon(
                            obscureConfirmText ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.silverEyeColor,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isConfirmPasswordValid ? Colors.green : AppColors.themeColor, 
                            width: 2
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        hintText: "Confirm your password",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                    if (confirmPassCon.text.isNotEmpty && !isConfirmPasswordValid)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 16),
                            SizedBox(width: 8),
                            AppText(
                              text: "Passwords don't match",
                              fontSize: Get.width * 0.032,
                              textcolor: Colors.red,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              Spacer(),
              
              // Terms and Conditions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Get.width * 0.065),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        text: "By continuing, you agree to our Terms of Service and Privacy Policy",
                        fontSize: Get.width * 0.03,
                        textcolor: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: Get.height * 0.03),

              Center(
                child: AppButton(
                  onPressed: (isPasswordValid && isConfirmPasswordValid)
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
    widget.requestModel.password = passCon.text;
    widget.requestModel.password2 = confirmPassCon.text;
    Get.to(() => FullNameScreen(requestModel: widget.requestModel,));
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? Colors.green : Colors.grey,
            size: 16,
          ),
          SizedBox(width: 8),
          AppText(
            text: text,
            fontSize: Get.width * 0.032,
            textcolor: isMet ? Colors.green : Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    passCon.dispose();
    confirmPassCon.dispose();
    super.dispose();
  }
}
