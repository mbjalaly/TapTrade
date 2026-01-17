import 'package:flutter/material.dart';
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
      setState(() => emailError = 'Please enter your email');
      hasError = true;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text.trim())) {
      setState(() => emailError = 'Please enter a valid email');
      hasError = true;
    }

    if (passwordController.text.isEmpty) {
      setState(() => passwordError = 'Please enter your password');
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
          // Parse the server response for better error messages
          final message = result.responseData['message']?.toString().toLowerCase() ?? '';
          
          if (message.contains('not found') || message.contains('no user') || message.contains('does not exist')) {
            emailError = 'No account found with this email';
          } else if (message.contains('password') || message.contains('invalid') || message.contains('incorrect')) {
            passwordError = 'Email or password is incorrect';
          } else {
            passwordError = 'Email or password is incorrect';
          }
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        // Network or server error - still show helpful message
        passwordError = 'Unable to sign in. Please check your connection and try again.';
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
          const SizedBox(height: 20),

          // Logo
          Image.asset(
            "assets/images/icon2.png",
            height: 120,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlue,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Sign in to continue trading',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.darkBlue.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 32),

          // Login form card
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthTextField(
                  controller: emailController,
                  label: 'Email',
                  hint: 'example@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  errorText: emailError,
                  onChanged: (_) => _clearErrors(),
                ),

                const SizedBox(height: 20),

                AuthTextField(
                  controller: passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  obscureText: obscureText,
                  errorText: passwordError,
                  onChanged: (_) => _clearErrors(),
                  onToggleObscure: () {
                    setState(() => obscureText = !obscureText);
                  },
                ),

                const SizedBox(height: 12),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Get.to(() => const ForgetPasswordScreen()),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Login button
                AuthPrimaryButton(
                  text: 'Sign In',
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
