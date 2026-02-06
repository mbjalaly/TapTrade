import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Utills/appColors.dart';

/// A shared scaffold widget for all authentication screens.
/// Provides consistent glassmorphism styling, background,
/// and navigation across Login, SignUp, and ForgotPassword flows.
class AuthScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final int? currentStep;
  final int? totalSteps;
  final bool showProgress;
  final EdgeInsets? contentPadding;

  const AuthScaffold({
    Key? key,
    required this.child,
    this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBack,
    this.currentStep,
    this.totalSteps,
    this.showProgress = false,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                "assets/images/background.png",
                fit: BoxFit.cover,
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.overlayStart(context),
                      AppColors.overlayMid(context),
                      AppColors.overlayEnd(context),
                    ],
                    stops: const [0.0, 0.3, 1.0],
                  ),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Progress bar (if showing)
                  if (showProgress &&
                      currentStep != null &&
                      totalSteps != null)
                    _buildProgressBar(),

                  // Back button and header
                  _buildHeader(context),

                  // Main content area
                  Expanded(
                    child: SingleChildScrollView(
                      padding: contentPadding ??
                          const EdgeInsets.symmetric(horizontal: 24),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = currentStep! / totalSteps!;
    return Container(
      height: 4,
      margin: const EdgeInsets.only(top: 16),
      child: Stack(
        children: [
          // Background track
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.darkBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Progress fill
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (showBackButton)
            GestureDetector(
              onTap: onBack ?? () => Get.back(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.contentBg(context),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkBlue.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primaryText(context),
                  size: 20,
                ),
              ),
            )
          else
            const SizedBox(width: 44),
          const Spacer(),
          if (showProgress &&
              currentStep != null &&
              totalSteps != null)
            Text(
              'Step $currentStep of $totalSteps',
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          const Spacer(),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

/// Glassmorphism card container for auth content
class AuthCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const AuthCard({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.glassBg(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.glassBorder(context),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkBlue.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Styled text field for auth screens with inline error support
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText; // Shows red border + error message when set
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  const AuthTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.onToggleObscure,
    this.keyboardType,
    this.suffixIcon,
    this.autofocus = false,
    this.onChanged,
  }) : super(key: key);

  bool get hasError => errorText != null && errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: hasError ? AppColors.errorColor : AppColors.primaryText(context),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          autofocus: autofocus,
          cursorColor: hasError ? AppColors.errorColor : AppColors.primaryColor,
          onChanged: onChanged,
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: hasError
                ? AppColors.errorColor.withOpacity(0.05)
                : AppColors.fieldBg(context),
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.hintText(context),
            ),
            suffixIcon: suffixIcon ??
                (onToggleObscure != null
                    ? IconButton(
                        icon: Icon(
                          obscureText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.secondaryText(context),
                        ),
                        onPressed: onToggleObscure,
                      )
                    : null),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: hasError
                  ? const BorderSide(color: AppColors.errorColor, width: 1.5)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: hasError
                  ? const BorderSide(color: AppColors.errorColor, width: 1.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.errorColor
                    : AppColors.primaryColor.withOpacity(0.5),
                width: 2,
              ),
            ),
          ),
        ),
        // Error message
        if (hasError) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 16,
                color: AppColors.errorColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  errorText!,
                  style: const TextStyle(
                    color: AppColors.errorColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ]
        // Helper text (only show if no error)
        else if (helperText != null) ...[
          const SizedBox(height: 10),
          Text(
            helperText!,
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Primary button for auth screens with gradient
class AuthPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthPrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.darkBlue,
                      ),
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
