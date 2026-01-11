import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Screens/Auth/CreateAccount/enterPhoneNumber.dart';
import 'package:taptrade/Services/IntegrationServices/firebaseEmailAuthService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';

class VerifyEmailOtpScreen extends StatefulWidget {
  final SignUpRequestModel requestModel;
  final String email;
  final UserCredential? userCredential; // Firebase user credential

  const VerifyEmailOtpScreen({
    Key? key,
    required this.requestModel,
    required this.email,
    this.userCredential,
  }) : super(key: key);

  @override
  State<VerifyEmailOtpScreen> createState() => _VerifyEmailOtpScreenState();
}

class _VerifyEmailOtpScreenState extends State<VerifyEmailOtpScreen> {
  bool isLoading = false;
  bool isChecking = false;
  int _resendSeconds = 60;
  Timer? _resendTimer;
  Timer? _checkTimer;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _startAutoCheck();
    
    // Debug: Print auth state
    FirebaseEmailAuthService.instance.debugAuthState();
    
    // Show initial message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _statusMessage = 'Check your email inbox (and spam folder) for the verification link.';
      });
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _checkTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() {
          _resendSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  // Automatically check if email is verified every 3 seconds
  void _startAutoCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      final isVerified = await FirebaseEmailAuthService.instance.isEmailVerified();
      if (isVerified) {
        timer.cancel();
        _onEmailVerified();
      }
    });
  }

  void _onEmailVerified() {
    ShowMessage.notify(context, 'Email verified successfully!');
    
    // Update request model
    widget.requestModel.email = widget.email;
    
    // Navigate to phone number entry screen
    Get.off(() => EnterPhoneNumberScreen(requestModel: widget.requestModel));
  }

  Future<void> _checkVerification() async {
    setState(() {
      isChecking = true;
      _statusMessage = 'Checking verification status...';
    });

    final isVerified = await FirebaseEmailAuthService.instance.isEmailVerified();

    setState(() {
      isChecking = false;
    });

    if (isVerified) {
      _onEmailVerified();
    } else {
      setState(() {
        _statusMessage = 'Email not verified yet. Please check your inbox and click the verification link.';
      });
      ShowMessage.notify(context, 'Please click the link in your email to verify');
    }
  }

  Future<void> _resendEmail() async {
    if (_resendSeconds > 0) return;

    setState(() {
      isLoading = true;
    });

    final success = await FirebaseEmailAuthService.instance.resendVerificationEmail(context);

    setState(() {
      isLoading = false;
    });

    if (success) {
      _startResendTimer();
      ShowMessage.notify(context, 'Verification email sent to ${widget.email}');
      setState(() {
        _statusMessage = 'Verification email sent! Check your inbox.';
      });
    }
  }

  Future<void> _openEmailApp() async {
    // Try to open email app
    ShowMessage.notify(context, 'Please open your email app to verify');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Get.width * 0.065),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Get.height * 0.02),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.grey,
                    size: 29,
                  ),
                ),
                SizedBox(height: Get.height * 0.05),
                Center(
                  child: Icon(
                    Icons.mark_email_unread_outlined,
                    size: Get.width * 0.25,
                    color: AppColors.themeColor,
                  ),
                ),
                SizedBox(height: Get.height * 0.03),
                Center(
                  child: AppText(
                    text: "Verify Your Email",
                    fontSize: Get.width * 0.07,
                    textcolor: AppColors.darkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Get.height * 0.02),
                Center(
                  child: AppText(
                    text: "We've sent a verification link to",
                    fontSize: Get.width * 0.035,
                    textcolor: Colors.grey,
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: Get.height * 0.01),
                Center(
                  child: AppText(
                    text: widget.email,
                    fontSize: Get.width * 0.04,
                    textcolor: AppColors.themeColor,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: Get.height * 0.02),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Click the link in your email to verify.\nThis page will automatically detect when you\'ve verified.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_statusMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        _statusMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: Get.height * 0.04),
                Center(
                  child: AppButton(
                    onPressed: isChecking ? () {} : _checkVerification,
                    isLoading: isChecking,
                    text: "I'VE VERIFIED MY EMAIL",
                    fontSize: Get.width * 0.04,
                    width: Get.width * 0.88,
                  ),
                ),
                SizedBox(height: Get.height * 0.02),
                Center(
                  child: GestureDetector(
                    onTap: _openEmailApp,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.themeColor),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.email_outlined, color: AppColors.themeColor),
                          const SizedBox(width: 8),
                          AppText(
                            text: "Open Email App",
                            textcolor: AppColors.themeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Get.height * 0.04),
                Center(
                  child: GestureDetector(
                    onTap: _resendSeconds == 0 && !isLoading ? _resendEmail : null,
                    child: isLoading
                        ? const CircularProgressIndicator(color: AppColors.themeColor)
                        : RichText(
                            text: TextSpan(
                              text: "Didn't receive the email? ",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: Get.width * 0.035,
                              ),
                              children: [
                                TextSpan(
                                  text: _resendSeconds > 0
                                      ? "Resend in ${_resendSeconds}s"
                                      : "Resend",
                                  style: TextStyle(
                                    color: _resendSeconds > 0
                                        ? Colors.grey
                                        : AppColors.themeColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                SizedBox(height: Get.height * 0.02),
                Center(
                  child: AppText(
                    text: "Check your spam folder if you don't see the email",
                    fontSize: Get.width * 0.03,
                    textcolor: Colors.grey,
                    fontWeight: FontWeight.w400,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
