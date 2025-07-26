import 'package:flutter/cupertino.dart';

@immutable
class ApiEndPoint {

  const ApiEndPoint._();

  static const baseUrl = 'https://taptradebackend.pythonanywhere.com/';
  static const register = '${baseUrl}api/user/register/';
  static const login = '${baseUrl}api/user/login/';
  static const socialLoginOrRegister = '${baseUrl}api/user/api/social_login_or_register/';
  static const getAllCategories = '${baseUrl}getallcategories/';
  static const getAllInterests = '${baseUrl}getallinterests/';
  static const activation = '${baseUrl}api/user/account/activation/';
  static const getUserProfile = '${baseUrl}api/user/me/';
  static const updateProfile = '${baseUrl}api/user/updateProfile/';
  static const addInterest = '${baseUrl}add-interests/';
  static const getUserInterests = '${baseUrl}getuserinterests/';
  static const addSingleProducts = '${baseUrl}add_products/';
  static const addUserProducts = '${baseUrl}add_user_products/';
  static const addPreference = '${baseUrl}api/trade/preferences/';
  static const updatePreference = '${baseUrl}update-interests/';
  static const getPreference = '${baseUrl}api/trade/getuserpreferences/';
  static const matchingProduct = '${baseUrl}api/trade/api/nearby-users/';
  static const likeProduct = '${baseUrl}api/trade/matchfeedback/user/';
  static const myProduct = '${baseUrl}getallproducts/';
  static const tradeRequestProduct = '${baseUrl}api/trade/trade-requests/';
  static const productLikeAndDisLike = '${baseUrl}api/trade/create-matchfeedback/';
  static const createTrade = '${baseUrl}api/trade/trade-requests/create/';
  static const acceptTrade = '${baseUrl}api/trade/accept-requests/';
  static const userNameAndEmailValidation = '${baseUrl}api/user/check-user/?';
  static const paymentUrl = 'https://app.duelingarea.com/api/payment/';
  static const traderProfile = '${baseUrl}api/user/profile/';
  static const tradePaymentStatus = '${baseUrl}api/trade/trade_payment_status/';
  static const deleteProduct = '${baseUrl}delete_products/';


}