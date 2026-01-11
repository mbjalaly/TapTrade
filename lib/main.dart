import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Screens/Splash/splashScreen.dart';

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
  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TapTrade',
      initialBinding: ControllerBinding(),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
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


