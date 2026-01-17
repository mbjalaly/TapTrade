import 'package:flutter/material.dart';

@immutable
class AppColors {

  const AppColors._();
  static const themeColor=Color(0xFF47ebe8);
  static const darkBlue=Color(0xff144A9A);
  static const darkYellow=Color(0xffF2B721);

  static const primaryTextColor = Color(0xff1D458A);
  static const primaryColor = Color(0xff00e3df);
  static const secondaryColor = Color(0xffffb700);

  static const fieldColor = Color(0xffF4F4F4);
  static const backGroundColor = Colors.white;
  static const whiteTextColor = Colors.white;
  static const blackTextColor = Colors.black;
  static const greyTextColor = Color(0xff33333380);
  static const errorTextColor = Colors.red;
  static const greyBackGroundColor = Color(0x1A333333);
  static const silverEyeColor = Color(0xFFC8C7CC);

  // Surfaces
  static const surface = Colors.white;
  static const surfaceVariant = Color(0xFFF5F7FB);
  static const outline = Color(0xFFE3E7EF);

  // States
  static const success = Color(0xFF1B5E20);
  static const warning = Color(0xFFF57F17);
  static const danger = Color(0xFFB71C1C);

  // Modern Design System Colors (for new auth flow)
  // Text colors
  static const secondaryTextColor = Color(0xFF6B6B6B); // Gray
  static const hintTextColor = Color(0xFF9E9E9E); // Light gray

  // Background
  static const cardBackground = Color(0xFFFAFAFA); // Slightly off-white

  // Modern states (brighter, more vibrant)
  static const successColor = Color(0xFF00C853); // Bright green
  static const errorColor = Color(0xFFD32F2F); // Material red
  static const warningColor = Color(0xFFFFA726); // Material orange

  // Shadows
  static const shadowColor = Color(0x1A000000); // 10% black

}