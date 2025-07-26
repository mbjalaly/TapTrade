import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Models/LikedProduct/likedProduct.dart';
import 'package:taptrade/Screens/Dashboard/Match/matchDeal.dart';
import 'package:taptrade/Screens/UserDetail/AddLocation/addLocation.dart';
import 'package:taptrade/Screens/UserDetail/Product/addProduct.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/ShimmerEffect/shimmerEffect.dart';
import 'package:taptrade/Widgets/customText.dart';

class MyProductScreen extends StatefulWidget {
  const MyProductScreen({Key? key}) : super(key: key);

  @override
  _MyProductScreenState createState() => _MyProductScreenState();
}

class _MyProductScreenState extends State<MyProductScreen> {
  var userController = Get.find<UserController>();
  var productController = Get.find<ProductController>();
  bool isLoading = false;
  bool isDeleting = false;
  int selectedIndex = -1;
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
        final result = await ProductService.instance.getMyProduct(context, id);
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
    final myProductList = productController.myProduct.value.data ?? [];
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () async {
            await Get.to(() => AddProductScreen(
                  isDirect: true,
                ));
            getData();
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset("assets/images/t.png"),
          ),
        ),
        backgroundColor: Colors.white,
        body: Container(
          height: size.height * 0.95,
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
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryTextColor,
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: AppText(
                            text: "My Products",
                            fontSize: size.width * 0.078,
                            textcolor: AppColors.darkBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Column(
                          children:
                              List.generate(myProductList.length, (index) {
                            var indexData = myProductList[index];
                            String image = indexData.image ?? '';
                            String category = indexData.category ?? '';
                            String title = indexData.title ?? '';
                            String minPrice = indexData.minPrice ?? '';
                            String maxPrice = indexData.maxPrice ?? '';
                            String status = indexData.status ?? '';
                            int id = indexData.id ?? -1;
                            bool isActive = status == 'active';
                            return isActive
                                ? CustomShimmer(
                                    isOn: isDeleting && selectedIndex == index,
                                    child: Stack(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          width: size.width,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            color: cardColors[
                                                index % cardColors.length],
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xff99f2e2)
                                                    .withOpacity(0.8),
                                                offset: const Offset(3, 3),
                                                blurRadius: 6,
                                                spreadRadius: 0, // No spread
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: size.height * 0.15,
                                                width: size.height * 0.15,
                                                margin: const EdgeInsets.only(
                                                    right: 10),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                  image: DecorationImage(
                                                      image: NetworkImage(image
                                                              .isNotEmpty
                                                          ? KeyConstants
                                                                  .imageUrl +
                                                              image
                                                          : KeyConstants
                                                              .imagePlaceHolder),
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  returnTexts(
                                                      'Category:   ', category),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  returnTexts(
                                                      'Title:           ',
                                                      title),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  returnTexts(
                                                      'Max Price: ', maxPrice),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  returnTexts(
                                                      'Min Price:  ', minPrice),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                            bottom: 20,
                                            right: 20,
                                            child: GestureDetector(
                                                onTap: () async {
                                                  if (id >= 0) {
                                                    try {
                                                      setState(() {
                                                        isDeleting = true;
                                                        selectedIndex = index;
                                                      });

                                                      final result =
                                                          await ProductService
                                                              .instance
                                                              .deleteMyProduct(
                                                        context,
                                                        id.toString(),
                                                      );

                                                      setState(() {
                                                        isDeleting = false;
                                                        selectedIndex = -1;
                                                      });

                                                      if (result.status ==
                                                              Status
                                                                  .COMPLETED &&
                                                          result.responseData[
                                                              'success']) {
                                                        ShowMessage.notify(
                                                            context,
                                                            result.responseData[
                                                                'message']);
                                                        productController
                                                            .myProduct
                                                            .value
                                                            .data
                                                            ?.removeAt(index);
                                                        setState(() {});
                                                      } else {
                                                        ShowMessage.notify(
                                                            context,
                                                            result.responseData[
                                                                'message']);
                                                      }
                                                    } catch (e) {
                                                      setState(() {
                                                        isDeleting = false;
                                                      });
                                                      ShowMessage.notify(
                                                          context,
                                                          'An error occurred: ${e.toString()}');
                                                    }
                                                  }
                                                },
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ))),
                                      ],
                                    ),
                                  )
                                : const SizedBox();
                          }),
                        )
                      ],
                    ),
                  ),
          ),
        ));
  }

  Widget returnTexts(String key, String value) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.5,
      child: RichText(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: key,
            style: TextStyle(
                color: AppColors.primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: size.width * 0.035),
            children: [
              TextSpan(
                  text: value.capitalize,
                  style: TextStyle(
                      color: AppColors.secondaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: size.width * 0.04))
            ],
          )),
    );
  }
}
