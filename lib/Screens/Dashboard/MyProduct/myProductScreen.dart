import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Controller/userController.dart';
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
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
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
    if (categoryId == null) return 'Not specified';
    
    final categories = GeneralService.instance.allCategory.value.data ?? [];
    final category = categories.firstWhereOrNull((cat) => cat.id == categoryId);
    return category?.name ?? 'Not specified';
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
          SnackBar(content: Text('Error loading products: ${e.toString()}')),
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
          backgroundColor: Colors.white,
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
              const Text(
                'Delete Product',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete:',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                '"${_cap(productTitle)}"',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'This action cannot be undone.',
                style: TextStyle(color: Colors.red.shade400, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
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
              child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
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
          (result.responseData['success'] == true ||
           result.responseData['status'] == 'success' ||
           result.responseData['status'] == true ||
           result.responseData['message']?.toString().toLowerCase().contains('deleted') == true ||
           result.responseData['message']?.toString().toLowerCase().contains('success') == true);

      if (isSuccess) {
        ShowMessage.success(context, result.responseData['message'] ?? 'Product deleted successfully');
        // Reload products to ensure list is up to date
        await getData();
      } else {
        final errorMsg = result.responseData['message'] 
            ?? result.responseData['error']
            ?? 'Failed to delete product';
        ShowMessage.error(context, errorMsg.toString());
      }
    } catch (e) {
      setState(() {
        isDeleting = false;
        selectedIndex = -1;
      });
      ShowMessage.error(context, 'An error occurred. Please try again.');
      debugPrint('Delete error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TabBar(
                labelColor: AppColors.primaryTextColor,
                unselectedLabelColor: AppColors.greyTextColor,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(color: AppColors.primaryColor, width: 3),
                  insets: EdgeInsets.symmetric(horizontal: 16),
                ),
                tabs: const [
                  Tab(text: 'My products'),
                  Tab(text: 'Completed deals'),
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
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryTextColor),
      );
    }
    return Obx(() {
      final myProductList = productController.myProduct.value.data ?? [];
      final activeProducts = myProductList.where((p) => (p.status ?? '') == 'active').toList();
      print("Obx rebuild - Total products: ${myProductList.length}, Active products: ${activeProducts.length}");
      if (myProductList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.greyTextColor),
              const SizedBox(height: 12),
              const Text('No products yet', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Add your first product to get started'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await Get.to(() => AddProductWizardScreen());
                  getData();
                },
                child: const Text('Add product'),
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
          child: activeProducts.isEmpty
              ? ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.greyTextColor),
                          const SizedBox(height: 12),
                          Text(
                            myProductList.isEmpty 
                                ? 'No products yet' 
                                : 'No active products',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            myProductList.isEmpty
                                ? 'Add your first product to get started'
                                : 'You have ${myProductList.length} product(s) but none are active',
                          ),
                          if (myProductList.isEmpty) ...[
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                await Get.to(() => AddProductWizardScreen());
                                getData();
                              },
                              child: const Text('Add product'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 140),
                  itemCount: activeProducts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final p = activeProducts[index];
                    final image = p.image ?? '';
                    final category = p.category ?? '';
                    final title = p.title ?? '';
                    final minPrice = p.minPrice ?? '';
                    final maxPrice = p.maxPrice ?? '';
                    final status = p.status ?? '';
                    final id = p.id ?? -1;
              return CustomShimmer(
                isOn: isDeleting && selectedIndex == index,
                child: Card(
                  color: AppColors.surfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFB3E5FC)), // light blue border
                  ),
                  elevation: 0,
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.white,
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
                                  Icon(Icons.attach_money, size: 14, color: AppColors.primaryTextColor.withOpacity(0.6)),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      '$minPrice - $maxPrice',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryTextColor.withOpacity(0.7),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _chip(_cap(category)),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete',
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
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outline),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryTextColor)),
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
                        style: const TextStyle(color: AppColors.greyTextColor, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: AppColors.greyTextColor),
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
                                      _chip(_cap(category)),
                                      _chip('Min: $minPrice'),
                                      _chip('Max: $maxPrice'),
                                      _chip('Status: ${_cap(status)}'),
                                      if ((condition).toString().isNotEmpty) _chip('Condition: ${_cap(condition)}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                        label: const Text('Edit'),
                      )
                    ],
                  ),
                ),
                _productGallery(p),
                // Section header for liked products
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red.shade400, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Products You Liked (${likedForThis.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.primaryTextColor,
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
                            color: AppColors.greyTextColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No likes yet',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.greyTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Swipe on products to like them',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.greyTextColor.withOpacity(0.7),
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
    final List<String> sources = <String>{
      ...raw,
      if (cover.isNotEmpty) cover,
    }.toList();
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
                color: AppColors.primaryTextColor,
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
