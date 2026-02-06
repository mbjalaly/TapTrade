import 'package:flutter/material.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Screens/Auth/ForgetPassword/forgetPassword.dart';
import 'package:taptrade/Screens/Dashboard/Bottombar/bottombarscreen.dart';
import 'package:taptrade/Screens/UserDetail/AddInterest/addInterest.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Services/LocationService/locationService.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/Auth/auth_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscureText = true;
  bool isLoading = false;
  String? emailError;
  String? passwordError;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    if (emailError != null || passwordError != null) {
      setState(() {
        emailError = null;
        passwordError = null;
      });
    }
  }

  Future<void> _handleLogin() async {
    bool hasError = false;

    if (emailController.text.isEmpty) {
      setState(() => emailError = AppLocalizations.of(context)?.pleaseEnterEmail ?? 'Please enter your email');
      hasError = true;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text.trim())) {
      setState(() => emailError = AppLocalizations.of(context)?.pleaseEnterValidEmail ?? 'Please enter a valid email');
      hasError = true;
    }

    if (passwordController.text.isEmpty) {
      setState(() => passwordError = AppLocalizations.of(context)?.pleaseEnterPassword ?? 'Please enter your password');
      hasError = true;
    }

    if (hasError) return;

    setState(() {
      isLoading = true;
      emailError = null;
      passwordError = null;
    });

    try {
      Map<String, dynamic> body = {
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
      };

      final result = await AuthService.instance.login(context, body);

      if (result.status == Status.COMPLETED &&
          result.responseData != null &&
          (result.responseData['success'] ?? false)) {
        await SharedPreferencesService().setString(
          KeyConstants.accessToken,
          result.responseData['token'],
        );

        final userId = result.responseData['data']?['id']?.toString() ??
            result.responseData['id']?.toString() ??
            '';
        await SharedPreferencesService().setString(
          KeyConstants.userId,
          userId,
        );

        ShowMessage.notify(context, result.responseData['message']);

        final response = await ProfileService.instance.getProfile(context);

        // Update location (non-blocking)
        try {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            final location =
                await LocationService.instance.getCurrentLocation();
            await LocationService.instance.updateLocationInDatabase(
              location.latitude,
              location.longitude,
            );
          }
        } catch (e) {
          debugPrint("Location update failed (non-critical): $e");
        }

        bool isProfileComplete =
            response.responseData['data']?['is_profile_completed'] ?? false;

        final userController = Get.find<UserController>();
        final profileUserId =
            userController.userProfile.value.data?.id ?? userId;

        if (isProfileComplete) {
          if (profileUserId.isNotEmpty) {
            await ProductService.instance
                .getMatchProduct(context, profileUserId);
          }
          setState(() => isLoading = false);
          Get.offAll(() => const BottomNavigationScreen());
        } else {
          setState(() => isLoading = false);
          Get.to(() => const AddInterestScreen());
        }
      } else {
        setState(() {
          isLoading = false;
          // Get error message from backend
          final errorMessage = result.message ??
                              result.responseData?['message']?.toString() ??
                              AppLocalizations.of(context)?.loginFailed ?? 'Login failed. Please try again.';

          // Show error on password field (more intuitive for users)
          passwordError = errorMessage;
        });

        // Don't show duplicate notification - error is already shown in dialog by authService
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        passwordError = 'An unexpected error occurred. Please try again.';
      });
      debugPrint("Login Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      child: Column(
        children: [
          const SizedBox(height: 40),

          const SizedBox(height: 60),

          // Title
          Text(
            AppLocalizations.of(context)?.welcomeBack ?? 'Welcome Back',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText(context),
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            AppLocalizations.of(context)?.signInToContinue ?? 'Sign in to continue',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.secondaryText(context),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 40),

          // Login form card
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthTextField(
                  controller: emailController,
                  label: AppLocalizations.of(context)?.email ?? 'Email',
                  hint: AppLocalizations.of(context)?.enterEmail ?? 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  errorText: emailError,
                  onChanged: (_) => _clearErrors(),
                ),

                const SizedBox(height: 20),

                AuthTextField(
                  controller: passwordController,
                  label: AppLocalizations.of(context)?.password ?? 'Password',
                  hint: AppLocalizations.of(context)?.enterPassword ?? 'Enter your password',
                  obscureText: obscureText,
                  errorText: passwordError,
                  onChanged: (_) => _clearErrors(),
                  onToggleObscure: () {
                    setState(() => obscureText = !obscureText);
                  },
                ),

                const SizedBox(height: 16),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Get.to(() => const ForgetPasswordScreen()),
                    child: Text(
                      AppLocalizations.of(context)?.forgotPassword ?? 'Forgot Password?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Login button
                AuthPrimaryButton(
                  text: AppLocalizations.of(context)?.login ?? 'Sign In',
                  isLoading: isLoading,
                  onPressed: _handleLogin,
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
