import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage app language preference with persistence
class LocalizationService {
  static LocalizationService? _instance;
  static LocalizationService get instance => _instance ??= LocalizationService._();
  
  LocalizationService._();
  
  static const String _languageCodeKey = 'language_code';
  
  /// Supported locales in the app
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ar'), // Arabic
  ];
  
  /// Get the saved locale or device locale
  Future<Locale> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_languageCodeKey);
    
    if (savedCode != null) {
      // Return saved preference
      return Locale(savedCode);
    }
    
    // Return device locale if supported, otherwise default to English
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    if (supportedLocales.any((l) => l.languageCode == deviceLocale.languageCode)) {
      return Locale(deviceLocale.languageCode);
    }
    
    return const Locale('en');
  }
  
  /// Save locale preference
  Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, locale.languageCode);
  }
  
  /// Check if locale is RTL
  static bool isRtl(Locale locale) {
    return locale.languageCode == 'ar';
  }
  
  /// Get language name for display
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
      default:
        return 'English';
    }
  }
}
