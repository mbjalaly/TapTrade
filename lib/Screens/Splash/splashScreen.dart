import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Screens/Dashboard/Bottombar/bottombarscreen.dart';
import 'package:taptrade/Screens/GetStarted/getStarted.dart';
import 'package:taptrade/Screens/GetStarted/locationPermissionScreen.dart';
import 'package:taptrade/Screens/UserDetail/AddInterest/addInterest.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/generalService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Services/LocationService/locationService.dart';
import 'package:taptrade/Services/TutorialService/tutorialService.dart';
import 'package:taptrade/Screens/Tutorial/introTutorialScreen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _navigateSafely(Widget page) async {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => page), (route) => false);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2)).then((_) => _init());
  }

  Future<void> _init() async {
    // Fire-and-forget preloads
    GeneralService.instance.getAllCategories(context);
    GeneralService.instance.getAllInterests(context);

    // Determine the destination screen
    Widget destination = await _resolveDestination();

    // Check location permission — gate everything behind it
    bool hasLocation = await _hasLocationPermission();
    if (!hasLocation) {
      await _navigateSafely(
        LocationPermissionScreen(destination: destination),
      );
      return;
    }

    // Location is granted, start updates and navigate
    LocationService.instance.startLocationUpdates();
    await _navigateSafely(destination);
  }

  Future<bool> _hasLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  Future<Widget> _resolveDestination() async {
    String? token = await SharedPreferencesService().getString(KeyConstants.accessToken);
    String? userId = await SharedPreferencesService().getString(KeyConstants.userId);

    if (token != null && userId != null && token.isNotEmpty && userId.isNotEmpty) {
      try {
        final result = await ProfileService.instance.getProfile(context);
        if (result.status == Status.COMPLETED) {
          bool isProfileComplete =
              result.responseData['data']['is_profile_completed'] ?? false;
          if (isProfileComplete) {
            final hasSeenTutorial = await TutorialService.hasSeen();
            if (hasSeenTutorial) {
              return const BottomNavigationScreen();
            } else {
              return const IntroTutorialScreen();
            }
          } else {
            return const AddInterestScreen();
          }
        }
      } catch (_) {}
    }
    return const GetStartedScreen();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
height: Get.height,
        width: Get.width,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                    "assets/images/background.png"
                ),fit: BoxFit.fill
            )
        ),
        child: Center(
          child: Image.asset("assets/images/appLogo.png",height: 200,width: 200,),
        ),
      ),
    );
  }
}
