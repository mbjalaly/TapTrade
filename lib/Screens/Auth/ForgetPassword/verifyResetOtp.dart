import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Screens/Auth/ForgetPassword/resetPassword.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
import 'package:taptrade/Services/IntegrationServices/firebasePhoneAuthService.dart';
import 'package:taptrade/Services/logService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/Auth/auth_scaffold.dart';
import 'package:pinput/pinput.dart';
import 'package:taptrade/l10n/app_localizations.dart';

class VerifyResetOtpScreen extends StatefulWidget {
  final String phoneNumber;

  const VerifyResetOtpScreen({
    Key? key,
    required this.phoneNumber,
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

  // Firebase verification ID (set when the SMS is sent)
  String? _verificationId;

  // Guard so auto-verification and manual entry can't both complete the flow
  bool _flowCompleted = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Send the SMS via Firebase as soon as the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendFirebaseOtp());
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  Future<void> _sendFirebaseOtp() async {
    printLog('[VerifyResetOtp] Sending Firebase OTP to ${widget.phoneNumber}');
    await FirebasePhoneAuthService.instance.sendOtp(
      phoneNumber: widget.phoneNumber,
      context: context,
      onCodeSent: (String verificationId) {
        printLog('[VerifyResetOtp] Firebase code sent');
        if (!mounted) return;
        setState(() => _verificationId = verificationId);
      },
      onAutoVerify: (PhoneAuthCredential credential) {
        _handleAutoVerify(credential);
      },
      onError: (String error) {
        printLog('[VerifyResetOtp] Firebase send error: $error');
        if (!mounted) return;
        setState(() {
          isLoading = false;
          otpError = error;
        });
      },
    );
  }

  void _startResendTimer() {
    _resendSeconds = 60; // 60 seconds cooldown
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
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

  /// Android may verify the SMS automatically without user input
  Future<void> _handleAutoVerify(PhoneAuthCredential credential) async {
    if (_flowCompleted) return;
    printLog('[VerifyResetOtp] Auto-verification triggered');

    setState(() => isLoading = true);

    final userCredential = await FirebasePhoneAuthService.instance
        .signInWithCredential(credential, context);

    if (userCredential == null) {
      if (!mounted) return;
      setState(() => isLoading = false);
      return;
    }

    await _exchangeForResetToken(userCredential);
  }

  Future<void> _verifyOtp() async {
    if (_flowCompleted) return;

    final code = otpController.text.trim();

    if (code.length != 6) {
      setState(() => otpError = AppLocalizations.of(context)?.pleaseEnterValid6DigitOtp ?? 'Please enter the 6-digit code');
      return;
    }

    if (_verificationId == null) {
      setState(() => otpError = 'Still sending the code. Please wait a moment and try again.');
      return;
    }

    setState(() {
      isLoading = true;
      otpError = null;
    });

    printLog('[VerifyResetOtp] Verifying OTP with Firebase');

    try {
      // Step 1: Verify the code with Firebase
      final userCredential = await FirebasePhoneAuthService.instance.verifyOtp(
        otp: code,
        context: context,
        verificationId: _verificationId,
      );

      if (userCredential == null) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          otpError = AppLocalizations.of(context)?.otpError ?? 'Invalid code. Please try again.';
        });
        return;
      }

      // Step 2: Exchange the Firebase proof for a backend reset token
      await _exchangeForResetToken(userCredential);
    } catch (e) {
      printLog('[VerifyResetOtp] Error: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        otpError = AppLocalizations.of(context)?.errorTryAgainLater ?? 'An error occurred. Please try again.';
      });
    }
  }

  Future<void> _exchangeForResetToken(UserCredential userCredential) async {
    try {
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          otpError = AppLocalizations.of(context)?.errorTryAgainLater ?? 'An error occurred. Please try again.';
        });
        return;
      }

      final result = await AuthService.instance.verifyPasswordResetOtp(
        context,
        widget.phoneNumber,
        idToken,
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      if (result.status == Status.COMPLETED && result.responseData['success'] == true) {
        _flowCompleted = true;
        final resetToken = result.responseData['reset_token'];
        printLog('[VerifyResetOtp] Verified, reset token received');

        // Clean up the temporary Firebase session
        try {
          await FirebasePhoneAuthService.instance.signOut();
        } catch (_) {}

        // Navigate to reset password screen
        final success = await Get.to(
              () => ResetPasswordScreen(
            resetToken: resetToken,
          ),
          transition: Transition.rightToLeft,
        );

        // If password was reset successfully, return to login
        if (success == true) {
          Get.back(result: true);
        } else {
          // Allow retrying if the user backed out of the reset screen
          _flowCompleted = false;
        }
      } else {
        setState(() {
          otpError = result.responseData['message'] ?? AppLocalizations.of(context)?.otpError ?? 'Verification failed. Please try again.';
        });
      }
    } catch (e) {
      printLog('[VerifyResetOtp] Exchange error: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        otpError = AppLocalizations.of(context)?.errorTryAgainLater ?? 'An error occurred. Please try again.';
      });
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0 || isLoading) return;

    setState(() => isLoading = true);

    printLog('[VerifyResetOtp] Resending Firebase OTP');

    try {
      final sent = await FirebasePhoneAuthService.instance.resendOtp(
        phoneNumber: widget.phoneNumber,
        context: context,
        onCodeSent: (String verificationId) {
          if (!mounted) return;
          setState(() => _verificationId = verificationId);
          _startResendTimer();
          ShowMessage.notify(context, AppLocalizations.of(context)?.verificationCodeSentTo(widget.phoneNumber) ?? 'Verification code sent');
          otpController.clear();
          _clearError();
        },
        onAutoVerify: (PhoneAuthCredential credential) {
          _handleAutoVerify(credential);
        },
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      if (!sent) {
        ShowMessage.inDialog(
          context,
          'Failed to resend code. Please try again.',
          true,
        );
      }
    } catch (e) {
      printLog('[VerifyResetOtp] Resend error: $e');
      if (!mounted) return;
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