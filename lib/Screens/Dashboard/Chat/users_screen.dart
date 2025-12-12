
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Widgets/customText.dart';
import 'package:taptrade/Widgets/search_field.dart';

class UserChatList extends StatefulWidget {
  const UserChatList({Key? key}) : super(key: key);

  @override
  _UserChatListState createState() => _UserChatListState();
}

class _UserChatListState extends State<UserChatList> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: Get.width * 0.04, right: Get.width * 0.04, top: Get.height * 0.01),

          child: Column(
            children: [
              Row(
                children: [


                  AppText(
                    text: "Traders",
                    textcolor: Colors.black,
                    fontSize: Get.width * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              SizedBox(height: Get.height*0.04,),
              TextFieldWithClearIcon(),
              SizedBox(height: Get.height*0.03,),
          Row(

            children: [
              _buildButton(0, "All"),
              SizedBox(width: 15,),
              _buildButton(1, "Favourites"),
              SizedBox(width: 15,),

              _buildButton(2, "Archives"),
            ],
          ),
              SizedBox(height: Get.height*0.03,),
              Container(
height: Get.height*0.6,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: 8,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
// Get.to(ChatPage());
                        },
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundImage: AssetImage("assets/images/image2.jpg"),
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8),
                                        AppText(
                                          text: "Anny Peter",
                                          textcolor: Colors.black,
                                          fontSize: Get.width * 0.033,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        SizedBox(height: 10),
                                        AppText(
                                          text: "Are you still in barcelona?",
                                          textcolor: Colors.black,
                                          fontSize: Get.width * 0.032,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: (){
                                    // Get.to(ConfirmBookingScreen());
                                  },
                                  child: AppText(text: "12:00 AM",textcolor: Colors.grey,fontSize: Get.width*0.03,textAlign: TextAlign.center,),
                                ),
                              ],
                            ),
                            SizedBox(height: 15,)
                          ],
                        ),
                      );
                    }),
              ),






            ],
          ),
        ),
      ),
    );
  }
  Widget _buildButton(int index, String title) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index; // Change the selected index
        });
      },
      child: Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.symmetric(vertical: 7, horizontal: 22),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFFFB700) : Colors.grey.withOpacity(.30), // Selected/unselected color
          borderRadius: BorderRadius.circular(25), // Rounded corners for buttons
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey, // Text color
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

