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

  // ============================================
  // DARK MODE COLORS
  // ============================================
  
  // Dark mode text colors
  static const darkPrimaryTextColor = Color(0xFFE0E0E0); // Light gray text
  static const darkSecondaryTextColor = Color(0xFFB0B0B0); // Medium gray
  static const darkHintTextColor = Color(0xFF757575); // Darker hint
  
  // Dark mode backgrounds
  static const darkBackgroundColor = Color(0xFF121212); // Material dark background
  static const darkSurface = Color(0xFF1E1E1E); // Slightly lighter surface
  static const darkSurfaceVariant = Color(0xFF2C2C2C); // Even lighter variant
  static const darkCardBackground = Color(0xFF252525); // Card background
  
  // Dark mode field colors
  static const darkFieldColor = Color(0xFF2A2A2A);
  static const darkOutline = Color(0xFF3D3D3D);
  
  // Dark mode greys
  static const darkGreyTextColor = Color(0xCCE0E0E0); // 80% opacity light gray
  static const darkGreyBackgroundColor = Color(0x33FFFFFF); // 20% white
  static const darkSilverEyeColor = Color(0xFF616161);

  // ============================================
  // CONTEXT-AWARE COLOR HELPERS (light/dark)
  // ============================================

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color backgroundColor(BuildContext context) =>
      isDark(context) ? darkBackgroundColor : backGroundColor;

  static Color surfaceColor(BuildContext context) =>
      isDark(context) ? darkSurface : surface;

  static Color surfaceVariantColor(BuildContext context) =>
      isDark(context) ? darkSurfaceVariant : surfaceVariant;

  static Color cardBg(BuildContext context) =>
      isDark(context) ? darkCardBackground : surfaceVariant;

  static Color fieldBg(BuildContext context) =>
      isDark(context) ? darkFieldColor : fieldColor;

  static Color outlineColor(BuildContext context) =>
      isDark(context) ? darkOutline : outline;

  static Color primaryText(BuildContext context) =>
      isDark(context) ? darkPrimaryTextColor : primaryTextColor;

  static Color secondaryText(BuildContext context) =>
      isDark(context) ? darkSecondaryTextColor : secondaryTextColor;

  static Color hintText(BuildContext context) =>
      isDark(context) ? darkHintTextColor : hintTextColor;

  static Color greyText(BuildContext context) =>
      isDark(context) ? darkGreyTextColor : greyTextColor;

  static Color silverEye(BuildContext context) =>
      isDark(context) ? darkSilverEyeColor : silverEyeColor;

  static Color greyBg(BuildContext context) =>
      isDark(context) ? darkSurfaceVariant : greyBackGroundColor;

  static Color contentBg(BuildContext context) =>
      isDark(context) ? darkSurface : Colors.white;

  static Color textOnBg(BuildContext context) =>
      isDark(context) ? darkPrimaryTextColor : Colors.black;

  // Auth scaffold gradient overlay colours
  static Color overlayStart(BuildContext context) =>
      isDark(context) ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.3);

  static Color overlayMid(BuildContext context) =>
      isDark(context) ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.6);

  static Color overlayEnd(BuildContext context) =>
      isDark(context) ? Colors.black.withOpacity(0.95) : Colors.white.withOpacity(0.95);

  // Glassmorphism card background
  static Color glassBg(BuildContext context) =>
      isDark(context) ? darkSurface.withOpacity(0.85) : Colors.white.withOpacity(0.85);

  static Color glassBorder(BuildContext context) =>
      isDark(context) ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5);

  // Page background color for tutorial / intro screens
  static Color pageBg(BuildContext context) =>
      isDark(context) ? darkBackgroundColor : Colors.white;
}