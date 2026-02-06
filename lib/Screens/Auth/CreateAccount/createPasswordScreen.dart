import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/Auth/auth_scaffold.dart';

import 'createFullName.dart';

class PasswordScreen extends StatefulWidget {
  final SignUpRequestModel requestModel;

  const PasswordScreen({Key? key, required this.requestModel}) : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController passCon = TextEditingController();
  final TextEditingController confirmPassCon = TextEditingController();
  bool obscureText = true;
  bool obscureConfirm = true;
  String? passwordError;
  String? confirmError;

  // Password criteria states
  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;

  @override
  void dispose() {
    passCon.dispose();
    confirmPassCon.dispose();
    super.dispose();
  }

  void _validatePassword(String value) {
    setState(() {
      hasMinLength = value.length >= 8;
      hasUppercase = value.contains(RegExp(r'[A-Z]'));
      hasLowercase = value.contains(RegExp(r'[a-z]'));
      hasNumber = value.contains(RegExp(r'[0-9]'));
      passwordError = null;
      
      // Clear confirm error if passwords now match
      if (confirmPassCon.text.isNotEmpty && confirmPassCon.text == value) {
        confirmError = null;
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isNotEmpty && value != passCon.text) {
        confirmError = AppLocalizations.of(context)?.passwordsDoNotMatch ?? 'Passwords do not match';
      } else {
        confirmError = null;
      }
    });
  }

  bool get isPasswordValid => hasMinLength && hasUppercase && hasLowercase && hasNumber;

  void _handleContinue() {
    // Check if password meets all criteria
    if (!isPasswordValid) {
      setState(() => passwordError = AppLocalizations.of(context)?.pleaseMeetAllRequirements ?? 'Please meet all password requirements');
      return;
    }

    // Check if confirmation is empty
    if (confirmPassCon.text.isEmpty) {
      setState(() => confirmError = AppLocalizations.of(context)?.pleaseConfirmPassword ?? 'Please confirm your password');
      return;
    }

    // Check if passwords match
    if (passCon.text != confirmPassCon.text) {
      setState(() => confirmError = AppLocalizations.of(context)?.passwordsDoNotMatch ?? 'Passwords do not match');
      return;
    }

    widget.requestModel.password = passCon.text;
    widget.requestModel.password2 = confirmPassCon.text;
    Get.to(() => FullNameScreen(requestModel: widget.requestModel));
  }

  Widget _buildCriteriaItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 18,
            color: isMet ? AppColors.successColor : AppColors.hintText(context),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isMet ? AppColors.successColor : AppColors.secondaryText(context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      showProgress: true,
      currentStep: 2,
      totalSteps: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          // Title
          Text(
            AppLocalizations.of(context)?.createPasswordTitle ?? 'Create a password',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText(context),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            AppLocalizations.of(context)?.makeItStrong ?? 'Make it strong and secure.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondaryText(context),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // Password input card
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Password field
                AuthTextField(
                  controller: passCon,
                  label: AppLocalizations.of(context)?.password ?? 'Password',
                  hint: AppLocalizations.of(context)?.enterPassword ?? 'Enter your password',
                  obscureText: obscureText,
                  autofocus: true,
                  errorText: passwordError,
                  onChanged: _validatePassword,
                  onToggleObscure: () {
                    setState(() => obscureText = !obscureText);
                  },
                ),

                const SizedBox(height: 16),

                // Password criteria
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariantColor(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.passwordMustContain ?? 'Password must contain:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText(context),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildCriteriaItem(AppLocalizations.of(context)?.atLeast8Characters ?? 'At least 8 characters', hasMinLength),
                      _buildCriteriaItem(AppLocalizations.of(context)?.oneUppercaseLetter ?? 'One uppercase letter (A-Z)', hasUppercase),
                      _buildCriteriaItem(AppLocalizations.of(context)?.oneLowercaseLetter ?? 'One lowercase letter (a-z)', hasLowercase),
                      _buildCriteriaItem(AppLocalizations.of(context)?.oneNumber ?? 'One number (0-9)', hasNumber),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Confirm password field
                AuthTextField(
                  controller: confirmPassCon,
                  label: AppLocalizations.of(context)?.confirmPassword ?? 'Confirm Password',
                  hint: AppLocalizations.of(context)?.reEnterPassword ?? 'Re-enter your password',
                  obscureText: obscureConfirm,
                  errorText: confirmError,
                  onChanged: _validateConfirmPassword,
                  onToggleObscure: () {
                    setState(() => obscureConfirm = !obscureConfirm);
                  },
                ),

                const SizedBox(height: 32),

                AuthPrimaryButton(
                  text: AppLocalizations.of(context)?.continue_ ?? 'Continue',
                  onPressed: _handleContinue,
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
