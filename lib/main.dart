import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Screens/Splash/splashScreen.dart';

import 'Const/controllerBinding.dart';
import 'Services/LocationService/locationService.dart';
import 'Utills/soundManager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocationService.instance.checkPermission();
  await LocationService.instance.startLocationUpdates();
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}


