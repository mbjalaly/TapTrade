import 'package:flutter/cupertino.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Screens/UserDetail/AddLocation/addLocation.dart';
import 'package:taptrade/Screens/Dashboard/Bottombar/bottombarscreen.dart';
import 'package:taptrade/Screens/Dashboard/Deals/completDetals.dart';
import 'package:taptrade/Screens/Dashboard/Match/matchDeal.dart';
import 'package:taptrade/Screens/Dashboard/TradeRequestScreen/tradeRequestScreen.dart';
import 'package:taptrade/Utills/appColors.dart';

import '../../../Widgets/customText.dart';
import 'LikedDeals/likedDeals.dart';
import 'DislikedDeals/dislikedDeals.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}
class _ExploreScreenState extends State<ExploreScreen> {
  final userController = Get.find<UserController>();

  // Logged-in user's SAVED profile coordinates (null/empty => not set yet)
  String? get _userLatitude =>
      userController.userProfile.value.data?.latitude?.toString();
  String? get _userLongitude =>
      userController.userProfile.value.data?.longitude?.toString();

  void _openLocationSetting() {
    Get.to(() => AddLocationScreen());
  }

  bool get _hasLocationSet {
    final lat = _userLatitude;
    final lng = _userLongitude;
    return lat != null &&
        lng != null &&
        lat.toString().trim().isNotEmpty &&
        lng.toString().trim().isNotEmpty;
  }
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: SingleChildScrollView(
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

              // ---------- ITEM 3: "Set your location" warning banner ----------
              if (!_hasLocationSet)
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Get.width * 0.05, vertical: 8),
                  child: GestureDetector(
                    onTap: _openLocationSetting,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_off, color: Colors.orange),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppText(
                              text: "Set your location to see suggested trades",
                              textcolor: AppColors.darkBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: Get.width * 0.038,
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.orange),
                        ],
                      ),
                    ),
                  ),
                ),
              // ----------------------------------------------------------------

              Center(
                child: GestureDetector(
                  onTap: () {
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
                            text: AppLocalizations.of(context)?.likedDeals ??
                                "Liked Deals",
                            textcolor: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Get.width * 0.045,
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
                  text: AppLocalizations.of(context)?.welcomeToDeals ??
                      "Welcome to Deals",
                  fontSize: Get.width * 0.05,
                  textcolor: AppColors.darkBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: Get.width * 0.06),
                child: AppText(
                  text: AppLocalizations.of(context)?.myVibesMatching ??
                      "My Vibes Matching",
                  fontSize: Get.width * 0.036,
                  textcolor: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                height: Get.height * 0.025,
              ),

              // ---------- ITEM 4: stacked (top/bottom) + enlarged cards ----------
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const TradeRequestScreen());
                    },
                    child: Container(
                        height: Get.height * 0.32,
                        width: Get.width * 0.9,
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
                              padding:
                              const EdgeInsets.only(bottom: 7, left: 5),
                              height: Get.height * 0.06,
                              width: Get.width,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(.40),
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      topLeft: Radius.circular(12))),
                            ),
                            Container(
                              padding:
                              const EdgeInsets.only(bottom: 7, left: 5),
                              height: Get.height * 0.06,
                              width: Get.width,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(.40),
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12))),
                              child: AppText(
                                text: AppLocalizations.of(context)
                                    ?.matchedDeals ??
                                    "Matched Deals",
                                textcolor: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Get.width * 0.045,
                              ),
                            ),
                          ],
                        )),
                  ),
                  SizedBox(height: Get.height * 0.02),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => CompletedDealScreen());
                    },
                    child: Container(
                        height: Get.height * 0.32,
                        width: Get.width * 0.9,
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
                              padding:
                              const EdgeInsets.only(bottom: 7, left: 5),
                              height: Get.height * 0.06,
                              width: Get.width,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(.40),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12))),
                            ),
                            Container(
                              padding:
                              const EdgeInsets.only(bottom: 7, left: 5),
                              height: Get.height * 0.06,
                              width: Get.width,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(.40),
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12))),
                              child: AppText(
                                text: AppLocalizations.of(context)
                                    ?.completedDeals ??
                                    "Completed Deals",
                                textcolor: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Get.width * 0.045,
                              ),
                            ),
                          ],
                        )),
                  ),
                ],
              ),
              // ------------------------------------------------------------------

              SizedBox(
                height: Get.height * 0.025,
              ),
              // Refused Matches Card
              Center(
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => const DislikedDealsScreen());
                  },
                  child: Container(
                    height: Get.height * 0.28,
                    width: Get.width * 0.9,
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: const DecorationImage(
                            image: AssetImage("assets/images/img_1.png"),
                            fit: BoxFit.fill,
                            colorFilter: ColorFilter.mode(
                              Colors.redAccent,
                              BlendMode.modulate,
                            ))),
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
                            text: AppLocalizations.of(context)?.refusedMatches ??
                                "Refused Matches",
                            textcolor: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Get.width * 0.045,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.025),
            ],
          ),
        ),
      ),
    );
  }
}