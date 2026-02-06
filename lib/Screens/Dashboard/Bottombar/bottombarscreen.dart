import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:taptrade/Screens/Dashboard/MyProduct/myProductScreen.dart';
import 'package:taptrade/Screens/Dashboard/homescreen.dart';
import 'package:taptrade/Screens/Dashboard/Chat/matchesListScreen.dart';
import 'package:taptrade/Screens/Dashboard/More/moreScreen.dart';
import 'package:taptrade/Screens/GetStarted/locationPermissionScreen.dart';
import 'package:taptrade/Services/IntegrationServices/chatService.dart';
import 'package:taptrade/Utills/appColors.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  _BottomNavigationScreenState createState() =>
      _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> with WidgetsBindingObserver {
  int selectedPage = 1; // 0: Products, 1: Bazaar, 2: Matches, 3: Profile
  int _totalUnreadCount = 0; // Track total unread messages
  Timer? _unreadTimer;
  StreamSubscription<ServiceStatus>? _serviceStatusSub;

  // Pages list to preserve state
  List<Widget>? _pages;

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
    WidgetsBinding.instance.addObserver(this);
    _fetchUnreadCount();
    // Poll for unread messages every 5 seconds for real-time updates
    _unreadTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchUnreadCount();
    });
    // Listen for location service being toggled off
    _serviceStatusSub = Geolocator.getServiceStatusStream().listen((status) {
      if (status == ServiceStatus.disabled) {
        _redirectToLocationScreen();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _unreadTimer?.cancel();
    _serviceStatusSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchUnreadCount();
      _checkLocationPermission();
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _redirectToLocationScreen();
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _redirectToLocationScreen();
      }
    } catch (_) {}
  }

  void _redirectToLocationScreen() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LocationPermissionScreen(
          destination: BottomNavigationScreen(),
        ),
      ),
      (route) => false,
    );
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
    // Initialize pages on first build to ensure proper context
    _pages ??= [
      const MyProductScreen(),
      HomeScreen(),
      const MatchesListScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      extendBody: true,
      body: IndexedStack(
        index: selectedPage,
        children: _pages!,
      ),
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
            color: AppColors.contentBg(context),
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
                        label: AppLocalizations.of(context)?.myProducts ?? 'Products',
                      ),
                      _buildNavItem(
                        index: 2,
                        icon: Icons.favorite,
                        label: AppLocalizations.of(context)?.matches ?? 'Matches',
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
                        icon: Icons.person_outline,
                        label: AppLocalizations.of(context)?.profile ?? 'Profile',
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
    final color = isSelected ? AppColors.primaryColor : AppColors.greyText(context);
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
                      color: color,
                    )
                  else if (icon != null)
                    Icon(
                      icon,
                      size: 22,
                      color: color,
                    ),
                  // Red badge
                  if (hasUnread)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          // Dynamic color: gray when on matches screen, red otherwise
                          color: (label == 'Matches' && selectedPage == 2)
                              ? Colors.grey.shade600
                              : Colors.lightBlue,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          style: TextStyle(
                            color: AppColors.primaryColor,
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
                    color: color,
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
