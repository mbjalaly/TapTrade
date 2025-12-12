import 'dart:io';

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
  int selectedPage = 1; // 0: Products, 1: Bazaar, 2: Profile

  final List<Widget> pages = const [
    MyProductScreen(),
    // Center tab: Bazaar (Home)
    // Placeholder, will be replaced at runtime with HomeScreen() since it's not const
    SizedBox.shrink(),
    ProfileSetting(),
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
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.075,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _sideTab(
                      context,
                      index: 0,
                      asset: 'assets/images/board.png',
                      label: 'Products',
                    ),
                  ),
                  const SizedBox(width: 56), // space for FAB notch
                  Expanded(
                    child: _sideTab(
                      context,
                      index: 2,
                      asset: 'assets/images/profile.png',
                      label: 'More',
                      alignRight: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sideTab(BuildContext context, {required int index, required String asset, required String label, bool alignRight = false}) {
    final bool isSelected = selectedPage == index;
    return InkWell(
      onTap: () => changePage(index),
      child: Padding(
        padding: EdgeInsets.only(left: alignRight ? 12 : 20, right: alignRight ? 20 : 12),
        child: Row(
          mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Image.asset(
              asset,
              height: 28,
              width: 28,
              color: isSelected ? AppColors.primaryColor : AppColors.greyTextColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primaryColor : AppColors.greyTextColor,
              ),
            ),
          ],
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
              color: Colors.black.withOpacity(0.5),
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
