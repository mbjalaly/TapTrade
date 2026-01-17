import 'package:taptrade/Models/ChatModels/matchModel.dart';

/// Groups multiple matches by a single product owned by the current user
/// Used to organize the matches list in a product-centric view
class MyProductMatchGroup {
  final int productId;
  final String productTitle;
  final String productImage;
  final List<MatchModel> matches;
  bool isExpanded;

  MyProductMatchGroup({
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.matches,
    this.isExpanded = false,
  });

  /// Total number of matches for this product
  int get matchCount => matches.length;

  /// Get total unread message count across all matches for this product
  int getTotalUnread(String currentUserId) {
    return matches.fold(0, (sum, match) =>
      sum + match.getUnreadCount(currentUserId)
    );
  }

  /// Get the most recent activity time across all matches
  DateTime? get lastActivity {
    final times = matches
      .map((m) => m.lastMessageAt)
      .whereType<DateTime>()
      .toList();

    if (times.isEmpty) return null;

    // Sort descending to get most recent
    times.sort((a, b) => b.compareTo(a));
    return times.first;
  }
}
