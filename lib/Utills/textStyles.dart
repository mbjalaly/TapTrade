import 'package:flutter/material.dart';
import 'package:taptrade/Utills/appColors.dart';

/// Modern typography scale for TapTrade auth flow
/// Follows Material Design and Apple HIG principles
/// Provides consistent text styling across the app
@immutable
class TextStyles {
  const TextStyles._();

  // Headings
  static const heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryTextColor,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryTextColor,
    height: 1.2,
    letterSpacing: -0.3,
  );

  static const heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryTextColor,
    height: 1.3,
    letterSpacing: -0.2,
  );

  static const heading4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryTextColor,
    height: 1.3,
  );

  // Body text
  static const body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryTextColor,
    height: 1.5,
  );

  static const body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryTextColor,
    height: 1.5,
  );

  // Specialized text styles
  static const subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryTextColor,
    height: 1.4,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.hintTextColor,
    height: 1.4,
  );

  static const overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.greyTextColor,
    height: 1.3,
    letterSpacing: 0.5,
  );

  // Button text
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.2,
  );

  static const buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.2,
  );

  // Link text
  static const link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryColor,
    height: 1.4,
    decoration: TextDecoration.none,
  );

  // Helper methods for color variations
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}
