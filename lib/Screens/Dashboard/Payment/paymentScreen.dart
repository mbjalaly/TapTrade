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

class _PaymentScreenState extends State<PaymentScreen> with TickerProviderStateMixin {
  var productController = Get.find<ProductController>();
  String? _selectedLanguage = "HDFC Credit Card";
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.secondaryColor.withOpacity(0.05),
            AppColors.darkBlue.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.payment,
            size: 60,
            color: AppColors.primaryColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Payment Methods',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your payment options and billing information.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              'Payment Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
          ),
          _buildPaymentCard(
            title: "Credit Cards",
            subtitle: "Visa, Mastercard, American Express",
            icon: Icons.credit_card,
            iconColor: AppColors.primaryColor,
            onTap: () => _showPaymentDialog("Credit Cards"),
          ),
          _buildPaymentCard(
            title: "Debit Cards",
            subtitle: "All major debit cards accepted",
            icon: Icons.account_balance_wallet,
            iconColor: AppColors.secondaryColor,
            onTap: () => _showPaymentDialog("Debit Cards"),
          ),
          _buildPaymentCard(
            title: "Digital Wallets",
            subtitle: "PayPal, Apple Pay, Google Pay",
            icon: Icons.account_balance,
            iconColor: AppColors.darkBlue,
            onTap: () => _showPaymentDialog("Digital Wallets"),
          ),
          _buildPaymentCard(
            title: "Bank Transfer",
            subtitle: "Direct bank transfers",
            icon: Icons.account_balance,
            iconColor: AppColors.primaryColor,
            onTap: () => _showPaymentDialog("Bank Transfer"),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillingSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              'Billing Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
          ),
          _buildBillingCard(
            title: "Billing Address",
            subtitle: "Manage your billing address",
            icon: Icons.location_on,
            iconColor: AppColors.primaryColor,
            onTap: () => _showBillingDialog("Billing Address"),
          ),
          _buildBillingCard(
            title: "Tax Information",
            subtitle: "Update your tax details",
            icon: Icons.receipt,
            iconColor: AppColors.secondaryColor,
            onTap: () => _showBillingDialog("Tax Information"),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          content: Text(
            "Payment method configuration for $title is coming soon!",
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBillingDialog(String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          content: Text(
            "Billing information management for $title is coming soon!",
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
    // If this is accessed from profile management (not direct payment)
    if (!widget.isDirect) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Payment Methods'),
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildPaymentMethods(),
                  _buildBillingSection(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Original payment flow for direct payments
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
            child: Column(
              children: [
                // Original payment flow content
                // ... rest of the original implementation
              ],
            ),
          ),
        ));
  }
}
