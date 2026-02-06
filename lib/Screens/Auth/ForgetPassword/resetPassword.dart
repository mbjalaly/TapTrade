import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
import 'package:taptrade/Services/logService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/Auth/auth_scaffold.dart';
import 'package:taptrade/l10n/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String resetToken;

  const ResetPasswordScreen({
    Key? key,
    required this.resetToken,
  }) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  String? passwordError;

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (passwordError != null) {
      setState(() => passwordError = null);
    }
  }

  String? _validatePassword() {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword.isEmpty) {
      return AppLocalizations.of(context)?.pleaseEnterNewPassword ?? 'Please enter a new password';
    }

    if (newPassword.length < 6) {
      return AppLocalizations.of(context)?.passwordMinLength ?? 'Password must be at least 6 characters';
    }

    if (confirmPassword.isEmpty) {
      return AppLocalizations.of(context)?.pleaseConfirmPassword ?? 'Please confirm your password';
    }

    if (newPassword != confirmPassword) {
      return AppLocalizations.of(context)?.passwordsDoNotMatch ?? 'Passwords do not match';
    }

    return null;
  }

  // Calculate password strength (0-3)
  int _getPasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;

    // Length check
    if (password.length >= 8) strength++;

    // Has uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength++;

    // Has number or special char
    if (password.contains(RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength;
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return AppColors.errorColor;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return AppColors.outlineColor(context);
    }
  }

  String _getStrengthText(int strength, AppLocalizations l10n) {
    switch (strength) {
      case 0:
        return l10n.tooWeak;
      case 1:
        return l10n.weak;
      case 2:
        return l10n.good;
      case 3:
        return l10n.strong;
      default:
        return '';
    }
  }

  Future<void> _resetPassword() async {
    final validation = _validatePassword();
    if (validation != null) {
      setState(() => passwordError = validation);
      return;
    }

    setState(() {
      isLoading = true;
      passwordError = null;
    });

    printLog('[ResetPassword] Resetting password with token');

    try {
      final result = await AuthService.instance.resetPassword(
        context,
        widget.resetToken,
        newPasswordController.text,
      );

      setState(() => isLoading = false);

      if (result.status == Status.COMPLETED && result.responseData['success'] == true) {
        printLog('[ResetPassword] Password reset successfully');

        // Show success message
        ShowMessage.notify(context, AppLocalizations.of(context)?.passwordResetSuccessfully ?? 'Password reset successfully!');

        // Return true to indicate success
        Get.back(result: true);
      } else {
        setState(() {
          passwordError = result.responseData['message'] ?? (AppLocalizations.of(context)?.failedToResetPassword ?? 'Failed to reset password. Please try again.');
        });
      }
    } catch (e) {
      printLog('[ResetPassword] Error: $e');
      setState(() {
        isLoading = false;
        passwordError = AppLocalizations.of(context)?.errorOccurredTryAgain ?? 'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final strength = _getPasswordStrength(newPasswordController.text);

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
              Icons.lock_outline_rounded,
              size: 50,
              color: AppColors.primaryColor,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            l10n.createNewPasswordTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText(context),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            l10n.passwordDifferentFromPrevious,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondaryText(context),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Password input card
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // New password field
                Text(
                  l10n.newPassword,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: !showNewPassword,
                  autofocus: true,
                  onChanged: (_) {
                    _clearError();
                    setState(() {}); // Rebuild for strength indicator
                  },
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText(context),
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.enterNewPassword,
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: AppColors.hintText(context),
                    ),
                    filled: true,
                    fillColor: AppColors.fieldBg(context),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showNewPassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.secondaryText(context),
                      ),
                      onPressed: () {
                        setState(() => showNewPassword = !showNewPassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: passwordError != null
                            ? AppColors.errorColor
                            : AppColors.outlineColor(context),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: passwordError != null
                            ? AppColors.errorColor
                            : AppColors.outlineColor(context),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: passwordError != null
                            ? AppColors.errorColor
                            : AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                // Password strength indicator
                if (newPasswordController.text.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: strength >= 1
                                ? _getStrengthColor(strength)
                                : AppColors.outlineColor(context),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: strength >= 2
                                ? _getStrengthColor(strength)
                                : AppColors.outlineColor(context),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: strength >= 3
                                ? _getStrengthColor(strength)
                                : AppColors.outlineColor(context),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getStrengthText(strength, l10n),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStrengthColor(strength),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Confirm password field
                Text(
                  l10n.confirmPassword,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !showConfirmPassword,
                  onChanged: (_) => _clearError(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText(context),
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.confirmNewPasswordHint,
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: AppColors.hintText(context),
                    ),
                    filled: true,
                    fillColor: AppColors.fieldBg(context),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.secondaryText(context),
                      ),
                      onPressed: () {
                        setState(() => showConfirmPassword = !showConfirmPassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: passwordError != null
                            ? AppColors.errorColor
                            : AppColors.outlineColor(context),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: passwordError != null
                            ? AppColors.errorColor
                            : AppColors.outlineColor(context),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: passwordError != null
                            ? AppColors.errorColor
                            : AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                // Error message
                if (passwordError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    passwordError!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.errorColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                AuthPrimaryButton(
                  text: l10n.resetPassword,
                  isLoading: isLoading,
                  onPressed: _resetPassword,
                ),

                const SizedBox(height: 16),

                // Password requirements
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.passwordMustContain,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildRequirement(l10n.atLeast6Characters, newPasswordController.text.length >= 6),
                      _buildRequirement(l10n.uppercaseLetterRecommended, newPasswordController.text.contains(RegExp(r'[A-Z]'))),
                      _buildRequirement(l10n.numberSpecialCharRecommended, newPasswordController.text.contains(RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]'))),
                    ],
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

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? Colors.green : AppColors.hintText(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.secondaryText(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
