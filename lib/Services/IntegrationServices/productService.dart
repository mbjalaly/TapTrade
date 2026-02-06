import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/apiEndPoint.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Models/LikedProduct/likedProduct.dart';
import 'package:taptrade/Models/MatchProduct/matchProduct.dart';
import 'package:taptrade/Models/MyProductModel/myProductModel.dart';
import 'package:taptrade/Models/TradeModel/tradeModel.dart';
import 'package:taptrade/Models/ChatModels/matchModel.dart';
import 'package:taptrade/Screens/Dashboard/Match/matchDeal.dart';
import 'package:taptrade/Screens/Dashboard/Chat/chatScreen.dart';
import 'package:taptrade/Models/TradeRequest/tradeRequest.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/ApiServices/apiServices.dart';
import 'package:taptrade/Services/logService.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taptrade/Services/NotificationService/notification_service.dart';
import 'package:taptrade/Services/CooldownService/cooldownService.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Widgets/matchPopupDialog.dart';
 

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
      print("=== ADDING PRODUCT ===");
      print("User ID: $id");
      print("Body keys: ${body.keys.toList()}");
      if (body['image'] != null) {
        print("Image file: ${body['image']}");
      }
      
      // Backend uses JWT token to identify user, no need to pass user ID in URL
      final result = await ApiService.postRequestWithFile(ApiEndPoint.addSingleProducts, body, context, sendToken: true);
      print("Product added successfully!");
      return ApiResponse.completed(result);
    }catch (e) {
      printLog("ApiException: ${e}");
      if (e is ApiException) {
        // Handle timeout errors specifically
        if (e.message.contains('timed out') || e.message.contains('timeout')) {
          ShowMessage.inDialog(context, 'Upload is taking longer than expected. Please check your internet connection and try again.', true);
          return ApiResponse.error('Upload timeout - please try again with a smaller image or better internet connection');
        }
        
        // Try to parse server error as JSON, otherwise fall back to plain text
        String fallback = 'Unable to add product. Please try again later.';
        try {
          final Map<String, dynamic> errorMessageJson = json.decode(e.message);
          // Handle different server response formats
          String errorMessage = errorMessageJson['message'] ?? 
                               errorMessageJson['error'] ?? 
                               fallback;
          
          // Handle specific server errors
          if (errorMessage.contains('disk I/O error')) {
            errorMessage = 'Server storage error. Please try again with a smaller image or contact support.';
          } else if (errorMessage.contains('file too large')) {
            errorMessage = 'Image file is too large. Please use a smaller image.';
          }
          
          ShowMessage.inDialog(context, errorMessage, true);
          return ApiResponse.error(errorMessage);
        } catch (_) {
          final String message = e.message.toString().startsWith('<!DOCTYPE')
              ? fallback
              : e.message.toString();
          ShowMessage.inDialog(context, message, true);
          return ApiResponse.error(message);
        }
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

  Future<ApiResponse<dynamic>> updateProduct(
      BuildContext context,
      Map<String, dynamic> body,
      String productId,
      )
  async {
    try{
      print("=== UPDATING PRODUCT ===");
      print("Product ID: $productId");
      print("Body keys: ${body.keys.toList()}");
      if (body['image'] != null) {
        print("Image file: ${body['image']}");
      }
      
      // Add product_id to body for backend
      body['product_id'] = productId;
      body['id'] = productId; // Also add as 'id' for compatibility
      
      // Backend uses PUT method, but postRequestWithFile can handle it if we modify the method
      // For now, use postRequestWithFile and backend will handle PUT
      final result = await ApiService.postRequestWithFile(ApiEndPoint.updateProduct, body, context, sendToken: true);
      print("Product updated successfully!");
      return ApiResponse.completed(result);
    }catch (e) {
      printLog("ApiException: ${e}");
      if (e is ApiException) {
        // Handle timeout errors specifically
        if (e.message.contains('timed out') || e.message.contains('timeout')) {
          ShowMessage.inDialog(context, 'Update is taking longer than expected. Please check your internet connection and try again.', true);
          return ApiResponse.error('Upload timeout - please try again with a smaller image or better internet connection');
        }
        
        // Try to parse server error as JSON, otherwise fall back to plain text
        String fallback = 'Unable to update product. Please try again later.';
        try {
          final Map<String, dynamic> errorMessageJson = json.decode(e.message);
          // Handle different server response formats
          String errorMessage = errorMessageJson['message'] ?? 
                               errorMessageJson['error'] ?? 
                               fallback;
          
          // Handle specific server errors
          if (errorMessage.contains('disk I/O error')) {
            errorMessage = 'Server storage error. Please try again with a smaller image or contact support.';
          } else if (errorMessage.contains('file too large')) {
            errorMessage = 'Image file is too large. Please use a smaller image.';
          }
          
          ShowMessage.inDialog(context, errorMessage, true);
          return ApiResponse.error(errorMessage);
        } catch (_) {
          final String message = e.message.toString().startsWith('<!DOCTYPE')
              ? fallback
              : e.message.toString();
          ShowMessage.inDialog(context, message, true);
          return ApiResponse.error(message);
        }
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
      print("=== API CALL DEBUG ===");
      // Backend uses JWT token to identify user, no need to pass user ID in URL
      print("Calling API: ${ApiEndPoint.matchingProduct}");
      final result = await ApiService.getRequestData(ApiEndPoint.matchingProduct, context, useToken: true);
      print("Raw API Response: $result");
      MatchProductResponseModel responseModel = MatchProductResponseModel.fromJson(result);
      print("Parsed Response - Success: ${responseModel.success}");
      print("Parsed Response - Message: ${responseModel.message}");
      print("Parsed Response - Data Count: ${responseModel.data?.length ?? 0}");
      if (responseModel.data != null && responseModel.data!.isNotEmpty) {
        print("First match data: User Product ID: ${responseModel.data!.first.userProduct?.id}, Other Product ID: ${responseModel.data!.first.otherProduct?.id}");
      }
      productController.setMatchedProduct = responseModel;
      // After updating controller, check for new matches and notify
      await _notifyOnNewMatches(responseModel);
      return ApiResponse.completed(result);
    }catch (e) {
      printLog("ApiException: ${e}");
      if (e is ApiException) {
        // Handle ApiException
        printLog("ApiException: ${e.message}");

        Map<String, dynamic> errorMessageJson = json.decode(e.message);
        String errorMessage =
            errorMessageJson['error'] ?? 'An error occurred';
        // ShowMessage.inDialog(context,errorMessage.capitalizeFirst.toString(), true);

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
      print("=== LIKE PRODUCT API DEBUG ===");
      // Backend uses JWT token to identify user, no need to pass user ID in URL
      print("Calling API: ${ApiEndPoint.likeProduct}");
      final result = await ApiService.getRequestData(ApiEndPoint.likeProduct, context, useToken: true);
      print("Raw Like API Response: $result");
      LikeProductResponseModel responseModel = LikeProductResponseModel.fromJson(result);
      print("Parsed Like Response - Success: ${responseModel.success}");
      print("Parsed Like Response - Message: ${responseModel.message}");
      print("Parsed Like Response - Data Count: ${responseModel.data?.length ?? 0}");
      if (responseModel.data != null && responseModel.data!.isNotEmpty) {
        print("Sample like data:");
        for (int i = 0; i < responseModel.data!.length && i < 3; i++) {
          final like = responseModel.data![i];
          print("  Like $i: User Product ID: ${like.userProduct?.id}, Other Product ID: ${like.otherProduct?.id}, Has Like: ${like.hasLike}");
        }
      }
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
        // ShowMessage.inDialog(context,errorMessage.capitalizeFirst.toString(), true);

        return ApiResponse.error(errorMessage);
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }

  /// Get all products the user has disliked (refused)
  Future<ApiResponse<dynamic>> getDislikedProducts(BuildContext context) async {
    try {
      final result = await ApiService.getRequestData(
        ApiEndPoint.dislikedProducts,
        context,
        useToken: true,
      );
      return ApiResponse.completed(result);
    } catch (e) {
      printLog("ApiException: $e");
      if (e is ApiException) {
        printLog("ApiException: ${e.message}");
        Map<String, dynamic> errorMessageJson = json.decode(e.message);
        String errorMessage = errorMessageJson['error'] ?? 'An error occurred';
        ShowMessage.inDialog(context, errorMessage.capitalizeFirst.toString(), true);
        return ApiResponse.error(errorMessage);
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }

  /// Remove a dislike record (re-enable product for swiping)
  Future<ApiResponse<dynamic>> removeDislike(
    BuildContext context,
    int feedbackId,
    int productId,
  ) async {
    try {
      final result = await ApiService.deleteRequestData(
        '${ApiEndPoint.removeDislike}$feedbackId/',
        context,
        sendToken: true,
      );

      // Also clear from local cooldown service
      await CooldownService.instance.clearCooldownForProduct(productId);

      return ApiResponse.completed(result);
    } catch (e) {
      printLog("ApiException: $e");
      if (e is ApiException) {
        printLog("ApiException: ${e.message}");
        Map<String, dynamic> errorMessageJson = json.decode(e.message);
        String errorMessage = errorMessageJson['error'] ?? 'An error occurred';
        ShowMessage.inDialog(context, errorMessage.capitalizeFirst.toString(), true);
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
      // Backend uses JWT token to identify user, no need to pass user ID in URL
      // Use longer timeout for products endpoint (may contain large base64 images)
      final result = await ApiService.getRequestData(
        ApiEndPoint.myProduct, 
        context, 
        useToken: true,
        timeout: const Duration(seconds: 30),
      );
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
        // ShowMessage.inDialog(context,errorMessage.capitalizeFirst.toString(), true);

        return ApiResponse.error(errorMessage);
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }

  Future<ApiResponse<dynamic>> activateProduct(
      BuildContext context,
      int productId,
      )
  async {
    try{
      final result = await ApiService.postRequestData(
        ApiEndPoint.activateProduct(productId),
        {},
        context,
        sendToken: true,
      );
      return ApiResponse.completed(result);
    }catch (e) {
      printLog("ApiException: ${e}");
      if (e is ApiException) {
        printLog("ApiException: ${e.message}");
        try {
          Map<String, dynamic> errorMessageJson = json.decode(e.message);
          String errorMessage = errorMessageJson['message'] ?? errorMessageJson['error'] ?? 'Failed to activate product';
          ShowMessage.inDialog(context, errorMessage, true);
          return ApiResponse.error(errorMessage);
        } catch (_) {
          ShowMessage.inDialog(context, e.message, true);
          return ApiResponse.error(e.message);
        }
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
      final result = await ApiService.deleteRequestData(ApiEndPoint.deleteProduct+'$id/', context, sendToken: true);
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
  
  /// Fetch a single product by ID with all images
  /// This fetches from getallproducts and filters by ID
  Future<Data?> getProductById(
      BuildContext context,
      int productId,
      ) async {
    try {
      debugPrint('=== FETCHING PRODUCT BY ID ===');
      debugPrint('Product ID: $productId');
      
      // Use the getallproducts endpoint which returns full product data with images
      final result = await ApiService.getRequestData(
        '${ApiEndPoint.myProduct}?product_id=$productId',
        context,
        useToken: true,
        timeout: const Duration(seconds: 15),
      );
      
      // Parse response - could be single product or list
      if (result is Map<String, dynamic>) {
        if (result['data'] != null) {
          if (result['data'] is List && (result['data'] as List).isNotEmpty) {
            // Find the product with matching ID
            final List<dynamic> products = result['data'] as List;
            final productJson = products.firstWhereOrNull(
              (p) => p['id'] == productId,
            );
            if (productJson != null) {
              final product = Data.fromJson(productJson);
              return product;
            }
          } else if (result['data'] is Map) {
            // Single product returned
            final product = Data.fromJson(result['data']);
            if (product.id == productId) {
              return product;
            }
          }
        }
      }
      
      return null;
    } catch (e) {
      printLog("Error fetching product by ID: $e");
      return null;
    }
  }


  Future<ApiResponse<dynamic>> getTradeRequestProduct(
      BuildContext context,
      String id,
      )
  async {
    try{
      final result = await ApiService.getRequestData(
        ApiEndPoint.tradeRequestProduct+'$id/', 
        context, 
        useToken: true,
      );
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
      print("=== LIKE/DISLIKE DEBUG ===");
      print("Like/Dislike body: $body");
      final result = await ApiService.postRequestData(ApiEndPoint.productLikeAndDisLike,body,context, sendToken: true);
      print("Like/Dislike result: $result");

      // Check if backend detected a mutual match
      final bool isMutualMatch = result['is_mutual_match'] == true;
      if (isMutualMatch) {
        print("🎉 MUTUAL MATCH DETECTED BY BACKEND! 🎉");
        print("Full result: ${json.encode(result)}");

        // Parse match data from response
        final mutualMatchData = result['mutual_match_data'];
        print("Mutual match data: ${json.encode(mutualMatchData)}");

        if (mutualMatchData != null && mutualMatchData['match'] != null) {
          final matchData = mutualMatchData['match'];
          print("Match data received: ${json.encode(matchData)}");

          // Create MatchModel from the response
          final match = MatchModel(
            id: matchData['id'],
            user1Id: matchData['user1_id'],
            user2Id: matchData['user2_id'],
            user1ProductId: matchData['user1_product_id'],
            user2ProductId: matchData['user2_product_id'],
            matchedAt: matchData['matched_at'] != null
                ? DateTime.tryParse(matchData['matched_at'])
                : DateTime.now(),
            status: matchData['status'] ?? 'active',
            myProduct: matchData['my_product'] != null
                ? MatchProductInfo.fromJson(matchData['my_product'])
                : null,
            theirProduct: matchData['their_product'] != null
                ? MatchProductInfo.fromJson(matchData['their_product'])
                : null,
            otherUser: matchData['other_user'] != null
                ? MatchUserInfo.fromJson(matchData['other_user'])
                : null,
          );

          // Show "It's a Match!" popup immediately (interrupt swiping like Tinder)
          print("🎊 Showing match popup - interrupting swipe session!");
          try {
            await MatchPopupDialog.show(
              context: context,
              match: match,
              onSendMessage: () {
                // Navigate to chat screen
                print("User chose to send message");
                Get.to(() => ChatScreen(match: match));
              },
              onKeepSwiping: () {
                // Just close popup, user continues swiping
                print("User chose to keep swiping");
              },
            );
          } catch (e) {
            print("❌ Error showing match popup: $e");
            // Fallback to notification if popup fails
            await NotificationService.showLocalMatchNotification(
              otherProductId: matchData['user2_product_id'] ?? 0,
              otherProductTitle: match.theirProduct?.title ?? "It's a Match!",
            );
          }
        } else {
          print("⚠️ WARNING: Match data is null or incomplete");
          print("mutualMatchData is null: ${mutualMatchData == null}");
          if (mutualMatchData != null) {
            print("mutualMatchData['match'] is null: ${mutualMatchData['match'] == null}");
          }

          // Fallback: Show notification if no match data
          final String nearbyUserProductId = body['nearby_user_product']?.toString() ?? '';
          await NotificationService.showLocalMatchNotification(
            otherProductId: int.tryParse(nearbyUserProductId) ?? 0,
            otherProductTitle: "It's a Match!",
          );
        }

        // Refresh like data
        final String userId = body['user']?.toString() ?? '';
        if (userId.isNotEmpty) {
          await getLikeProduct(context, userId);
        }
      }

      return ApiResponse.completed(result);
    }catch (e) {
      printLog("ApiException in productLikeDislike: ${e}");
      if (e is ApiException) {
        printLog("ApiException message: ${e.message}");

        try {
          Map<String, dynamic> errorMessageJson = json.decode(e.message);
          String errorMessage = errorMessageJson['error'] ?? errorMessageJson['message'] ?? 'An error occurred';
          ShowMessage.inDialog(context, errorMessage.capitalizeFirst.toString(), true);
          return ApiResponse.error(errorMessage);
        } catch (parseError) {
          // If error message isn't valid JSON, use it as-is
          ShowMessage.inDialog(context, e.message.capitalizeFirst.toString(), true);
          return ApiResponse.error(e.message);
        }
      } else {
        print("Non-ApiException error in productLikeDislike: $e");
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

  /// Mark a trade as complete (first user marks their side as done)
  Future<ApiResponse<dynamic>> markTradeComplete(
      BuildContext context,
      int tradeRequestId,
      ) async {
    try {
      print("=== MARKING TRADE COMPLETE ===");
      print("Trade Request ID: $tradeRequestId");
      
      final result = await ApiService.postRequestData(
        ApiEndPoint.markTradeComplete(tradeRequestId),
        {},
        context,
        sendToken: true,
      );
      
      print("Mark complete result: $result");
      return ApiResponse.completed(result);
    } catch (e) {
      printLog("ApiException in markTradeComplete: $e");
      if (e is ApiException) {
        try {
          Map<String, dynamic> errorJson = json.decode(e.message);
          String errorMessage = errorJson['message'] ?? errorJson['error'] ?? 'Failed to mark trade complete';
          ShowMessage.inDialog(context, errorMessage, true);
          return ApiResponse.error(errorMessage);
        } catch (_) {
          ShowMessage.inDialog(context, e.message, true);
          return ApiResponse.error(e.message);
        }
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }

  /// Confirm a trade as complete (second user confirms the trade is done)
  Future<ApiResponse<dynamic>> confirmTradeComplete(
      BuildContext context,
      int tradeRequestId,
      ) async {
    try {
      print("=== CONFIRMING TRADE COMPLETE ===");
      print("Trade Request ID: $tradeRequestId");
      
      final result = await ApiService.postRequestData(
        ApiEndPoint.confirmTradeComplete(tradeRequestId),
        {},
        context,
        sendToken: true,
      );
      
      print("Confirm complete result: $result");
      return ApiResponse.completed(result);
    } catch (e) {
      printLog("ApiException in confirmTradeComplete: $e");
      if (e is ApiException) {
        try {
          Map<String, dynamic> errorJson = json.decode(e.message);
          String errorMessage = errorJson['message'] ?? errorJson['error'] ?? 'Failed to confirm trade';
          ShowMessage.inDialog(context, errorMessage, true);
          return ApiResponse.error(errorMessage);
        } catch (_) {
          ShowMessage.inDialog(context, e.message, true);
          return ApiResponse.error(e.message);
        }
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }

  /// Cancel a trade request
  Future<ApiResponse<dynamic>> cancelTrade(
      BuildContext context,
      int tradeRequestId,
      ) async {
    try {
      print("=== CANCELLING TRADE ===");
      print("Trade Request ID: $tradeRequestId");
      
      final result = await ApiService.postRequestData(
        ApiEndPoint.cancelTrade(tradeRequestId),
        {},
        context,
        sendToken: true,
      );
      
      print("Cancel trade result: $result");
      return ApiResponse.completed(result);
    } catch (e) {
      printLog("ApiException in cancelTrade: $e");
      if (e is ApiException) {
        try {
          Map<String, dynamic> errorJson = json.decode(e.message);
          String errorMessage = errorJson['message'] ?? errorJson['error'] ?? 'Failed to cancel trade';
          ShowMessage.inDialog(context, errorMessage, true);
          return ApiResponse.error(errorMessage);
        } catch (_) {
          ShowMessage.inDialog(context, e.message, true);
          return ApiResponse.error(e.message);
        }
      } else {
        return ApiResponse.error(e.toString());
      }
    }
  }
}

extension _MatchNotifyExt on ProductService {
  Future<void> _notifyOnNewMatches(MatchProductResponseModel responseModel) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Set<String> seen = (prefs.getStringList(KeyConstants.seenMatchKeys) ?? const <String>[]) .toSet();
      final List<MatchData> matches = responseModel.data ?? const <MatchData>[];
      bool updated = false;
      for (final m in matches) {
        final int otherId = m.otherProduct?.id ?? -1;
        if (otherId <= 0) continue;
        final String key = 'other:$otherId';
        if (!seen.contains(key)) {
          seen.add(key);
          updated = true;
        }
      }
      if (updated) {
        await prefs.setStringList(KeyConstants.seenMatchKeys, seen.toList());
      }
    } catch (_) {
      // Never throw from notifier
    }
  }
  
  Future<void> _checkForMutualMatch(BuildContext context, Map<String, dynamic> body) async {
    try {
      print("=== CHECKING FOR MUTUAL MATCH ===");
      
      // Only check for mutual match if this was a "like" action
      final bool hasLike = body['has_like'] ?? false;
      if (!hasLike) {
        print("Not a like action, skipping mutual match check");
        return;
      }
      
      final String userId = body['user']?.toString() ?? '';
      final String nearbyUserId = body['nearby_user']?.toString() ?? '';
      final String userProductId = body['user_product']?.toString() ?? '';
      final String nearbyUserProductId = body['nearby_user_product']?.toString() ?? '';
      
      print("Checking mutual match:");
      print("  User ID: $userId");
      print("  Nearby User ID: $nearbyUserId");
      print("  User Product ID: $userProductId");
      print("  Nearby User Product ID: $nearbyUserProductId");
      
      if (userId.isEmpty || nearbyUserId.isEmpty || userProductId.isEmpty || nearbyUserProductId.isEmpty) {
        print("Missing required data for mutual match check");
        return;
      }
      
      // Fetch current like data to check for mutual match
      await getLikeProduct(context, userId);
      final allLikes = productController.likeProduct.value.data ?? [];
      
      // Check if the other user also liked our product
      final mutualMatch = allLikes.where((like) =>
        (like.userProduct?.id.toString() == nearbyUserProductId) &&
        (like.otherProduct?.id.toString() == userProductId) &&
        (like.hasLike ?? false)
      ).isNotEmpty;
      
      print("Mutual match found: $mutualMatch");
      
      if (mutualMatch) {
        print("🎉 MUTUAL MATCH DETECTED! 🎉");

        // Show notification for mutual match
        await NotificationService.showLocalMatchNotification(
          otherProductId: int.tryParse(nearbyUserProductId) ?? 0,
          otherProductTitle: "Mutual Match Found!",
        );

        // Navigate to match screen to show the match
        final matchedLike = allLikes.firstWhere(
          (like) =>
              (like.userProduct?.id.toString() == nearbyUserProductId) &&
              (like.otherProduct?.id.toString() == userProductId) &&
              (like.hasLike ?? false),
        );

        // Use Get.to to navigate to match screen
        // Import required: import 'package:get/get.dart';
        // Import required: import 'package:taptrade/Screens/Dashboard/Match/matchDeal.dart';
        Get.to(() => MatchDealScreen(
          isDirect: false,
          likeData: matchedLike,
          matchData: null,
          tradeRequestData: null,
        ));
      }
      
    } catch (e) {
      print("Error checking for mutual match: $e");
      // Don't throw error as this is a background operation
    }
  }
}
