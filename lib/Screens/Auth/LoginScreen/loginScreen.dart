import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Screens/Dashboard/Bottombar/bottombarscreen.dart';
import 'package:taptrade/Screens/UserDetail/AddProfile/addProfile.dart';
import 'package:taptrade/Screens/Auth/createAccount/userNameScreen.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Screens/Auth/ForgotPassword/forgotPasswordScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusNode emailFocus = FocusNode();
  final TextEditingController emailController = TextEditingController();
  final FocusNode passwordFocus = FocusNode();
  final TextEditingController passwordController = TextEditingController();
  bool obscureText = true;
  bool isLoading = false;
  bool isEmailValid = false;
  bool isPasswordValid = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    
    // Add listeners for validation
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
  }

  void _validateEmail() {
    final email = emailController.text.trim();
    setState(() {
      isEmailValid = _isValidEmail(email);
    });
  }

  void _validatePassword() {
    final password = passwordController.text.trim();
    setState(() {
      isPasswordValid = password.isNotEmpty && password.length >= 6;
    });
  }

  bool _isValidEmail(String email) {
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailFocus.dispose();
    emailController.dispose();
    passwordFocus.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor.withValues(alpha: 0.1),
                AppColors.secondaryColor.withValues(alpha: 0.1),
                Colors.white,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                height: size.height,
                child: Column(
                  children: [
                    // Back arrow and top section
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.primaryTextColor,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    
                    // Top section with logo and welcome text
                    Expanded(
                      flex: 2,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo without frame
                            Image.asset(
                              "assets/images/appLogo.png",
                              height: 100,
                              width: 100,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Welcome Back!",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryTextColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Sign in to continue trading",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.greyTextColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Login form section
                    Expanded(
                      flex: 3,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              // Login card
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Email field
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.email_outlined,
                                              color: AppColors.primaryColor,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Email Address",
                                              style: TextStyle(
                                                color: AppColors.primaryTextColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        TextFormField(
                                          controller: emailController,
                                          focusNode: emailFocus,
                                          keyboardType: TextInputType.emailAddress,
                                          style: TextStyle(
                                            color: AppColors.primaryTextColor,
                                            fontSize: 16,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Enter your email',
                                            hintStyle: TextStyle(
                                              color: AppColors.greyTextColor.withValues(alpha: 0.7),
                                              fontSize: 14,
                                            ),
                                            filled: true,
                                            fillColor: AppColors.fieldColor,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: emailController.text.isNotEmpty 
                                                    ? (isEmailValid ? Colors.green : Colors.red)
                                                    : AppColors.primaryColor,
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 16,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.email_outlined,
                                              color: AppColors.greyTextColor.withValues(alpha: 0.5),
                                              size: 20,
                                            ),
                                            suffixIcon: emailController.text.isNotEmpty
                                                ? Icon(
                                                    isEmailValid ? Icons.check_circle : Icons.error,
                                                    color: isEmailValid ? Colors.green : Colors.red,
                                                    size: 20,
                                                  )
                                                : null,
                                          ),
                                        ),
                                        if (emailController.text.isNotEmpty && !isEmailValid)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8, left: 8),
                                            child: Row(
                                              children: [
                                                Icon(Icons.error, color: Colors.red, size: 16),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Please enter a valid email address",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 24),
                                    
                                    // Password field
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.lock_outline,
                                              color: AppColors.primaryColor,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Password",
                                              style: TextStyle(
                                                color: AppColors.primaryTextColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        TextFormField(
                                          controller: passwordController,
                                          obscureText: obscureText,
                                          focusNode: passwordFocus,
                                          style: TextStyle(
                                            color: AppColors.primaryTextColor,
                                            fontSize: 16,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Enter your password',
                                            hintStyle: TextStyle(
                                              color: AppColors.greyTextColor.withValues(alpha: 0.7),
                                              fontSize: 14,
                                            ),
                                            filled: true,
                                            fillColor: AppColors.fieldColor,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: passwordController.text.isNotEmpty 
                                                    ? (isPasswordValid ? Colors.green : Colors.red)
                                                    : AppColors.primaryColor,
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 16,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.lock_outline,
                                              color: AppColors.greyTextColor.withValues(alpha: 0.5),
                                              size: 20,
                                            ),
                                            suffixIcon: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (passwordController.text.isNotEmpty)
                                                  Icon(
                                                    isPasswordValid ? Icons.check_circle : Icons.error,
                                                    color: isPasswordValid ? Colors.green : Colors.red,
                                                    size: 20,
                                                  ),
                                                IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      obscureText = !obscureText;
                                                    });
                                                  },
                                                  icon: Icon(
                                                    obscureText
                                                        ? Icons.visibility_off_outlined
                                                        : Icons.visibility_outlined,
                                                    color: AppColors.greyTextColor.withValues(alpha: 0.7),
                                                    size: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (passwordController.text.isNotEmpty && !isPasswordValid)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8, left: 8),
                                            child: Row(
                                              children: [
                                                Icon(Icons.error, color: Colors.red, size: 16),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Password must be at least 6 characters",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        
                                        // Forgot Password link right under password field
                                        SizedBox(height: 12),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                            onTap: () {
                                              Get.to(() => const ForgotPasswordScreen());
                                            },
                                            child: Text(
                                              "Forgot Password?",
                                              style: TextStyle(
                                                color: AppColors.primaryColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 32),
                                    
                                    // Login button
                                    AppButton(
                                      onPressed: (isEmailValid && isPasswordValid && !isLoading)
                                          ? () async {
                                              setState(() {
                                                isLoading = true;
                                              });

                                              try {
                                                // Prepare the request body
                                                Map<String, dynamic> body = {
                                                  "email": emailController.text.trim(),
                                                  "password": passwordController.text.trim(),
                                                };

                                                // Perform login request
                                                final result = await AuthService.instance.login(context, body);

                                                // Handle response
                                                if (result.status == Status.COMPLETED) {
                                                  if (result.responseData['success'] == true) {
                                                    // Save token and user ID in shared preferences
                                                    if (result.responseData['token'] != null) {
                                                      await SharedPreferencesService().setString(
                                                        KeyConstants.accessToken,
                                                        result.responseData['token'],
                                                      );
                                                    }
                                                    
                                                    if (result.responseData['id'] != null) {
                                                      await SharedPreferencesService().setString(
                                                        KeyConstants.userId,
                                                        result.responseData['id'].toString(),
                                                      );
                                                    }

                                                    // Notify user of success
                                                    ShowMessage.notify(
                                                      context,
                                                      result.responseData['message'] ?? "Login successful!",
                                                    );

                                                    // Fetch profile data
                                                    try {
                                                      final response = await ProfileService.instance.getProfile(context);

                                                      // Check if the profile is complete
                                                      bool isProfileComplete =
                                                          response.responseData['data']?['is_profile_completed'] ?? false;

                                                      if (isProfileComplete) {
                                                        // Load match products and navigate to main screen
                                                        await ProductService.instance.getMatchProduct(
                                                            context, result.responseData['id']);
                                                        setState(() {
                                                          isLoading = false;
                                                        });
                                                        Get.offAll(() => const BottomNavigationScreen());
                                                      } else {
                                                        // Navigate to profile setup screen
                                                        setState(() {
                                                          isLoading = false;
                                                        });
                                                        Get.to(() => const AddProfileScreen());
                                                      }
                                                    } catch (profileError) {
                                                      // If profile fetch fails, still proceed to main screen
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                      Get.offAll(() => const BottomNavigationScreen());
                                                    }
                                                  } else {
                                                    // Handle unsuccessful login
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                    ShowMessage.notify(
                                                      context,
                                                      result.responseData['message'] ?? "Invalid credentials",
                                                    );
                                                  }
                                                } else {
                                                  // Handle error response
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                  ShowMessage.notify(
                                                    context,
                                                    result.message ?? "An error occurred during login",
                                                  );
                                                }
                                              } catch (e) {
                                                // Handle exceptions
                                                setState(() {
                                                  isLoading = false;
                                                });

                                                ShowMessage.notify(
                                                  context,
                                                  "Network error. Please check your internet connection and try again.",
                                                );
                                              }
                                            }
                                          : null,
                                      text: 'Sign In',
                                      isLoading: isLoading,
                                      width: double.infinity,
                                      height: 56,
                                      fontSize: 18,
                                      backgroundColor: (isEmailValid && isPasswordValid) 
                                          ? AppColors.primaryColor 
                                          : AppColors.greyTextColor.withValues(alpha: 0.3),
                                    ),
                                    
                                    // Additional options
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Don't have an account? ",
                                          style: TextStyle(
                                            color: AppColors.greyTextColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            // Navigate to sign up screen
                                            Get.to(() => UserNameScreen());
                                          },
                                          child: Text(
                                            "Sign Up",
                                            style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
