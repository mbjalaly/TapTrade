import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/apiEndPoint.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Models/TradeModel/tradeModel.dart';
import 'package:taptrade/Models/TraderProfileModel/traderProfileModel.dart';
import 'package:taptrade/Screens/Dashboard/Bottombar/bottombarscreen.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/NetworkImageProvider/networkImageProvider.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactTrader extends StatefulWidget {
  const ContactTrader({Key? key}) : super(key: key);
  // TradeData tradeResponseModel;
  @override
  State<ContactTrader> createState() => _ContactTraderState();
}

class _ContactTraderState extends State<ContactTrader> {
  List<String> iconStrings = [
    "assets/images/mailIcon.png",
    "assets/images/callIcon.png",
    "assets/images/whatsAppIcon.png",
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GetBuilder(
      init: UserController(),
        builder: (userController){
        if(userController.isLoading.isTrue || userController.traderProfile.value.data == null){
          return Scaffold(
            body: Container(
              height: size.height,
              width: size.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFecfcff), // #ecfcff
                    Color(0xFFfff5db), // #fff5db
                  ],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryTextColor,
                ),
              )
            ),
          );
        }else{
          TraderProfileResponseModel userProfile = userController.traderProfile.value;
          return Scaffold(
            bottomNavigationBar: Container(
              width: size.width,
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.225,vertical: 05),
              decoration: const BoxDecoration(
                color: Color(0xFFfff5db),
              ),
              child: Material(
                elevation: 4.0,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25.0),
                child: AppButton(
                  onPressed: (){
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const BottomNavigationScreen()),
                            (route) => false);
                  },
                  text: "Back To Home",
                  fontSize: size.width*0.043,
                  width: size.width*0.45,
                ),
              ),
            ),
            body: Container(
              height: size.height,
              width: size.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFecfcff), // #ecfcff
                    Color(0xFFfff5db), // #fff5db
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.height * 0.1,
                  ),
                  Image.asset(
                    "assets/images/logo2.png",
                    height: 100,
                  ),
                  SizedBox(
                    height: size.height * 0.04,
                  ),
                  AppText(
                    text: "Congratulations",
                    fontSize: size.width * 0.08,
                    textcolor: AppColors.darkBlue,
                    fontWeight: FontWeight.w900,
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  AppText(
                    text: "Contact ${(userProfile.data?.fullName ?? '').capitalize} now",
                    fontSize: size.width * 0.042,
                    textcolor: AppColors.secondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  Container(
                    height: size.height / 3,
                    width: size.height / 3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // Shadow color
                          spreadRadius: 5, // Spread radius
                          blurRadius: 7, // Blur radius
                          offset: const Offset(0, 3), // Shadow position (x, y)
                        ),
                      ],
                    ),
                    child: avatarSelection(context,userProfile.data?.image ?? ''),
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                        iconStrings.length,
                            (index) => GestureDetector(
                          onTap: () {
                            if(index==0){
                              CommunicationChannel.openEmail(userProfile.data?.email ?? '');
                            }else if(index == 1){
                              CommunicationChannel.openPhoneDialer(userProfile.data?.contact ?? '');
                            }else if(index == 2){
                              CommunicationChannel.openWhatsApp(userProfile.data?.contact ?? '');
                            }else{

                            }
                          },
                          child: Image.asset(
                            iconStrings[index],
                            height: 60,
                          ),
                        )),
                  ),
                ],
              ),
            ),
          );
        }

    });
  }
  avatarSelection(BuildContext context, String image){
    if(image.isNotEmpty){
      return NetworkImageProvider(
        url: "${KeyConstants.imageUrl}$image",
        borderRadius: BorderRadius.circular(1000.0),
        fit: BoxFit.fill,
      );
        // ClipRRect(
        //   borderRadius: BorderRadius.circular(1000.0),
        //   clipBehavior: Clip.antiAlias, child: Image.network("${KeyConstants.imageUrl}$image",fit: BoxFit.fill,));
    }else{
      return Padding(
        padding: const EdgeInsets.all(60.0),
        child: SvgPicture.asset("assets/svgs/Camera.svg"),
      );
    }
  }

}



class CommunicationChannel {
  static void openEmail(String email) async {
    print("${email}");
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Trade Product&body=Hi\nhow are you', // Optional
    );
    String url = params.toString();

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static void openPhoneDialer(String phoneNumber) async {
    final Uri params = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    String url = params.toString();

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static void openWhatsApp(String phoneNumber) async {
    String url = 'https://wa.me/$phoneNumber';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}


