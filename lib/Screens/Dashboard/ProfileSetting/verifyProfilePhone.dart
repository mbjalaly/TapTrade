import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Services/IntegrationServices/unoSendSmsService.dart';
import 'package:taptrade/Services/logService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:pinput/pinput.dart';
import 'package:taptrade/l10n/app_localizations.dart';

/// Simplified phone verification screen for profile updates
/// Only verifies phone and updates phone_verified status
class VerifyProfilePhoneScreen extends StatefulWidget {
  final String phoneNumber;

  const VerifyProfilePhoneScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<VerifyProfilePhoneScreen> createState() => _VerifyProfilePhoneScreenState();
}

class _VerifyProfilePhoneScreenState extends State<VerifyProfilePhoneScreen> {
  final TextEditingController otpController = TextEditingController();
  final userController = Get.find<UserController>();
  bool isLoading = false;
  int _resendSeconds = 60; // 60 seconds cooldown
  Timer? _resendTimer;
  String? otpError;

  @override
  void initState() {
    super.initState();
    _sendInitialOtp();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60; // 60 seconds cooldown
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

  Future<void> _sendInitialOtp() async {
    setState(() => isLoading = true);

    printLog('[VerifyProfilePhone] Sending initial OTP to ${widget.phoneNumber}');

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
        result['message'] ?? 'Failed to send verification code',
        true,
      );
    }
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

    printLog('[VerifyProfilePhone] Verifying OTP');

    final result = await UnoSendSmsService.instance.verifyOtp(
      phoneNumber: widget.phoneNumber,
      code: code,
      context: context,
    );

    if (result['success'] == true && result['phone_verified'] == true) {
      printLog('[VerifyProfilePhone] Verification successful');
      await _updatePhoneVerifiedStatus();
    } else {
      setState(() {
        isLoading = false;
        otpError = result['message'] ?? 'Invalid code. Please try again.';
      });
    }
  }

  Future<void> _updatePhoneVerifiedStatus() async {
    try {
      printLog('[VerifyProfilePhone] Updating phone_verified status');

      // Get current user ID
      String userId = userController.userProfile.value.data?.id ?? '';

      if (userId.isEmpty) {
        setState(() {
          isLoading = false;
          otpError = 'User ID not found. Please try again.';
        });
        return;
      }

      // Update profile with phone_verified: true
      Map<String, dynamic> body = {
        'contact': widget.phoneNumber,
        'phone_verified': true,
      };

      final result = await ProfileService.instance.updateProfile(
        context,
        body,
        userId,
      );

      setState(() => isLoading = false);

      if (result.status == Status.COMPLETED) {
        printLog('[VerifyProfilePhone] Phone verification status updated');

        // Refresh profile to get updated data
        await ProfileService.instance.getProfile(context);

        // Show success message
        ShowMessage.notify(context, AppLocalizations.of(context)?.phoneVerifiedAuto ?? 'Phone number verified successfully!');

        // Navigate back to profile screen
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        setState(() {
          otpError = result.message ?? 'Failed to update verification status. Please try again.';
        });
      }
    } catch (e) {
      printLog('[VerifyProfilePhone] Error updating phone_verified: $e');
      setState(() {
        isLoading = false;
        otpError = 'Failed to update verification status. Please try again.';
      });
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0 || isLoading) return;

    setState(() => isLoading = true);

    printLog('[VerifyProfilePhone] Resending OTP');

    final result = await UnoSendSmsService.instance.sendOtp(
      phoneNumber: widget.phoneNumber,
      context: context,
    );

    setState(() => isLoading = false);

    if (result['success'] == true) {
      _startResendTimer();
      ShowMessage.notify(context, 'Verification code sent');
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
        color: AppColors.darkBlue,
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

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)?.verifyYourPhone ?? 'Verify Phone',
          style: TextStyle(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
                color: AppColors.darkBlue,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              AppLocalizations.of(context)?.verificationCodeSentTo(widget.phoneNumber) ?? 'Enter the 6-digit code sent to',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.darkBlue.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '', // Phone number is already included in the localized message above
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
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)?.verifyYourPhone ?? 'Verify Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 32),

            // Resend section
            GestureDetector(
              onTap: _resendSeconds == 0 && !isLoading ? _resendOtp : null,
              child: RichText(
                text: TextSpan(
                  text: "Didn't receive the code? ",
                  style: TextStyle(
                    color: AppColors.darkBlue.withOpacity(0.6),
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: _formatResendTime(),
                      style: TextStyle(
                        color: _resendSeconds > 0
                            ? AppColors.darkBlue.withOpacity(0.4)
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
