import 'package:flutter/material.dart';
import 'package:taptrade/Utills/appColors.dart';

/// Social login button for Google and Apple authentication
/// Features:
/// - Branded colors and icons
/// - Loading state with spinner
/// - Ripple animation
/// - 56px height, full width
/// - Clean minimal design
class SocialLoginButton extends StatelessWidget {
  final String provider; // 'google' or 'apple'
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialLoginButton({
    Key? key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provider-specific configuration
    final bool isGoogle = provider.toLowerCase() == 'google';
    final bool isApple = provider.toLowerCase() == 'apple';

    final String buttonText = isGoogle
        ? 'Continue with Google'
        : isApple
            ? 'Continue with Apple'
            : 'Continue';

    final IconData iconData = isGoogle
        ? Icons.g_mobiledata_rounded // Google "G" icon
        : isApple
            ? Icons.apple
            : Icons.login;

    final Color buttonColor = Colors.white;
    final Color textColor = AppColors.primaryText(context);
    final Color iconColor = isGoogle
        ? Color(0xFF4285F4) // Google blue
        : isApple
            ? Colors.black
            : AppColors.primaryColor;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColors.greyText(context).withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconData,
                    size: isGoogle ? 32 : 24,
                    color: iconColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
