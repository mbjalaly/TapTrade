import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Screens/Dashboard/Bottombar/bottombarscreen.dart';
import 'package:taptrade/Screens/GetStarted/getStarted.dart';
import 'package:taptrade/Screens/UserDetail/AddProfile/addProfile.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/generalService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2)).then((value) async {
      String? token = await SharedPreferencesService().getString(KeyConstants.accessToken);
      String? userId = await SharedPreferencesService().getString(KeyConstants.userId);
      GeneralService.instance.getAllCategories(context);
      GeneralService.instance.getAllInterests(context);
      if(token != null && userId != null && token.isNotEmpty && userId.isNotEmpty){
       final result = await ProfileService.instance.getProfile(context);
       if(result.status == Status.COMPLETED){
         bool isProfileComplete = result.responseData['data']['is_profile_completed'] ?? false;
         if(isProfileComplete){
           Navigator.pushAndRemoveUntil(
               context,
               MaterialPageRoute(builder: (_) => const BottomNavigationScreen()),
                   (route) => false);
         }else{
           Navigator.pushAndRemoveUntil(
               context,
               MaterialPageRoute(builder: (_) => const AddProfileScreen()),
                   (route) => false);
         }
       }else{
         Navigator.pushAndRemoveUntil(
             context,
             MaterialPageRoute(builder: (_) => const GetStartedScreen()),
                 (route) => false);
       }
      }else{
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const GetStartedScreen()),
                (route) => false);
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
