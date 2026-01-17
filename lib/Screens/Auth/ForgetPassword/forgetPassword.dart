import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/Auth/auth_scaffold.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String? emailError;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (emailError != null) {
      setState(() => emailError = null);
    }
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> _handleResetPassword() async {
    final validation = _validateEmail(emailController.text.trim());
    if (validation != null) {
      setState(() => emailError = validation);
      return;
    }

    setState(() {
      isLoading = true;
      emailError = null;
    });

    try {
      Map<String, dynamic> body = {
        "email": emailController.text.trim(),
      };

      final result = await AuthService.instance.forgetPassword(context, body);

      if (result.status == Status.COMPLETED &&
          (result.responseData['success'] ?? false)) {
        ShowMessage.notify(context, result.responseData['message']);
        setState(() {
          isLoading = false;
          emailController.clear();
        });
      } else {
        setState(() {
          isLoading = false;
          emailError = result.responseData['message'] ?? 'Email not found';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        emailError = 'An error occurred. Please try again.';
      });
      debugPrint("Forgot Password Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Lock icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_reset_rounded,
              size: 50,
              color: AppColors.primaryColor,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            'Forgot password?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlue,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'No worries! Enter your email and we\'ll send you a reset link.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.darkBlue.withOpacity(0.6),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Email input card
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthTextField(
                  controller: emailController,
                  label: 'Email Address',
                  hint: 'example@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  errorText: emailError,
                  onChanged: (_) => _clearError(),
                ),

                const SizedBox(height: 32),

                AuthPrimaryButton(
                  text: 'Send Reset Link',
                  isLoading: isLoading,
                  onPressed: _handleResetPassword,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Back to login
          GestureDetector(
            onTap: () => Get.back(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: AppColors.darkBlue.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Back to Sign In',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue.withOpacity(0.6),
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
