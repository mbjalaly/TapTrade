import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:taptrade/Models/DislikedProduct/dislikedProductModel.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/saudi_riyal_symbol.dart';

class DislikedDealsScreen extends StatefulWidget {
  const DislikedDealsScreen({Key? key}) : super(key: key);

  @override
  State<DislikedDealsScreen> createState() => _DislikedDealsScreenState();
}

class _DislikedDealsScreenState extends State<DislikedDealsScreen> {
  final productController = Get.find<ProductController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productController.getDislikedProduct(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.refusedMatches ?? 'Refused Matches'),
        centerTitle: true,
      ),
      body: Obx(() {
        // Loading state
        if (productController.dislikedProduct.value.status == Status.LOADING) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (productController.dislikedProduct.value.status == Status.ERROR) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)?.failedToLoadRefusedMatches ?? 'Failed to load refused matches',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => productController.getDislikedProduct(context),
                  child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
                ),
              ],
            ),
          );
        }

        // Parse data
        final response = productController.dislikedProduct.value.responseData;
        final List<DislikedProductModel> dislikedProducts = [];

        if (response != null && response['data'] != null) {
          for (var item in response['data']) {
            dislikedProducts.add(DislikedProductModel.fromJson(item));
          }
        }

        // Empty state
        if (dislikedProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.thumb_down_off_alt, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)?.noRefusedMatches ?? 'No Refused Matches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)?.swipeLeftAppearHere ?? 'Products you swipe left on will appear here',
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Grid view
        return RefreshIndicator(
          onRefresh: () => productController.getDislikedProduct(context),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: dislikedProducts.length,
            itemBuilder: (context, index) {
              return _DislikedProductCard(
                dislikedProduct: dislikedProducts[index],
                onRemove: () async {
                  // Show confirmation dialog
                  final confirm = await _showRemoveConfirmation(context);
                  if (confirm == true) {
                    await productController.removeDislikeAndRefresh(
                      context,
                      dislikedProducts[index].id!,
                      dislikedProducts[index].otherProduct!.id!,
                    );
                    ShowMessage.success(context, 'Dislike removed');
                  }
                },
              );
            },
          ),
        );
      }),
    );
  }

  Future<bool?> _showRemoveConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.removeDislike ?? 'Remove Dislike?'),
        content: Text(
          AppLocalizations.of(context)?.removeDislikeMessage ?? 'This product will be available for swiping again. You can like or dislike it in the future.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: Text(AppLocalizations.of(context)?.remove ?? 'Remove'),
          ),
        ],
      ),
    );
  }
}

class _DislikedProductCard extends StatelessWidget {
  final DislikedProductModel dislikedProduct;
  final VoidCallback onRemove;

  const _DislikedProductCard({
    required this.dislikedProduct,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final otherProduct = dislikedProduct.otherProduct;
    final canReSwipe = dislikedProduct.canReSwipe ?? false;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product image
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    otherProduct?.image ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported, size: 48),
                      );
                    },
                  ),
                ),
                // Cooldown overlay
                if (!canReSwipe)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            dislikedProduct.getTimeUntilAvailableString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Product details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherProduct?.title ?? (AppLocalizations.of(context)?.unknown ?? 'Unknown'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  SaudiRiyalFormatter.formatRange(
                    otherProduct?.minPrice ?? '0',
                    otherProduct?.maxPrice ?? '0',
                    fontSize: 12,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  const Spacer(),
                  // Re-enable button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onRemove,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: Text(AppLocalizations.of(context)?.reEnable ?? 'Re-enable', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        side: BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
