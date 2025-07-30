import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Screens/Dashboard/MyProduct/myProductScreen.dart';
import 'package:taptrade/Screens/Dashboard/ProfileSetting/profileSetting.dart';
import 'package:taptrade/Screens/Dashboard/homescreen.dart';
import 'package:taptrade/Utills/appColors.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  _BottomNavigationScreenState createState() =>
      _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int selectedPage = 1; // Default to Home screen (center button)

  List<String> bottomImages = [
    "assets/images/t.png",
    "assets/images/fav.png",
    "assets/images/ProfileSettingImages/setting.png",
  ];

  List<String> bottomLabels = [
    "My Products",
    "Home",
    "More",
  ];

  List<Widget> pages = [
    const MyProductScreen(),
    HomeScreen(),
    const ProfileSetting(),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          pages[selectedPage],
          // Bottom navigation bar overlaying the screen
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              child: Stack(
                children: [
                  // White rectangular bar at the bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.1 * 255).toInt()),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Left side items
                          _buildSmallNavItem(0),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.15),
                          // Right side items
                          _buildSmallNavItem(2),
                        ],
                      ),
                    ),
                  ),
                  // Prominent center button that overlaps the bar
                  Positioned(
                    bottom: 25,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _buildCenterButton(),
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

  Widget _buildCenterButton() {
    bool isSelected = selectedPage == 1;
    return GestureDetector(
      onTap: () {
        changePage(1);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.22,
        height: MediaQuery.of(context).size.width * 0.22  ,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.primaryColor : AppColors.darkBlue,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.3 * 255).toInt()),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              bottomImages[1],
              height: 35,
              width: 35,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              bottomLabels[1],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallNavItem(int index) {
    bool isSelected = selectedPage == index;
    return GestureDetector(
      onTap: () {
        changePage(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            bottomImages[index],
            height: index == 2 ? 30 : 25, // Bigger icon for "More" tab
            width: index == 2 ? 30 : 25,  // Bigger icon for "More" tab
            color: isSelected ? AppColors.primaryColor : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            bottomLabels[index],
            style: TextStyle(
              color: isSelected ? AppColors.primaryColor : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
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
      onTap: () {
        print("InstructionOverLay tapped - navigating to main screen");
        Get.offAll(() => const BottomNavigationScreen());
      },
      child: Material(
        child: Stack(
          children: [
            const BottomNavigationScreen(),
            Container(
              width: size.width,
              height: size.height,
              color: Colors.black.withAlpha((0.5 * 255).toInt()),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Tap anywhere to continue",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset("assets/images/leftSwip.png", height: 150, width: 150),
                      Image.asset("assets/images/rightSwip.png", height: 150, width: 150),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
