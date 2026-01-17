import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Screens/Dashboard/MyProduct/myProductScreen.dart';
import 'package:taptrade/Screens/Dashboard/homescreen.dart';
import 'package:taptrade/Screens/Dashboard/Chat/matchesListScreen.dart';
import 'package:taptrade/Screens/Dashboard/More/moreScreen.dart';
import 'package:taptrade/Utills/appColors.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  _BottomNavigationScreenState createState() =>
      _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int selectedPage = 1; // 0: Products, 1: Bazaar, 2: Matches, 3: More

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
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
  }) {
    final bool isSelected = selectedPage == index;
    final color = isSelected ? AppColors.primaryColor : AppColors.greyTextColor;

    return Expanded(
      child: InkWell(
        onTap: index >= 0 ? () => changePage(index) : null,
        child: SizedBox(
          height: 56, // Match BottomAppBar height exactly
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon - compact size
              if (asset != null)
                Image.asset(
                  asset,
                  height: 22,
                  width: 22,
                  color: color,
                )
              else if (icon != null)
                Icon(icon, size: 22, color: color),
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
