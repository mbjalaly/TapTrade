import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/apiEndPoint.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/ApiServices/apiServices.dart';
import 'package:taptrade/Services/logService.dart';
import 'package:taptrade/Utills/showMessages.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();

  factory AuthService() {
    return instance;
  }

  AuthService._internal();

  // Helper function to handle API errors
  ApiResponse<dynamic> _handleApiError(dynamic e, BuildContext context) {
    printLog("ApiException: $e");
    if (e is ApiException) {
      printLog("ApiException: ${e.message}");

      try {
        Map<String, dynamic> errorMessageJson = json.decode(e.message);
        
        // Extract error message - check message field first, then error
        String errorMessage = errorMessageJson['message'] ?? 
                              errorMessageJson['error'] ?? 
                              'An error occurred';
        
        // If there are field errors, append them to the message
        if (errorMessageJson['errors'] != null) {
          final errors = errorMessageJson['errors'];
          if (errors['fieldErrors'] != null) {
            final fieldErrors = errors['fieldErrors'] as Map<String, dynamic>;
            final fieldErrorMessages = fieldErrors.values
                .expand((v) => v is List ? v : [v])
                .map((v) => v.toString())
                .join(', ');
            if (fieldErrorMessages.isNotEmpty) {
              errorMessage = '$errorMessage: $fieldErrorMessages';
            }
          }
        }
        
        ShowMessage.inDialog(context, errorMessage.capitalizeFirst.toString(), true);
        return ApiResponse.error(errorMessage);
      } catch (parseError) {
        // If JSON parsing fails, use the raw message if it's not empty, otherwise default error
        String rawMessage = e.message.toString();
        // Clean up common prefixes if present
        rawMessage = rawMessage.replaceAll('Exception:', '').trim();
        
        String finalError = rawMessage.isNotEmpty ? rawMessage : 'An error occurred';
        ShowMessage.inDialog(context, finalError, true);
        return ApiResponse.error(finalError);
      }
    } else {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> signUp(
    BuildContext context,
      Map<String, dynamic> body
  )
  async {
    try{
      final result = await ApiService.postRequestData(ApiEndPoint.register, body, context);
      return ApiResponse.completed(result);
    } catch (e) {
      return _handleApiError(e, context);
    }
  }

  Future<ApiResponse<dynamic>> login(
    BuildContext context,
      Map<String, dynamic> body
  )
  async {
    try{
      final result = await ApiService.postRequestData(ApiEndPoint.login, body, context);
      return ApiResponse.completed(result);
    } catch (e) {
      return _handleApiError(e, context);
    }
  }

  Future<ApiResponse<dynamic>> forgetPassword(
      BuildContext context,
      Map<String, dynamic> body
      )
  async {
    try{
      final result = await ApiService.postRequestData(ApiEndPoint.forgotPassword, body, context);
      return ApiResponse.completed(result);
    }catch (e) {
      printLog("ApiException: ${e}");
      if (e is ApiException) {
        // Handle ApiException
        printLog("ApiException: ${e.message}");

        Map<String, dynamic> errorMessageJson = json.decode(e.message);
        String errorMessage =
            errorMessageJson['error'] ?? 'An error occurred';
        ShowMessage.inDialog(context,errorMessage.capitalizeFirst.toString(), true);

        return ApiResponse.error(errorMessage);
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }

  /// Send password reset OTP to user's phone number
  /// This initiates the password reset flow by sending a verification code
  /// Returns success status and verification_id for the next step
  Future<ApiResponse<dynamic>> sendPasswordResetOtp(
    BuildContext context,
    String phoneNumber,
  ) async {
    try {
      printLog("AuthService: Sending password reset OTP to $phoneNumber");

      Map<String, dynamic> body = {
        'phone': phoneNumber,
      };

      final result = await ApiService.postRequestData(
        ApiEndPoint.forgotPassword,
        body,
        context,
        sendToken: false, // No auth required for password reset initiation
      );

      printLog("AuthService: Password reset OTP sent - ${result['message']}");
      return ApiResponse.completed(result);
    } catch (e) {
      return _handleApiError(e, context);
    }
  }

  /// Verify password reset OTP and get reset token
  /// This verifies the OTP code and returns a reset_token for the final step
  /// Returns success status and reset_token
  Future<ApiResponse<dynamic>> verifyPasswordResetOtp(
    BuildContext context,
    String phoneNumber,
    String code,
    String verificationId,
  ) async {
    try {
      printLog("AuthService: Verifying password reset OTP for $phoneNumber");

      Map<String, dynamic> body = {
        'phone': phoneNumber,
        'code': code,
        'verification_id': verificationId,
      };

      final result = await ApiService.postRequestData(
        ApiEndPoint.verifyResetOtp,
        body,
        context,
        sendToken: false, // No auth required for OTP verification
      );

      if (result['success'] == true && result['reset_token'] != null) {
        printLog("AuthService: Password reset OTP verified successfully");
        return ApiResponse.completed(result);
      } else {
        printLog("AuthService: Password reset OTP verification failed: ${result['message']}");
        return ApiResponse.error(result['message'] ?? 'Verification failed');
      }
    } catch (e) {
      return _handleApiError(e, context);
    }
  }

  /// Reset password with verified reset token
  /// This is the final step that updates the user's password
  /// Returns success status
  Future<ApiResponse<dynamic>> resetPassword(
    BuildContext context,
    String resetToken,
    String newPassword,
  ) async {
    try {
      printLog("AuthService: Resetting password with token");

      Map<String, dynamic> body = {
        'reset_token': resetToken,
        'new_password': newPassword,
      };

      final result = await ApiService.postRequestData(
        ApiEndPoint.resetPassword,
        body,
        context,
        sendToken: false, // No auth required, using reset_token instead
      );

      if (result['success'] == true) {
        printLog("AuthService: Password reset successfully");
        return ApiResponse.completed(result);
      } else {
        printLog("AuthService: Password reset failed: ${result['message']}");
        return ApiResponse.error(result['message'] ?? 'Password reset failed');
      }
    } catch (e) {
      return _handleApiError(e, context);
    }
  }

  Future<ApiResponse<dynamic>> googleSignIn(
    BuildContext context,
      Map<String, dynamic> body
  )
  async {
    try{
      final result = await ApiService.postRequestData(ApiEndPoint.googleLoginOrRegister, body, context);
      return ApiResponse.completed(result);
    }catch (e) {
      printLog("ApiException: ${e}");
      if (e is ApiException) {
        // Handle ApiException
        printLog("ApiException: ${e.message}");

        Map<String, dynamic> errorMessageJson = json.decode(e.message);
        String errorMessage =
            errorMessageJson['error'] ?? 'An error occurred';
        ShowMessage.inDialog(context,errorMessage.capitalizeFirst.toString(), true);

        return ApiResponse.error(errorMessage);
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }

  Future<ApiResponse<dynamic>> appleSignIn(
      BuildContext context,
      Map<String, dynamic> body
      )
  async {
    try{
      final result = await ApiService.postRequestData(ApiEndPoint.appleLoginOrRegister, body, context);
      return ApiResponse.completed(result);
    }catch (e) {
      printLog("ApiException: ${e}");
      if (e is ApiException) {
        // Handle ApiException
        printLog("ApiException: ${e.message}");

        Map<String, dynamic> errorMessageJson = json.decode(e.message);
        String errorMessage =
            errorMessageJson['error'] ?? 'An error occurred';
        ShowMessage.inDialog(context,errorMessage.capitalizeFirst.toString(), true);

        return ApiResponse.error(errorMessage);
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }

  Future<ApiResponse<dynamic>> verifyOtp(
      BuildContext context,
      dynamic otp
      )
  async {
    try{
      Map<String,dynamic> body = {
        "code": "$otp"
      };
      final result = await ApiService.postRequestData(ApiEndPoint.activation, body, context);
      return ApiResponse.completed(result);
    }catch (e) {
      printLog("ApiException: ${e}");
      if (e is ApiException) {
        // Handle ApiException
        printLog("ApiException: ${e.message}");

        Map<String, dynamic> errorMessageJson = json.decode(e.message);
        String errorMessage =
            errorMessageJson['error'] ?? 'An error occurred';
        ShowMessage.inDialog(context,errorMessage.capitalizeFirst.toString(), true);

        return ApiResponse.error(errorMessage);
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }

  Future<ApiResponse<dynamic>> updateUserDetails(
      BuildContext context,
  Map<String, dynamic> body
      )
  async {
    try{
      final result = await ApiService.postRequestWithFile(ApiEndPoint.activation, body, context);
      return ApiResponse.completed(result);
    }catch (e) {
      printLog("ApiException: ${e}");
      if (e is ApiException) {
        // Handle ApiException
        printLog("ApiException: ${e.message}");

        Map<String, dynamic> errorMessageJson = json.decode(e.message);
        String errorMessage =
            errorMessageJson['error'] ?? 'An error occurred';
        ShowMessage.inDialog(context,errorMessage.capitalizeFirst.toString(), true);

        return ApiResponse.error(errorMessage);
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }

  Future<dynamic> checkUserNameAndEmail(
      BuildContext context,
      String subject
      )
  async {
    try {
      var response = await http.get(Uri.parse(ApiEndPoint.userNameAndEmailValidation+subject));
      var jsonBody = jsonDecode(response.body);
      var result = {
        'code': response.statusCode,
        'message': jsonBody['message'] ?? 'An error occurred',
        'success': jsonBody['success'] ?? false,
        'exists': jsonBody['exists'] ?? false, // Backend returns 'exists' field
      };
      return result;
    } catch (e) {
      printLog("ApiException: $e");
      // Return error result instead of null
      return {
        'code': 500,
        'message': 'Network error. Please check your connection and try again.',
        'success': false,
        'exists': true, // Assume exists on error to prevent proceeding
      };
    }
  }

  /// Verify phone OTP via UnoSend backend
  /// This method coordinates with the backend SMS verification system
  /// Returns success status and verification result
  Future<ApiResponse<dynamic>> verifyPhoneOtp(
    BuildContext context,
    String phoneNumber,
    String otp,
  ) async {
    try {
      printLog("AuthService: Verifying phone OTP for $phoneNumber");

      Map<String, dynamic> body = {
        'phone': phoneNumber,
        'code': otp,
      };

      final result = await ApiService.postRequestData(
        ApiEndPoint.verifySmsOtp,
        body,
        context,
        sendToken: false,
      );

      if (result['success'] == true && result['phone_verified'] == true) {
        printLog("AuthService: Phone verified successfully");
        return ApiResponse.completed(result);
      } else {
        printLog("AuthService: Phone verification failed: ${result['message']}");
        return ApiResponse.error(result['message'] ?? 'Verification failed');
      }
    } catch (e) {
      return _handleApiError(e, context);
    }
  }

}
