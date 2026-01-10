import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Screens/UserDetail/AddProfile/addProfile.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
import 'package:taptrade/Services/IntegrationServices/firebasePhoneAuthService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customPinCode.dart';
import 'package:taptrade/Widgets/customText.dart';

class VerifyOtpScreen extends StatefulWidget {
  VerifyOtpScreen({
    Key? key,
    required this.requestModel,
    this.verificationId,
    this.phoneNumber,
    this.autoVerifiedCredential,
  }) : super(key: key);
  
  final SignUpRequestModel requestModel;
  final String? verificationId;
  final String? phoneNumber;
  final PhoneAuthCredential? autoVerifiedCredential;
  
  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  bool isResending = false;
  
  // Resend timer
  int _resendSeconds = 0;
  Timer? _resendTimer;
  
  @override
  void initState() {
    super.initState();
    _startResendTimer();
    
    // Handle auto-verified credential (Android)
    if (widget.autoVerifiedCredential != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleAutoVerification();
      });
    }
  }
  
  @override
  void dispose() {
    _resendTimer?.cancel();
    otpController.dispose();
    super.dispose();
  }
  
  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() {
          _resendSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }
  
  /// Handle auto-verification on Android
  Future<void> _handleAutoVerification() async {
    if (widget.autoVerifiedCredential == null) return;
    
    setState(() {
      isLoading = true;
    });
    
    final userCredential = await FirebasePhoneAuthService.instance
        .signInWithCredential(widget.autoVerifiedCredential!, context);
    
    if (userCredential != null) {
      await _completeRegistration(userCredential);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  /// Verify OTP with Firebase
  Future<void> _verifyOtp() async {
    if (otpController.text.trim().isEmpty) {
      ShowMessage.notify(context, "Please enter the OTP code");
      return;
    }
    
    if (otpController.text.trim().length < 6) {
      ShowMessage.notify(context, "Please enter a valid 6-digit OTP");
      return;
    }
    
    setState(() {
      isLoading = true;
    });
    
    final userCredential = await FirebasePhoneAuthService.instance.verifyOtp(
      otp: otpController.text.trim(),
      context: context,
      verificationId: widget.verificationId,
    );
    
    if (userCredential != null) {
      await _completeRegistration(userCredential);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  /// Complete registration with backend after Firebase verification
  Future<void> _completeRegistration(UserCredential userCredential) async {
    try {
      // Add Firebase UID to request model for backend reference
      final requestData = widget.requestModel.toJson();
      requestData['firebase_uid'] = userCredential.user?.uid;
      requestData['phone_verified'] = true;
      
      // Register user with backend
      final result = await AuthService.instance.signUp(context, requestData);
      
      setState(() {
        isLoading = false;
      });
      
      if (result.status == Status.COMPLETED) {
        // Debug: Print response to see token structure
        print('[Auth] Registration response: ${result.responseData}');
        
        // Try multiple possible token keys
        String? token = result.responseData['token'] 
            ?? result.responseData['access_token']
            ?? result.responseData['data']?['token']
            ?? result.responseData['data']?['access_token'];
        
        if (token != null && token.isNotEmpty) {
          await SharedPreferencesService().setString(
            KeyConstants.accessToken,
            token,
          );
          print('[Auth] Token saved successfully');
        } else {
          print('[Auth] WARNING: No token found in response!');
        }
        
        // Try multiple possible user ID keys
        String? userId = result.responseData['user_profile']?['id']?.toString()
            ?? result.responseData['user']?['id']?.toString()
            ?? result.responseData['data']?['user_profile']?['id']?.toString()
            ?? result.responseData['data']?['user']?['id']?.toString()
            ?? result.responseData['id']?.toString();
        
        if (userId != null && userId.isNotEmpty) {
          await SharedPreferencesService().setString(
            KeyConstants.userId,
            userId,
          );
          print('[Auth] User ID saved: $userId');
        } else {
          print('[Auth] WARNING: No user ID found in response!');
        }
        
        ShowMessage.notify(
          context,
          result.responseData['message'] ?? 'Phone verified successfully!',
        );
        
        // Clear Firebase session
        FirebasePhoneAuthService.instance.clearSession();
        
        // Get profile and navigate
        ProfileService.instance.getProfile(context);
        Get.offAll(() => const AddProfileScreen());
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ShowMessage.inDialog(context, 'Registration failed. Please try again.', true);
    }
  }
  
  /// Resend OTP
  Future<void> _resendOtp() async {
    if (_resendSeconds > 0 || widget.phoneNumber == null) return;
    
    setState(() {
      isResending = true;
    });
    
    await FirebasePhoneAuthService.instance.resendOtp(
      phoneNumber: widget.phoneNumber!,
      context: context,
      onCodeSent: (String verificationId) {
        setState(() {
          isResending = false;
        });
        _startResendTimer();
        ShowMessage.notify(context, "OTP resent successfully!");
      },
      onAutoVerify: (PhoneAuthCredential credential) async {
        setState(() {
          isResending = false;
        });
        final userCredential = await FirebasePhoneAuthService.instance
            .signInWithCredential(credential, context);
        if (userCredential != null) {
          await _completeRegistration(userCredential);
        }
      },
    );
    
    setState(() {
      isResending = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: Get.height * 0.02,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      FirebasePhoneAuthService.instance.clearSession();
                      Get.back();
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.grey,
                      size: 29,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: Get.width * 0.065,
                    top: Get.height * 0.03,
                  ),
                  child: AppText(
                    text: "Enter OTP",
                    fontSize: Get.width * 0.065,
                    textcolor: AppColors.darkBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.phoneNumber != null)
                  Padding(
                    padding: EdgeInsets.only(
                      left: Get.width * 0.065,
                      top: Get.height * 0.01,
                    ),
                    child: AppText(
                      text: "Code sent to ${widget.phoneNumber}",
                      fontSize: Get.width * 0.035,
                      textcolor: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                SizedBox(
                  height: Get.height * 0.05,
                ),
                Center(
                  child: CustomPinCodeInput(
                    controller: otpController,
                    onDone: (pin) {
                      // Auto-verify when 6 digits entered
                      if (pin.length == 6) {
                        _verifyOtp();
                      }
                    },
                    onTextChanged: (pin) {},
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.03,
                ),
                // Resend OTP section
                Center(
                  child: _resendSeconds > 0
                      ? AppText(
                          text: "Resend code in ${_resendSeconds}s",
                          fontSize: Get.width * 0.035,
                          textcolor: Colors.grey,
                          fontWeight: FontWeight.w400,
                        )
                      : GestureDetector(
                          onTap: isResending ? null : _resendOtp,
                          child: isResending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : AppText(
                                  text: "Resend OTP",
                                  fontSize: Get.width * 0.035,
                                  textcolor: AppColors.darkBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                        ),
                ),
                SizedBox(
                  height: Get.height * 0.04,
                ),
                Center(
                  child: AppButton(
                    onPressed: isLoading ? () {} : _verifyOtp,
                    isLoading: isLoading,
                    text: "VERIFY",
                    fontSize: Get.width * 0.043,
                    width: Get.width * 0.88,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
