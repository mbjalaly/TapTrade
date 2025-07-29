import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';

import 'createFullName.dart';

class PasswordScreen extends StatefulWidget {
  PasswordScreen({Key? key, required this.requestModel}) : super(key: key);
  final SignUpRequestModel requestModel;
  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController passCon = TextEditingController();
  final TextEditingController confirmPassCon = TextEditingController();
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
      
      // Make password validation less strict - only require min length and at least 3 other criteria
      int criteriaMet = 0;
      if (hasUpperCase) criteriaMet++;
      if (hasLowerCase) criteriaMet++;
      if (hasNumbers) criteriaMet++;
      if (hasSpecialChar) criteriaMet++;
      
      isPasswordValid = hasMinLength && criteriaMet >= 2; // Require min length + at least 2 other criteria
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

    // Adjust strength based on new validation logic
    if (strength >= 3 && hasMinLength) {
      return Colors.green;
    } else if (strength >= 2 && hasMinLength) {
      return Colors.lightGreen;
    } else if (strength >= 1 && hasMinLength) {
      return Colors.yellow;
    } else if (hasMinLength) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getStrengthText() {
    int strength = 0;
    if (hasUpperCase) strength++;
    if (hasLowerCase) strength++;
    if (hasNumbers) strength++;
    if (hasSpecialChar) strength++;

    if (!hasMinLength) {
      return "Too Short";
    } else if (strength >= 3) {
      return "Strong";
    } else if (strength >= 2) {
      return "Good";
    } else if (strength >= 1) {
      return "Fair";
    } else {
      return "Weak";
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
                color: Colors.grey.withAlpha((0.1 * 255).toInt()),
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
              
              // Debug information (can be removed in production)
              if (passCon.text.isNotEmpty || confirmPassCon.text.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Get.width * 0.065),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      AppText(
                        text: "Debug Info:",
                        fontSize: Get.width * 0.03,
                        textcolor: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      AppText(
                        text: "Password Valid: $isPasswordValid",
                        fontSize: Get.width * 0.028,
                        textcolor: isPasswordValid ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w400,
                      ),
                      AppText(
                        text: "Confirm Valid: $isConfirmPasswordValid",
                        fontSize: Get.width * 0.028,
                        textcolor: isConfirmPasswordValid ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w400,
                      ),
                      AppText(
                        text: "Button Enabled: ${isPasswordValid && isConfirmPasswordValid}",
                        fontSize: Get.width * 0.028,
                        textcolor: (isPasswordValid && isConfirmPasswordValid) ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
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
