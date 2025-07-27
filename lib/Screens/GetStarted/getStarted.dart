import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taptrade/Screens/Auth/LoginScreen/loginScreen.dart';
import 'package:taptrade/Screens/Auth/SsoAccount/phoneNumberSignIn.dart';
import 'package:taptrade/Screens/Auth/createAccount/userNameScreen.dart';
import 'package:taptrade/Services/IntegrationServices/generalService.dart';
import 'package:taptrade/Services/IntegrationServices/googleSignIn.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/customText.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> with TickerProviderStateMixin {
  bool showLoginMethods = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleLoginMethods() {
    setState(() {
      showLoginMethods = !showLoginMethods;
    });

    if (showLoginMethods) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.fill
            )
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: Get.height * 0.06),
                Image.asset("assets/images/icon2.png"),

                // This Spacer pushes the buttons to the bottom
                const Spacer(),

                // Bottom buttons section - everything stays together
                Padding(
                  padding: EdgeInsets.only(bottom: Get.height * 0.05),
                  child: Column(
                    children: [
                      // Only show terms text when NOT in login methods view
                      if (!showLoginMethods) ...[
                        // Terms and privacy text right above the buttons
                        SizedBox(
                          width: Get.width * 0.95,
                          child: Column(
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: 'By clicking',
                                  style: GoogleFonts.lato(
                                    fontSize: 13,
                                    color: AppColors.darkBlue,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: ' "Log in",',
                                      style: GoogleFonts.lato(
                                        fontSize: 13,
                                        color: AppColors.darkBlue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      recognizer: TapGestureRecognizer()..onTap = () {},
                                    ),
                                    TextSpan(
                                      text: ' you agree with our ',
                                      style: GoogleFonts.lato(
                                        fontSize: 13,
                                        color: AppColors.darkBlue,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Terms.',
                                      style: GoogleFonts.lato(
                                        fontSize: 13,
                                        color: AppColors.darkBlue,
                                        decorationColor: AppColors.darkBlue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()..onTap = () {},
                                    ),
                                  ],
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  text: ' Learn how we process your data in our ',
                                  style: GoogleFonts.lato(
                                    fontSize: 13,
                                    color: AppColors.darkBlue,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: GoogleFonts.lato(
                                        fontSize: 13,
                                        color: AppColors.darkBlue,
                                        decorationColor: AppColors.darkBlue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()..onTap = () {},
                                    ),
                                    TextSpan(
                                      text: ' and ',
                                      style: GoogleFonts.lato(
                                        fontSize: 13,
                                        color: AppColors.darkBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Center(
                                child: Text(
                                  'Cookies Policy.',
                                  style: GoogleFonts.lato(
                                    fontSize: 13,
                                    color: AppColors.darkBlue,
                                    decorationColor: AppColors.darkBlue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Get.height * 0.015),
                      ],

                      // Show terms text in login methods view too, but right above buttons
                      if (showLoginMethods) ...[
                        SizedBox(
                          width: Get.width * 0.95,
                          child: Column(
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: 'By clicking',
                                  style: GoogleFonts.lato(
                                    fontSize: 13,
                                    color: AppColors.darkBlue,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: ' "Log in",',
                                      style: GoogleFonts.lato(
                                        fontSize: 13,
                                        color: AppColors.darkBlue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      recognizer: TapGestureRecognizer()..onTap = () {},
                                    ),
                                    TextSpan(
                                      text: ' you agree with our ',
                                      style: GoogleFonts.lato(
                                        fontSize: 13,
                                        color: AppColors.darkBlue,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Terms.',
                                      style: GoogleFonts.lato(
                                        fontSize: 13,
                                        color: AppColors.darkBlue,
                                        decorationColor: AppColors.darkBlue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()..onTap = () {},
                                    ),
                                  ],
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  text: ' Learn how we process your data in our ',
                                  style: GoogleFonts.lato(
                                    fontSize: 13,
                                    color: AppColors.darkBlue,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: GoogleFonts.lato(
                                        fontSize: 13,
                                        color: AppColors.darkBlue,
                                        decorationColor: AppColors.darkBlue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()..onTap = () {},
                                    ),
                                    TextSpan(
                                      text: ' and ',
                                      style: GoogleFonts.lato(
                                        fontSize: 13,
                                        color: AppColors.darkBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Center(
                                child: Text(
                                  'Cookies Policy.',
                                  style: GoogleFonts.lato(
                                    fontSize: 13,
                                    color: AppColors.darkBlue,
                                    decorationColor: AppColors.darkBlue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Get.height * 0.015),
                      ],

                      // Create Account Button (only show when NOT in login methods)
                      if (!showLoginMethods) ...[
                        AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: 1.0 - _fadeAnimation.value,
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(UserNameScreen());
                                },
                                child: Container(
                                  height: Get.height * 0.063,
                                  width: Get.width * 0.92,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30)
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: Get.width * 0.06),
                                    child: Center(
                                      child: AppText(
                                        text: "CREATE ACCOUNT",
                                        fontSize: Get.width * 0.042,
                                        textcolor: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: Get.height * 0.015),
                      ],

                      // Animated Login Section
                      if (!showLoginMethods) ...[
                        // Main Login Button
                        AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: 1.0 - _fadeAnimation.value,
                              child: GestureDetector(
                                onTap: _toggleLoginMethods,
                                child: Container(
                                  height: Get.height * 0.063,
                                  width: Get.width * 0.92,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30)
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: Get.width * 0.06),
                                    child: Center(
                                      child: AppText(
                                        text: "SIGN IN",
                                        fontSize: Get.width * 0.042,
                                        textcolor: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],

                      // Login Method Options
                      if (showLoginMethods) ...[
                        // Sign in with Credentials
                        AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimation.value,
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(() => const LoginScreen());
                                },
                                child: Container(
                                  height: Get.height * 0.063,
                                  width: Get.width * 0.92,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30)
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: Get.width * 0.06),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person,
                                          color: Colors.grey[600],
                                          size: Get.width * 0.05,
                                        ),
                                        SizedBox(width: Get.width * 0.02),
                                        AppText(
                                          text: "SIGN IN WITH CREDENTIALS",
                                          fontSize: Get.width * 0.042,
                                          textcolor: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: Get.height * 0.015),

                        // Sign in with Google
                        AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimation.value,
                              child: GestureDetector(
                                onTap: () {
                                  // Handle Google sign in
                                  // GoogleSignInService().signInWithGoogle();
                                },
                                child: Container(
                                  height: Get.height * 0.063,
                                  width: Get.width * 0.92,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30)
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: Get.width * 0.06),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/svgs/google.svg",
                                          width: Get.width * 0.05,
                                          height: Get.width * 0.05,
                                        ),
                                        SizedBox(width: Get.width * 0.02),
                                        AppText(
                                          text: "SIGN IN WITH GOOGLE",
                                          fontSize: Get.width * 0.042,
                                          textcolor: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],

                      SizedBox(height: Get.height * 0.025),

                      // Trouble logging in (always visible)
                      GestureDetector(
                        onTap: () {

                        },
                        child: AppText(
                          text: "Trouble logging in?",
                          fontSize: Get.width * 0.042,
                          textcolor: AppColors.darkBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Back arrow (top left when showing login methods)
            if (showLoginMethods)
              Positioned(
                top: Get.height * 0.06,
                left: Get.width * 0.05,
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: GestureDetector(
                        onTap: _toggleLoginMethods,
                        child: Container(
                          padding: EdgeInsets.all(Get.width * 0.03),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.darkBlue,
                            size: Get.width * 0.06,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}