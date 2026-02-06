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
  static String get updatePreference => '${baseUrl}api/trade/preferences/';
  static String get getPreference => '${baseUrl}api/trade/getuserpreferences/';
  static String get matchingProduct => '${baseUrl}api/trade/api/nearby-users/';
  static String get likeProduct => '${baseUrl}api/trade/matchfeedback/user/';
  static String get dislikedProducts => '${baseUrl}api/trade/disliked-products/';
  static String get removeDislike => '${baseUrl}api/trade/disliked-products/';
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
  static String activateProduct(int id) => '${baseUrl}activate_product/$id/';

  // Password Reset Endpoints (Phone OTP-based)
  static String get forgotPassword => '${baseUrl}api/user/forgot-password/';
  static String get verifyResetOtp => '${baseUrl}api/user/verify-reset-otp/';
  static String get resetPassword => '${baseUrl}api/user/reset-password/';

  // SMS OTP Endpoints (UnoSend)
  static String get sendSmsOtp => '${baseUrl}api/sms/send-otp/';
  static String get verifySmsOtp => '${baseUrl}api/sms/verify-otp/';

  // Payment URL - separate service, also configurable
  static String get paymentUrl => AppConfig.paymentApiUrl;

  // Match & Chat Endpoints
  static String get createMatch => '${baseUrl}api/matches/create/';
  static String get getMatches => '${baseUrl}api/matches/';
  static String getMatchById(int matchId) => '${baseUrl}api/matches/$matchId/';
  static String getMatchMessages(int matchId) => '${baseUrl}api/matches/$matchId/messages/';
  static String sendMatchMessage(int matchId) => '${baseUrl}api/matches/$matchId/messages/';
  static String markMatchRead(int matchId) => '${baseUrl}api/matches/$matchId/read/';

  // Bilateral Trade Confirmation Endpoints
  static String markTradeComplete(int tradeRequestId) => '${baseUrl}api/trade/mark-complete/$tradeRequestId/';
  static String confirmTradeComplete(int tradeRequestId) => '${baseUrl}api/trade/confirm-complete/$tradeRequestId/';
  static String cancelTrade(int tradeRequestId) => '${baseUrl}api/trade/cancel/$tradeRequestId/';

}