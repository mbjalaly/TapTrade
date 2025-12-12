import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Models/TradeRequest/tradeRequest.dart';
import 'package:taptrade/Screens/Dashboard/Match/matchDeal.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/customText.dart';

class TradeRequestScreen extends StatefulWidget {
  const TradeRequestScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _TradeRequestScreenState createState() => _TradeRequestScreenState();
}

class _TradeRequestScreenState extends State<TradeRequestScreen> {
  var userController = Get.find<UserController>();
  var productController = Get.find<ProductController>();
  bool isLoading = false;
  final List<Color> cardColors = const [
    Color(0xfffff585),
    Color(0xff61ffdd),
    Color(0xffc3f8be),
    Color(0xfffee598),
    Color(0xff9feefe),
    Color(0xff61fddd),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    try {
      setState(() {
        isLoading = true;
      });

      String id = userController.userProfile.value.data?.id ?? '';
      if (id.isNotEmpty) {
        final result = await ProductService.instance.getTradeRequestProduct(context, id);
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final tradeList = (productController.tradeRequestProduct.value.data ?? []).where((e) => e.status == 'pending').toList();
    return Scaffold(
        backgroundColor: Colors.white,
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
          child: SafeArea(
            child: isLoading ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTextColor,),): SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: AppText(
                      text: "Match Deals",
                      fontSize: size.width * 0.078,
                      textcolor: AppColors.darkBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    primary: false,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: tradeList.length, // Adjust to the number of items you want to display
                    itemBuilder: (context, index) {
                      TradeRequestUserProduct otherProduct = tradeList[index].otherProduct ?? TradeRequestUserProduct();
                      TradeRequestUserProduct userProduct = tradeList[index].userProduct ?? TradeRequestUserProduct();
                      return GestureDetector(
                        onTap: () {
                          Get.to( () => MatchDealScreen(isDirect: false, likeData: null, matchData: null, tradeRequestData: tradeList[index],));
                        },
                        child: Container(
                          height: size.height * 0.26,
                          width: size.width * 0.37,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: cardColors[index % cardColors.length],
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xff99f2e2).withOpacity(0.8),
                                offset: const Offset(3, 3),
                                blurRadius: 6,
                                spreadRadius: 0, // No spread
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.favorite,
                                      color: Color(0xfff2b721),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: size.height * 0.16,
                                width: size.width,
                                child: Stack(
                                  children: [
                                    // First image (shoes)
                                    Container(
                                      margin: EdgeInsets.only(left: 15),
                                      height: size.height * 0.16,
                                      width: size.width * 0.22,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.green,
                                        image:  DecorationImage(
                                          image: NetworkImage(KeyConstants.imageUrl+(userProduct.image ?? '')),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    // Second image (watch)
                                    Positioned(
                                      left: size.width * 0.21,
                                      child: Container(
                                        height: size.height * 0.16,
                                        width: size.width * 0.22,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(50),
                                          color: Colors.green,
                                          image:  DecorationImage(
                                            image: NetworkImage(KeyConstants.imageUrl+(otherProduct.image ?? '')),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Discount tags
                                    // Positioned(
                                    //   top: size.height * 0.11,
                                    //   left: 3,
                                    //   child: Row(
                                    //     children: [
                                    //       const CircleAvatar(
                                    //         radius: 19,
                                    //         backgroundColor: Colors.white,
                                    //         child: Text(
                                    //           "5 word \n description",
                                    //           style: TextStyle(
                                    //             fontSize: 6,
                                    //             color: Colors.black,
                                    //           ),
                                    //           textAlign: TextAlign.center,
                                    //         ),
                                    //       ),
                                    //       SizedBox(width: size.width * 0.255),
                                    //       const CircleAvatar(
                                    //         radius: 19,
                                    //         backgroundColor: Colors.white,
                                    //         child: Text(
                                    //           "5 word \n description",
                                    //           style: TextStyle(
                                    //             fontSize: 6,
                                    //             color: Colors.black,
                                    //           ),
                                    //           textAlign: TextAlign.center,
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 3.5,
                              ),
                              // Product description
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width: size.width * 0.2,
                                    child: Text(
                                      "${(userProduct.title ?? '').capitalize}",
                                      maxLines: 2,
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.black,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * 0.2,
                                    child: Text(
                                      "${(otherProduct.title ?? '').capitalize}",
                                      maxLines: 2,
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.black,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
