import 'package:flutter/material.dart';
import 'package:taptrade/Const/appConfig.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class KeyConstants {
  static const String accessToken = 'accessToken';
  static const String userId = 'userId';
  static const String graphCurrency = 'graphCurrency';
  static const String onboardingCompleted = 'onboardingCompleted';
  static const String fcmToken = 'fcmToken';
  static const String seenMatchKeys = 'seenMatchKeys';
  
  // Use AppConfig for dynamic configuration from .env
  static String get imageUrl => AppConfig.imageBaseUrl;
  static const String imagePlaceHolder = 'https://archive.org/download/placeholder-image/placeholder-image.jpg';
}

class Global {
  static String globalCurrency = "";
  static String about = "";

  // Method to set global currency
  static void setGlobalCurrency(String currency) {
    globalCurrency = currency;
  }

  static void setAbout(String about2) {
    about = about2;
  }

  // Method to get global currency
  static String getGlobalCurrency() {
    return globalCurrency;
  }

  static String getAbout() {
    return about;
  }
}
