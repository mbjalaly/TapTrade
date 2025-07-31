import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Models/MatchProduct/matchProduct.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/fadedAnimationUtils.dart';
import 'package:taptrade/Utills/soundManager.dart';
import 'package:taptrade/Utills/utils.dart';
import 'package:taptrade/Widgets/customText.dart';
import 'Match/matchDeal.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var userController = Get.find<UserController>();
  var productController = Get.find<ProductController>();
  List<SwipeItem> swipeItems = <SwipeItem>[];
  MatchEngine? matchEngine;
  bool isLoading = false;

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    swipeItems.clear();
  }

  getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      String id = userController.userProfile.value.data?.id ?? '';
      if (id.isNotEmpty) {
        await ProductService.instance.getMatchProduct(context, id);
        await ProfileService.instance.getTradePreference(context, id);
        addItems();
      }
    } catch (e) {
      print("Error occurred while fetching match products: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  likeDislike(Map<String, dynamic> body) async {
    await ProductService.instance.productLikeDislike(context, body);
  }

  addItems() {
    final listResponse = productController.matchedProduct.value.data ?? [];
    for (int i = 0; i < listResponse.length; i++) {
      swipeItems.add(SwipeItem(
        content: listResponse[i],
        likeAction: () {
          Map<String, dynamic> body = {
            "user": listResponse[i].userProduct?.user ?? '',
            "nearby_user": listResponse[i].otherProduct?.user ?? '',
            "user_product": listResponse[i].userProduct?.id ?? '',
            "nearby_user_product": listResponse[i].otherProduct?.id ?? '',
            "feedback": "like",
            "has_like": true,
            "has_dislike": false
          };
          SoundManager().play("bazaarSwipeRight");
          likeDislike(body);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("LIKE"),
            backgroundColor: AppColors.primaryTextColor,
            duration: Duration(milliseconds: 500),
          ));
        },
        nopeAction: () {
          Map<String, dynamic> body = {
            "user": listResponse[i].userProduct?.user ?? '',
            "nearby_user": listResponse[i].otherProduct?.user ?? '',
            "user_product": listResponse[i].userProduct?.id ?? '',
            "nearby_user_product": listResponse[i].otherProduct?.id ?? '',
            "feedback": "like",
            "has_like": false,
            "has_dislike": true
          };
          SoundManager().play("bazaarSwipeLeft");
          likeDislike(body);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("NOPE"),
            duration: Duration(milliseconds: 500),
          ));
        },
      ));
    }
    matchEngine = MatchEngine(swipeItems: swipeItems);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              AppText(
                text: "TapTrade",
                fontSize: size.width * 0.078,
                textcolor: AppColors.darkBlue,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(
                height: size.height * 0.70, // Reduced from 0.75 to 0.70
                width: size.width,
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => MatchDealScreen(
                          isDirect: true,
                          likeData: null,
                          matchData: matchEngine?.currentItem?.content,
                          tradeRequestData: null,
                        ));
                  },
                  child: Builder(builder: (context) {
                    var currentItem = matchEngine?.currentItem;
                    if (matchEngine != null && currentItem != null) {
                      return SwipeCards(
                        matchEngine: matchEngine!,
                        itemBuilder: (BuildContext context, int index) {
                          UserProduct userProduct =
                              matchEngine?.currentItem?.content.userProduct;
                          UserProduct otherProduct =
                              matchEngine?.currentItem?.content.otherProduct;
                          NearbyUser nearbyUser =
                              matchEngine?.currentItem?.content.nearbyUser;
                          // Removed unused variable 'matchingCount'

                          return Center(
                            child: Container(
                                height: size.height * 0.68, // Reduced from 0.73 to 0.68
                                width: size.width * 0.94,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: index.isEven
                                      ? const Color(0xff61ffdd)
                                      : const Color(0xfffee598),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: size.height * 0.50, // Reduced from 0.55 to 0.50
                                            width: size.width,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.transparent,
                                            ),
                                          ),
                                          Positioned(
                                            left: 20,
                                            bottom: 100,
                                            child: FadeAnimation(
                                              direction: AnimationDirection.ltr,
                                              delay: 0.5,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: size.height * 0.25, // Reduced from 0.3
                                                    width: size.width * 0.45,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      color: Colors.green,
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            KeyConstants
                                                                    .imageUrl +
                                                                (userProduct
                                                                        .image ??
                                                                    '')),
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  FadeAnimation(
                                                    direction:
                                                        AnimationDirection.ltr,
                                                    delay: 0.5,
                                                    child: SizedBox(
                                                      width: size.width * 0.4,
                                                      child: Text(
                                                        "${(userProduct.title ?? '').capitalize}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontFamily: 'Cinzel',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppColors
                                                                .primaryTextColor,
                                                            fontSize: size.width *
                                                                0.045),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 20,
                                            bottom: 100,
                                            child: FadeAnimation(
                                              direction: AnimationDirection.rtl,
                                              delay: 0.5,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: size.height * 0.25, // Reduced from 0.3
                                                    width: size.width * 0.45,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      color: Colors.green,
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            KeyConstants
                                                                    .imageUrl +
                                                                (otherProduct
                                                                        .image ??
                                                                    '')),
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  FadeAnimation(
                                                    direction:
                                                        AnimationDirection.rtl,
                                                    delay: 0.5,
                                                    child: SizedBox(
                                                      width: size.width * 0.4,
                                                      child: Text(
                                                        "${(otherProduct.title ?? '').capitalize}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontFamily: 'Cinzel',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppColors
                                                                .primaryTextColor,
                                                            fontSize: size.width *
                                                                0.045),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    FadeAnimation(
                                      direction: AnimationDirection.btt,
                                      delay: 0.5,
                                      child: Container(
                                        width: size.width,
                                        height: size.height * 0.10, // Reduced from 0.12 to 0.10
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15)),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.black
                                                  .withAlpha((0.1 * 255).toInt()),
                                              Colors.black
                                                  .withAlpha((0.7 * 255).toInt()),
                                            ],
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                AppText(
                                                  text: "Let's Trade ?",
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: size.width * 0.065,
                                                  textcolor: Colors.white,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                                const SizedBox(
                                                  width: 3,
                                                ),
                                                AppText(
                                                  text:
                                                      "${calculateDistance(nearbyUser.latitude ?? 0.0, nearbyUser.longitude ?? 0.0).toStringAsFixed(1)} miles away",
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: size.width * 0.038,
                                                  textcolor: Colors.white,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          );
                        },
                        onStackFinished: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Restarting Matches..."),
                            duration: Duration(milliseconds: 500),
                          ));
                          // Reset matchEngine with the same swipeItems to loop
                          setState(() {
                            matchEngine = MatchEngine(swipeItems: swipeItems);
                          });
                        },
                        itemChanged: (SwipeItem item, int index) {
                          print("item: ${item.content}, index: $index");
                        },
                        leftSwipeAllowed: true,
                        rightSwipeAllowed: true,
                        // upSwipeAllowed: true,
                        // fillSpace: true,
                        likeTag: Image.asset(
                          'assets/icons/likeIcon.png',
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                        nopeTag: Container(
                          margin: const EdgeInsets.all(5.0),
                          child: Image.asset(
                            'assets/icons/dislikeIcon.png',
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    } else {
                      if (isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryTextColor,
                          ),
                        );
                      } else {
                        return const Center(
                          child: Text('No product data available'),
                        );
                      }
                    }
                  }),
                ),
              ),
            ],
          ),
        ));
  }
}
