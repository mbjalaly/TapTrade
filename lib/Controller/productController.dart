import 'package:get/get.dart';
import 'package:taptrade/Models/LikedProduct/likedProduct.dart';
import 'package:taptrade/Models/MatchProduct/matchProduct.dart';
import 'package:taptrade/Models/MyProductModel/myProductModel.dart';
import 'package:taptrade/Models/TradeModel/tradeModel.dart';
import 'package:taptrade/Models/TradeRequest/tradeRequest.dart';


class ProductController extends GetxController{
  Rx<MatchProductResponseModel> matchedProduct = MatchProductResponseModel().obs;
  Rx<LikeProductResponseModel> likeProduct = LikeProductResponseModel().obs;
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
}