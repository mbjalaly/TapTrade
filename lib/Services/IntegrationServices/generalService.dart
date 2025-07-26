import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get.dart' as getx;
import 'package:taptrade/Const/apiEndPoint.dart';
import 'package:taptrade/Models/AllCategories/allCategories.dart';
import 'package:taptrade/Models/AllInterest/allInterest.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/ApiServices/apiServices.dart';
import 'package:taptrade/Services/logService.dart';
import 'package:taptrade/Utills/showMessages.dart';

class GeneralService {
  static final GeneralService instance = GeneralService._internal();

  factory GeneralService() {
    return instance;
  }

  GeneralService._internal();
  Rx<AllCategoriesResponseModel> allCategory = AllCategoriesResponseModel().obs;
  Rx<AllInterestResponseModel> allInterest = AllInterestResponseModel().obs;

  Future<ApiResponse<dynamic>> getAllCategories(
    BuildContext context,
  )
  async {
    try {
      var response = await ApiService.getRequestData(
          ApiEndPoint.getAllCategories, context,useToken: false);
      AllCategoriesResponseModel responseModel =
          AllCategoriesResponseModel.fromJson(response);
      allCategory.value = responseModel;
      printLog("Saved Response ${allCategory.toJson()}");
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

  Future<ApiResponse<dynamic>> getAllInterests(
    BuildContext context,
  )
  async {
    try {
      var response = await ApiService.getRequestData(
          ApiEndPoint.getAllInterests, context,useToken: false);
      AllInterestResponseModel responseModel =
      AllInterestResponseModel.fromJson(response);
      allInterest.value = responseModel;
      printLog("Saved Response ${allInterest.toJson()}");
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
}
