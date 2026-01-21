import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Screens/Dashboard/MyProduct/myProductScreen.dart';
import 'package:taptrade/Screens/Dashboard/homescreen.dart';
import 'package:taptrade/Screens/Dashboard/Chat/matchesListScreen.dart';
import 'package:taptrade/Screens/Dashboard/More/moreScreen.dart';
import 'package:taptrade/Services/IntegrationServices/chatService.dart';
import 'package:taptrade/Utills/appColors.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  _BottomNavigationScreenState createState() =>
      _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int selectedPage = 1; // 0: Products, 1: Bazaar, 2: Matches, 3: More
  int _totalUnreadCount = 0; // Track total unread messages
  Timer? _unreadTimer;

  final List<Widget> pages = const [
    MyProductScreen(),
    // Center tab: Bazaar (Home)
    // Placeholder, will be replaced at runtime with HomeScreen() since it's not const
    SizedBox.shrink(),
    MatchesListScreen(), // Matches tab
    MoreScreen(), // NEW: More tab (settings and profile)
  ];

  // Function to change page
  void changePage(int index) {
    setState(() {
      selectedPage = index;
    });
    // Refresh unread count when changing pages
    if (index == 2) {
      _fetchUnreadCount();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
    // Poll for unread messages every 30 seconds
    _unreadTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchUnreadCount();
    });
  }

  @override
  void dispose() {
    _unreadTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final response = await ChatService.getMatches(context: context);
      if (response?.matches != null && mounted) {
        int totalUnread = 0;
        for (var match in response!.matches!) {
          totalUnread += match.user1UnreadCount ?? 0;
        }
        setState(() {
          _totalUnreadCount = totalUnread;
        });
      }
    } catch (_) {
      // Silently fail - don't show errors for background polling
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget currentPage = selectedPage == 1 ? HomeScreen() : pages[selectedPage];
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: currentPage,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 8),
        child: FloatingActionButton(
          shape: const CircleBorder(),
          foregroundColor: Colors.white,
          heroTag: 'bazaarFab',
          elevation: 4,
          backgroundColor: AppColors.primaryColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: Image.asset(
            'assets/images/t.png',
            height: 34,
            width: 34,
            color: Colors.white,
          ),
          onPressed: () => changePage(1),
        ),
      ),
      bottomNavigationBar: Transform.translate(
        offset: const Offset(0, 8),
        child: SafeArea(
          bottom: false,
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 4,
            color: Colors.white,
            elevation: 6,
            height: 56, // Standard Material height - no overflow
            padding: EdgeInsets.zero, // Remove default padding
            child: Row(
              children: [
                // Left side: Products + Matches
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        index: 0,
                        asset: 'assets/images/board.png',
                        label: 'Products',
                      ),
                      _buildNavItem(
                        index: 2,
                        icon: Icons.favorite,
                        label: 'Matches',
                        badgeCount: _totalUnreadCount,
                      ),
                    ],
                  ),
                ),
                // Spacer for FAB
                const SizedBox(width: 80),
                // Right side: More
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNavItem(
                        index: 3,
                        icon: Icons.more_horiz,
                        label: 'More',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    String? asset,
    IconData? icon,
    required String label,
    int badgeCount = 0,
  }) {
    final bool isSelected = selectedPage == index;
    final color = isSelected ? AppColors.primaryColor : AppColors.greyTextColor;
    final bool hasUnread = badgeCount > 0;

    return Expanded(
      child: InkWell(
        onTap: index >= 0 ? () => changePage(index) : null,
        child: SizedBox(
          height: 56, // Match BottomAppBar height exactly
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  if (asset != null)
                    Image.asset(
                      asset,
                      height: 22,
                      width: 22,
                      color: hasUnread ? Colors.red : color,
                    )
                  else if (icon != null)
                    Icon(
                      icon, 
                      size: 22, 
                      color: hasUnread ? Colors.red : color,
                    ),
                  // Red badge
                  if (hasUnread)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              // Label - intrinsically sized with FittedBox to prevent overflow
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: hasUnread ? Colors.red : color,
                    height: 1.0,
                    letterSpacing: -0.2, // Tighter letter spacing
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class InstructionOverLay extends StatelessWidget {
  const InstructionOverLay({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => Get.off(() => const BottomNavigationScreen()),
      child: Material(
        child: Stack(
          children: [
            const BottomNavigationScreen(),
            Container(
              width: size.width,
              height: size.height,
              color: Colors.black.withValues(alpha: 0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/images/leftSwip.png",height: 150,width: 150,),
                  Image.asset("assets/images/rightSwip.png",height: 150,width: 150,),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
