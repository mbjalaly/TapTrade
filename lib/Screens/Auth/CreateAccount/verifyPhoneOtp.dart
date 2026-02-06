import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Screens/UserDetail/AddInterest/addInterest.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
import 'package:taptrade/Services/IntegrationServices/unoSendSmsService.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Services/logService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/Auth/auth_scaffold.dart';
import 'package:pinput/pinput.dart';
import 'package:taptrade/l10n/app_localizations.dart';

class VerifyPhoneOtpScreen extends StatefulWidget {
  final SignUpRequestModel requestModel;
  final String phoneNumber;
  final String? verificationId;

  const VerifyPhoneOtpScreen({
    Key? key,
    required this.requestModel,
    required this.phoneNumber,
    this.verificationId,
  }) : super(key: key);

  @override
  State<VerifyPhoneOtpScreen> createState() => _VerifyPhoneOtpScreenState();
}

class _VerifyPhoneOtpScreenState extends State<VerifyPhoneOtpScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  int _resendSeconds = 60;
  Timer? _resendTimer;
  String? otpError;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;  // 60 seconds cooldown
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  void _clearError() {
    if (otpError != null) {
      setState(() => otpError = null);
    }
  }

  String _formatResendTime() {
    if (_resendSeconds <= 0) return AppLocalizations.of(context)?.resendCode ?? 'Resend Code';

    final minutes = _resendSeconds ~/ 60;
    final seconds = _resendSeconds % 60;

    String timeStr;
    if (minutes > 0) {
      timeStr = '${minutes}m ${seconds}';
    } else {
      timeStr = '${seconds}';
    }
    return AppLocalizations.of(context)?.resendCodeIn(timeStr) ?? 'Resend in $timeStr';
  }

  Future<void> _verifyOtp() async {
    final code = otpController.text.trim();

    if (code.length != 6) {
      setState(() => otpError = AppLocalizations.of(context)?.pleaseEnterValid6DigitOtp ?? 'Please enter the 6-digit code');
      return;
    }

    setState(() {
      isLoading = true;
      otpError = null;
    });

    printLog('[VerifyPhoneOtp] Verifying OTP via UnoSend');

    final result = await UnoSendSmsService.instance.verifyOtp(
      phoneNumber: widget.phoneNumber,
      code: code,
      context: context,
    );

    if (result['success'] == true && result['phone_verified'] == true) {
      printLog('[VerifyPhoneOtp] Verification successful');
      await _completeRegistration();
    } else {
      setState(() {
        isLoading = false;
        otpError = result['message'] ?? 'Invalid code. Please try again.';
      });
    }
  }

  Future<void> _completeRegistration() async {
    try {
      printLog('[VerifyPhoneOtp] Completing registration');

      // Prepare registration data
      final requestData = widget.requestModel.toJson();
      requestData['phone_verified'] = true;
      requestData['email_verified'] = false;
      requestData['contact'] = widget.phoneNumber; // Full format like +966555555555 - backend will parse it

      // Remove email if empty
      if (requestData['email'] == null || requestData['email'].toString().isEmpty) {
        requestData.remove('email');
      }

      printLog('[VerifyPhoneOtp] Registration data: $requestData');

      // Call registration API
      final result = await AuthService.instance.signUp(context, requestData);

      setState(() => isLoading = false);

      if (result.status == Status.COMPLETED) {
        printLog('[VerifyPhoneOtp] Registration successful');

        // Extract data from response
        final responseData = result.responseData;
        final token = responseData['token'];
        final userData = responseData['data'];

        if (token != null) {
          // Save token
          await SharedPreferencesService().setString(
            KeyConstants.accessToken,
            token,
          );

          // Save user ID
          if (userData != null && userData['id'] != null) {
            await SharedPreferencesService().setString(
              KeyConstants.userId,
              userData['id'].toString(),
            );
          }

          printLog('[VerifyPhoneOtp] Token saved, navigating to AddInterest');

          // Show success message
          ShowMessage.notify(context, 'Account created successfully!');

          // Navigate to AddInterest screen
          Get.offAll(() => const AddInterestScreen());
        } else {
          ShowMessage.inDialog(
            context,
            'Registration successful but no token received. Please try logging in.',
            true,
          );
        }
      } else {
        setState(() {
          otpError = result.message ?? 'Registration failed. Please try again.';
        });
      }
    } catch (e) {
      printLog('[VerifyPhoneOtp] Registration error: $e');
      setState(() {
        isLoading = false;
        otpError = 'Registration failed. Please try again.';
      });
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0 || isLoading) return;

    setState(() => isLoading = true);

    printLog('[VerifyPhoneOtp] Resending OTP via UnoSend');

    final result = await UnoSendSmsService.instance.sendOtp(
      phoneNumber: widget.phoneNumber,
      context: context,
    );

    setState(() => isLoading = false);

    if (result['success'] == true) {
      _startResendTimer();
      ShowMessage.notify(context, AppLocalizations.of(context)?.verificationCodeSentTo(widget.phoneNumber) ?? 'Verification code sent');
    } else {
      ShowMessage.inDialog(
        context,
        result['message'] ?? 'Failed to resend code',
        true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.contentBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: otpError != null
              ? Colors.red.withOpacity(0.5)
              : AppColors.primaryColor.withOpacity(0.3),
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.contentBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    return AuthScaffold(
      showBackButton: true,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Phone icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.phone_android_rounded,
                size: 50,
                color: AppColors.primaryColor,
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              AppLocalizations.of(context)?.verifyYourPhone ?? 'Verify your phone',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText(context),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              AppLocalizations.of(context)?.verificationCodeSentTo(widget.phoneNumber) ?? 'Enter the 6-digit code sent to',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.secondaryText(context),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '', // Phone number included in message above
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),

            const SizedBox(height: 40),

            // OTP Input
            Pinput(
              controller: otpController,
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              onChanged: (_) => _clearError(),
              onCompleted: (_) => _verifyOtp(),
              errorText: otpError,
              errorTextStyle: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),

            if (otpError != null) ...[
              const SizedBox(height: 12),
              Text(
                otpError!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 32),

            // Verify button
            AuthPrimaryButton(
              text: AppLocalizations.of(context)?.verifyYourPhone ?? 'Verify Code',
              isLoading: isLoading,
              onPressed: _verifyOtp,
            ),

            const SizedBox(height: 32),

            // Resend section
            GestureDetector(
              onTap: _resendSeconds == 0 && !isLoading ? _resendOtp : null,
              child: RichText(
                text: TextSpan(
                  text: "Didn't receive the code? ",
                  style: TextStyle(
                    color: AppColors.secondaryText(context),
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: _formatResendTime(),
                      style: TextStyle(
                        color: _resendSeconds > 0
                            ? AppColors.hintText(context)
                            : AppColors.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
