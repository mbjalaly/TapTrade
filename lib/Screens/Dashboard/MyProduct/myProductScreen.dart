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
                              Text(_cap(title), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                              const SizedBox(height: 6),
                              _chip(_cap(category)),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () async {
                            if (id >= 0) {
                              try {
                                setState(() {
                                  isDeleting = true;
                                  selectedIndex = index;
                                });
                                final result = await ProductService.instance.deleteMyProduct(
                                  context,
                                  id.toString(),
                                );
                                setState(() {
                                  isDeleting = false;
                                  selectedIndex = -1;
                                });
                                if (result.status == Status.COMPLETED && result.responseData['success']) {
                                  ShowMessage.notify(context, result.responseData['message']);
                                  // Reload products to ensure list is up to date
                                  await getData();
                                } else {
                                  ShowMessage.notify(context, result.responseData['message'] ?? 'Failed to delete product');
                                }
                              } catch (e) {
                                setState(() {
                                  isDeleting = false;
                                });
                                ShowMessage.notify(context, 'An error occurred: ${e.toString()}');
                              }
                            }
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
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
    final liked = productController.likeProduct.value.data ?? [];
    // Filter likes for this product and only where you actually liked
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
    
    print("=== MUTUAL MATCH DEBUGGING ===");
    print("Product ID: ${p.id}");
    print("Total likes for this product: ${likedForThis.length}");
    print("Total all likes: ${allLikes.length}");
    
    // For each product I liked, check if the other user also liked my product
    for (final myLike in likedForThis) {
      final otherProductId = myLike.otherProduct?.id ?? -1;
      final myProductId = p.id ?? -1;
      final otherUserId = myLike.otherProduct?.user ?? '';
      
      print("Checking mutual match:");
      print("  My Product ID: $myProductId");
      print("  Other Product ID: $otherProductId");
      print("  Other User ID: $otherUserId");
      print("  I liked their product: ${myLike.hasLike}");
      
      // Check if the other user also liked my product
      final otherUserLikedMe = allLikes.where((like) =>
        (like.userProduct?.id ?? -1) == otherProductId &&
        (like.otherProduct?.id ?? -1) == myProductId &&
        (like.hasLike ?? false)
      ).toList();
      
      print("  Found ${otherUserLikedMe.length} likes from other user to my product");
      if (otherUserLikedMe.isNotEmpty) {
        print("  Mutual match found! Adding to list.");
        mutualMatches.add(myLike);
      } else {
        print("  No mutual match - other user hasn't liked my product yet");
      }
    }
    
    print("Final mutual matches count: ${mutualMatches.length}");
    print("=== END MUTUAL MATCH DEBUGGING ===");

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.45,
      minChildSize: 0.25,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return DefaultTabController(
          length: 2,
          child: SingleChildScrollView(
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
                TabBar(
                  labelColor: AppColors.primaryTextColor,
                  unselectedLabelColor: AppColors.greyTextColor,
                  tabs: [
                    Tab(text: 'Liked by you (${likedForThis.length})'),
                    Tab(text: 'Matched Product (${mutualMatches.length})'),
                  ],
                ),
                Builder(builder: (context) {
                  final double h = MediaQuery.of(context).size.height * 0.55;
                  return SizedBox(
                    height: h,
                    child: TabBarView(
                      children: [
                        likedForThis.isEmpty
                            ? const Center(child: Text('No likes yet'))
                            : Row(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.all(12),
                                      itemCount: likedForThis.length,
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
                                            final matchData = _convertLikeDataToMatchData(item);
                                            Get.to(() => ProductDetailsScreen(matchData: matchData));
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  // Scroll indicator
                                  Container(
                                    width: 4,
                                    height: 200,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryTextColor.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                        mutualMatches.isEmpty
                            ? const Center(child: Text('No mutual matches yet'))
                            : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(12),
                                itemCount: mutualMatches.length,
                                itemBuilder: (_, i) {
                                  final likeData = mutualMatches[i];
                                  final other = likeData.otherProduct;
                                  final imageUrl = (other?.image ?? '').isNotEmpty
                                      ? (KeyConstants.imageUrl + (other?.image ?? ''))
                                      : KeyConstants.imagePlaceHolder;
                                  return _listRow(
                                    imageUrl: imageUrl,
                                    title: _cap(other?.title),
                                    subtitle: 'Mutual match!',
                                    onTap: () async {
                                      await Get.to(() => MatchDealScreen(
                                        isDirect: true,
                                        likeData: likeData,
                                        matchData: null,
                                        tradeRequestData: null,
                                      ));
                                    },
                                  );
                                },
                              ),
                      ],
                    ),
                  );
                }),
              ],
            ),
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
