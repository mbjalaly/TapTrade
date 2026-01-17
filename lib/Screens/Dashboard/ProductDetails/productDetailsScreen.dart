import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Models/MatchProduct/matchProduct.dart';
import 'package:taptrade/Models/MyProductModel/myProductModel.dart';
import 'package:taptrade/Services/IntegrationServices/generalService.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/customText.dart';

class ProductDetailsScreen extends StatefulWidget {
  final MatchData matchData;
  
  const ProductDetailsScreen({Key? key, required this.matchData}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  List<String> _fetchedImages = [];
  bool _isLoadingImages = true;
  
  @override
  void initState() {
    super.initState();
    _fetchProductImages();
  }
  
  Future<void> _fetchProductImages() async {
    final productId = widget.matchData.otherProduct?.id;
    if (productId == null) {
      setState(() => _isLoadingImages = false);
      return;
    }
    
    debugPrint('=== FETCHING FULL PRODUCT FOR IMAGES ===');
    debugPrint('Product ID: $productId');
    
    try {
      // Try to fetch full product data with all images
      final product = await ProductService.instance.getProductById(context, productId);
      if (product != null && mounted) {
        final List<String> images = [];
        
        // Add main image first
        if (product.image?.isNotEmpty ?? false) {
          final mainImg = product.image!;
          final url = mainImg.startsWith('http') ? mainImg : KeyConstants.imageUrl + mainImg;
          images.add(url);
        }
        
        // Add additional images
        for (final img in (product.images ?? [])) {
          if (img.isNotEmpty) {
            final url = img.startsWith('http') ? img : KeyConstants.imageUrl + img;
            if (!images.contains(url)) {
              images.add(url);
            }
          }
        }
        
        debugPrint('Fetched ${images.length} images for product');
        setState(() {
          _fetchedImages = images;
          _isLoadingImages = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('Error fetching product images: $e');
    }
    
    if (mounted) {
      setState(() => _isLoadingImages = false);
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  String _getCategoryName(int? categoryId) {
    if (categoryId == null) return 'Not specified';
    
    final categories = GeneralService.instance.allCategory.value.data ?? [];
    final category = categories.firstWhereOrNull((cat) => cat.id == categoryId);
    return category?.name ?? 'Not specified';
  }
  
  List<String> _getProductImages() {
    // If we've fetched images from the API, use those
    if (_fetchedImages.isNotEmpty) {
      debugPrint('Using ${_fetchedImages.length} fetched images from API');
      return _fetchedImages;
    }
    
    // Fallback to match data images while loading or if fetch failed
    final otherProduct = widget.matchData.otherProduct;
    final mainImage = otherProduct?.image ?? '';
    final productId = otherProduct?.id;
    
    // Try to get full product data from myProduct (which has images array)
    List<String> additionalImages = otherProduct?.images ?? [];
    
    // If we didn't get images from the match data, try to find them from
    // the stored products in the controller
    if (additionalImages.isEmpty && productId != null) {
      final productController = Get.find<ProductController>();
      final allProducts = productController.myProduct.value.data ?? [];
      final fullProduct = allProducts.firstWhereOrNull((p) => p.id == productId);
      if (fullProduct != null && fullProduct.images != null && fullProduct.images!.isNotEmpty) {
        additionalImages = fullProduct.images!;
      }
    }
    
    // Combine main image with additional images (main image first)
    final List<String> allImages = [];
    
    // Add main image first
    if (mainImage.isNotEmpty) {
      final imageUrl = mainImage.startsWith('http')
          ? mainImage
          : KeyConstants.imageUrl + mainImage;
      allImages.add(imageUrl);
    }
    
    // Add additional images from images array
    for (final img in additionalImages) {
      if (img.isNotEmpty) {
        final imageUrl = img.startsWith('http')
            ? img
            : KeyConstants.imageUrl + img;
        // Avoid duplicates
        if (!allImages.contains(imageUrl)) {
          allImages.add(imageUrl);
        }
      }
    }
    
    return allImages;
  }
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final otherProduct = widget.matchData.otherProduct;
    final images = _getProductImages();
    
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
            // Swipeable Product Image Gallery
            Container(
              height: size.height * 0.4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
              ),
              child: images.isEmpty
                  ? Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey,
                      ),
                    )
                  : Stack(
                      children: [
                        // PageView for swiping images
                        PageView.builder(
                          controller: _pageController,
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
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
                            );
                          },
                        ),
                        // Dot indicators
                        if (images.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                images.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: _currentImageIndex == index ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentImageIndex == index
                                        ? AppColors.primaryColor
                                        : Colors.white.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Image counter badge
                        if (images.length > 1)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${_currentImageIndex + 1} / ${images.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
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
