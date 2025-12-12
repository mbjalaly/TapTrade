import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Models/MatchProduct/matchProduct.dart';
import 'package:taptrade/Services/IntegrationServices/generalService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/customText.dart';

class ProductDetailsScreen extends StatefulWidget {
  final MatchData matchData;
  
  const ProductDetailsScreen({Key? key, required this.matchData}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  
  String _getCategoryName(int? categoryId) {
    if (categoryId == null) return 'Not specified';
    
    final categories = GeneralService.instance.allCategory.value.data ?? [];
    final category = categories.firstWhereOrNull((cat) => cat.id == categoryId);
    return category?.name ?? 'Not specified';
  }
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final otherProduct = widget.matchData.otherProduct;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText(
          text: 'Product Details',
          fontWeight: FontWeight.w600,
          fontSize: size.width * 0.045,
          textcolor: AppColors.primaryTextColor,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: size.height * 0.4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                child: Image.network(
                  (otherProduct?.image ?? '').startsWith('http')
                      ? (otherProduct?.image ?? '')
                      : KeyConstants.imageUrl + (otherProduct?.image ?? ''),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Product Details
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Title
                  AppText(
                    text: otherProduct?.title ?? 'No title',
                    fontWeight: FontWeight.w700,
                    fontSize: size.width * 0.055,
                    textcolor: AppColors.primaryTextColor,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Price Range
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTextColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          color: AppColors.primaryTextColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        AppText(
                          text: '\$${otherProduct?.minPrice ?? '0'} - \$${otherProduct?.maxPrice ?? '0'}',
                          fontWeight: FontWeight.w600,
                          fontSize: size.width * 0.045,
                          textcolor: AppColors.primaryTextColor,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Product Condition
                  _buildDetailRow(
                    icon: Icons.check_circle_outline,
                    label: 'Condition',
                    value: otherProduct?.productCondition ?? 'Not specified',
                    size: size,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Category
                  _buildDetailRow(
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: _getCategoryName(otherProduct?.category),
                    size: size,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Status
                  _buildDetailRow(
                    icon: Icons.info_outline,
                    label: 'Status',
                    value: otherProduct?.status ?? 'Not specified',
                    size: size,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate back to home screen
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: AppColors.primaryTextColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: AppText(
                            text: 'Back to Swipe',
                            fontWeight: FontWeight.w600,
                            fontSize: size.width * 0.045,
                            textcolor: AppColors.primaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Size size,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.primaryTextColor.withOpacity(0.7),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: label,
                fontWeight: FontWeight.w500,
                fontSize: size.width * 0.04,
                textcolor: AppColors.primaryTextColor.withOpacity(0.7),
              ),
              const SizedBox(height: 2),
              AppText(
                text: value,
                fontWeight: FontWeight.w600,
                fontSize: size.width * 0.042,
                textcolor: AppColors.primaryTextColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
