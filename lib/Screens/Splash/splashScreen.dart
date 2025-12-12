import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Screens/Dashboard/Bottombar/bottombarscreen.dart';
import 'package:taptrade/Screens/GetStarted/getStarted.dart';
import 'package:taptrade/Screens/UserDetail/AddProfile/addProfile.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/generalService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Services/LocationService/locationService.dart';
import 'package:taptrade/Screens/UserDetail/AddLocation/addLocation.dart';


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
    Future.delayed(const Duration(seconds: 2)).then((value) async {
      // Enforce location permission before proceeding into the app, with timeout fallback
      try {
        await LocationService.instance
            .ensurePermissionsGranted()
            .timeout(const Duration(seconds: 8));
      } on TimeoutException catch (_) {
        await _navigateSafely(AddLocationScreen());
        return;
      } catch (e) {
        await _navigateSafely(AddLocationScreen());
        return;
      }

      String? token = await SharedPreferencesService().getString(KeyConstants.accessToken);
      String? userId = await SharedPreferencesService().getString(KeyConstants.userId);

      // Fire-and-forget preloads
      GeneralService.instance.getAllCategories(context);
      GeneralService.instance.getAllInterests(context);
      LocationService.instance.startLocationUpdates();

      if (token != null && userId != null && token.isNotEmpty && userId.isNotEmpty) {
        try {
          final result = await ProfileService.instance.getProfile(context);
          if (result.status == Status.COMPLETED) {
            bool isProfileComplete = result.responseData['data']['is_profile_completed'] ?? false;
            if (isProfileComplete) {
              await _navigateSafely(const BottomNavigationScreen());
            } else {
              await _navigateSafely(const AddProfileScreen());
            }
          } else {
            await _navigateSafely(const GetStartedScreen());
          }
        } catch (_) {
          await _navigateSafely(const GetStartedScreen());
        }
      } else {
        await _navigateSafely(const GetStartedScreen());
      }
    }
        );
    // TODO: implement initState
    super.initState();
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
