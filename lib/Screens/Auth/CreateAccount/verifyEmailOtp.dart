import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Screens/Auth/CreateAccount/enterPhoneNumber.dart';
import 'package:taptrade/Services/IntegrationServices/firebaseEmailAuthService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/Auth/auth_scaffold.dart';

class VerifyEmailOtpScreen extends StatefulWidget {
  final SignUpRequestModel requestModel;
  final String email;
  final UserCredential? userCredential;

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

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _startAutoCheck();
    FirebaseEmailAuthService.instance.debugAuthState();
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
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  void _startAutoCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final isVerified =
          await FirebaseEmailAuthService.instance.isEmailVerified();
      if (isVerified) {
        timer.cancel();
        _onEmailVerified();
      }
    });
  }

  void _onEmailVerified() {
    ShowMessage.notify(context, 'Email verified successfully!');
    widget.requestModel.email = widget.email;
    Get.off(() => EnterPhoneNumberScreen(requestModel: widget.requestModel));
  }

  Future<void> _checkVerification() async {
    setState(() => isChecking = true);

    final isVerified =
        await FirebaseEmailAuthService.instance.isEmailVerified();

    setState(() => isChecking = false);

    if (isVerified) {
      _onEmailVerified();
    } else {
      ShowMessage.notify(
          context, 'Please click the link in your email to verify');
    }
  }

  Future<void> _resendEmail() async {
    if (_resendSeconds > 0) return;

    setState(() => isLoading = true);

    final success =
        await FirebaseEmailAuthService.instance.resendVerificationEmail(context);

    setState(() => isLoading = false);

    if (success) {
      _startResendTimer();
      ShowMessage.notify(
          context, 'Verification email sent to ${widget.email}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Email icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mark_email_unread_outlined,
              size: 50,
              color: AppColors.primaryColor,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            'Verify your email',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlue,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'We\'ve sent a verification link to',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.darkBlue.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.email,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),

          const SizedBox(height: 32),

          // Info card
          AuthCard(
            child: Column(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.darkBlue.withOpacity(0.6),
                  size: 28,
                ),
                const SizedBox(height: 12),
                Text(
                  'Click the link in your email to verify.\nThis page will automatically detect when you\'re done.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.darkBlue.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Verify button
          AuthPrimaryButton(
            text: 'I\'ve Verified My Email',
            isLoading: isChecking,
            onPressed: _checkVerification,
          ),

          const SizedBox(height: 16),

          // Open email app button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => ShowMessage.notify(
                  context, 'Please open your email app to verify'),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.darkBlue.withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: AppColors.darkBlue.withOpacity(0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Open Email App',
                      style: TextStyle(
                        color: AppColors.darkBlue.withOpacity(0.7),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Resend section
          GestureDetector(
            onTap: _resendSeconds == 0 && !isLoading ? _resendEmail : null,
            child: isLoading
                ? CircularProgressIndicator(
                    color: AppColors.primaryColor,
                    strokeWidth: 2,
                  )
                : RichText(
                    text: TextSpan(
                      text: "Didn't receive the email? ",
                      style: TextStyle(
                        color: AppColors.darkBlue.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: _resendSeconds > 0
                              ? 'Resend in ${_resendSeconds}s'
                              : 'Resend',
                          style: TextStyle(
                            color: _resendSeconds > 0
                                ? AppColors.darkBlue.withOpacity(0.4)
                                : AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          const SizedBox(height: 12),

          Text(
            'Check your spam folder if you don\'t see it',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.darkBlue.withOpacity(0.4),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
