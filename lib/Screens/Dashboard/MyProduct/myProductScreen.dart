import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:taptrade/Widgets/saudi_riyal_symbol.dart';
import 'package:taptrade/Models/LikedProduct/likedProduct.dart';
import 'package:taptrade/Models/MatchProduct/matchProduct.dart';
import 'package:taptrade/Screens/Dashboard/Match/matchDeal.dart';
import 'package:taptrade/Screens/UserDetail/Product/addProductWizard.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Screens/UserDetail/Product/editProductScreen.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Services/IntegrationServices/generalService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/ShimmerEffect/shimmerEffect.dart';
import 'package:taptrade/Widgets/customText.dart';
import 'package:taptrade/Screens/Dashboard/Deals/completDetals.dart';
import 'package:taptrade/Screens/Dashboard/ProductDetails/productDetailsScreen.dart';

class MyProductScreen extends StatefulWidget {
  const MyProductScreen({Key? key}) : super(key: key);

  @override
  _MyProductScreenState createState() => _MyProductScreenState();
}

class _MyProductScreenState extends State<MyProductScreen> {
  // Helper widget to display images (handles base64 data URIs and regular URLs)
  Widget _buildProductImage(String? imageUrl, {double? width, double? height}) {
    final w = width ?? 88.0;
    final h = height ?? 88.0;
    
    // Always return a widget, even if there's an error
    Widget buildPlaceholder() {
      return Image.network(
        KeyConstants.imagePlaceHolder,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: w,
            height: h,
            color: AppColors.surfaceVariantColor(context),
            child: Icon(Icons.image_not_supported, color: AppColors.greyText(context)),
          );
        },
      );
    }
    
    if (imageUrl == null || imageUrl.isEmpty) {
      return buildPlaceholder();
    }
    
    // Handle base64 data URIs
    if (imageUrl.startsWith('data:image')) {
      try {
        final parts = imageUrl.split(',');
        if (parts.length == 2) {
          final base64String = parts[1];
          final bytes = base64Decode(base64String);
          return Image.memory(
            Uint8List.fromList(bytes),
            width: w,
            height: h,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error displaying base64 image: $error');
              return buildPlaceholder();
            },
          );
        }
      } catch (e) {
        print('Error decoding base64 image: $e');
        return buildPlaceholder();
      }
    }
    
    // Handle regular HTTP URLs or relative paths
    try {
      final finalUrl = imageUrl.startsWith('http')
          ? imageUrl
          : KeyConstants.imageUrl + imageUrl;
      
      return Image.network(
        finalUrl,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading network image: $error');
          return buildPlaceholder();
        },
      );
    } catch (e) {
      print('Error building image URL: $e');
      return buildPlaceholder();
    }
  }
  
  String _getCategoryName(int? categoryId) {
    if (categoryId == null) return AppLocalizations.of(navigatorKey.currentContext!)?.notSpecified ?? 'Not specified';
    
    final categories = GeneralService.instance.allCategory.value.data ?? [];
    final category = categories.firstWhereOrNull((cat) => cat.id == categoryId);
    return category?.name ?? (AppLocalizations.of(navigatorKey.currentContext!)?.notSpecified ?? 'Not specified');
  }
  
  MatchData _convertLikeDataToMatchData(LikeData likeData) {
    // Convert LikeData to MatchData for product details screen
    return MatchData(
      userProduct: UserProduct(
        id: likeData.userProduct?.id,
        title: likeData.userProduct?.title,
        minPrice: likeData.userProduct?.minPrice,
        maxPrice: likeData.userProduct?.maxPrice,
        image: likeData.userProduct?.image,
        productCondition: likeData.userProduct?.productCondition,
        status: likeData.userProduct?.status,
        category: likeData.userProduct?.category,
        user: likeData.userProduct?.user,
      ),
      otherProduct: UserProduct(
        id: likeData.otherProduct?.id,
        title: likeData.otherProduct?.title,
        minPrice: likeData.otherProduct?.minPrice,
        maxPrice: likeData.otherProduct?.maxPrice,
        image: likeData.otherProduct?.image,
        productCondition: likeData.otherProduct?.productCondition,
        status: likeData.otherProduct?.status,
        category: likeData.otherProduct?.category,
        user: likeData.otherProduct?.user,
      ),
      nearbyUser: null, // Not available in LikeData
      matchCount: 0,
    );
  }
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

  String _cap(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '';
    return v[0].toUpperCase() + v.substring(1);
  }

  String _translateValue(String? value) {
    if (value == null || value.isEmpty) return '';
    final lowerValue = value.toLowerCase().trim();

    // Translate status values
    if (lowerValue == 'active') {
      return AppLocalizations.of(navigatorKey.currentContext!)?.active ?? 'Active';
    }
    if (lowerValue == 'inactive') {
      return AppLocalizations.of(navigatorKey.currentContext!)?.inactive ?? 'Inactive';
    }

    // Translate condition values
    if (lowerValue == 'new') {
      return AppLocalizations.of(navigatorKey.currentContext!)?.productNew ?? 'New';
    }
    if (lowerValue == 'used') {
      return AppLocalizations.of(navigatorKey.currentContext!)?.productUsed ?? 'Used';
    }
    if (lowerValue == 'like new' || lowerValue == 'likenew') {
      return AppLocalizations.of(navigatorKey.currentContext!)?.productLikeNew ?? 'Like New';
    }
    if (lowerValue == 'good') {
      return AppLocalizations.of(navigatorKey.currentContext!)?.productGood ?? 'Good';
    }
    if (lowerValue == 'fair') {
      return AppLocalizations.of(navigatorKey.currentContext!)?.productFair ?? 'Fair';
    }

    // Return capitalized value if no translation found
    return _cap(value);
  }

  // Extract mutual match logic into reusable helper
  List<LikeData> _getMutualMatchesForProduct(dynamic product) {
    final p = product;
    final liked = productController.likeProduct.value.data ?? [];

    // Filter likes for this product where I actually liked
    final filtered = liked.where((e) =>
      ((e.userProduct?.id ?? -1) == (p.id ?? -2)) && (e.hasLike ?? false)
    );

    // De-duplicate by other product id
    final Map<int, LikeData> uniqueByOtherId = {};
    for (final e in filtered) {
      final oid = e.otherProduct?.id ?? -1;
      if (oid >= 0) uniqueByOtherId[oid] = e;
    }
    final likedForThis = uniqueByOtherId.values.toList();

    // Find mutual matches (where both users liked each other's products)
    final allLikes = productController.likeProduct.value.data ?? [];
    final mutualMatches = <LikeData>[];

    // For each product I liked, check if the other user also liked my product
    for (final myLike in likedForThis) {
      final otherProductId = myLike.otherProduct?.id ?? -1;
      final myProductId = p.id ?? -1;

      // Check if the other user also liked my product
      final otherUserLikedMe = allLikes.where((like) =>
        (like.userProduct?.id ?? -1) == otherProductId &&
        (like.otherProduct?.id ?? -1) == myProductId &&
        (like.hasLike ?? false)
      ).isNotEmpty;

      if (otherUserLikedMe) {
        mutualMatches.add(myLike);
      }
    }

    return mutualMatches;
  }

  Future<void> getData({bool showLoader = true}) async {
    try {
      if (showLoader) {
        setState(() {
          isLoading = true;
        });
      }

      print("=== FETCHING PRODUCTS ===");
      // Backend uses JWT token, but we still need user ID for likes/matches
      String id = userController.userProfile.value.data?.id ?? '';
      print("User ID: $id");
      
      if (id.isEmpty) {
        print("WARNING: User ID is empty! Cannot fetch products.");
        if (mounted && showLoader) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }
      
      final result = await ProductService.instance.getMyProduct(context, id);
      print("getMyProduct result status: ${result.status}");
      print("Products count: ${productController.myProduct.value.data?.length ?? 0}");
      
      // Also fetch likes and matches so details sheet can compute counts
      await Future.wait([
        ProductService.instance.getLikeProduct(context, id),
        ProductService.instance.getMatchProduct(context, id),
      ]);
      
      print("=== PRODUCTS FETCHED ===");
      print("Final products count: ${productController.myProduct.value.data?.length ?? 0}");
    } catch (e) {
      print("Error occurred while fetching products: $e");
      print("Stack trace: ${StackTrace.current}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)?.errorLoadingProducts ?? 'Error loading products'}: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted && showLoader) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Show modern delete confirmation dialog
  Future<void> _showDeleteConfirmation({
    required BuildContext context,
    required String productTitle,
    required int productId,
    required int index,
  }) async {
    if (productId < 0) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundColor(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.deleteProduct,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.areYouSureDeleteProduct,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                '"${_cap(productTitle)}"',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.thisActionCannotBeUndone,
                style: TextStyle(color: Colors.red.shade400, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(AppLocalizations.of(context)!.delete, style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // Proceed with deletion
    try {
      setState(() {
        isDeleting = true;
        selectedIndex = index;
      });

      final result = await ProductService.instance.deleteMyProduct(
        context,
        productId.toString(),
      );

      setState(() {
        isDeleting = false;
        selectedIndex = -1;
      });

      // Handle multiple possible success response formats
      final isSuccess = result.status == Status.COMPLETED &&
          result.responseData != null &&
          (result.responseData['success'] == true ||
           result.responseData['status'] == 'success' ||
           result.responseData['status'] == true ||
           result.responseData['message']?.toString().toLowerCase().contains('deleted') == true ||
           result.responseData['message']?.toString().toLowerCase().contains('success') == true);

      if (isSuccess) {
        ShowMessage.success(context, result.responseData?['message'] ?? AppLocalizations.of(context)!.productDeletedSuccessfully);
        // Reload products to ensure list is up to date
        await getData();
      } else {
        final errorMsg = result.responseData?['message']
            ?? result.responseData?['error']
            ?? (AppLocalizations.of(context)?.failedToDeleteProduct ?? 'Failed to delete product');
        ShowMessage.error(context, errorMsg.toString());
      }
    } catch (e) {
      setState(() {
        isDeleting = false;
        selectedIndex = -1;
      });
      ShowMessage.error(context, AppLocalizations.of(context)?.errorTryAgainLater ?? 'An error occurred. Please try again.');
      debugPrint('Delete error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
        body: Column(
          children: [
            const SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TabBar(
                labelColor: AppColors.primaryText(context),
                unselectedLabelColor: AppColors.greyText(context),
                labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(color: AppColors.primaryColor, width: 3),
                  insets: EdgeInsets.symmetric(horizontal: 16),
                ),
                tabs: [
                  Tab(text: AppLocalizations.of(context)?.myProducts ?? 'My products'),
                  Tab(text: AppLocalizations.of(context)?.completedDeals ?? 'Completed deals'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                children: [
                  _buildMyProductsTab(context),
                  // Show completed deals screen
                  CompletedDealScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyProductsTab(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primaryText(context)),
      );
    }
    return Obx(() {
      final myProductList = productController.myProduct.value.data ?? [];
      print("Obx rebuild - Total products: ${myProductList.length}");
      if (myProductList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.greyText(context)),
              const SizedBox(height: 12),
              Text(AppLocalizations.of(context)?.noProductsYet ?? 'No products yet', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(AppLocalizations.of(context)?.addYourFirstProductToGetStarted ?? 'Add your first product to get started'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await Get.to(() => AddProductWizardScreen());
                  getData();
                },
                child: Text(AppLocalizations.of(context)?.addProduct ?? 'Add product'),
              ),
            ],
          ),
        );
      }
      return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            await getData(showLoader: false);
          },
          child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 140),
                  itemCount: myProductList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final p = myProductList[index];
                    final bool isActive = (p.status ?? '') == 'active';
                    final image = p.image ?? '';
                    final category = p.category ?? '';
                    final title = p.title ?? '';
                    final minPrice = p.minPrice ?? '';
                    final maxPrice = p.maxPrice ?? '';
                    final status = p.status ?? '';
                    final id = p.id ?? -1;
              return Opacity(
                opacity: isActive ? 1.0 : 0.45,
                child: ColorFiltered(
                  colorFilter: isActive
                      ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                      : const ColorFilter.matrix(<double>[
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0,      0,      0,      1, 0,
                        ]),
                  child: CustomShimmer(
                isOn: isDeleting && selectedIndex == index,
                child: Stack(
                  children: [
                  Card(
                  color: AppColors.surfaceVariantColor(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFB3E5FC)), // light blue border
                  ),
                  elevation: 0,
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: AppColors.backgroundColor(context),
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (_) => _detailsSheet(p),
                      );
                    },
                    child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildProductImage(image, width: 88, height: 88),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _cap(title),
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  _matchBadge(_getMutualMatchesForProduct(p).length),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Price range display
                              Row(
                                children: [
                                  SaudiRiyalFormatter.formatRange(
                                    minPrice,
                                    maxPrice,
                                    fontSize: 16,
                                    color: AppColors.primaryText(context).withOpacity(0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _chip(_cap(category)),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: AppLocalizations.of(context)?.delete ?? 'Delete',
                          onPressed: () => _showDeleteConfirmation(
                            context: context,
                            productTitle: title,
                            productId: id,
                            index: index,
                          ),
                          icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              if (!isActive)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.productInactive ?? 'INACTIVE',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
              ),
              ),
              ),
              );
            },
          ),
        ),
        Positioned(
          right: 16,
          bottom: 10,
          child: SafeArea(
            top: false,
            child: FloatingActionButton(
              heroTag: 'myProductsAddFab',
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              onPressed: () async {
                await Get.to(() => AddProductWizardScreen());
                getData();
              },
              child: const Icon(Icons.add, size: 32),
            ),
          ),
        ),
      ],
    );
    });
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantColor(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outlineColor(context)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryText(context))),
    );
  }

  // Elegant match badge that feels inevitable
  Widget _matchBadge(int count) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryColor,
            Color(0xFF00B894), // Darker teal for depth
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count > 99 ? '99+' : count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.favorite,
            color: Colors.white,
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget _listRow({
    required String imageUrl,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildProductImage(imageUrl, width: 44, height: 44),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if ((subtitle ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.greyText(context), fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: AppColors.greyText(context)),
          ],
        ),
      ),
    );
  }

  Widget _detailsSheet(dynamic p) {
    final image = p.image ?? '';
    final category = p.category ?? '';
    final title = p.title ?? '';
    final minPrice = p.minPrice ?? '';
    final maxPrice = p.maxPrice ?? '';
    final status = p.status ?? '';
    final condition = p.productCondition ?? '';
    
    // Get liked products from matchedProduct's alreadyLikedProducts (not likeProduct)
    final allLikedProducts = productController.matchedProduct.value.alreadyLikedProducts ?? [];
    
    // Debug: Print all likes data
    debugPrint('=== LIKES DEBUG ===');
    debugPrint('Selected Product ID: ${p.id}');
    debugPrint('Total alreadyLikedProducts: ${allLikedProducts.length}');
    
    // Filter likes for this product - userProduct is MY product, otherProduct is what I liked
    final likedForThis = allLikedProducts.where((e) {
      final myProductId = e.userProduct?.id ?? -1;
      final selectedProductId = p.id ?? -2;
      final isLiked = e.alreadyLiked ?? true; // Default true since it's in alreadyLikedProducts
      
      debugPrint('Like entry: myProductId=$myProductId, selectedProductId=$selectedProductId, alreadyLiked=$isLiked, otherProduct=${e.otherProduct?.title}');
      
      return myProductId == selectedProductId;
    }).toList();
    
    debugPrint('Filtered likedForThis count: ${likedForThis.length}');
    debugPrint('=== END LIKES DEBUG ===');

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.45,
      minChildSize: 0.25,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return SingleChildScrollView(
          controller: controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildProductImage(image, width: 72, height: 72),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_cap(title), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      _chip(_cap(category)), // Category is already localized from backend
                                      _chip('${AppLocalizations.of(context)?.minPrice ?? 'Min Price'}: $minPrice'),
                                      _chip('${AppLocalizations.of(context)?.maxPrice ?? 'Max Price'}: $maxPrice'),
                                      if ((p.quantity ?? 0) > 0) _chip('${AppLocalizations.of(context)?.quantity ?? 'Quantity'}: ${p.quantity}'),
                                      _chip('${AppLocalizations.of(context)?.status ?? 'Status'}: ${_translateValue(status)}'),
                                      if ((condition).toString().isNotEmpty) _chip('${AppLocalizations.of(context)?.condition ?? 'Condition'}: ${_translateValue(condition)}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if ((p.status ?? '') == 'active')
                        TextButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            final result = await Get.to(() => EditProductScreen(product: p));
                            // Refresh products if product was updated
                            if (result == true) {
                              getData();
                            }
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(AppLocalizations.of(context)?.edit ?? 'Edit'),
                        )
                      else
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final productService = ProductService();
                            final result = await productService.activateProduct(context, p.id ?? 0);
                            if (result.status == Status.COMPLETED) {
                              Navigator.pop(context);
                              ShowMessage.inDialog(context, AppLocalizations.of(context)?.productActivatedSuccess ?? 'Product activated!', false);
                              getData();
                            }
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(AppLocalizations.of(context)?.activateProduct ?? 'Activate'),
                        )
                    ],
                  ),
                ),
                _productGallery(p),
                // Product Description
                if ((p.description ?? '').toString().trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.description ?? 'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.primaryText(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p.description.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryText(context),
                            height: 1.5,
                          ),
                        ),
                        const Divider(height: 24),
                      ],
                    ),
                  ),
                // Section header for liked products
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red.shade400, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)?.productsYouLiked(likedForThis.length) ?? 'Products You Liked (${likedForThis.length})',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.primaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Liked products list
                Builder(builder: (context) {
                  if (likedForThis.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_outline,
                            size: 48,
                            color: AppColors.greyText(context).withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)?.noLikesYet ?? 'No likes yet',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.greyText(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)?.swipeProductsToLike ?? 'Swipe on products to like them',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.greyText(context).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: likedForThis.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final item = likedForThis[i];
                      final other = item.otherProduct;
                      final imageUrl = (other?.image ?? '').isNotEmpty
                          ? (other?.image ?? '')
                          : KeyConstants.imagePlaceHolder;
                      return _listRow(
                        imageUrl: imageUrl,
                        title: _cap(other?.title),
                        subtitle: _getCategoryName(other?.category),
                        onTap: () {
                          // item is already MatchData, no conversion needed
                          Get.to(() => ProductDetailsScreen(matchData: item));
                        },
                      );
                    },
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          );
      },
    );
  }

  Widget _productGallery(dynamic p) {
    final List<String> raw = (p.images as List<String>?) ?? <String>[];
    final String cover = (p.image ?? '').toString();

    // Remove duplicates using Set to prevent showing same image multiple times
    final baseList = raw.isNotEmpty ? raw : (cover.isNotEmpty ? [cover] : <String>[]);
    final List<String> sources = List<String>.from(baseList.toSet());

    if (sources.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: sources.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final imageStr = sources[i].toString();
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildProductImage(imageStr, width: 200, height: 140),
          );
        },
      ),
    );
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
                color: AppColors.primaryText(context),
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
