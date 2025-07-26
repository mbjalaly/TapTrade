import 'package:get/get.dart';
import 'package:taptrade/Models/AllInterest/allInterest.dart';
import 'package:taptrade/Models/TradePreference/tradePreference.dart';
import 'package:taptrade/Models/TraderProfileModel/traderProfileModel.dart';
import 'package:taptrade/Models/UserProfile/userProfile.dart';

class UserController extends GetxController{
  Rx<UserProfileResponseModel> userProfile = UserProfileResponseModel().obs;
  Rx<TraderProfileResponseModel> traderProfile = TraderProfileResponseModel().obs;
  Rx<AllInterestResponseModel> userInterest = AllInterestResponseModel().obs;
  Rx<GetTradePreferenceResponseModel> getPreference = GetTradePreferenceResponseModel().obs;
  Rx<bool> isLoading = false.obs;

  set setUserProfile(UserProfileResponseModel responseModel){
    userProfile(responseModel);
    update();
  }
  set setTraderProfile(TraderProfileResponseModel responseModel){
    traderProfile(responseModel);
    update();
  }

  set setUserInterest(AllInterestResponseModel responseModel){
    userInterest(responseModel);
    update();
  }
  set setUserPreference(GetTradePreferenceResponseModel responseModel){
    getPreference(responseModel);
    update();
  }

  set setLoading(bool loading){
    isLoading(loading);
    update();
  }

  void clearAllData() {
    userProfile = UserProfileResponseModel().obs;
    userInterest = AllInterestResponseModel().obs;
    getPreference = GetTradePreferenceResponseModel().obs;
    update(); // Notify listeners of the changes
  }

}