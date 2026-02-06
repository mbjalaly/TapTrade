import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:taptrade/Controller/languageController.dart';
import 'package:taptrade/Screens/Splash/splashScreen.dart';
import 'package:taptrade/Services/LocalizationService/localization_service.dart';

import 'Const/appConfig.dart';
import 'Const/controllerBinding.dart';
import 'Const/globleKey.dart';
import 'Services/LocationService/locationService.dart';
import 'Services/NotificationService/notification_service.dart';
import 'Utills/soundManager.dart';
import 'Utills/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment configuration first
  await AppConfig.initialize();
  
  // Print config in debug mode (optional)
  // AppConfig.printConfig();
  
  await Firebase.initializeApp();
  await NotificationService.initialize();
  await LocationService.instance.checkPermission((){});
  LocationService.instance.startLocationUpdates();
  await SoundManager().loadSounds();
  
  // Load saved locale before running app
  final savedLocale = await LocalizationService.instance.getSavedLocale();
  
  runApp(MyApp(initialLocale: savedLocale));
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;
  
  const MyApp({super.key, required this.initialLocale});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TapTrade',
      initialBinding: ControllerBinding(),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      
      // Localization configuration
      locale: initialLocale,
      fallbackLocale: const Locale('en'),
      supportedLocales: LocalizationService.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light, // Force light mode (change back to ThemeMode.system when dark mode is ready)
      home: const SplashScreen(),
      // Suppress route information warnings (for Firebase reCAPTCHA)
      logWriterCallback: (String text, {bool isError = false}) {
        // Filter out "Failed to handle route information" warnings
        if (text.contains('Failed to handle route information')) {
          // This is expected for Firebase reCAPTCHA - ignore it
          return;
        }
        // Log other messages normally
        if (isError) {
          debugPrint(text);
        }
      },
    );
  }
}
