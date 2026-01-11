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
        // If JSON parsing fails, show the raw message
        ShowMessage.inDialog(context, 'An error occurred. Please try again.', true);
        return ApiResponse.error('An error occurred');
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
        'success': jsonBody['success'] ?? false
      };
      return result;
    } catch (e) {
      printLog("ApiException: $e");
      // Return error result instead of null
      return {
        'code': 500,
        'message': 'Network error. Please check your connection and try again.',
        'success': true
      };
    }
  }

}
