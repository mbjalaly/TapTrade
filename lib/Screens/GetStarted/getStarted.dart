import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:taptrade/Controller/languageController.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:taptrade/Screens/Auth/LoginScreen/loginScreen.dart';
import 'package:taptrade/Screens/Auth/CreateAccount/userNameScreen.dart';
import 'package:taptrade/Services/IntegrationServices/appleAuthService.dart';
import 'package:taptrade/Services/IntegrationServices/googleSignIn.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/textStyles.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _buttonsFade;
  late Animation<Offset> _buttonsSlide;
  late Animation<double> _footerFade;
  late Animation<double> _pulseAnimation;
  
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Staggered animations for a premium feel
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _buttonsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );
    
    _buttonsSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _footerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _mainController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),
          // Gradient overlay for better readability
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
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          // Language toggle at top right
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () {
                    final langController = Get.find<LanguageController>();
                    langController.toggleLanguage();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.glassBg(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.language, size: 18, color: AppColors.primaryColor),
                        const SizedBox(width: 4),
                        Obx(() {
                          final langController = Get.find<LanguageController>();
                          return Text(
                            langController.languageCode == 'en' ? 'عربي' : 'EN',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // Animated Logo Section
                  AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: _buildLogoSection(),
                        ),
                      );
                    },
                  ),
                  
                  const Spacer(flex: 1),
                  
                  // Action Buttons with Glassmorphism
                  AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _buttonsFade,
                        child: SlideTransition(
                          position: _buttonsSlide,
                          child: _buildActionCard(),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Footer Links
                  AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _footerFade,
                        child: _buildFooter(),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo with subtle pulse effect - larger size
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Image.asset(
                  "assets/images/appLogo.png",
                  height: 190,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        // Tagline with gradient effect
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              AppColors.darkBlue,
              AppColors.primaryColor,
            ],
          ).createShader(bounds),
          child: Text(
            'The Wanted for the Unwanted',         
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Google Button
              _buildSocialButton(
                icon: 'assets/images/google_icon.png',
                fallbackIcon: Icons.g_mobiledata_rounded,
                label: AppLocalizations.of(context)?.continueWithGoogle ?? 'Continue with Google',
                isLoading: _isGoogleLoading,
                onTap: () async {
                  setState(() => _isGoogleLoading = true);
                  try {
                    await AuthWithGoogle.google(context: context);
                  } finally {
                    if (mounted) setState(() => _isGoogleLoading = false);
                  }
                },
                isPrimary: true,
              ),
              
              if (Platform.isIOS) ...[
                const SizedBox(height: 12),
                _buildSocialButton(
                  icon: null,
                  fallbackIcon: Icons.apple,
                  label: AppLocalizations.of(context)?.continueWithApple ?? 'Continue with Apple',
                  isLoading: _isAppleLoading,
                  onTap: () async {
                    setState(() => _isAppleLoading = true);
                    try {
                      await AppleAuthService.instance.apple(context: context);
                    } finally {
                      if (mounted) setState(() => _isAppleLoading = false);
                    }
                  },
                  isApple: true,
                ),
              ],
              
              const SizedBox(height: 20),
              
              // Divider
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.outlineColor(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppLocalizations.of(context)?.orDivider ?? 'or',
                      style: TextStyles.caption.copyWith(
                        color: AppColors.secondaryText(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.outlineColor(context),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Email Button
              _buildEmailButton(),
              
              const SizedBox(height: 16),
              
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)?.alreadyHaveAccount ?? 'Already have an account?',
                    style: TextStyles.body2.copyWith(
                      color: AppColors.secondaryText(context),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => Get.to(() => const LoginScreen()),
                    child: Text(
                      AppLocalizations.of(context)?.signIn ?? 'Sign in',
                      style: TextStyles.body2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String? icon,
    required IconData fallbackIcon,
    required String label,
    required bool isLoading,
    required VoidCallback onTap,
    bool isPrimary = false,
    bool isApple = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: isApple ? Colors.black : AppColors.contentBg(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isApple
                  ? Colors.black
                  : AppColors.outlineColor(context),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isApple ? Colors.black : AppColors.darkBlue)
                    .withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isApple ? Colors.white : AppColors.primaryColor,
                      ),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      fallbackIcon,
                      size: isPrimary ? 28 : 24,
                      color: isApple 
                          ? Colors.white 
                          : (isPrimary ? const Color(0xFF4285F4) : Colors.black),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isApple ? Colors.white : AppColors.primaryText(context),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildEmailButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.to(() => UserNameScreen()),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 54,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mail_outline_rounded,
                size: 22,
                color: AppColors.darkBlue,
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)?.createAccount ?? 'Create account',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text.rich(
        TextSpan(
          text: AppLocalizations.of(context)?.byContinuingYouAgree ?? 'By continuing, you agree to our ',
          style: TextStyles.caption.copyWith(
            fontSize: 12,
            color: AppColors.secondaryText(context),
          ),
          children: [
            TextSpan(
              text: AppLocalizations.of(context)?.terms ?? 'Terms',
              style: TextStyles.caption.copyWith(
                fontSize: 12,
                color: AppColors.primaryText(context),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.secondaryText(context),
              ),
              recognizer: TapGestureRecognizer()..onTap = () {},
            ),
            TextSpan(text: AppLocalizations.of(context)?.andWord ?? ' and '),
            TextSpan(
              text: AppLocalizations.of(context)?.privacyPolicy ?? 'Privacy Policy',
              style: TextStyles.caption.copyWith(
                fontSize: 12,
                color: AppColors.primaryText(context),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.secondaryText(context),
              ),
              recognizer: TapGestureRecognizer()..onTap = () {},
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
