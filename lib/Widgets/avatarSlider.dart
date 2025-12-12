import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class AvatarSlider extends StatefulWidget {
  const AvatarSlider({super.key});

  @override
  State<AvatarSlider> createState() => _AvatarSliderState();
}

class _AvatarSliderState extends State<AvatarSlider> {
  static const List<String> avatarList = [
    'assets/avatarProfile/1.png',
    'assets/avatarProfile/2.png',
    'assets/avatarProfile/3.png',
    'assets/avatarProfile/4.png',
    'assets/avatarProfile/5.png',
  ];
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return CarouselSlider(
      items: List.generate(avatarList.length, (index) =>  InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor:
        Colors.transparent,
        onTap: () async {
          Navigator.pop(context,avatarList[index]);
        },
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(12),
          child: Image.asset(
            avatarList[index],
            width: double.infinity,
            height: 85,
            fit: BoxFit.fill,
          ),
        ),
      ),),
      options: CarouselOptions(
        height: size.height * 0.3,
        enlargeCenterPage: true,
        autoPlay: false,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.easeInOutBack,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: Duration(seconds: 1),
        viewportFraction: 0.7,
      ),
    );
  }
}