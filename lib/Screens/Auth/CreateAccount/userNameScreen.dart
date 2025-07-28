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
  bool isUsernameValid = false;
  bool isUsernameAvailable = false;
  bool isCheckingUsername = false;

  @override
  void initState() {
    super.initState();
    nameCon.addListener(_validateUsername);
  }

  void _validateUsername() {
    final username = nameCon.text.trim();
    setState(() {
      isUsernameValid = _isValidUsername(username);
      isUsernameAvailable = false; // Reset availability when username changes
    });
  }

  bool _isValidUsername(String username) {
    // Username should be 3-20 characters, alphanumeric and underscores only
    return username.length >= 3 && 
           username.length <= 20 && 
           RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username) &&
           !RegExp(r'^[0-9]').hasMatch(username); // Can't start with number
  }

  Future<void> _checkUsernameAvailability() async {
    if (!isUsernameValid) return;

    setState(() {
      isCheckingUsername = true;
    });

    try {
      String checkUserName = "username=${nameCon.text.trim()}";
      final result = await AuthService.instance.checkUserNameAndEmail(context, checkUserName);
      
      setState(() {
        isCheckingUsername = false;
        isUsernameAvailable = result['success'] == false && result['code'] == 404;
      });
    } catch (e) {
      setState(() {
        isCheckingUsername = false;
      });
    }
  }

  String _getUsernameValidationMessage() {
    final username = nameCon.text.trim();
    if (username.isEmpty) return "Username is required";
    if (username.length < 3) return "Username must be at least 3 characters";
    if (username.length > 20) return "Username must be 20 characters or less";
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) return "Username can only contain letters, numbers, and underscores";
    if (RegExp(r'^[0-9]').hasMatch(username)) return "Username cannot start with a number";
    if (isUsernameValid && !isUsernameAvailable && !isCheckingUsername) return "This username is already taken";
    return "";
  }

  Color _getUsernameBorderColor() {
    if (nameCon.text.isEmpty) return Colors.grey.shade300;
    if (!isUsernameValid) return Colors.red;
    if (isUsernameValid && isUsernameAvailable) return Colors.green;
    if (isUsernameValid && !isUsernameAvailable && !isCheckingUsername) return Colors.red;
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
                  text: "Choose Username",
                  fontSize: Get.width * 0.065,
                  textcolor: AppColors.darkBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065, top: Get.height * 0.02),
                child: AppText(
                  text: "This will be your unique identifier on TapTrade",
                  fontSize: Get.width * 0.035,
                  textcolor: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: Get.height * 0.04),

              // Username Field
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065,
                    right: Get.width * 0.065),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: "Username",
                      fontSize: Get.width * 0.04,
                      textcolor: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: nameCon,
                      cursorColor: Colors.grey,
                      onChanged: (value) {
                        _validateUsername();
                        if (isUsernameValid) {
                          _checkUsernameAvailability();
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _getUsernameBorderColor()),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _getUsernameBorderColor(), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _getUsernameBorderColor()),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        hintText: "Enter your username",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Icon(Icons.person_outline, color: Colors.grey.shade400),
                        suffixIcon: isCheckingUsername 
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
                          : isUsernameValid && isUsernameAvailable
                            ? Icon(Icons.check_circle, color: Colors.green, size: 24)
                            : isUsernameValid && !isUsernameAvailable && !isCheckingUsername
                              ? Icon(Icons.error, color: Colors.red, size: 24)
                              : null,
                      ),
                    ),
                    if (nameCon.text.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(
                              isUsernameValid && isUsernameAvailable ? Icons.check_circle : Icons.error,
                              color: isUsernameValid && isUsernameAvailable ? Colors.green : Colors.red,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: AppText(
                                text: _getUsernameValidationMessage(),
                                fontSize: Get.width * 0.032,
                                textcolor: isUsernameValid && isUsernameAvailable ? Colors.green : Colors.red,
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

              // Username Guidelines
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Get.width * 0.065),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade600, size: 20),
                          SizedBox(width: 8),
                          AppText(
                            text: "Username Guidelines",
                            fontSize: Get.width * 0.04,
                            textcolor: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      _buildGuidelineItem("3-20 characters long"),
                      _buildGuidelineItem("Letters, numbers, and underscores only"),
                      _buildGuidelineItem("Cannot start with a number"),
                      _buildGuidelineItem("Must be unique"),
                      _buildGuidelineItem("Cannot be changed later"),
                    ],
                  ),
                ),
              ),

              SizedBox(height: Get.height * 0.04),

              // Username Preview
              if (isUsernameValid && isUsernameAvailable)
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
                            text: "Your profile will be: @${nameCon.text.trim()}",
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
                  onPressed: (isUsernameValid && isUsernameAvailable && !isCheckingUsername)
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
        requestModel.username = nameCon.text.trim();
      });
      Get.to(() => PasswordScreen(requestModel: requestModel));
    } catch (e) {
      ShowMessage.notify(context, "Something went wrong. Please try again.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.orange.shade400, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: AppText(
              text: text,
              fontSize: Get.width * 0.032,
              textcolor: Colors.orange.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameCon.dispose();
    super.dispose();
  }
}
