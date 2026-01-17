import 'package:taptrade/Models/ChatModels/matchModel.dart';
import 'package:taptrade/Models/ChatModels/myProductMatchGroup.dart';

/// Helper class for grouping matches by user's products
class MatchGroupingHelper {
  /// Group matches by the current user's products
  ///
  /// Takes a flat list of matches and organizes them by which product
  /// the current user is offering in each match. This creates a
  /// product-centric view where users can see all matches for each
  /// of their products.
  ///
  /// [matches] - List of all matches for the current user
  /// [currentUserId] - ID of the current logged-in user
  ///
  /// Returns a list of [MyProductMatchGroup] sorted by last activity
  static List<MyProductMatchGroup> groupByMyProduct(
    List<MatchModel> matches,
    String currentUserId,
  ) {
    if (matches.isEmpty) {
      return [];
    }

    final Map<int, List<MatchModel>> grouped = {};
    final Map<int, Map<String, String>> productInfo = {};

    for (var match in matches) {
      // The API returns "myProduct" which is already the current user's product
      // No need to check user IDs - the backend handles this
      final myProduct = match.myProduct;
      final myProductId = myProduct?.id;

      // Group by my product ID
      if (myProductId != null && myProduct != null) {
        grouped.putIfAbsent(myProductId, () => []).add(match);

        // Store product info (only need to do once per product)
        productInfo.putIfAbsent(myProductId, () => {
          'title': myProduct.title ?? 'Product',
          'image': myProduct.image ?? '',
        });
      }
    }

    // Convert grouped map to list of MyProductMatchGroup objects
    final groups = grouped.entries.map((entry) {
      final info = productInfo[entry.key]!;
      return MyProductMatchGroup(
        productId: entry.key,
        productTitle: info['title']!,
        productImage: info['image']!,
        matches: entry.value,
      );
    }).toList();

    // Sort groups by most recent activity first
    groups.sort((a, b) {
      final aTime = a.lastActivity;
      final bTime = b.lastActivity;

      // Handle null cases
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1; // Nulls go to end
      if (bTime == null) return -1;

      // Sort descending (most recent first)
      return bTime.compareTo(aTime);
    });

    return groups;
  }
}
