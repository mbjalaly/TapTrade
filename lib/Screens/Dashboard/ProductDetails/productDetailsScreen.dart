import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:taptrade/Models/MatchProduct/matchProduct.dart';
import 'package:taptrade/Models/MyProductModel/myProductModel.dart';
import 'package:taptrade/Services/IntegrationServices/generalService.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/customText.dart';
import 'package:taptrade/Widgets/saudi_riyal_symbol.dart';

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
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText(
          text: AppLocalizations.of(context)?.productDetails ?? 'Product Details',
          fontWeight: FontWeight.w600,
          fontSize: size.width * 0.045,
          textcolor: AppColors.primaryText(context),
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
                color: AppColors.surfaceVariantColor(context),
              ),
              child: images.isEmpty
                  ? Container(
                      color: AppColors.surfaceVariantColor(context),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: AppColors.greyText(context),
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
                                  color: AppColors.surfaceVariantColor(context),
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 80,
                                    color: AppColors.greyText(context),
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
                    text: otherProduct?.title ?? (AppLocalizations.of(context)?.noTitle ?? 'No title'),
                    fontWeight: FontWeight.w700,
                    fontSize: size.width * 0.055,
                    textcolor: AppColors.primaryText(context),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Price Range
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryText(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        SaudiRiyalFormatter.formatRange(
                          otherProduct?.minPrice ?? '0',
                          otherProduct?.maxPrice ?? '0',
                          fontSize: size.width * 0.045,
                          color: AppColors.primaryText(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // DESCRIPTION SECTION - NEW
                  if (otherProduct?.description != null && otherProduct!.description!.trim().isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: AppColors.primaryText(context),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            AppText(
                              text: AppLocalizations.of(context)?.descriptionLabel ?? 'Description',
                              fontWeight: FontWeight.w600,
                              fontSize: size.width * 0.04,
                              textcolor: AppColors.primaryText(context).withOpacity(0.7),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariantColor(context).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.outlineColor(context).withOpacity(0.3)),
                          ),
                          child: AppText(
                            text: otherProduct.description!,
                            fontSize: size.width * 0.038,
                            textcolor: AppColors.primaryText(context),
                            fontWeight: FontWeight.w400,
                            maxLines: null, // Allow unlimited lines
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // QUANTITY SECTION - NEW
                  _buildDetailRow(
                    icon: Icons.inventory_2_outlined,
                    label: AppLocalizations.of(context)?.quantityAvailable ?? 'Quantity Available',
                    value: (otherProduct?.quantity ?? 1).toString(),
                    size: size,
                  ),

                  const SizedBox(height: 16),

                  // Product Condition
                  _buildDetailRow(
                    icon: Icons.check_circle_outline,
                    label: AppLocalizations.of(context)?.condition ?? 'Condition',
                    value: otherProduct?.productCondition ?? (AppLocalizations.of(context)?.notSpecified ?? 'Not specified'),
                    size: size,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Category
                  _buildDetailRow(
                    icon: Icons.category_outlined,
                    label: AppLocalizations.of(context)?.category ?? 'Category',
                    value: _getCategoryName(otherProduct?.category),
                    size: size,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Status
                  _buildDetailRow(
                    icon: Icons.info_outline,
                    label: AppLocalizations.of(context)?.status ?? 'Status',
                    value: otherProduct?.status ?? (AppLocalizations.of(context)?.notSpecified ?? 'Not specified'),
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
                            foregroundColor: AppColors.primaryText(context),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: AppText(
                            text: AppLocalizations.of(context)?.backToSwipe ?? 'Back to Swipe',
                            fontWeight: FontWeight.w600,
                            fontSize: size.width * 0.045,
                            textcolor: AppColors.primaryText(context),
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
          color: AppColors.primaryText(context).withOpacity(0.7),
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
                textcolor: AppColors.primaryText(context).withOpacity(0.7),
              ),
              const SizedBox(height: 2),
              AppText(
                text: value,
                fontWeight: FontWeight.w600,
                fontSize: size.width * 0.042,
                textcolor: AppColors.primaryText(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
