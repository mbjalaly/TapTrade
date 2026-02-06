import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Screens/Auth/ForgetPassword/resetPassword.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
import 'package:taptrade/Services/logService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/Auth/auth_scaffold.dart';
import 'package:pinput/pinput.dart';
import 'package:taptrade/l10n/app_localizations.dart';

class VerifyResetOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const VerifyResetOtpScreen({
    Key? key,
    required this.phoneNumber,
    required this.verificationId,
  }) : super(key: key);

  @override
  State<VerifyResetOtpScreen> createState() => _VerifyResetOtpScreenState();
}

class _VerifyResetOtpScreenState extends State<VerifyResetOtpScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  int _resendSeconds = 60; // 60 seconds cooldown
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

    if (minutes > 0) {
      return AppLocalizations.of(context)?.resendCodeIn('${minutes}m ${seconds}') ?? 'Resend in ${minutes}m ${seconds}s';
    } else {
      return AppLocalizations.of(context)?.resendCodeIn('${seconds}') ?? 'Resend in ${seconds}s';
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

    printLog('[VerifyResetOtp] Verifying password reset OTP');

    try {
      final result = await AuthService.instance.verifyPasswordResetOtp(
        context,
        widget.phoneNumber,
        code,
        widget.verificationId,
      );

      setState(() => isLoading = false);

      if (result.status == Status.COMPLETED && result.responseData['success'] == true) {
        final resetToken = result.responseData['reset_token'];
        printLog('[VerifyResetOtp] OTP verified, reset token received');

        // Navigate to reset password screen
        final success = await Get.to(
          () => ResetPasswordScreen(
            resetToken: resetToken,
          ),
          transition: Transition.rightToLeft,
        );

        // If password was reset successfully, return to login
        if (success == true) {
          // Return true to indicate success (will trigger navigation to login in ForgetPasswordScreen)
          Get.back(result: true);
        }
      } else {
        setState(() {
          otpError = result.responseData['message'] ?? AppLocalizations.of(context)?.otpError ?? 'Invalid code. Please try again.';
        });
      }
    } catch (e) {
      printLog('[VerifyResetOtp] Error: $e');
      setState(() {
        isLoading = false;
        otpError = AppLocalizations.of(context)?.errorTryAgainLater ?? 'An error occurred. Please try again.';
      });
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0 || isLoading) return;

    setState(() => isLoading = true);

    printLog('[VerifyResetOtp] Resending password reset OTP');

    try {
      final result = await AuthService.instance.sendPasswordResetOtp(
        context,
        widget.phoneNumber,
      );

      setState(() => isLoading = false);

      if (result.status == Status.COMPLETED && result.responseData['success'] == true) {
        _startResendTimer();
        ShowMessage.notify(context, AppLocalizations.of(context)?.verificationCodeSentTo(widget.phoneNumber) ?? 'Verification code sent');
        otpController.clear();
        _clearError();
      } else {
        ShowMessage.inDialog(
          context,
          result.responseData['message'] ?? 'Failed to resend code',
          true,
        );
      }
    } catch (e) {
      printLog('[VerifyResetOtp] Resend error: $e');
      setState(() => isLoading = false);
      ShowMessage.inDialog(
        context,
        'Failed to resend code. Please try again.',
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
        color: AppColors.fieldBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: otpError != null ? AppColors.errorColor : AppColors.outlineColor(context),
          width: 1,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(
          color: otpError != null ? AppColors.errorColor : AppColors.primaryColor,
          width: 2,
        ),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(
          color: AppColors.errorColor,
          width: 1,
        ),
      ),
    );

    return AuthScaffold(
      showBackButton: true,
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

          // Phone number display
          Text(
            AppLocalizations.of(context)?.weSentCodeTo ?? 'We sent a code to',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondaryText(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.phoneNumber,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText(context),
            ),
          ),

          const SizedBox(height: 40),

          // OTP input card
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)?.enterVerificationCode ?? 'Enter verification code',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 16),

                // Pinput OTP input
                Center(
                  child: Pinput(
                    controller: otpController,
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    errorPinTheme: errorPinTheme,
                    autofocus: true,
                    onChanged: (_) => _clearError(),
                    onCompleted: (_) => _verifyOtp(),
                  ),
                ),

                // Error message
                if (otpError != null) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      otpError!,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.errorColor,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                AuthPrimaryButton(
                  text: AppLocalizations.of(context)?.verifyYourPhone ?? 'Verify Code',
                  isLoading: isLoading,
                  onPressed: _verifyOtp,
                ),

                const SizedBox(height: 16),

                // Resend button
                Center(
                  child: TextButton(
                    onPressed: _resendSeconds <= 0 && !isLoading ? _resendOtp : null,
                    child: Text(
                      _formatResendTime(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _resendSeconds <= 0
                            ? AppColors.primaryColor
                            : AppColors.hintText(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
