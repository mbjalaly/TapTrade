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
      String? id = await SharedPreferencesService().getString(KeyConstants.userId);
      final result = await ApiService.getRequestData(ApiEndPoint.getUserProfile+'$id/', context,useToken: true);
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
            errorMessageJson['error'] ?? 'An error occurred';
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
    try{
      final result = await ApiService.postRequestWithFile(ApiEndPoint.updateProfile+'$id/', body, context);
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

  Future<ApiResponse<dynamic>> updateTradePreference(
      BuildContext context,
      Map<String, dynamic> body,
      String id,
      )
  async {
    try{
      final result = await ApiService.postRequestData(ApiEndPoint.updatePreference+'$id/', body, context);
      print("updateTradePreference Saved Response: ${result}");
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

  Future<ApiResponse<dynamic>> getTradePreference(
      BuildContext context,
      String id,
      )
  async {
    try {
      var response = await ApiService.getRequestData(
          ApiEndPoint.getPreference+"$id/", context,useToken: false);
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
      final result = await ApiService.postRequestData(ApiEndPoint.addInterest+'$id/', body, context);
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

  Future<ApiResponse<dynamic>> getUserInterests(
      BuildContext context,
      String id,
      )
  async {
    try {
      var response = await ApiService.getRequestData(
          ApiEndPoint.getUserInterests+"$id/", context,useToken: false);
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
            errorMessageJson['error'] ?? 'An error occurred';
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
            errorMessageJson['error'] ?? 'An error occurred';
        ShowMessage.inDialog(context,errorMessage.capitalizeFirst.toString(), true);

        return ApiResponse.error(errorMessage);
      } else {
        userController.setLoading = false;
        return ApiResponse.error(e.toString());
      }
    }
  }


}

