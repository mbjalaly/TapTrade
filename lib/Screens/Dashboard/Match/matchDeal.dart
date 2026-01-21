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
  bool isMarkingComplete = false;
  bool showMatch = false; // New state to control match reveal
  var userController = Get.find<UserController>();
  var productController = Get.find<ProductController>();

  // Helper to get current user id
  String get currentUserId => userController.userProfile.value.data?.id ?? '';

  // Check if current user has already marked complete
  bool get hasCurrentUserMarkedComplete {
    if (widget.tradeRequestData == null) return false;
    final isRequester = widget.tradeRequestData?.requester == currentUserId;
    final isReceiver = widget.tradeRequestData?.receiver == currentUserId;
    if (isRequester) return widget.tradeRequestData?.completedByRequester ?? false;
    if (isReceiver) return widget.tradeRequestData?.completedByReceiver ?? false;
    return false;
  }

  // Check if other user has marked complete
  bool get hasOtherUserMarkedComplete {
    if (widget.tradeRequestData == null) return false;
    final isRequester = widget.tradeRequestData?.requester == currentUserId;
    if (isRequester) return widget.tradeRequestData?.completedByReceiver ?? false;
    return widget.tradeRequestData?.completedByRequester ?? false;
  }


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

  /// Mark trade as complete (first user action)
  Future<void> markTradeAsComplete() async {
    if (widget.tradeRequestData == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Trade as Complete?'),
        content: const Text(
          'Have you completed this trade in person? The other party will need to confirm before the trade is finalized.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Yes, Mark Complete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => isMarkingComplete = true);
    
    try {
      final result = await ProductService.instance.markTradeComplete(
        context,
        widget.tradeRequestData!.id ?? -1,
      );
      
      if (result.status == Status.COMPLETED) {
        ShowMessage.notify(context, 'Trade marked as complete. Waiting for other party to confirm.');
        // Update local state
        setState(() {
          widget.tradeRequestData?.completedByRequester = 
            widget.tradeRequestData?.requester == currentUserId ? true : widget.tradeRequestData?.completedByRequester;
          widget.tradeRequestData?.completedByReceiver = 
            widget.tradeRequestData?.receiver == currentUserId ? true : widget.tradeRequestData?.completedByReceiver;
          widget.tradeRequestData?.status = 'pending_confirmation';
        });
      }
    } finally {
      setState(() => isMarkingComplete = false);
    }
  }

  /// Confirm trade completion (second user action)
  Future<void> confirmTradeComplete() async {
    if (widget.tradeRequestData == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Trade Completion?'),
        content: const Text(
          'The other party has marked this trade as complete. Do you confirm that the trade has been completed successfully?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Yet'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Yes, Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => isMarkingComplete = true);
    
    try {
      final result = await ProductService.instance.confirmTradeComplete(
        context,
        widget.tradeRequestData!.id ?? -1,
      );
      
      if (result.status == Status.COMPLETED) {
        ShowMessage.notify(context, 'Trade completed successfully! 🎉');
        // Update local state
        setState(() {
          widget.tradeRequestData?.completedByRequester = true;
          widget.tradeRequestData?.completedByReceiver = true;
          widget.tradeRequestData?.status = 'completed';
          widget.tradeRequestData?.paymentStatus = 'paid';
        });
      }
    } finally {
      setState(() => isMarkingComplete = false);
    }
  }

  /// Build the appropriate bottom button based on trade status
  Widget _buildBottomButton() {
    final status = widget.tradeRequestData?.status ?? '';
    final isCompleted = status == 'completed';
    final isPendingConfirmation = status == 'pending_confirmation';
    final canMarkComplete = status == 'accepted' || status == 'in_progress';

    // For completed trades, show a nice completion message
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: EdgeInsets.symmetric(horizontal: Get.width / 6, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Trade Completed ✓',
              style: TextStyle(
                color: Colors.white,
                fontSize: Get.width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // For pending confirmation - show different button based on who has marked complete
    if (isPendingConfirmation) {
      if (hasCurrentUserMarkedComplete && !hasOtherUserMarkedComplete) {
        // Current user has marked, waiting for other
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          margin: EdgeInsets.symmetric(horizontal: Get.width / 8, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.orange.shade400,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Waiting for Confirmation...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Get.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      } else if (hasOtherUserMarkedComplete && !hasCurrentUserMarkedComplete) {
        // Other user has marked, current user needs to confirm
        return AppButton(
          isLoading: isMarkingComplete,
          onPressed: confirmTradeComplete,
          width: Get.width * 0.5,
          text: "Confirm Completion",
          fontSize: Get.width * 0.045,
          margin: EdgeInsets.symmetric(horizontal: Get.width / 6, vertical: 20),
        );
      }
    }

    // For accepted/in_progress trades - show Mark Complete button
    if (canMarkComplete && widget.tradeRequestData != null) {
      return AppButton(
        isLoading: isMarkingComplete,
        onPressed: markTradeAsComplete,
        width: Get.width * 0.5,
        text: "Mark as Completed",
        fontSize: Get.width * 0.045,
        margin: EdgeInsets.symmetric(horizontal: Get.width / 6, vertical: 20),
      );
    }

    // Default: Reveal Trader button (for new matches/likes)
    return AppButton(
      isLoading: isLoading,
      onPressed: () async {
        if (!showMatch) {
          ShowMessage.notify(context, "Please tap on a product to reveal the match first!");
          return;
        }

        setState(() {
          isLoading = true;
        });

        try {
          bool? success;
          if (widget.likeData != null) {
            success = await createLikeTradeRequest();
          } else if (widget.matchData != null) {
            success = await createTradeRequest();
          } else if (widget.tradeRequestData != null) {
            success = await acceptTradeRequest();
          }
          
          if (success == true) {
            ShowMessage.notify(context, "Trader revealed successfully!");
          } else {
            ShowMessage.notify(context, "Your request cannot proceed at the moment please try again later");
          }
        } catch (error, stackTrace) {
          debugPrint("Error in reveal trader: $error");
          debugPrint("Stack trace: $stackTrace");
          ShowMessage.notify(context, 'An error occurred. Please try again later.');
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      },
      width: Get.width * 0.45,
      text: "Reveal Trader",
      fontSize: Get.width * 0.05,
      margin: EdgeInsets.symmetric(horizontal: Get.width / 6, vertical: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFecfcff), // #ecfcff
            Color(0xFFfff5db), // #fff5db
          ],
        ),
      ),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          bottomNavigationBar: _buildBottomButton(),
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
                    height: Get.height * 0.1,
                  ),
                  if (showMatch) ...[
                    Image.asset(
                      "assets/images/img.png",
                      scale: 1.3,
                    ),
                  ] else ...[
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: AppColors.secondaryColor, width: 3),
                      ),
                      child: Icon(
                        Icons.favorite,
                        size: 50,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  ],
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
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showMatch = true;
                              });
                            },
                            child: Container(
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
                          ),
                          SizedBox(
                            width: Get.width * 0.4,
                            height: Get.height * 0.1,
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
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showMatch = true;
                              });
                            },
                            child: Container(
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
                          ),
                          SizedBox(
                            width: Get.width * 0.4,
                            height: Get.height * 0.1,
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
                ],
              ),
            ),
          )),
    );
  }
}
