import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Models/MatchProduct/matchProduct.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/fadedAnimationUtils.dart';
import 'package:taptrade/Utills/soundManager.dart';
import 'package:taptrade/Utills/utils.dart';
import 'package:taptrade/Widgets/customText.dart';
import 'package:taptrade/Services/SearchFilterService/search_filter_service.dart';
import 'package:taptrade/Services/NotificationService/notification_service.dart';
import 'package:taptrade/Services/LocationService/locationService.dart';
import 'package:taptrade/Services/CooldownService/cooldownService.dart';
import 'ProductDetails/productDetailsScreen.dart';
import 'ProfileSetting/TradePreferences/tradePreferences.dart';
import 'ProfileSetting/SearchFilters/search_filter_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  var userController = Get.find<UserController>();
  var productController = Get.find<ProductController>();
  List<SwipeItem> swipeItems = <SwipeItem>[];
  MatchEngine? matchEngine;
  bool isLoading = false;
  bool _highlightLeft = false;
  bool _highlightRight = false;
  bool _dragLeft = false;
  bool _dragRight = false;
  double _dragAccumX = 0;
  
  // Product selection radio list
  List<int> selectedProductIds = [];
  List<dynamic> userProducts = [];
  bool showProductSelector = false;
  void _triggerSwipe(bool isRight) {
    final current = matchEngine?.currentItem;
    if (current == null) return;
    if (isRight) {
      current.like();
      setState(() { _highlightRight = true; _highlightLeft = false; });
      Future.delayed(const Duration(milliseconds: 400), () { if (mounted) setState(() { _highlightRight = false; }); });
    } else {
      current.nope();
      setState(() { _highlightLeft = true; _highlightRight = false; });
      Future.delayed(const Duration(milliseconds: 400), () { if (mounted) setState(() { _highlightLeft = false; }); });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _loadUserProducts();
    getData();
    super.initState();
  }
  
  Future<void> _loadUserProducts() async {
    try {
      String id = userController.userProfile.value.data?.id ?? '';
      if (id.isNotEmpty) {
        await ProductService.instance.getMyProduct(context, id);
        setState(() {
          userProducts = productController.myProduct.value.data ?? [];
          // Start with no filters - user must explicitly select products to filter
          selectedProductIds = [];
        });
      }
    } catch (e) {
      print("Error loading user products: $e");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    swipeItems.clear();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // When user returns to the app, resync current location and refresh matches
      getData();
    }
  }

  Future<void> _syncCurrentLocation() async {
    try {
      print("Syncing current location...");
      final position = await LocationService.instance.getCurrentLocation();
      final double currentLatitude = position.latitude;
      final double currentLongitude = position.longitude;
      print("Current location: $currentLatitude, $currentLongitude");

      String address = LocationService.instance.userAddress;
      if (address.isEmpty) {
        address = await LocationService.instance
            .getAddressFromLatLng(currentLatitude, currentLongitude);
      }
      print("Address: $address");

      final String userId = userController.userProfile.value.data?.id ?? '';
      if (userId.isEmpty) {
        print("WARNING: Cannot sync location - User ID is empty");
        return;
      }

      final Map<String, dynamic> body = {
        'latitude': double.parse(currentLatitude.toStringAsFixed(6)),
        'longitude': double.parse(currentLongitude.toStringAsFixed(6)),
        'address': address,
      };

      print("Updating profile with location...");
      await ProfileService.instance.updateProfile(context, body, userId);
      print("Profile location updated successfully");
    } catch (e) {
      print("ERROR syncing location: $e");
      // Don't block UX, but log the error
      NotificationService.info(
        title: 'Location access',
        message: 'Unable to access your location. Products may not be accurate.',
      );
    }
  }

  getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      String id = userController.userProfile.value.data?.id ?? '';
      if (id.isEmpty) {
        print("ERROR: User ID is empty, cannot fetch products");
        return;
      }

      print("=== FETCHING PRODUCTS FOR USER: $id ===");

      // Ensure location is synced before fetching products
      await _syncCurrentLocation();
      print("Location synced successfully");

      // Load user products if not already loaded
      if (userProducts.isEmpty) {
        await _loadUserProducts();
        print("User products loaded: ${userProducts.length}");
      }

      // Nearby candidates within radius
      print("Fetching nearby products...");
      await ProductService.instance.getMatchProduct(context, id);
      print("Match products fetched: ${productController.matchedProduct.value.data?.length ?? 0}");

      await ProfileService.instance.getTradePreference(context, id);
      await addItems();

      print("=== FETCH COMPLETE: ${swipeItems.length} swipe items ready ===");
    } catch (e) {
      print("ERROR occurred while fetching match products: $e");
      NotificationService.error(
        title: 'Error loading products',
        message: 'Please check your internet connection and try again',
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  

  likeDislike(Map<String, dynamic> body) async {
    final result =
        await ProductService.instance.productLikeDislike(context, body);
    
    // Refresh like data to update mutual matches
    try {
      String id = userController.userProfile.value.data?.id ?? '';
      if (id.isNotEmpty) {
        await ProductService.instance.getLikeProduct(context, id);
      }
    } catch (e) {
      print("Error refreshing like data: $e");
    }
  }

  Future<void> addItems() async {
    // Build the swipe deck from nearby candidates within radius
    final List<MatchData> listResponse = List<MatchData>.from(productController.matchedProduct.value.data ?? const <MatchData>[]);
    final String currentUserId = userController.userProfile.value.data?.id ?? '';
    swipeItems.clear();
    // Load any saved filters
    final SearchFilters filters = await SearchFilterService.instance.loadFilters();
    
    print("=== DEBUGGING MATCH FILTERING ===");
    print("API Response - Total matches from server: ${listResponse.length}");
    print("Current User ID: $currentUserId");
    print("Selected Product IDs: $selectedProductIds");
    print("Saved Filters - My Product IDs: ${filters.myProductIds}");
    print("Saved Filters - Category IDs: ${filters.categoryIds}");
    print("Saved Filters - Interest Names: ${filters.interestNames}");
    
    // Filter out products that are in cooldown (3-day cooldown)
    final List<MatchData> filteredList = await CooldownService.instance.filterProductsInCooldown(
      listResponse, 
      (MatchData matchData) => matchData.otherProduct?.id ?? -1
    );
    
    print("After cooldown filter: ${filteredList.length}");

    // Sort products by distance from nearest to farthest
    filteredList.sort((a, b) {
      final double distanceA = calculateDistanceForSorting(a.nearbyUser);
      final double distanceB = calculateDistanceForSorting(b.nearbyUser);
      return distanceA.compareTo(distanceB);
    });

    print("Sorted ${filteredList.length} products by distance");

    // Products now sorted by proximity (nearest to farthest)

    // Primary: matched products (nearby candidates) - using filtered list
    int processedCount = 0;
    int skippedOwnProduct = 0;
    int skippedInvalidProduct = 0;
    int skippedProductFilter = 0;
    int skippedCategoryFilter = 0;
    int skippedInterestFilter = 0;
    
    for (int i = 0; i < filteredList.length; i++) {
      processedCount++;
      final match = filteredList[i];
      
      // Skip matches where the other product belongs to the current user
      final String otherOwnerId = match.otherProduct?.user ?? '';
      if (otherOwnerId == currentUserId) {
        skippedOwnProduct++;
        print("SKIPPED (own product): Other Owner ID: $otherOwnerId, Current User: $currentUserId");
        continue;
      }
      final int otherProductId = match.otherProduct?.id ?? -1;
      if (otherProductId <= 0) {
        skippedInvalidProduct++;
        print("SKIPPED (invalid product): Product ID: $otherProductId");
        continue;
      }

      // Apply optional filters
      final int userProductId = match.userProduct?.id ?? -1;
      final int otherCategoryId = match.otherProduct?.category ?? -1;
      final String otherTitle = (match.otherProduct?.title ?? '').toString();
      
      print("Processing match $processedCount: User Product ID: $userProductId, Other Product ID: $otherProductId, Category: $otherCategoryId, Title: $otherTitle");
      
      // Filter by selected products (only apply if user explicitly selected products)
      // Priority: 1) Runtime selection (selectedProductIds) 2) Saved filter (filters.selectedMyProductId)
      final List<int> filterProductIds = selectedProductIds.isNotEmpty
          ? selectedProductIds
          : (filters.selectedMyProductId != null ? [filters.selectedMyProductId!] : []);

      // Only apply product filter if user explicitly selected products
      if (filterProductIds.isNotEmpty && !filterProductIds.contains(userProductId)) {
        skippedProductFilter++;
        print("SKIPPED (product filter): User Product ID $userProductId not in selected products $filterProductIds");
        continue;
      }
      if (filters.categoryIds.isNotEmpty && !filters.categoryIds.contains(otherCategoryId)) {
        skippedCategoryFilter++;
        print("SKIPPED (category filter): Category ID $otherCategoryId not in saved filters ${filters.categoryIds}");
        continue;
      }
      if (filters.interestNames.isNotEmpty) {
        final String titleLower = otherTitle.toLowerCase();
        final bool matchesInterest = filters.interestNames.any((name) => titleLower.contains(name.toLowerCase()));
        if (!matchesInterest) {
          skippedInterestFilter++;
          print("SKIPPED (interest filter): Title '$otherTitle' doesn't match interests ${filters.interestNames}");
          continue;
        }
      }

      swipeItems.add(SwipeItem(
        content: filteredList[i],
        likeAction: () {
          // Block making deals with own product
          if ((filteredList[i].otherProduct?.user ?? '') == currentUserId) {
            return;
          }
          
          // Record product interaction for cooldown
          final int productId = filteredList[i].otherProduct?.id ?? -1;
          if (productId > 0) {
            CooldownService.instance.recordProductInteraction(productId);
          }
          
          Map<String, dynamic> body = {
            "user": filteredList[i].userProduct?.user ?? '',
            "nearby_user": filteredList[i].otherProduct?.user ?? '',
            "user_product": filteredList[i].userProduct?.id ?? '',
            "nearby_user_product": filteredList[i].otherProduct?.id ?? '',
            "feedback": "like",
            "has_like": true,
            "has_dislike": false
          };
          SoundManager().play("bazaarSwipeRight");
          likeDislike(body);
          setState(() {
            _highlightRight = true;
            _highlightLeft = false;
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) setState(() { _highlightRight = false; });
          });
        },
        nopeAction: () {
          // Block making deals with own product
          if ((filteredList[i].otherProduct?.user ?? '') == currentUserId) {
            return;
          }
          
          // Record product interaction for cooldown
          final int productId = filteredList[i].otherProduct?.id ?? -1;
          if (productId > 0) {
            CooldownService.instance.recordProductInteraction(productId);
          }
          
          Map<String, dynamic> body = {
            "user": filteredList[i].userProduct?.user ?? '',
            "nearby_user": filteredList[i].otherProduct?.user ?? '',
            "user_product": filteredList[i].userProduct?.id ?? '',
            "nearby_user_product": filteredList[i].otherProduct?.id ?? '',
            "feedback": "like",
            "has_like": false,
            "has_dislike": true
          };
          SoundManager().play("bazaarSwipeLeft");
          likeDislike(body);
          setState(() {
            _highlightLeft = true;
            _highlightRight = false;
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) setState(() { _highlightLeft = false; });
          });
        },
      ));
    }

    // No fallback to own products; keep empty if no nearby matches
    matchEngine = MatchEngine(swipeItems: swipeItems);

    print("=== FILTERING SUMMARY ===");
    print("Total processed: $processedCount");
    print("Skipped - Own products: $skippedOwnProduct");
    print("Skipped - Invalid products: $skippedInvalidProduct");
    print("Skipped - Product filter: $skippedProductFilter");
    print("Skipped - Category filter: $skippedCategoryFilter");
    print("Skipped - Interest filter: $skippedInterestFilter");
    print("Final swipe items: ${swipeItems.length}");
    print("=== END DEBUGGING ===");

    setState(() {});
    if (swipeItems.isNotEmpty) {
      NotificationService.success(
        title: 'Deals near you',
        message: 'Swipe to explore ${swipeItems.length} items',
      );
    } else {
      // Provide helpful feedback based on why no products are showing
      if (userProducts.isEmpty) {
        NotificationService.info(
          title: 'Add your first product',
          message: 'List products to start trading with others nearby',
        );
      } else if (listResponse.isEmpty) {
        NotificationService.info(
          title: 'No nearby trades',
          message: 'Try increasing your search radius in preferences',
        );
      } else if (skippedProductFilter > 0 || skippedCategoryFilter > 0 || skippedInterestFilter > 0) {
        NotificationService.info(
          title: 'All products filtered',
          message: 'Try adjusting your filters to see more trades',
        );
      } else {
        NotificationService.info(
          title: 'No matches yet',
          message: 'Check back soon for new trading opportunities',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              // Header with title and settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppText(
                      text: "BAZAAR",
                      fontSize: size.width * 0.08,
                      textcolor: AppColors.darkBlue,
                      fontWeight: FontWeight.w700,
                    ),
                    Row(
                      children: [
                        // Product selector toggle button
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              showProductSelector ? Icons.close : Icons.inventory_2_outlined,
                              color: AppColors.primaryColor,
                              size: 24,
                            ),
                            onPressed: () {
                              setState(() {
                                showProductSelector = !showProductSelector;
                              });
                            },
                            tooltip: showProductSelector ? 'Close product selector' : 'Select products',
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Settings button
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.settings_rounded, color: AppColors.primaryColor),
                            onPressed: () async {
                              await Get.to(() => SearchFilterScreen());
                              await getData();
                            },
                            tooltip: 'Search filters',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Product selector panel
              if (showProductSelector) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: "Select Products to Trade",
                        fontSize: size.width * 0.045,
                        textcolor: AppColors.primaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 12),
                      if (userProducts.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'No products available',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: userProducts.map<Widget>((product) {
                            final isSelected = selectedProductIds.contains(product.id);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedProductIds.remove(product.id);
                                  } else {
                                    selectedProductIds.add(product.id);
                                  }
                                });
                                // Refresh matches with new selection
                                getData();
                              },
                              child: Container(
                                width: (size.width - 80) / 2, // Two items per row
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppColors.primaryColor.withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected 
                                        ? AppColors.primaryColor 
                                        : Colors.grey.withOpacity(0.3),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Product image
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: Colors.grey.withOpacity(0.2),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: buildProductImage(
                                          imageUrl: product.image,
                                          fit: BoxFit.cover,
                                          errorWidget: const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Product title
                                    Expanded(
                                      child: Text(
                                        product.title ?? "Product ${product.id}",
                                        style: TextStyle(
                                          fontSize: size.width * 0.035,
                                          color: AppColors.primaryTextColor,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // Selection indicator
                                    Icon(
                                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: isSelected ? AppColors.primaryColor : Colors.grey,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 12),
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedProductIds = userProducts.map((p) => p.id as int).toList();
                              });
                              getData();
                            },
                            child: const Text('Select All'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedProductIds.clear();
                              });
                              getData();
                            },
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
              Expanded(
                child: SizedBox(
                  width: size.width,
                  child: GestureDetector(
                  onTap: () {
                    final MatchData? currentMatch = matchEngine?.currentItem?.content as MatchData?;
                    if (currentMatch != null) {
                      Get.to(() => ProductDetailsScreen(matchData: currentMatch));
                    }
                  },
                  child: Builder(builder: (context) {
                    var currentItem = matchEngine?.currentItem;
                    if (matchEngine != null && swipeItems.isNotEmpty) {
                      return Listener(
                        onPointerDown: (_) {
                          _dragAccumX = 0;
                        },
                        onPointerMove: (evt) {
                          _dragAccumX += evt.delta.dx;
                          final double threshold = size.width * 0.18;
                          if (_dragAccumX > threshold) {
                            setState(() { _dragRight = true; _dragLeft = false; });
                          } else if (_dragAccumX < -threshold) {
                            setState(() { _dragLeft = true; _dragRight = false; });
                          } else {
                            setState(() { _dragLeft = false; _dragRight = false; });
                          }
                        },
                        onPointerUp: (_) {
                          setState(() { _dragLeft = false; _dragRight = false; });
                        },
                        behavior: HitTestBehavior.translucent,
                        child: SwipeCards(
                        matchEngine: matchEngine!,
                        itemBuilder: (BuildContext context, int index) {
                          final MatchData card = swipeItems[index].content as MatchData;
                          UserProduct? userProduct = card.userProduct;
                          UserProduct? otherProduct = card.otherProduct;
                          NearbyUser? nearbyUser = card.nearbyUser;

                          if (userProduct == null || otherProduct == null) {
                            return const Center(
                              child: Text('No product data available'),
                            );
                          }
                          return Center(
                            child: Container(
                                height: double.infinity,
                                width: size.width * 0.94,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: index.isEven
                                      ? const Color(0xff61ffdd)
                                      : const Color(0xfffee598),
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final double availableHeight = constraints.maxHeight;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              height: availableHeight * 0.6,
                                              width: size.width,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                                color: Colors.transparent,
                                              ),
                                            ),
                                            Positioned(
                                              left: 20,
                                              bottom: 50,
                                              child: FadeAnimation(
                                                direction: AnimationDirection.ltr,
                                                delay: 0.5,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: availableHeight * 0.3,
                                                      width: size.width * 0.45,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(100),
                                                        color: Colors.green,
                                                        image: DecorationImage(
                                                          image: getImageProvider(userProduct.image),
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    FadeAnimation(
                                                      direction: AnimationDirection.ltr,
                                                      delay: 0.5,
                                                      child: SizedBox(
                                                        width: size.width * 0.4,
                                                        height: availableHeight * 0.1,
                                                        child: Text(
                                                          "${(userProduct.title ?? '').capitalize}",
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                              fontFamily: 'Cinzel',
                                                              fontWeight: FontWeight.bold,
                                                              color: AppColors.primaryTextColor,
                                                              fontSize: size.width * 0.045),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 20,
                                              bottom: 50,
                                              child: FadeAnimation(
                                                direction: AnimationDirection.rtl,
                                                delay: 0.5,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: availableHeight * 0.3,
                                                      width: size.width * 0.45,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(100),
                                                        color: Colors.green,
                                                        image: DecorationImage(
                                                          image: getImageProvider(otherProduct.image),
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    FadeAnimation(
                                                      direction: AnimationDirection.rtl,
                                                      delay: 0.5,
                                                      child: SizedBox(
                                                        width: size.width * 0.4,
                                                        height: availableHeight * 0.1,
                                                        child: Text(
                                                          "${(otherProduct.title ?? '').capitalize}",
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                              fontFamily: 'Cinzel',
                                                              fontWeight: FontWeight.bold,
                                                              color: AppColors.primaryTextColor,
                                                              fontSize: size.width * 0.045),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        FadeAnimation(
                                          direction: AnimationDirection.btt,
                                          delay: 0.5,
                                          child: Container(
                                            width: size.width,
                                            height: availableHeight * 0.14,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.only(
                                                  bottomLeft: Radius.circular(15),
                                                  bottomRight: Radius.circular(15)),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.black.withOpacity(0.1),
                                                  Colors.black.withOpacity(0.7),
                                                ],
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    AppText(
                                                      text: "Let’s Trade ?",
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: size.width * 0.065,
                                                      textcolor: Colors.white,
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on_outlined,
                                                      color: Colors.white,
                                                      size: 22,
                                                    ),
                                                    const SizedBox(
                                                      width: 3,
                                                    ),
                                                    AppText(
                                                      text: "${calculateDistance(nearbyUser?.latitude ?? 0.0, nearbyUser?.longitude ?? 0.0).toStringAsFixed(1)} km away",
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: size.width * 0.038,
                                                      textcolor: Colors.white,
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )),
                          );
                        },
                        onStackFinished: () async {
                          // Rebuild items applying suppression so interacted products don't immediately reappear
                          await addItems();
                        },
                        itemChanged: (SwipeItem item, int index) {
                          print("item: ${item.content}, index: $index");
                        },
                        leftSwipeAllowed: true,
                        rightSwipeAllowed: true,
                        // upSwipeAllowed: true,
                        // fillSpace: true,
                        likeTag: SizedBox.expand(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 24, bottom: 0),
                              child: const CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.green,
                                child: Icon(Icons.check_rounded, color: Colors.white, size: 36),
                              ),
                            ),
                          ),
                        ),
                        nopeTag: SizedBox.expand(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 24, bottom: 0),
                              child: const CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close_rounded, color: Colors.white, size: 36),
                              ),
                            ),
                          ),
                        ),
                        ),
                      );
                    } else {
                      if (isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryTextColor,
                          ),
                        );
                      } else {
                        // Show appropriate empty state based on the situation
                        String title = 'No matches found nearby';
                        String message = 'Try increasing your search radius or adding more interests to discover more products.';
                        IconData icon = Icons.tune_rounded;
                        String buttonText = 'Adjust search preferences';
                        VoidCallback? onPressed = () async {
                          final profile = userController.userProfile.value;
                          await Get.to(() => TradePreferences(profileData: profile));
                          await getData();
                        };

                        if (userProducts.isEmpty) {
                          title = 'No products to trade';
                          message = 'Add your first product to start trading with others nearby.';
                          icon = Icons.add_circle_outline;
                          buttonText = 'Add a product';
                          onPressed = () async {
                            // Navigate to add product screen
                            await getData();
                          };
                        }

                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                userProducts.isEmpty ? Icons.inventory_2_outlined : Icons.location_off_outlined,
                                size: 64,
                                color: AppColors.primaryTextColor.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                title,
                                style: const TextStyle(
                                  color: AppColors.primaryTextColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Text(
                                  message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.primaryTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: onPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryTextColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: Icon(icon),
                                label: Text(buttonText),
                              ),
                              if (userProducts.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: () async {
                                    await getData();
                                  },
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Refresh'),
                                ),
                              ],
                            ],
                          ),
                        );
                      }
                    }
                  }),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _triggerSwipe(false),
                    child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (_highlightLeft || _dragLeft) ? Colors.red : Colors.transparent,
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                    child: Icon(Icons.close_rounded, color: (_highlightLeft || _dragLeft) ? Colors.white : Colors.red, size: 22),
                  ),
                  ),
                  GestureDetector(
                    onTap: () => _triggerSwipe(true),
                    child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (_highlightRight || _dragRight) ? Colors.green : Colors.transparent,
                      border: Border.all(color: Colors.green, width: 3),
                    ),
                    child: Icon(Icons.check_rounded, color: (_highlightRight || _dragRight) ? Colors.white : Colors.green, size: 22),
                  ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ));
  }
}
