import 'package:flutter/material.dart';
import 'package:get/get.dart';
class CustomProductCard extends StatelessWidget {
  final Color color; // Add a color parameter to the card

  CustomProductCard({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.26,
      width: Get.width * 0.37,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color,
        boxShadow: [
          BoxShadow(
            color: Color(0xff99f2e2).withOpacity(0.8), // Shadow color with opacity
            offset: Offset(3, 3), // Right side 3, bottom side 3, no left side shadow
            blurRadius: 6, // Adjust the blur radius as needed
            spreadRadius: 0, // No spread
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.favorite,
                  color: Color(0xfff2b721),
                ),
              ),
            ),
          ),
          Container(
            height: Get.height * 0.16,
            width: Get.width,
            child: Stack(
              children: [
                // First image (shoes)
                Container(
                  margin: EdgeInsets.only(left: 15),
                  height: Get.height * 0.16,
                  width: Get.width * 0.22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.green,
                    image: DecorationImage(
                      image: AssetImage("assets/images/shoes.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                // Second image (watch)
                Positioned(
                  left: Get.width * 0.21,
                  child: Container(
                    height: Get.height * 0.16,
                    width: Get.width * 0.22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.green,
                      image: DecorationImage(
                        image: AssetImage("assets/images/watch.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                // Discount tags
                Positioned(
                  top: Get.height * 0.11,
                  left: 3,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 19,
                        backgroundColor: Colors.white,
                        child: Text(
                          "20%\noff",
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: Get.width * 0.255),
                      CircleAvatar(
                        radius: 19,
                        backgroundColor: Colors.white,
                        child: Text(
                          "50%\noff",
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.5,),
          // Product description
          Text(
            "Products \nDescription",
            style: TextStyle(
              color: Colors.black,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}