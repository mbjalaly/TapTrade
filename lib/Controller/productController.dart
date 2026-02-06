import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Models/LikedProduct/likedProduct.dart';
import 'package:taptrade/Models/MatchProduct/matchProduct.dart';
import 'package:taptrade/Models/MyProductModel/myProductModel.dart';
import 'package:taptrade/Models/TradeModel/tradeModel.dart';
import 'package:taptrade/Models/TradeRequest/tradeRequest.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';


class ProductController extends GetxController{
  Rx<MatchProductResponseModel> matchedProduct = MatchProductResponseModel().obs;
  Rx<LikeProductResponseModel> likeProduct = LikeProductResponseModel().obs;
  var dislikedProduct = ApiResponse<dynamic>.loading('Loading disliked products').obs;
  Rx<MyProductResponseModel> myProduct = MyProductResponseModel().obs;
  Rx<TradeRequestResponseModel> tradeRequestProduct = TradeRequestResponseModel().obs;
  Rx<TradeResponseModel> tradeResponseModel = TradeResponseModel().obs;

  set setMatchedProduct(MatchProductResponseModel responseModel){
    matchedProduct(responseModel);
    update();
  }

  set setLikeProduct(LikeProductResponseModel responseModel){
    likeProduct(responseModel);
    update();
  }
  set setMyProduct(MyProductResponseModel responseModel){
    myProduct(responseModel);
    update();
  }

  set setTradeRequestProduct(TradeRequestResponseModel responseModel){
    tradeRequestProduct(responseModel);
    update();
  }

  set setTradeResponseModel(TradeResponseModel responseModel){
    tradeResponseModel(responseModel);
    update();
  }
  void clearAllData() {
    matchedProduct.value = MatchProductResponseModel(); // Reset to default instance
    likeProduct.value = LikeProductResponseModel();
    myProduct.value = MyProductResponseModel();
    tradeRequestProduct.value = TradeRequestResponseModel();
    tradeResponseModel.value = TradeResponseModel();
    update(); // Notify listeners of the changes
  }

  /// Fetch disliked products (refused matches)
  Future<void> getDislikedProduct(BuildContext context) async {
    dislikedProduct.value = ApiResponse.loading('Loading disliked products');
    final result = await ProductService.instance.getDislikedProducts(context);
    dislikedProduct.value = result;
  }

  /// Remove a dislike and refresh list
  Future<void> removeDislikeAndRefresh(
    BuildContext context,
    int feedbackId,
    int productId,
  ) async {
    final result = await ProductService.instance.removeDislike(
      context,
      feedbackId,
      productId,
    );

    if (result.status == Status.COMPLETED) {
      // Refresh disliked products list
      await getDislikedProduct(context);
      // Also refresh the swipe deck
      final userController = Get.find<UserController>();
      String userId = userController.userProfile.value.data?.id ?? '';
      if (userId.isNotEmpty) {
        await ProductService.instance.getMatchProduct(context, userId);
      }
    }

    return;
  }
}