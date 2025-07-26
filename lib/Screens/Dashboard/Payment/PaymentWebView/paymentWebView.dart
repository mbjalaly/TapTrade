import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Models/LikedProduct/likedProduct.dart';
import 'package:taptrade/Models/MatchProduct/matchProduct.dart';
import 'package:taptrade/Models/TradeModel/tradeModel.dart';
import 'package:taptrade/Models/TradeRequest/tradeRequest.dart';
import 'package:taptrade/Screens/Dashboard/Bottombar/bottombarscreen.dart';
import 'package:taptrade/Screens/Dashboard/ContactTrader/contactTrader.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Utills/soundManager.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

GlobalKey<PaymentWebViewState> webviewKey = GlobalKey<PaymentWebViewState>();

class PaymentWebView extends StatefulWidget {
  PaymentWebView(
      {Key? key,
      required this.url,
      required this.id,
      required this.isDirect,
      // required this.likeData,
      // required this.matchData,
      // required this.tradeRequestData
      })
      : super(key: key);
  final bool isDirect;
  // LikeData? likeData;
  // MatchData? matchData;
  // TradeRequestData? tradeRequestData;
  String url;
  String id;

  @override
  PaymentWebViewState createState() => PaymentWebViewState();
}

class PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _webViewController;
  var productController = Get.find<ProductController>();
  double progress = 0;
  String status = '';
  bool isLoading = false;

  Future<bool> onWillPop() async {
    // Custom behavior on back press, for now, it just returns false to prevent navigating back
    return Future.value(true);
  }

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..clearCache()
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (String url) {
          setState(() {
            progress = 0;
          });
        },
        onProgress: (int value) {
          setState(() {
            progress = value / 100;
          });
        },
        onPageFinished: (String url) {
          setState(() {
            progress = 1.0;
          });
        },
        onNavigationRequest: (NavigationRequest request) async {
          print("Web Navigation URL: ${request.url}");
          if (request.url.startsWith(
              'https://app.duelingarea.com/payment/result/')) {
            await fetchTransactionStatus(request.url);
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> fetchTransactionStatus(String url) async {
    try {
      // Fetch the HTML content from the URL
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the HTML content
        var document = html_parser.parse(response.body);

        // Locate the <p> tag that contains the "Transaction Status" text
        var paragraphs = document.getElementsByTagName('p');
        for (var paragraph in paragraphs) {
          if (paragraph.text.contains("Transaction Status:")) {
            // Extract the value after "Transaction Status:"
            String extractedText =
                paragraph.text.split("Transaction Status:").last.trim();
            setState(() {
              status = extractedText; // Update the state with the fetched value
            });
            print("====================================== ${status}");
            return; // Exit after finding the desired text
          }
        }

        // If no match is found
        setState(() {
          status = "Transaction Status not found!";
        });
      } else {
        setState(() {
          status = "Failed to load data: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        status = "Error: $e";
      });
    }
  }

  Future<bool> acceptTradeRequest() async{
    if(widget.id.isNotEmpty){
      String id =  (widget.id ?? -1).toString();
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
    Size size = MediaQuery.of(context).size;
    print("--------------------------------- $status");
    return WillPopScope(
      key: webviewKey,
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child:
                const Icon(Icons.arrow_back, color: AppColors.primaryTextColor),
          ),
          backgroundColor: AppColors.themeColor,
          title: const Text("Tap Trade",
              style:
                  TextStyle(color: AppColors.primaryTextColor, fontSize: 18.0)),
          automaticallyImplyLeading: false,
        ),
        bottomNavigationBar: returnButton(size),
        body: SafeArea(
          child: Column(
            children: [
              if (progress < 1.0)
                LinearProgressIndicator(
                  value: progress,
                  color: AppColors.darkBlue,
                ),
              Expanded(
                child: WebViewWidget(controller: _webViewController),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget returnButton(Size size){
    if(status.isEmpty){
      return const SizedBox();
    }else{
      if(status.toString().toLowerCase() == "captured"){
      return AppButton(
        onPressed: () async {
          try {

            setState(() {
              isLoading = true;
            });

            // Check different conditions and execute corresponding function
            // if (widget.likeData != null) {
            //   success = await createLikeTradeRequest();
            // } else if (widget.matchData != null) {
            //   success = await createTradeRequest();
            // } else if (widget.tradeRequestData != null) {
            //
            // }
            bool success = await acceptTradeRequest();
            TradeData? tradeResponseModel = productController.tradeResponseModel.value.data;

            setState(() {
              isLoading = false;
            });

            // Check if tradeResponseModel is not null and success is true
            if (tradeResponseModel != null && success) {
              // Get.to(() => ContactTrader(tradeResponseModel: tradeResponseModel));
              ProfileService.instance.traderProfile(context,(tradeResponseModel.otherProduct?.user ?? '').toString());
              Get.to(() => const ContactTrader());
              SoundManager().play("traderRevealed");
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
        width: size.width,
        height: size.height * 0.065,
        text: "Reveal Trader",
        isLoading: isLoading,
        margin: EdgeInsets.symmetric(horizontal: size.width / 8),
      );
      }else{
        return AppButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const BottomNavigationScreen()),
                    (route) => false);
          },
          width: size.width,
          height: size.height * 0.065,
          text: "Back To Home",
          margin: EdgeInsets.symmetric(horizontal: size.width / 8),
        );
      }
    }
  }
}
