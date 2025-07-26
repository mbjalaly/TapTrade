import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taptrade/Screens/Auth/LoginScreen/loginScreen.dart';
import 'package:taptrade/Screens/Auth/SsoAccount/phoneNumberSignIn.dart';
import 'package:taptrade/Screens/Auth/createAccount/userNameScreen.dart';
import 'package:taptrade/Services/IntegrationServices/generalService.dart';
import 'package:taptrade/Services/IntegrationServices/googleSignIn.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/customText.dart';
class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  @override

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: Get.height*0.06,),
            Image.asset("assets/images/icon2.png",),
            SizedBox(height: Get.height*0.02,),
            SizedBox(
              width: Get.width * 0.95,
              child: Column(
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'By clicking',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: AppColors.darkBlue,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' “Log in”,',
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            color: AppColors.darkBlue,
                            fontWeight: FontWeight.w500,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        TextSpan(
                          text: ' you agree with our ',
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        TextSpan(
                          text: 'Terms.',
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            color: AppColors.darkBlue,
                            decorationColor: AppColors.darkBlue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: ' Learn how we process your data in our ',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: AppColors.darkBlue,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Privacy Policy',
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            color: AppColors.darkBlue,
                            decorationColor: AppColors.darkBlue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        TextSpan(
                          text: ' and ',
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            color: AppColors.darkBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Text(
                      'Cookies Policy.',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: AppColors.darkBlue,
                        decorationColor: AppColors.darkBlue,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Get.height*0.04,),
            GestureDetector(
              onTap: (){
                AuthWithGoogle.google(context: context);
                // Get.to(PhoneSignInScreen());
              },
              child: Container(
                height: Get.height*0.071,
                width: Get.width*0.92,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30)
                ),
                child: Padding(
                  padding:  EdgeInsets.only(left: Get.width*0.06),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset("assets/svgs/google.svg"),
                      SizedBox(
                        width: Get.width * 0.6,
                        child: AppText(text: "LOG IN WITH GOOGLE",
                        fontSize: Get.width*0.042,
                          textcolor: Colors.black,
                        ),
                      ),
                      SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: Get.height*0.025,),
            GestureDetector(
              onTap: (){
                Get.to(UserNameScreen());
              },
              child: Container(
                height: Get.height*0.071,
                width: Get.width*0.92,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)
                ),
                child: Padding(
                  padding:  EdgeInsets.only(left: Get.width*0.06),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset("assets/svgs/msg.svg"),
                      SizedBox(
                        width: Get.width * 0.6,
                        child: AppText(text: "CREATE ACCOUNT",
                          fontSize: Get.width*0.042,
                          textcolor: Colors.black,
                        ),
                      ),
                      SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: Get.height*0.025,),
            GestureDetector(
              onTap: (){
                Get.to(() => const LoginScreen());
              },
              child: Container(
                height: Get.height*0.071,
                width: Get.width*0.92,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)
                ),
                child: Padding(
                  padding:  EdgeInsets.only(left: Get.width*0.06),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset("assets/svgs/login.svg"),
                      SizedBox(
                        width: Get.width * 0.6,
                        child: AppText(text: "LOGIN WITH CREDENTIALS",
                          fontSize: Get.width*0.042,
                          textcolor: Colors.black,
                        ),
                      ),
                      SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: Get.height*0.025,),
            GestureDetector(
              onTap: (){

              },
              child: AppText(text: "Trouble logging in?",
                fontSize: Get.width*0.042,
                textcolor: AppColors.darkBlue,
                fontWeight: FontWeight.w500,
              ),
            )

          ],
        ),
      ),
    );
  }
}
