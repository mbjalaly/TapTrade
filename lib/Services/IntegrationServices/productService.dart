import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/apiEndPoint.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Models/LikedProduct/likedProduct.dart';
import 'package:taptrade/Models/MatchProduct/matchProduct.dart';
import 'package:taptrade/Models/MyProductModel/myProductModel.dart';
import 'package:taptrade/Models/TradeModel/tradeModel.dart';
import 'package:taptrade/Models/TradeRequest/tradeRequest.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/ApiServices/apiServices.dart';
import 'package:taptrade/Services/logService.dart';
import 'package:taptrade/Utills/showMessages.dart';

class ProductService {
  static final ProductService instance = ProductService._internal();

  factory ProductService() {
    return instance;
  }

  ProductService._internal();

  var productController = Get.find<ProductController>();

  // Rx<MatchProductResponseModel> matchedProduct = MatchProductResponseModel().obs;
  // Rx<LikeProductResponseModel> likeProduct = LikeProductResponseModel().obs;
  // Rx<LikeProductResponseModel> myProduct = LikeProductResponseModel().obs;
  // Rx<TradeRequestResponseModel> tradeRequestProduct = TradeRequestResponseModel().obs;
  // Rx<TradeResponseModel> tradeResponseModel = TradeResponseModel().obs;

  Future<ApiResponse<dynamic>> addSingleProduct(
      BuildContext context,
      Map<String, dynamic> body,
      String id,
      )
  async {
    try{
      final result = await ApiService.postRequestWithFile(ApiEndPoint.addSingleProducts+'$id/', body, context);
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

  Future<ApiResponse<dynamic>> addUserProducts(
      BuildContext context,
      Map<String, dynamic> body,
      String id,
      )
  async {
    try{
      final result = await ApiService.postRequestData(ApiEndPoint.addUserProducts+'$id/', body, context);
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

  Future<ApiResponse<dynamic>> getMatchProduct(
      BuildContext context,
      String id,
      )
  async {
    try{
      final result = await ApiService.getRequestData(ApiEndPoint.matchingProduct+'$id/', context);
      MatchProductResponseModel responseModel = MatchProductResponseModel.fromJson(result);
      productController.setMatchedProduct = responseModel;
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


  Future<ApiResponse<dynamic>> getLikeProduct(
      BuildContext context,
      String id,
      )
  async {
    try{
      final result = await ApiService.getRequestData(ApiEndPoint.likeProduct+'$id/', context);
      LikeProductResponseModel responseModel = LikeProductResponseModel.fromJson(result);
      productController.setLikeProduct = responseModel;
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

  Future<ApiResponse<dynamic>> getMyProduct(
      BuildContext context,
      String id,
      )
  async {
    try{
      final result = await ApiService.getRequestData(ApiEndPoint.myProduct+'$id/', context);
      MyProductResponseModel responseModel = MyProductResponseModel.fromJson(result);
      productController.setMyProduct = responseModel;
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

  Future<ApiResponse<dynamic>> deleteMyProduct(
      BuildContext context,
      String id,
      )
  async {
    try{
      final result = await ApiService.deleteRequestData(ApiEndPoint.deleteProduct+'$id/', context);
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


  Future<ApiResponse<dynamic>> getTradeRequestProduct(
      BuildContext context,
      String id,
      )
  async {
    try{
      final result = await ApiService.getRequestData(ApiEndPoint.tradeRequestProduct+'$id/', context);
      TradeRequestResponseModel responseModel = TradeRequestResponseModel.fromJson(result);
      productController.setTradeRequestProduct = responseModel;
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

  Future<ApiResponse<dynamic>> productLikeDislike(
      BuildContext context,
      Map<String,dynamic> body,
      )
  async {
    try{
      final result = await ApiService.postRequestData(ApiEndPoint.productLikeAndDisLike,body,context);
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

  Future<ApiResponse<dynamic>> createTradeRequest(
      BuildContext context,
      Map<String,dynamic> body,
      )
  async {
    try{
      final result = await ApiService.postRequestData(ApiEndPoint.createTrade,body,context);
      TradeResponseModel responseModel = TradeResponseModel.fromJson(result);
      productController.setTradeResponseModel = responseModel;
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

  Future<ApiResponse<dynamic>> acceptTradeRequest(
      BuildContext context,
      String id,
      )
  async {
    try{
      final result = await ApiService.postRequestData(ApiEndPoint.acceptTrade+"$id/",{},context);
      TradeResponseModel responseModel = TradeResponseModel.fromJson(result);
      productController.setTradeResponseModel = responseModel;
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


  Future<ApiResponse<dynamic>> tradePaymentStatus(
      BuildContext context,
      String id,
      )
  async {
    try{
      Map<String,dynamic> body = {
        "payment_status": "paid"
      };
      final result = await ApiService.patchRequestData(ApiEndPoint.tradePaymentStatus+"$id/",body,context);
      // TradeResponseModel responseModel = TradeResponseModel.fromJson(result);
      // productController.setTradeResponseModel = responseModel;
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
}
