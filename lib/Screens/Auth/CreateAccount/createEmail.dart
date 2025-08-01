import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Screens/Auth/SsoAccount/phoneNumberSignIn.dart';
import 'package:taptrade/Screens/Auth/CreateAccount/createFullName.dart';
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
  bool isEmailValid = false;
  bool isEmailAvailable = false;
  bool isCheckingEmail = false;

  @override
  void initState() {
    super.initState();
    emailCon.addListener(_validateEmail);
  }

  void _validateEmail() {
    final email = emailCon.text.trim();
    setState(() {
      isEmailValid = _isValidEmail(email);
      isEmailAvailable = false; // Reset availability when email changes
    });
  }

  bool _isValidEmail(String email) {
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  Future<void> _checkEmailAvailability() async {
    if (!isEmailValid) return;

    setState(() {
      isCheckingEmail = true;
    });

    try {
      String checkUserName = "email=${emailCon.text.trim()}";
      final result = await AuthService.instance.checkUserNameAndEmail(context, checkUserName);
      
      setState(() {
        isCheckingEmail = false;
        isEmailAvailable = result['success'] == false && result['code'] == 404;
      });
    } catch (e) {
      setState(() {
        isCheckingEmail = false;
      });
    }
  }

  String _getEmailValidationMessage() {
    final email = emailCon.text.trim();
    if (email.isEmpty) return "Email is required";
    if (!isEmailValid) return "Please enter a valid email address";
    if (isEmailValid && !isEmailAvailable && !isCheckingEmail) return "This email is already registered";
    return "";
  }

  Color _getEmailBorderColor() {
    if (emailCon.text.isEmpty) return Colors.grey.shade300;
    if (!isEmailValid) return Colors.red;
    if (isEmailValid && isEmailAvailable) return Colors.green;
    if (isEmailValid && !isEmailAvailable && !isCheckingEmail) return Colors.red;
    return AppColors.themeColor;
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
                  text: "Email Address",
                  fontSize: Get.width * 0.065,
                  textcolor: AppColors.darkBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065, top: Get.height * 0.02),
                child: AppText(
                  text: "We'll use this to send you important updates and notifications",
                  fontSize: Get.width * 0.035,
                  textcolor: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: Get.height * 0.04),

              // Email Field
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065,
                    right: Get.width * 0.065),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: "Email",
                      fontSize: Get.width * 0.04,
                      textcolor: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: emailCon,
                      cursorColor: Colors.grey,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        _validateEmail();
                        if (isEmailValid) {
                          _checkEmailAvailability();
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _getEmailBorderColor()),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _getEmailBorderColor(), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _getEmailBorderColor()),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        hintText: "Enter your email address",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade400),
                        suffixIcon: isCheckingEmail 
                          ? Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.themeColor),
                                ),
                              ),
                            )
                          : isEmailValid && isEmailAvailable
                            ? Icon(Icons.check_circle, color: Colors.green, size: 24)
                            : isEmailValid && !isEmailAvailable && !isCheckingEmail
                              ? Icon(Icons.error, color: Colors.red, size: 24)
                              : null,
                      ),
                    ),
                    if (emailCon.text.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(
                              isEmailValid && isEmailAvailable ? Icons.check_circle : Icons.error,
                              color: isEmailValid && isEmailAvailable ? Colors.green : Colors.red,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: AppText(
                                text: _getEmailValidationMessage(),
                                fontSize: Get.width * 0.032,
                                textcolor: isEmailValid && isEmailAvailable ? Colors.green : Colors.red,
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

              // Email Benefits
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Get.width * 0.065),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                          SizedBox(width: 8),
                          AppText(
                            text: "Why we need your email",
                            fontSize: Get.width * 0.04,
                            textcolor: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      _buildBenefitItem("Account verification and security"),
                      _buildBenefitItem("Important updates about your trades"),
                      _buildBenefitItem("Recovery options if you forget your password"),
                      _buildBenefitItem("Newsletter and promotional offers (optional)"),
                    ],
                  ),
                ),
              ),

              Spacer(),

              Center(
                child: AppButton(
                  onPressed: (isEmailValid && isEmailAvailable && !isCheckingEmail)
                      ? () { _handleContinue(); }
                      : null,
                  isLoading: isLoading,
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

  void _handleContinue() async {
    setState(() {
      isLoading = true;
    });
    try {
      setState(() {
        widget.requestModel.email = emailCon.text.trim();
      });
      Get.to(() => PhoneSignInScreen(requestModel: widget.requestModel,));
    } catch (e) {
      ShowMessage.notify(context, "Something went wrong. Please try again.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.blue.shade400, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: AppText(
              text: text,
              fontSize: Get.width * 0.032,
              textcolor: Colors.blue.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailCon.dispose();
    super.dispose();
  }
}
