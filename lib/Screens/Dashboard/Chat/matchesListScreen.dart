import 'package:flutter/material.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Models/ChatModels/matchModel.dart';
import 'package:taptrade/Models/ChatModels/myProductMatchGroup.dart';
import 'package:taptrade/Helpers/matchGroupingHelper.dart';
import 'package:taptrade/Screens/Dashboard/Chat/chatScreen.dart';
import 'package:taptrade/Services/IntegrationServices/chatService.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/customText.dart';

/// Screen showing list of all matches with chat preview
class MatchesListScreen extends StatefulWidget {
  const MatchesListScreen({Key? key}) : super(key: key);

  @override
  State<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends State<MatchesListScreen> {
  List<MatchModel> _matches = [];
  List<MyProductMatchGroup> _productGroups = []; // NEW: Grouped matches
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    _currentUserId = await SharedPreferencesService().getString(KeyConstants.userId);

    setState(() => _isLoading = true);

    final response = await ChatService.getMatches(context: context);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response?.matches != null) {
          _matches = response!.matches!;
          print('📦 Loaded ${_matches.length} matches from API');

          // NEW: Group matches by user's products
          _productGroups = MatchGroupingHelper.groupByMyProduct(
            _matches,
            _currentUserId ?? '',
          );
          print('📁 Grouped into ${_productGroups.length} product groups');

          // Debug: Show what products were found
          for (var group in _productGroups) {
            print('   • ${group.productTitle}: ${group.matchCount} matches');
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button
        title: AppText(
          text: 'Matches',
          textcolor: AppColors.primaryTextColor,
          fontSize: size.width * 0.05,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _productGroups.isEmpty
              ? _buildEmptyState(size)
              : RefreshIndicator(
                  onRefresh: _loadMatches,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.height * 0.02,
                    ),
                    itemCount: _productGroups.length,
                    itemBuilder: (context, index) {
                      return _buildProductGroupCard(_productGroups[index], size);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(Size size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: size.width * 0.2,
            color: AppColors.greyTextColor,
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            'No matches yet',
            style: TextStyle(
              fontSize: size.width * 0.05,
              color: AppColors.primaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.15),
            child: Text(
              'Keep swiping to find people who want to trade with you!',
              style: TextStyle(
                fontSize: size.width * 0.035,
                color: AppColors.greyTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Product group card with expandable matches
  Widget _buildProductGroupCard(MyProductMatchGroup group, Size size) {
    final totalUnread = group.getTotalUnread(_currentUserId ?? '');

    return Card(
      margin: EdgeInsets.only(bottom: size.height * 0.015),
      elevation: group.isExpanded ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: totalUnread > 0
              ? AppColors.primaryColor.withValues(alpha: 0.3)
              : AppColors.outline,
          width: totalUnread > 0 ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          _buildGroupHeader(group, size),
          if (group.isExpanded)
            _buildExpandedMatches(group, size),
        ],
      ),
    );
  }

  // NEW: Group header (collapsed state)
  Widget _buildGroupHeader(MyProductMatchGroup group, Size size) {
    final totalUnread = group.getTotalUnread(_currentUserId ?? '');

    return InkWell(
      onTap: () {
        setState(() {
          group.isExpanded = !group.isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.03),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildProductImage(
                group.productImage,
                size.width * 0.15,
              ),
            ),

            SizedBox(width: size.width * 0.03),

            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.productTitle,
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      // Match count badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor,
                              Color(0xFF00B894),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${group.matchCount} ${group.matchCount == 1 ? 'match' : 'matches'}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.028,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      if (group.lastActivity != null) ...[
                        SizedBox(width: 8),
                        Text(
                          _formatMatchTime(group.lastActivity),
                          style: TextStyle(
                            fontSize: size.width * 0.028,
                            color: AppColors.greyTextColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Unread badge
            if (totalUnread > 0)
              Container(
                margin: EdgeInsets.only(right: 8),
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  totalUnread > 99 ? '99+' : totalUnread.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.028,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Expand icon
            Icon(
              group.isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: AppColors.primaryTextColor,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Expanded matches list
  Widget _buildExpandedMatches(MyProductMatchGroup group, Size size) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.outline, width: 1),
        ),
      ),
      child: Column(
        children: group.matches.map((match) {
          return _buildMatchTile(match, size);
        }).toList(),
      ),
    );
  }

  // NEW: Individual match tile inside expanded group
  Widget _buildMatchTile(MatchModel match, Size size) {
    final unreadCount = match.getUnreadCount(_currentUserId ?? '');
    final hasUnread = unreadCount > 0;

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(match: match),
          ),
        );
        _loadMatches(); // Refresh after chat
      },
      child: Container(
        padding: EdgeInsets.all(size.width * 0.03),
        decoration: BoxDecoration(
          color: hasUnread
              ? AppColors.primaryColor.withValues(alpha: 0.05)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: AppColors.outline, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Other user's product image
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: _buildProductImage(
                match.theirProduct?.image ?? '',
                size.width * 0.12,
              ),
            ),

            SizedBox(width: size.width * 0.03),

            // Match info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Other product title
                  Text(
                    match.theirProduct?.title ?? 'Product',
                    style: TextStyle(
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 2),

                  // User name
                  Text(
                    match.otherUser?.username ?? 'User',
                    style: TextStyle(
                      fontSize: size.width * 0.03,
                      color: AppColors.greyTextColor,
                    ),
                  ),

                  SizedBox(height: 2),

                  // Last message preview
                  Text(
                    match.lastMessage ?? 'Start chatting!',
                    style: TextStyle(
                      fontSize: size.width * 0.03,
                      color: hasUnread
                          ? AppColors.primaryTextColor
                          : AppColors.greyTextColor,
                      fontWeight: hasUnread
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Unread badge
            if (hasUnread)
              Container(
                margin: EdgeInsets.only(left: 8),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.02,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.028,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Chevron
            Icon(
              Icons.chevron_right,
              color: AppColors.greyTextColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Product image widget
  Widget _buildProductImage(String imageUrl, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: AppColors.surfaceVariant,
      ),
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.image,
                color: AppColors.greyTextColor,
              ),
            )
          : Icon(
              Icons.shopping_bag,
              color: AppColors.greyTextColor,
            ),
    );
  }

  String _formatMatchTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 7) {
      return '${time.day}/${time.month}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'Now';
    }
  }
}
