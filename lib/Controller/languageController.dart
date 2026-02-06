import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Screens/Splash/splashScreen.dart';
import 'package:taptrade/Services/LocalizationService/localization_service.dart';

/// GetX Controller for managing app language with reactive updates
class LanguageController extends GetxController {
  static LanguageController get to => Get.find<LanguageController>();
  
  /// Current locale - observable for reactive UI updates
  final Rx<Locale> currentLocale = const Locale('en').obs;
  
  /// Whether the app is in RTL mode
  bool get isRtl => currentLocale.value.languageCode == 'ar';
  
  /// Current language code
  String get languageCode => currentLocale.value.languageCode;
  
  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }
  
  /// Load saved locale on app startup
  Future<void> _loadSavedLocale() async {
    final savedLocale = await LocalizationService.instance.getSavedLocale();
    currentLocale.value = savedLocale;
    debugPrint('Loaded locale: ${savedLocale.languageCode}');
  }
  
  /// Change app language
  Future<void> changeLanguage(String languageCode) async {
    final newLocale = Locale(languageCode);

    // Update the locale
    currentLocale.value = newLocale;

    // Save preference
    await LocalizationService.instance.saveLocale(newLocale);

    // Update GetMaterialApp locale
    Get.updateLocale(newLocale);

    debugPrint('Language changed to: $languageCode');

    // Wait for the locale rebuild to finish, then restart from splash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAll(() => const SplashScreen());
    });
  }
  
  /// Toggle between English and Arabic
  Future<void> toggleLanguage() async {
    final newCode = languageCode == 'en' ? 'ar' : 'en';
    await changeLanguage(newCode);
  }
  
  /// Get display name for current language
  String get currentLanguageName => 
      LocalizationService.getLanguageName(languageCode);
}
