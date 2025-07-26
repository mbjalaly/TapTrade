import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Screens/Dashboard/Explore/exploreScreen.dart';
import 'package:taptrade/Screens/Dashboard/MyProduct/myProductScreen.dart';
import 'package:taptrade/Screens/Dashboard/ProfileSetting/profileSetting.dart';
import 'package:taptrade/Screens/Dashboard/homescreen.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  _BottomNavigationScreenState createState() =>
      _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int selectedPage = 2;

  List<String> bottomImages = [
    "assets/images/t.png",
    "assets/images/board.png",
    "assets/images/fav.png",
    // "assets/images/chatIcon.png",
    "assets/images/profile.png",
  ];

  List<Widget> pages = [
    const MyProductScreen(),
    const ExploreScreen(),
    HomeScreen(),
    // const UserChatList(),
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
      body: pages[selectedPage],
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.07,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.black, // Color of the border
              width: 2.0, // Border width
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            bottomImages.length,
                (index) => bottomItemButton(index),
          ),
        ),
      ),
    );
  }

  Widget bottomItemButton(int index) {
    return GestureDetector(
      onTap: () {
        changePage(index);
      },
      child: Container(
        height: 70,
        width: MediaQuery.of(context).size.width * 0.19,
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Image.asset(
              bottomImages[index],
              height: 25,
              width: 25,
            )
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
