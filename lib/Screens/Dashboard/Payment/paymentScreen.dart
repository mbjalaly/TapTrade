import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Models/LikedProduct/likedProduct.dart';
import 'package:taptrade/Models/MatchProduct/matchProduct.dart';
import 'package:taptrade/Models/TradeModel/tradeModel.dart';
import 'package:taptrade/Models/TradeRequest/tradeRequest.dart';
import 'package:taptrade/Screens/Dashboard/ContactTrader/contactTrader.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';

class PaymentScreen extends StatefulWidget {
  PaymentScreen({Key? key, required this.isDirect , required this.likeData, required this.matchData, required this.tradeRequestData}) : super(key: key);
  final bool isDirect;
  LikeData? likeData;
  MatchData? matchData;
  TradeRequestData? tradeRequestData;
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  var productController = Get.find<ProductController>();
  String? _selectedLanguage = "HDFC Credit Card";
  bool isLoading = false;

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
      final result = await ProductService.instance.acceptTradeRequest(context,id);
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
    Size size = MediaQuery.of(context).size;
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
            child: Padding(
              padding: EdgeInsets.only(
                  left: size.width * 0.04,
                  right: size.width * 0.04,
                  top: size.height * 0.01),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                        alignment: Alignment.topRight,
                        child: Image.asset(
                          "assets/images/logo2.png",
                          height: 100,
                          width: 100,
                        )),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    AppText(
                      text: "Add Payment Method",
                      fontSize: size.width * 0.078,
                      textcolor: AppColors.darkBlue,
                      fontWeight: FontWeight.w700,
                    ),
                    AppText(
                      text: "Complete your payment info to enjoy the most",
                      fontSize: size.width * 0.036,
                      textcolor: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                    SizedBox(
                      height: size.height * 0.06,
                    ),
                    AppText(
                      text: "Payment Options",
                      fontSize: size.width * 0.047,
                      textcolor: AppColors.darkBlue,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    _buildLanguageCheckbox(size,
                        "HDFC Credit Card", "assets/images/master.png"),
                    _buildLanguageCheckbox(size,
                        "ICICI Credit Card", "assets/images/visa.png"),
                    const Divider(
                      height: 30,
                      color: Colors.grey,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: "UPI",
                              textcolor: AppColors.darkBlue,
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                            AppText(
                              text: "Payment",
                              textcolor: AppColors.darkBlue,
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                        AppText(
                          text: "Linked",
                          textcolor: AppColors.darkBlue,
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w800,
                        ),
                      ],
                    ),
                    const Divider(
                      height: 30,
                      color: Colors.grey,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: "PayTM/",
                              textcolor: AppColors.darkBlue,
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                            AppText(
                              text: "Wallets",
                              textcolor: AppColors.darkBlue,
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                        AppText(
                          text: "",
                          textcolor: AppColors.darkBlue,
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w800,
                        ),
                      ],
                    ),
                    const Divider(
                      height: 30,
                      color: Colors.grey,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: "Net",
                              textcolor: AppColors.darkBlue,
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                            AppText(
                              text: "Banking",
                              textcolor: AppColors.darkBlue,
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                        AppText(
                          text: "",
                          textcolor: AppColors.darkBlue,
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w800,
                        ),
                      ],
                    ),
                    const Divider(
                      height: 30,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: size.height * 0.08,
                    ),
                    Center(
                      child: AppButton(
                        onPressed: () async {
                          try {
                            bool? success;
                            setState(() {
                              isLoading = true;
                            });

                            // Check different conditions and execute corresponding function
                            if (widget.likeData != null) {
                              success = await createLikeTradeRequest();
                            } else if (widget.matchData != null) {
                              success = await createTradeRequest();
                            } else if (widget.tradeRequestData != null) {
                              success = await acceptTradeRequest();
                            }

                            TradeData? tradeResponseModel = productController.tradeResponseModel.value.data;

                            setState(() {
                              isLoading = false;
                            });

                            // Check if tradeResponseModel is not null and success is true
                            if (tradeResponseModel != null && (success ?? false)) {
                              ProfileService.instance.traderProfile(context,(tradeResponseModel.otherProduct?.user ?? '').toString());
                              Get.to(() => const ContactTrader());
                            } else {
                              ShowMessage.notify(context, "Something went wrong");
                            }
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                            });

                            // Display error message or log the error
                            ShowMessage.notify(context, "An error occurred: $e");
                          }
                        },

                        isLoading: isLoading,
                        width: size.width * 0.45,
                        text: "Save Payment Info",
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildLanguageCheckbox(Size size, String language, String image) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });

        // provider.changeLanguage(Locale.fromSubtags(languageCode: language));
      },
      child: Container(
        width: size.width,
        margin: EdgeInsets.only(bottom: size.height * 0.02),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Padding(
          padding: EdgeInsets.only(
            right: size.width * 0.07,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                      height: 20,
                      width: 20,
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: _selectedLanguage == language
                                  ? const Color(0xffdd3562)
                                  : Colors.grey),
                          shape: BoxShape.circle,
                          color: _selectedLanguage == language
                              ? const Color(0xffdd3562)
                              : Colors.white),
                      child: _selectedLanguage == language
                          ? Container(
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.grey),
                            )),
                  SizedBox(
                    width: size.width * 0.07,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: language,
                        textcolor: AppColors.darkBlue,
                        fontSize: size.width * 0.042,
                        fontWeight: FontWeight.w500,
                      ),
                      AppText(
                        text: "**** **** **** 5229",
                        textcolor: Colors.grey,
                        fontSize: size.width * 0.037,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ],
              ),
              Image.asset(
                image,
                height: 35,
                width: 35,
              )
            ],
          ),
        ),
      ),
    );
  }
}
