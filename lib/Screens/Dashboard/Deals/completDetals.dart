import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Models/TradeRequest/tradeRequest.dart';
import 'package:taptrade/Screens/Dashboard/ContactTrader/contactTrader.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/customText.dart';

class CompletedDealScreen extends StatefulWidget {
  CompletedDealScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _CompletedDealScreenState createState() => _CompletedDealScreenState();
}

class _CompletedDealScreenState extends State<CompletedDealScreen> {
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
        final result =
            await ProductService.instance.getTradeRequestProduct(context, id);
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
    final tradeList = (productController.tradeRequestProduct.value.data ?? []).where((e) => e.paymentStatus == 'paid').toList();
    return Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
        body: SafeArea(
          top: false,
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryText(context),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 2, 12, 60),
                        itemCount: tradeList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final otherProduct = tradeList[index].otherProduct ?? TradeRequestUserProduct();
                          final userProduct = tradeList[index].userProduct ?? TradeRequestUserProduct();
                          return InkWell(
                            onTap: () {
                              String traderId = ((otherProduct.user ?? "") == userController.userProfile.value.data?.id ? userProduct.user : otherProduct.user) ?? "";
                              ProfileService.instance.traderProfile(context, traderId.toString());
                              Get.to(() => ContactTrader());
                            },
                            child: Card(
                              color: AppColors.surfaceVariantColor(context),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: Color(0xFFB3E5FC)),
                              ),
                              elevation: 0,
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // My product (left)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            (userProduct.image ?? '').isNotEmpty ? KeyConstants.imageUrl + (userProduct.image ?? '') : KeyConstants.imagePlaceHolder,
                                            height: 88,
                                            width: 88,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        SizedBox(
                                          width: 88,
                                          child: Text(
                                            (userProduct.title ?? '').capitalize ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    // Other product (right)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            (otherProduct.image ?? '').isNotEmpty ? KeyConstants.imageUrl + (otherProduct.image ?? '') : KeyConstants.imagePlaceHolder,
                                            height: 88,
                                            width: 88,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        SizedBox(
                                          width: 88,
                                          child: Text(
                                            (otherProduct.title ?? '').capitalize ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ));
  }
}
