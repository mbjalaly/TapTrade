import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/l10n/app_localizations.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isSwipeProcessing = false;
  DateTime? _lastSwipeTime;
  DateTime? _lastResumeTime;

  // Product selection radio list
  List<int> selectedProductIds = [];
  List<dynamic> userProducts = [];
  bool showProductSelector = false;
  void _triggerSwipe(bool isRight) {
    // Prevent spam clicking - return if already processing a swipe
    if (_isSwipeProcessing) return;

    // Enforce minimum 600ms cooldown between swipes to prevent rapid clicking
    final now = DateTime.now();
    if (_lastSwipeTime != null) {
      final timeSinceLastSwipe = now.difference(_lastSwipeTime!);
      if (timeSinceLastSwipe.inMilliseconds < 600) {
        return; // Ignore clicks that are too fast
      }
    }

    final current = matchEngine?.currentItem;
    if (current == null) return;

    // Check if there are any swipe items left
    if (swipeItems.isEmpty) return;

    // Update last swipe time
    _lastSwipeTime = now;

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
    _lastResumeTime = DateTime.now();
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
      // Only refresh if it's been more than 2 minutes since last resume/load
      // to avoid clearing the swipe deck on brief app switches
      final now = DateTime.now();
      if (_lastResumeTime != null && now.difference(_lastResumeTime!).inMinutes < 2) {
        return;
      }
      _lastResumeTime = now;
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

      // PIGGYBACK FCM TOKEN IF AVAILABLE
      // This ensures we have a backup way to send the token
      final prefs = await SharedPreferences.getInstance();
      String? fcmToken = prefs.getString(KeyConstants.fcmToken);
      if (fcmToken != null && fcmToken.isNotEmpty) {
        body['fcm_token'] = fcmToken;
        print("📎 Attached FCM token to location update");
      }

      print("Updating profile with location & token...");
      await ProfileService.instance.updateProfile(context, body, userId);
      print("Profile location updated successfully");
    } catch (e) {
      print("ERROR syncing location: $e");
      // Don't block UX, but log the error
      NotificationService.info(
        title: AppLocalizations.of(context)?.locationAccess ?? 'Location access',
        message: AppLocalizations.of(context)?.unableToAccessLocation ?? 'Unable to access your location. Products may not be accurate.',
      );
    }
  }

  Future<void> _syncFcmToken() async {
    try {
      // DIRECT FETCH FROM SERVICE (Fixes race condition & ensures freshness)
      final String? token = await NotificationService.fetchAndSaveToken();
      
      print("🔍 HomeScreen: Token from Service: '$token'");

      if (token != null && token.isNotEmpty) {
        final String userId = userController.userProfile.value.data?.id ?? '';
        if (userId.isNotEmpty) {
             print("🚀 Syncing FCM token: $token");
             if (mounted) {
                final result = await ProfileService.instance.updateProfile(context, {'fcm_token': token}, userId);
                print("📝 Sync result: ${result?.message ?? 'No response'}");
                
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('last_synced_fcm_token', token);
                print("✅ FCM Token synced");
             }
        } else {
            print("❌ Cannot sync FCM: User ID is empty");
        }
      }
    } catch (e) {
      print("Error syncing FCM token: $e");
    }
  }

  getData() async {
    final bool isFirstLoad = swipeItems.isEmpty;
    try {
      // Only show loading spinner on first load (no existing cards)
      if (isFirstLoad) {
        setState(() {
          isLoading = true;
        });
      }
      String id = userController.userProfile.value.data?.id ?? '';
      if (id.isEmpty) {
        print("ERROR: User ID is empty, cannot fetch products");
        return;
      }

      print("=== FETCHING PRODUCTS FOR USER: $id ===");

      // Fire all independent operations in parallel:
      // - Fetch products immediately (using server's last-known location)
      // - Sync location, FCM token, user products, trade prefs in background
      final productsFuture = ProductService.instance.getMatchProduct(context, id);

      // These don't block product loading
      _syncFcmToken();
      _syncCurrentLocation().then((_) {
        // After location syncs, re-fetch products if location may have changed
        if (mounted && !isFirstLoad) {
          ProductService.instance.getMatchProduct(context, id).then((_) {
            if (mounted) addItems();
          });
        }
      });
      if (userProducts.isEmpty) {
        _loadUserProducts();
      }
      ProfileService.instance.getTradePreference(context, id);

      // Only await the product fetch — the critical path
      await productsFuture;
      print("Match products fetched: ${productController.matchedProduct.value.data?.length ?? 0}");

      await addItems();

      print("=== FETCH COMPLETE: ${swipeItems.length} swipe items ready ===");
    } catch (e) {
      print("ERROR occurred while fetching match products: $e");
      // Only show error if we have no products to display at all
      if (swipeItems.isEmpty &&
          (productController.matchedProduct.value.data == null ||
          productController.matchedProduct.value.data!.isEmpty)) {
        NotificationService.error(
          title: AppLocalizations.of(context)?.errorLoadingProducts ?? 'Error loading products',
          message: AppLocalizations.of(context)?.checkInternetConnection ?? 'Please check your internet connection and try again',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
    final List<MatchData> alreadyLikedResponse = List<MatchData>.from(productController.matchedProduct.value.alreadyLikedProducts ?? const <MatchData>[]);
    final String currentUserId = userController.userProfile.value.data?.id ?? '';
    swipeItems.clear();
    // Load any saved filters
    final SearchFilters filters = await SearchFilterService.instance.loadFilters();

    print("=== DEBUGGING MATCH FILTERING ===");
    print("API Response - New matches from server: ${listResponse.length}");
    print("API Response - Already liked products: ${alreadyLikedResponse.length}");
    print("Current User ID: $currentUserId");
    print("Selected Product IDs: $selectedProductIds");
    print("Saved Filters - My Product IDs: ${filters.myProductIds}");
    print("Saved Filters - Category IDs: ${filters.categoryIds}");
    print("Saved Filters - Interest Names: ${filters.interestNames}");

    // No cooldown - use listResponse directly
    // Backend already filters out liked/disliked products

    // If no new products, use already-liked products as fallback
    bool usingFallback = false;
    List<MatchData> productsToShow = listResponse;
    if (listResponse.isEmpty && alreadyLikedResponse.isNotEmpty) {
      print("No new products available, showing ${alreadyLikedResponse.length} already-liked products as fallback");
      productsToShow = alreadyLikedResponse;
      usingFallback = true;
    }

    // Sort products by distance from nearest to farthest
    productsToShow.sort((a, b) {
      final double distanceA = calculateDistanceForSorting(a.nearbyUser);
      final double distanceB = calculateDistanceForSorting(b.nearbyUser);
      return distanceA.compareTo(distanceB);
    });

    print("Sorted ${productsToShow.length} products by distance");

    // Products now sorted by proximity (nearest to farthest)

    // Primary: matched products (nearby candidates) - using filtered list
    int processedCount = 0;
    int skippedOwnProduct = 0;
    int skippedInvalidProduct = 0;
    int skippedProductFilter = 0;
    int skippedCategoryFilter = 0;
    int skippedInterestFilter = 0;

    for (int i = 0; i < productsToShow.length; i++) {
      processedCount++;
      final match = productsToShow[i];
      
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
        content: productsToShow[i],
        likeAction: () async {
          // Prevent multiple simultaneous swipes
          if (_isSwipeProcessing) return;

          // Block making deals with own product
          if ((productsToShow[i].otherProduct?.user ?? '') == currentUserId) {
            return;
          }

          try {
            setState(() => _isSwipeProcessing = true);

            Map<String, dynamic> body = {
              "user": productsToShow[i].userProduct?.user ?? '',
              "nearby_user": productsToShow[i].otherProduct?.user ?? '',
              "user_product": productsToShow[i].userProduct?.id ?? '',
              "nearby_user_product": productsToShow[i].otherProduct?.id ?? '',
              "feedback": "like",
              "has_like": true,
              "has_dislike": false
            };

            SoundManager().play("bazaarSwipeRight");
            await likeDislike(body); // NOW AWAIT THE OPERATION

            if (mounted) {
              setState(() {
                _highlightRight = true;
                _highlightLeft = false;
              });
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) setState(() { _highlightRight = false; });
              });
            }
          } finally {
            if (mounted) {
              setState(() => _isSwipeProcessing = false);
            }
          }
        },
        nopeAction: () async {
          // Prevent multiple simultaneous swipes
          if (_isSwipeProcessing) return;

          // Block making deals with own product
          if ((productsToShow[i].otherProduct?.user ?? '') == currentUserId) {
            return;
          }

          try {
            setState(() => _isSwipeProcessing = true);

            Map<String, dynamic> body = {
              "user": productsToShow[i].userProduct?.user ?? '',
              "nearby_user": productsToShow[i].otherProduct?.user ?? '',
              "user_product": productsToShow[i].userProduct?.id ?? '',
              "nearby_user_product": productsToShow[i].otherProduct?.id ?? '',
              "feedback": "dislike",
              "has_like": false,
              "has_dislike": true
            };

            SoundManager().play("bazaarSwipeLeft");
            await likeDislike(body); // NOW AWAIT THE OPERATION

            if (mounted) {
              setState(() {
                _highlightLeft = true;
                _highlightRight = false;
              });
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) setState(() { _highlightLeft = false; });
              });
            }
          } finally {
            if (mounted) {
              setState(() => _isSwipeProcessing = false);
            }
          }
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
      if (usingFallback) {
        NotificationService.info(
          title: AppLocalizations.of(context)?.noNewProductsNearby ?? 'No new products nearby',
          message: AppLocalizations.of(context)?.showingAlreadyLikedProducts(swipeItems.length) ?? 'Showing ${swipeItems.length} products you already liked',
        );
      } else {
        NotificationService.success(
          title: AppLocalizations.of(context)?.dealsNearYou ?? 'Deals near you',
          message: AppLocalizations.of(context)?.swipeToExploreItems(swipeItems.length) ?? 'Swipe to explore ${swipeItems.length} items',
        );
      }
    } else {
      // Provide helpful feedback based on why no products are showing
      if (userProducts.isEmpty) {
        NotificationService.info(
          title: AppLocalizations.of(context)?.addYourFirstProduct ?? 'Add your first product',
          message: AppLocalizations.of(context)?.listProductsToStartTrading ?? 'List products to start trading with others nearby',
        );
      } else if (listResponse.isEmpty && alreadyLikedResponse.isEmpty) {
        NotificationService.info(
          title: AppLocalizations.of(context)?.noNearbyTrades ?? 'No nearby trades',
          message: AppLocalizations.of(context)?.tryIncreasingSearchRadius ?? 'Try increasing your search radius in preferences',
        );
      } else if (skippedProductFilter > 0 || skippedCategoryFilter > 0 || skippedInterestFilter > 0) {
        NotificationService.info(
          title: AppLocalizations.of(context)?.allProductsFiltered ?? 'All products filtered',
          message: AppLocalizations.of(context)?.tryAdjustingFilters ?? 'Try adjusting your filters to see more trades',
        );
      } else {
        NotificationService.info(
          title: AppLocalizations.of(context)?.noMatchesYet ?? 'No matches yet',
          message: AppLocalizations.of(context)?.checkBackSoon ?? 'Check back soon for new trading opportunities',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
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
                      text: AppLocalizations.of(context)?.bazaar ?? "BAZAAR",
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
                            tooltip: showProductSelector ? (AppLocalizations.of(context)?.closeProductSelector ?? 'Close product selector') : (AppLocalizations.of(context)?.selectProducts ?? 'Select products'),
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
                            icon: const Icon(Icons.filter_list, color: AppColors.primaryColor),
                            onPressed: () async {
                              await Get.to(() => SearchFilterScreen());
                              await getData();
                            },
                            tooltip: AppLocalizations.of(context)?.searchFiltersTooltip ?? 'Search filters',
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
                    color: AppColors.contentBg(context),
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
                        text: AppLocalizations.of(context)?.selectProductsToTrade ?? "Select Products to Trade",
                        fontSize: size.width * 0.045,
                        textcolor: AppColors.primaryText(context),
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 12),
                      if (userProducts.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              AppLocalizations.of(context)?.noProductsAvailable ?? 'No products available',
                              style: TextStyle(color: AppColors.greyText(context)),
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
                                      : AppColors.greyBg(context).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected 
                                        ? AppColors.primaryColor 
                                        : AppColors.outlineColor(context).withOpacity(0.3),
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
                                        color: AppColors.greyBg(context).withOpacity(0.2),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: buildProductImage(
                                          imageUrl: product.image,
                                          fit: BoxFit.cover,
                                          errorWidget: Icon(
                                            Icons.image_not_supported,
                                            color: AppColors.greyText(context),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Product title
                                    Expanded(
                                      child: Text(
                                        product.title ?? (AppLocalizations.of(context)?.productFallback ?? "Product {id}").toString().replaceAll('{id}', '${product.id}'),
                                        style: TextStyle(
                                          fontSize: size.width * 0.035,
                                          color: AppColors.primaryText(context),
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
                            child: Text(AppLocalizations.of(context)?.selectAll ?? 'Select All'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedProductIds.clear();
                              });
                              getData();
                            },
                            child: Text(AppLocalizations.of(context)?.clearAll ?? 'Clear All'),
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
                            return Center(
                              child: Text(AppLocalizations.of(context)?.noProductDataAvailable ?? 'No product data available'),
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
                                                              color: AppColors.primaryText(context),
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
                                                              color: AppColors.primaryText(context),
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
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              alignment: AlignmentDirectional.bottomEnd,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  AppText(
                                                    text: AppLocalizations.of(context)?.letsTrade ?? "Let's Trade?",
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: size.width * 0.065,
                                                    textcolor: Colors.white,
                                                  ),
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
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
                                                        text: AppLocalizations.of(context)?.kmAway(calculateDistance(nearbyUser?.latitude ?? 0.0, nearbyUser?.longitude ?? 0.0).toStringAsFixed(1)) ?? "${calculateDistance(nearbyUser?.latitude ?? 0.0, nearbyUser?.longitude ?? 0.0).toStringAsFixed(1)} km away",
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
                        likeTag: const CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.green,
                          child: Icon(Icons.check_rounded, color: Colors.white, size: 36),
                        ),
                        nopeTag: const CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.close_rounded, color: Colors.white, size: 36),
                        ),
                        ),
                      );
                    } else {
                      if (isLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryText(context),
                          ),
                        );
                      } else {
                        // Show appropriate empty state based on the situation
                        String title = AppLocalizations.of(context)?.noMatchesNearby ?? 'No matches found nearby';
                        String message = AppLocalizations.of(context)?.noMatchesNearbyMessage ?? 'Try increasing your search radius or adding more interests to discover more products.';
                        IconData icon = Icons.filter_list;
                        String buttonText = AppLocalizations.of(context)?.adjustSearchPreferences ?? 'Adjust search preferences';
                        VoidCallback? onPressed = () async {
                          await Get.to(() => SearchFilterScreen());
                          await getData();
                        };

                        if (userProducts.isEmpty) {
                          title = AppLocalizations.of(context)?.noProductsToTrade ?? 'No products to trade';
                          message = AppLocalizations.of(context)?.noProductsToTradeMessage ?? 'Add your first product to start trading with others nearby.';
                          icon = Icons.add_circle_outline;
                          buttonText = AppLocalizations.of(context)?.addAProduct ?? 'Add a product';
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
                                color: AppColors.primaryText(context).withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                title,
                                style: TextStyle(
                                  color: AppColors.primaryText(context),
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
                                  style: TextStyle(
                                    color: AppColors.primaryText(context),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: onPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryText(context),
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
                                  label: Text(AppLocalizations.of(context)?.refresh ?? 'Refresh'),
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
              child: Directionality(
                textDirection: TextDirection.ltr,
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
            ),
            ],
          ),
        ));
  }
}
