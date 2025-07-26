import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:taptrade/Screens/Dashboard/Bottombar/bottombarscreen.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: Container(
        height: size.height * 0.07,
        padding: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withOpacity(0.5),
              AppColors.primaryColor.withOpacity(0.5)
            ], // Define your gradient colors
            begin: Alignment.topCenter, // Starting point of the gradient
            end: Alignment.bottomCenter, // Ending point of the gradient
          ),
        ),
        child: Center(
          child: Material(
            elevation: 4.0,
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(25.0),
            child: AppButton(
              onPressed: (){
                Get.to(() => const InstructionOverLay());
                // Get.to(() => const BottomNavigationScreen());
              },
              text: "Next",
              fontSize: Get.width*0.043,
              width: Get.width*0.45,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: Get.height,
            width: Get.width,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.whiteTextColor.withOpacity(0.1),
                    AppColors.primaryColor.withOpacity(0.5)
                  ], // Define your gradient colors
                  begin: Alignment.topCenter, // Starting point of the gradient
                  end: Alignment.bottomCenter, // Ending point of the gradient
                ),
                // image:  DecorationImage(
                //     image: AssetImage(
                //         "assets/images/background.png"
                //     ),fit: BoxFit.fill
                // )
            ),
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: Get.height*0.1,),
                  Image.asset("assets/images/logo2.png",),
                  SizedBox(height: Get.height*0.08,),
                  AppText(text: "Congratulations!",
                    fontSize: Get.width*0.078,
                    textcolor: AppColors.darkBlue,
                    fontWeight: FontWeight.w900,
                  ),
                  SizedBox(height: Get.height*0.02,),
                  AppText(text: "You are good to trade!",
                    fontSize: Get.width*0.042,
                    textcolor: AppColors.darkBlue,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: Get.height*0.36,),
                ],
              ),
            ),
          ),
          Positioned(
            left: -100,
            right: 0,
            bottom: 200,
            child: Lottie.asset('assets/animation/celebration.json',height: size.height / 2,width: size.width / 2,fit: BoxFit.contain),
          ),
          Positioned(
            left: 100,
            right: -100,
            bottom: 200,
            child: Lottie.asset('assets/animation/celebration.json',height: size.height / 2,width: size.width / 2,fit: BoxFit.contain),
          )
        ],
      ),
    );
  }
}
