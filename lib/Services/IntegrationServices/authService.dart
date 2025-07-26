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

  Future<ApiResponse<dynamic>> signUp(
    BuildContext context,
      Map<String, dynamic> body
  )
  async {
    try{
      final result = await ApiService.postRequestData(ApiEndPoint.register, body, context);
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

  Future<ApiResponse<dynamic>> login(
    BuildContext context,
      Map<String, dynamic> body
  )
  async {
    try{
      final result = await ApiService.postRequestData(ApiEndPoint.login, body, context);
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
      final result = await ApiService.postRequestData(ApiEndPoint.socialLoginOrRegister, body, context);
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
      var result = {'code':response.statusCode,'message':jsonBody['message'],'success':jsonBody['success']};
      return result;
    } catch (e) {
      printLog("ApiException: $e");
    }
  }

}
