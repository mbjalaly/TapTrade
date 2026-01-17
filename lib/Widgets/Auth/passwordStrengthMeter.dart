import 'package:flutter/material.dart';
import 'package:taptrade/Utills/appColors.dart';

/// Password strength visualization with requirements checklist
/// Features:
/// - Colored strength bar (red → yellow → green)
/// - Strength label (Weak | Fair | Strong)
/// - Requirements checklist with checkmarks
/// - Real-time validation
enum PasswordStrength { weak, fair, strong }

class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const PasswordStrengthMeter({
    Key? key,
    required this.password,
  }) : super(key: key);

  /// Calculate password strength based on criteria
  PasswordStrength _calculateStrength() {
    if (password.isEmpty) return PasswordStrength.weak;

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety checks
    if (RegExp(r'[a-z]').hasMatch(password)) score++; // Lowercase
    if (RegExp(r'[A-Z]').hasMatch(password)) score++; // Uppercase
    if (RegExp(r'[0-9]').hasMatch(password)) score++; // Number
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++; // Special char

    // Determine strength
    if (score >= 5) return PasswordStrength.strong;
    if (score >= 3) return PasswordStrength.fair;
    return PasswordStrength.weak;
  }

  /// Check if password meets minimum requirements
  bool get _meetsMinimumRequirements {
    return password.length >= 8 &&
        RegExp(r'[a-zA-Z]').hasMatch(password) &&
        RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength();
    final hasMinLength = password.length >= 8;
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    // Strength-based colors and labels
    Color barColor;
    String strengthLabel;
    double strengthValue;

    switch (strength) {
      case PasswordStrength.strong:
        barColor = AppColors.successColor ?? Colors.green;
        strengthLabel = 'Strong';
        strengthValue = 1.0;
        break;
      case PasswordStrength.fair:
        barColor = Colors.orange;
        strengthLabel = 'Fair';
        strengthValue = 0.6;
        break;
      case PasswordStrength.weak:
      default:
        barColor = Colors.red;
        strengthLabel = 'Weak';
        strengthValue = 0.3;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bar
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: password.isEmpty ? 0 : strengthValue,
                  backgroundColor: AppColors.greyTextColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  minHeight: 6,
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              password.isEmpty ? '' : strengthLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: barColor,
              ),
            ),
          ],
        ),

        SizedBox(height: 12),

        // Requirements checklist
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildRequirement(
              label: '8+ chars',
              isMet: hasMinLength,
            ),
            _buildRequirement(
              label: 'Letter',
              isMet: hasLetter,
            ),
            _buildRequirement(
              label: 'Number/Symbol',
              isMet: hasNumber,
            ),
          ],
        ),
      ],
    );
  }

  /// Build individual requirement item with checkmark
  Widget _buildRequirement({
    required String label,
    required bool isMet,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: isMet
              ? AppColors.successColor ?? Colors.green
              : AppColors.greyTextColor.withValues(alpha: 0.5),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isMet
                ? AppColors.primaryTextColor
                : AppColors.greyTextColor,
            fontWeight: isMet ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
