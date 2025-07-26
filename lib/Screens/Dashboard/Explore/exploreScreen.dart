import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:taptrade/Screens/Dashboard/Bottombar/bottombarscreen.dart';
import 'package:taptrade/Screens/Dashboard/Deals/completDetals.dart';
import 'package:taptrade/Screens/Dashboard/Match/matchDeal.dart';
import 'package:taptrade/Screens/Dashboard/TradeRequestScreen/tradeRequestScreen.dart';
import 'package:taptrade/Utills/appColors.dart';

import '../../../Widgets/customText.dart';
import 'LikedDeals/likedDeals.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    "assets/images/logo2.png",
                    height: 100,
                    width: 100,
                  )),
            ),
            Center(
              child: GestureDetector(
                onTap: (){
                  Get.to(() => const LikedDealScreen());
                },
                child: Container(
                  height: Get.height * 0.28,
                  width: Get.width * 0.9,
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                          image: AssetImage("assets/images/likeProduct.png"),
                          fit: BoxFit.fill)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 7, left: 5),
                        height: Get.height * 0.06,
                        width: Get.width,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.40),
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12))),
                      ),
                      Container(
                        padding: const EdgeInsets.only(bottom: 7, left: 5),
                        height: Get.height * 0.06,
                        width: Get.width,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.40),
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12))),
                        child: AppText(
                          text: "Liked Deals",
                          textcolor: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: Get.width * 0.05,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: Get.width * 0.06),
              child: AppText(
                text: "Welcome to Deals",
                fontSize: Get.width * 0.05,
                textcolor: AppColors.darkBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: Get.width * 0.06),
              child: AppText(
                text: "My Vibes Matching",
                fontSize: Get.width * 0.036,
                textcolor: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(
              height: Get.height * 0.025,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: (){
                    Get.to(() => const TradeRequestScreen());
                  },
                  child: Container(
                    height: Get.height * 0.28,
                    width: Get.width * 0.43,
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: const DecorationImage(
                            image: AssetImage("assets/images/11.png"),
                            fit: BoxFit.fill)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 7, left: 5),
                          height: Get.height * 0.06,
                          width: Get.width,
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.40),
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  topLeft: Radius.circular(12))),

                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 7, left: 5),
                          height: Get.height * 0.06,
                          width: Get.width,
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.40),
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12))),
                          child: AppText(
                            text: "Matched Deals",
                            textcolor: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Get.width * 0.05,
                          ),
                        ),
                      ],
                    )
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => CompletedDealScreen());
                  },
                  child: Container(
                    height: Get.height * 0.28,
                    width: Get.width * 0.43,
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: const DecorationImage(
                            image: AssetImage("assets/images/img_1.png"),
                            fit: BoxFit.fill)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 7, left: 5),
                          height: Get.height * 0.06,
                          width: Get.width,
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.40),
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12))),

                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 7, left: 5),
                          height: Get.height * 0.06,
                          width: Get.width,
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.40),
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12))),
                          child: AppText(
                            text: "Completed Deals",
                            textcolor: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Get.width * 0.05,
                          ),
                        ),
                      ],
                    )
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
