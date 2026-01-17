import 'package:flutter/cupertino.dart';
import 'package:taptrade/Const/appConfig.dart';

@immutable
class ApiEndPoint {

  const ApiEndPoint._();

  // Dynamic base URL from environment configuration
  // To switch to Railway: Update API_BASE_URL in .env file
  static String get baseUrl => AppConfig.apiBaseUrl;
  
  // API Endpoints - now use dynamic baseUrl from AppConfig
  static String get register => '${baseUrl}api/user/register/';
  static String get login => '${baseUrl}api/user/login/';
  static String get googleLoginOrRegister => '${baseUrl}api/user/api/social_login_or_register/';
  static String get appleLoginOrRegister => '${baseUrl}api/user/api/social_login_or_register/';
  static String get getAllCategories => '${baseUrl}getallcategories/';
  static String get getAllInterests => '${baseUrl}getallinterests/';
  static String get activation => '${baseUrl}api/user/account/activation/';
  static String get getUserProfile => '${baseUrl}api/user/me/';
  static String get updateProfile => '${baseUrl}api/user/updateProfile/';
  static String get addInterest => '${baseUrl}add-interests/';
  static String get getUserInterests => '${baseUrl}getuserinterests/';
  static String get addSingleProducts => '${baseUrl}add_products/';
  static String get addUserProducts => '${baseUrl}add_user_products/';
  static String get addPreference => '${baseUrl}api/trade/preferences/';
  static String get updatePreference => '${baseUrl}update-interests/';
  static String get getPreference => '${baseUrl}api/trade/getuserpreferences/';
  static String get matchingProduct => '${baseUrl}api/trade/api/nearby-users/';
  static String get likeProduct => '${baseUrl}api/trade/matchfeedback/user/';
  static String get myProduct => '${baseUrl}getallproducts/';
  static String get tradeRequestProduct => '${baseUrl}api/trade/trade-requests/';
  static String get productLikeAndDisLike => '${baseUrl}api/trade/create-matchfeedback/';
  static String get createTrade => '${baseUrl}api/trade/trade-requests/create/';
  static String get acceptTrade => '${baseUrl}api/trade/accept-requests/';
  static String get userNameAndEmailValidation => '${baseUrl}api/user/check-user/?';
  static String get traderProfile => '${baseUrl}api/user/profile/';
  static String get tradePaymentStatus => '${baseUrl}api/trade/trade_payment_status/';
  static String get deleteProduct => '${baseUrl}delete_products/';
  static String get updateProduct => '${baseUrl}update_products/';
  static String get deleteUser => '${baseUrl}api/user/delete/';
  static String get forgotPassword => '${baseUrl}api/user/forgotpassword/';

  // Payment URL - separate service, also configurable
  static String get paymentUrl => AppConfig.paymentApiUrl;

  // Match & Chat Endpoints
  static String get createMatch => '${baseUrl}api/matches/create/';
  static String get getMatches => '${baseUrl}api/matches/';
  static String getMatchMessages(int matchId) => '${baseUrl}api/matches/$matchId/messages/';
  static String sendMatchMessage(int matchId) => '${baseUrl}api/matches/$matchId/messages/';
  static String markMatchRead(int matchId) => '${baseUrl}api/matches/$matchId/read/';

}