import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/apiEndPoint.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Models/AllInterest/allInterest.dart';
import 'package:taptrade/Models/TradePreference/tradePreference.dart';
import 'package:taptrade/Models/TraderProfileModel/traderProfileModel.dart';
import 'package:taptrade/Models/UserProfile/userProfile.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/ApiServices/apiServices.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Services/logService.dart';
import 'package:taptrade/Utills/showMessages.dart';

class ProfileService {
  static final ProfileService instance = ProfileService._internal();

  factory ProfileService() {
    return instance;
  }

  ProfileService._internal();

  var userController = Get.find<UserController>();



  Future<ApiResponse<dynamic>> getProfile(
      BuildContext context,
      )
  async {
    try{
      // Backend uses JWT token to identify user, no need to pass user ID
      final result = await ApiService.getRequestData(ApiEndPoint.getUserProfile, context, useToken: true);
      UserProfileResponseModel responseModel = UserProfileResponseModel.fromJson(result);
      userController.setUserProfile = responseModel;
      printLog("Saved Response ${userController.userProfile.value.toJson()}");
      return ApiResponse.completed(result);
    }catch (e) {
      printLog("ApiException: ${e}");
      if (e is ApiException) {
        // Handle ApiException
        printLog("ApiException: ${e.message}");

        Map<String, dynamic> errorMessageJson = json.decode(e.message);
        String errorMessage =
            errorMessageJson['message'] ?? errorMessageJson['error'] ?? 'An error occurred';
        ShowMessage.inDialog(context,errorMessage.capitalizeFirst.toString(), true);

        return ApiResponse.error(errorMessage);
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }

  Future<ApiResponse<dynamic>> updateProfile(
      BuildContext context,
      Map<String, dynamic> body,
      String id,
      )
  async {
    try {
      printLog("🚀 ProfileService.updateProfile CALLED");
      printLog("URL: ${ApiEndPoint.updateProfile}");
      printLog("BODY: $body");
      
      // Backend uses JWT token to identify user, no need to pass user ID in URL
      final result = await ApiService.postRequestWithFile(
        ApiEndPoint.updateProfile, 
        body, 
        context,
        sendToken: true,  // Send auth token with request
      );
      printLog("✅ ProfileService.updateProfile SUCCESS: $result");
      return ApiResponse.completed(result);
    }catch (e) {
      printLog("ApiException: ${e}");
      if (e is ApiException) {
        // Handle ApiException
        printLog("ApiException: ${e.message}");

        Map<String, dynamic> errorMessageJson = json.decode(e.message);
        
        // Extract the most specific error message available
        String errorMessage = 'An error occurred';
        
        // Check for nested error object with details (e.g., database errors)
        if (errorMessageJson['error'] is Map) {
          var errorObj = errorMessageJson['error'] as Map;
          if (errorObj['details'] != null && errorObj['details'].toString().isNotEmpty) {
            // Parse details like "Key (email)=(test@email.com) already exists."
            String details = errorObj['details'].toString();
            if (details.contains('already exists')) {
              if (details.contains('email')) {
                errorMessage = 'This email is already registered to another account';
              } else if (details.contains('phone') || details.contains('contact')) {
                errorMessage = 'This phone number is already registered to another account';
              } else if (details.contains('username')) {
                errorMessage = 'This username is already taken';
              } else {
                errorMessage = details;
              }
            } else {
              errorMessage = details;
            }
          } else if (errorObj['message'] != null) {
            errorMessage = errorObj['message'].toString();
          }
        } else if (errorMessageJson['message'] != null && 
                   errorMessageJson['message'] != 'Failed to update profile') {
          // Use message if it's specific (not the generic "Failed to update profile")
          errorMessage = errorMessageJson['message'].toString();
        } else if (errorMessageJson['error'] is String) {
          errorMessage = errorMessageJson['error'].toString();
        }
        
        ShowMessage.inDialog(context, errorMessage.capitalizeFirst.toString(), true);

        return ApiResponse.error(errorMessage);
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }

  Future<ApiResponse<dynamic>> deleteUser(
      BuildContext context,
      String id,
      )
  async {
    try{
      final result = await ApiService.deleteRequestData('${ApiEndPoint.deleteUser}$id/', context);
      return ApiResponse.completed(result);
    }catch (e) {
      printLog("ApiException: ${e}");
      if (e is ApiException) {
        // Handle ApiException
        printLog("ApiException: ${e.message}");

        Map<String, dynamic> errorMessageJson = json.decode(e.message);
        String errorMessage =
            errorMessageJson['message'] ?? errorMessageJson['error'] ?? 'An error occurred';
        ShowMessage.inDialog(context,errorMessage.capitalizeFirst.toString(), true);

        return ApiResponse.error(errorMessage);
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }

  Future<ApiResponse<dynamic>> updateTradePreference(
      BuildContext context,
      Map<String, dynamic> body,
      String id,
      )
  async {
    try{
      final result = await ApiService.postRequestData(ApiEndPoint.updatePreference, body, context, sendToken: true);
      print("updateTradePreference Saved Response: ${result}");
      return ApiResponse.completed(result);
    }catch (e) {
      printLog("ApiException: ${e}");
      if (e is ApiException) {
        // Handle ApiException
        printLog("ApiException: ${e.message}");

        Map<String, dynamic> errorMessageJson = json.decode(e.message);
        String errorMessage =
            errorMessageJson['message'] ?? errorMessageJson['error'] ?? 'An error occurred';
        ShowMessage.inDialog(context,errorMessage.capitalizeFirst.toString(), true);

        return ApiResponse.error(errorMessage);
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }

  Future<ApiResponse<dynamic>> getTradePreference(
      BuildContext context,
      String id,
      )
  async {
    try {
      // Backend uses JWT token to identify user, no need to pass user ID in URL
      var response = await ApiService.getRequestData(
          ApiEndPoint.getPreference, context, useToken: true);
      GetTradePreferenceResponseModel responseModel = GetTradePreferenceResponseModel.fromJson(response);
      userController.setUserPreference  = responseModel;
      printLog("getTradePreference Saved Response ${userController.userInterest.value.toJson()}");
      return ApiResponse.completed(response);
    } catch (e) {
      printLog("ApiException: $e");
      if (e is ApiException) {
        // Handle ApiException
        printLog("ApiException: ${e.message}");

        Map<String, dynamic> errorMessageJson = json.decode(e.message);
        String errorMessage =
            errorMessageJson['message'] ?? 'An error occurred';
        ShowMessage.inDialog(
            context, errorMessage.capitalizeFirst.toString(), true);

        return ApiResponse.error(errorMessage);
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }

  Future<ApiResponse<dynamic>> addUserInterest(
      BuildContext context,
      Map<String, dynamic> body,
      String id,
      )
  async {
    try{
      // Backend uses JWT token to identify user, no need to pass user ID in URL
      final result = await ApiService.postRequestData(ApiEndPoint.addInterest, body, context, sendToken: true);
      return ApiResponse.completed(result);
    }catch (e) {
      printLog("ApiException: ${e}");
      if (e is ApiException) {
        // Handle ApiException
        printLog("ApiException: ${e.message}");

        Map<String, dynamic> errorMessageJson = json.decode(e.message);
        String errorMessage =
            errorMessageJson['message'] ?? errorMessageJson['error'] ?? 'An error occurred';
        ShowMessage.inDialog(context,errorMessage.capitalizeFirst.toString(), true);

        return ApiResponse.error(errorMessage);
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }

  Future<ApiResponse<dynamic>> getUserInterests(
      BuildContext context,
      String id,
      )
  async {
    try {
      // Backend uses JWT token to identify user, no need to pass user ID in URL
      var response = await ApiService.getRequestData(
          ApiEndPoint.getUserInterests, context, useToken: true);
      AllInterestResponseModel responseModel =
      AllInterestResponseModel.fromJson(response);
      userController.setUserInterest = responseModel;
      printLog("Saved Response ${userController.userInterest.value.toJson()}");
      return ApiResponse.completed(response);
    } catch (e) {
      printLog("ApiException: $e");
      if (e is ApiException) {
        // Handle ApiException
        printLog("ApiException: ${e.message}");

        Map<String, dynamic> errorMessageJson = json.decode(e.message);
        String errorMessage =
            errorMessageJson['message'] ?? 'An error occurred';
        ShowMessage.inDialog(
            context, errorMessage.capitalizeFirst.toString(), true);

        return ApiResponse.error(errorMessage);
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }


  Future<ApiResponse<dynamic>> paymentRequest(
      BuildContext context,
      Map<String, dynamic> body,
      )
  async {
    try{
      final result = await ApiService.postRequestData(ApiEndPoint.paymentUrl, body, context);
      return ApiResponse.completed(result);
    }catch (e) {
      printLog("ApiException: ${e}");
      if (e is ApiException) {
        // Handle ApiException
        printLog("ApiException: ${e.message}");

        Map<String, dynamic> errorMessageJson = json.decode(e.message);
        String errorMessage =
            errorMessageJson['message'] ?? errorMessageJson['error'] ?? 'An error occurred';
        ShowMessage.inDialog(context,errorMessage.capitalizeFirst.toString(), true);

        return ApiResponse.error(errorMessage);
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }

  Future<ApiResponse<dynamic>> traderProfile(
      BuildContext context,
      String id,
      )
  async {
    try{
      userController.setLoading = true;
      final result = await ApiService.getRequestData(ApiEndPoint.traderProfile+'$id/', context,useToken: true);
      TraderProfileResponseModel responseModel = TraderProfileResponseModel.fromJson(result);
      userController.setTraderProfile = responseModel;
      printLog("Saved Response ${userController.traderProfile.value.toJson()}");
      userController.setLoading = false;
      return ApiResponse.completed(result);
    }catch (e) {
      printLog("ApiException: ${e}");
      if (e is ApiException) {
        userController.setLoading = false;
        // Handle ApiException
        printLog("ApiException: ${e.message}");

        Map<String, dynamic> errorMessageJson = json.decode(e.message);
        String errorMessage =
            errorMessageJson['message'] ?? errorMessageJson['error'] ?? 'An error occurred';
        ShowMessage.inDialog(context,errorMessage.capitalizeFirst.toString(), true);

        return ApiResponse.error(errorMessage);
      } else {
        userController.setLoading = false;
        return ApiResponse.error(e.toString());
      }
    }
  }


}

