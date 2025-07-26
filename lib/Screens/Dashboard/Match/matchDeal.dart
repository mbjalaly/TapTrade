import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Models/LikedProduct/likedProduct.dart';
import 'package:taptrade/Models/MatchProduct/matchProduct.dart';
import 'package:taptrade/Models/TradeModel/tradeModel.dart';
import 'package:taptrade/Models/TradeRequest/tradeRequest.dart';
import 'package:taptrade/Models/UserProfile/userProfile.dart';
import 'package:taptrade/Screens/Dashboard/Payment/PaymentWebView/paymentWebView.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Utills/soundManager.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';

class MatchDealScreen extends StatefulWidget {
  MatchDealScreen(
      {Key? key,
      required this.isDirect,
      required this.likeData,
      required this.matchData,
      required this.tradeRequestData})
      : super(key: key);
  final bool isDirect;
  LikeData? likeData;
  MatchData? matchData;
  TradeRequestData? tradeRequestData;

  @override
  _MatchDealScreenState createState() => _MatchDealScreenState();
}

class _MatchDealScreenState extends State<MatchDealScreen> {
  String userProductImage = '';
  String otherProductImage = '';
  String userProduct = '';
  String otherProduct = '';
  bool removeBaseUrl = false;
  bool isLoading = false;
  var userController = Get.find<UserController>();
  var productController = Get.find<ProductController>();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SoundManager().play("bazaarMatch");
    if (widget.isDirect) {
      setState(() {
        userProductImage = widget.matchData?.userProduct?.image ?? '';
        userProduct = widget.matchData?.userProduct?.title ?? '';
        otherProductImage = widget.matchData?.otherProduct?.image ?? '';
        otherProduct = widget.matchData?.otherProduct?.title ?? '';
      });
    } else if (widget.likeData != null) {
      setState(() {
        userProductImage = widget.likeData?.userProduct?.image ?? '';
        userProduct = widget.likeData?.userProduct?.title ?? '';
        otherProductImage = widget.likeData?.otherProduct?.image ?? '';
        otherProduct = widget.likeData?.otherProduct?.title ?? '';
        removeBaseUrl = true;
      });
    } else if (widget.tradeRequestData != null) {
      setState(() {
        userProductImage = widget.tradeRequestData?.userProduct?.image ?? '';
        userProduct = widget.tradeRequestData?.userProduct?.title ?? '';
        otherProductImage = widget.tradeRequestData?.otherProduct?.image ?? '';
        otherProduct = widget.tradeRequestData?.otherProduct?.title ?? '';
      });
    } else {}
  }

  Future<bool> createTradeRequest() async{
    if(widget.matchData != null){
      Map<String,dynamic> body = {
        "user_product_id": widget.matchData?.userProduct?.id ?? '',
        "other_product_id": widget.matchData?.otherProduct?.id ?? '',
        "receiver_id": widget.matchData?.otherProduct?.user ?? '',
        "requester_id": widget.matchData?.userProduct?.user ?? '',
      };
      final result = await ProductService.instance.createTradeRequest(context,body);
      if(result.status == Status.COMPLETED){
        return true;
      }else{
        ShowMessage.notify(context, result.responseData['message']);
        return false;
      }
    }
    return false;
  }

  Future<bool> createLikeTradeRequest() async{
    if(widget.likeData != null){
      Map<String,dynamic> body = {
        "user_product_id": widget.likeData?.userProduct?.id ?? '',
        "other_product_id": widget.likeData?.otherProduct?.id ?? '',
        "receiver_id": widget.likeData?.otherProduct?.user ?? '',
        "requester_id": widget.likeData?.userProduct?.user ?? '',
      };
      final result = await ProductService.instance.createTradeRequest(context,body);
      if(result.status == Status.COMPLETED){
        return true;
      }else{
        ShowMessage.notify(context, result.responseData['message']);
        return false;
      }
    }
    return false;
  }

  Future<bool> acceptTradeRequest() async{
    if(widget.tradeRequestData != null){
      String id =  (widget.tradeRequestData?.id ?? -1).toString();
      final result = await ProductService.instance.tradePaymentStatus(context,id);
      if(result.status == Status.COMPLETED){
        return true;
      }else{
        ShowMessage.notify(context, result.responseData['message']);
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: Get.height,
          width: Get.width,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: AppText(
                          text: "Matched Deal",
                          fontSize: Get.width * 0.078,
                          textcolor: AppColors.darkBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey.withOpacity(.70),
                          ))
                    ],
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.15,
                ),
                Image.asset(
                  "assets/images/img.png",
                  scale: 1.3,
                ),
                SizedBox(
                  height: Get.height * 0.025,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: Get.height * 0.25,
                          width: Get.width * 0.35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(80),
                            color: Colors.green,
                            border: Border.all(color: AppColors.secondaryColor,width: 5),
                            image: DecorationImage(
                              image: removeBaseUrl
                                  ? NetworkImage(userProductImage)
                                  : NetworkImage(KeyConstants.imageUrl + userProductImage),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: Get.width * 0.4,
                          child: Center(
                            child: Text(
                              "${userProduct.capitalize}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontWeight: FontWeight.bold,
                                  color: AppColors
                                      .primaryTextColor,
                                  fontSize:
                                  Get.width * 0.045),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: Get.height * 0.25,
                          width: Get.width * 0.35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(80),
                            color: Colors.green,
                            border: Border.all(color: AppColors.secondaryColor,width: 5),
                            image: DecorationImage(
                              image: removeBaseUrl
                                  ? NetworkImage(otherProductImage)
                                  : NetworkImage(
                                  KeyConstants.imageUrl + otherProductImage),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: Get.width * 0.4,
                          child: Center(
                            child: Text(
                              "${otherProduct.capitalize}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontWeight: FontWeight.bold,
                                  color: AppColors
                                      .primaryTextColor,
                                  fontSize:
                                  Get.width * 0.045),
                            ),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
                SizedBox(
                  height: Get.height * 0.1,
                ),
                AppButton(
                  isLoading: isLoading,
                  onPressed: () async {
                    UserData? userProfile =
                        userController.userProfile.value.data;
                    if (userProfile == null) {
                      ShowMessage.notify(
                          context, "Please restart the application");
                      return;
                    }

                    setState(() {
                      isLoading = true;
                    });

                    try {
                      Map<String, dynamic> body = {
                        "customer_first_name": "${userProfile.username}",
                        "customer_middle_name": "",
                        "customer_last_name": "${userProfile.username}",
                        "customer_email": "${userProfile.email}",
                        "customer_phone_country_code": 965,
                        "customer_phone_number": "${userProfile.contact}",
                        "amount": 10,
                        "customer_initiated": true
                      };

                      final result = await ProfileService.instance
                          .paymentRequest(context, body);
                      String url =
                          result.responseData?['transaction']?['url'] ?? '';

                      if (result.status == Status.COMPLETED && url.isNotEmpty) {
                        bool? success;
                        if (widget.likeData != null) {
                          success = await createLikeTradeRequest();
                        } else if (widget.matchData != null) {
                          success = await createTradeRequest();
                        } else if (widget.tradeRequestData != null) {
                          success = await acceptTradeRequest();
                        }
                        if(success == null || !success){
                          ShowMessage.notify(context, "Your request cannot proceed at the moment please try again later");
                          return;
                        }

                        TradeData? tradeResponseModel = productController.tradeResponseModel.value.data;
                        String id = (tradeResponseModel?.tradeRequest ?? '').toString();
                        Get.to(() => PaymentWebView(
                              url: url,
                              isDirect: widget.isDirect,
                          id: id,
                            ));
                      } else {
                        ShowMessage.notify(context, 'Something went wrong');
                      }
                    } catch (error, stackTrace) {
                      // Log the error and stack trace for debugging (optional)
                      debugPrint("Error in payment request: $error");
                      debugPrint("Stack trace: $stackTrace");

                      ShowMessage.notify(context,
                          'An error occurred. Please try again later.');
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                    // Get.to(() => PaymentScreen(isDirect: widget.isDirect,likeData: widget.likeData,matchData: widget.matchData,tradeRequestData: widget.tradeRequestData,));
                  },
                  width: Get.width * 0.45,
                  text: "Continue",
                ),
              ],
            ),
          ),
        ));
  }
}
