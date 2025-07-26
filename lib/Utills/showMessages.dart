import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Screens/GetStarted/getStarted.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'appColors.dart';

class ShowMessage {

  // static void toast(String msg) {
  //   Fluttertoast.showToast(
  //       msg: msg,
  //       fontSize: 16,
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.CENTER);
  // }

  static void inDialog(BuildContext context,String message, bool isError) {
    Color color = isError ? Colors.redAccent : Colors.green;
    Get.defaultDialog(
        title: '',
        titleStyle: TextStyle(
            fontFamily: 'Monts',
            fontSize: Get.height * 0.0,
            fontWeight: FontWeight.bold),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: Get.height * 0.032,
              backgroundColor: color,
              child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: Get.height * 0.030,
                  child: Icon(
                    isError ? Icons.warning : Icons.done_outline,
                    color: color,
                    size: Get.height * 0.042,
                  )),
            ),
            SizedBox(
              height: Get.height * 0.016,
            ),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Monts', fontSize: Get.height * 0.022)),
            SizedBox(height: Get.height * 0.02),
          ],
        ),
        actions: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 16),
                  width: Get.width * .32,
                  height: Get.height * .05,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.primaryColor),
                  child: Text(
                    'OK',
                    style: TextStyle(
                        fontFamily: 'Monts',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Get.height * .024),
                  ),
                ),
              )
            ],
          )
        ]);
  }

  static void notify(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(20),
        backgroundColor: AppColors.primaryTextColor,
        elevation: 4,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        content: Text(text),
      ),
    );
  }

  static void inDialogInternet(String message, bool isError) {
    Color color = isError ? Colors.redAccent : Colors.green;
    Get.defaultDialog(
      title: '',
      titleStyle: TextStyle(
          fontFamily: 'Monts',
          fontSize: Get.height * 0.0,
          fontWeight: FontWeight.bold),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: Get.height * 0.032,
            backgroundColor: color,
            child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: Get.height * 0.030,
                child: Icon(
                  isError ? Icons.warning : Icons.done_outline,
                  color: color,
                  size: Get.height * 0.042,
                )),
          ),
          SizedBox(
            height: Get.height * 0.016,
          ),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Monts', fontSize: Get.height * 0.022)),
          SizedBox(height: Get.height * 0.02),
        ],
      ),
      // actions: [
      //   Wrap(
      //     alignment: WrapAlignment.center,
      //     spacing: 8,
      //     runSpacing: 8,
      //     children: [
      //       GestureDetector(
      //         onTap: () => Get.back(),
      //         child: Container(
      //           alignment: Alignment.center,
      //           margin: const EdgeInsets.only(bottom: 16),
      //           width: Get.width * .32,
      //           height: Get.height * .05,
      //           decoration: BoxDecoration(
      //               borderRadius: BorderRadius.circular(10),
      //               color: Resource.colors.appMainColor),
      //           child: Text(
      //             'OK',
      //             style: TextStyle(
      //                 fontFamily: 'Monts',
      //                 color: Colors.white,
      //                 fontWeight: FontWeight.bold,
      //                 fontSize: Get.height * .024),
      //           ),
      //         ),
      //       )
      //     ],
      //   )
      // ]
    );
  }

  static void inDialogUrlCannotLaunch(BuildContext context, String message, bool isError,VoidCallback onTap) {
    Color color = isError ? Colors.redAccent : Colors.green;
    Get.defaultDialog(
        title: '',
        titleStyle: TextStyle(
            fontFamily: 'Monts',
            fontSize: Get.height * 0.0,
            fontWeight: FontWeight.bold),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: Get.height * 0.032,
              backgroundColor: color,
              child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: Get.height * 0.030,
                  child: Icon(
                    isError ? Icons.warning : Icons.done_outline,
                    color: color,
                    size: Get.height * 0.042,
                  )),
            ),
            SizedBox(
              height: Get.height * 0.016,
            ),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Monts', fontSize: Get.height * 0.022)),
            SizedBox(height: Get.height * 0.02),
          ],
        ),
        actions: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              GestureDetector(
                onTap: onTap,
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 16),
                  width: Get.width * .32,
                  height: Get.height * .05,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.primaryColor,),
                  child: Text(
                    'OK',
                    style: TextStyle(
                        fontFamily: 'Monts',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Get.height * .024),
                  ),
                ),
              )
            ],
          )
        ]);
  }

  static void inDialogImageSelection(BuildContext context,String message, bool isError) {
    Color color = isError ? Colors.redAccent : Colors.green;
    Get.defaultDialog(
        title: '',
        titleStyle: TextStyle(
            fontFamily: 'Monts',
            fontSize: Get.height * 0.0,
            fontWeight: FontWeight.bold),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: Get.height * 0.032,
              backgroundColor: color,
              child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: Get.height * 0.030,
                  child: Icon(
                    isError ? Icons.warning : Icons.done_outline,
                    color: color,
                    size: Get.height * 0.042,
                  )),
            ),
            SizedBox(
              height: Get.height * 0.016,
            ),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Monts', fontSize: Get.height * 0.022)),
            SizedBox(height: Get.height * 0.02),
          ],
        ),
        actions: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 16),
                  width: Get.width * .32,
                  height: Get.height * .05,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.primaryColor),
                  child: Text(
                    'OK',
                    style: TextStyle(
                        fontFamily: 'Monts',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Get.height * .024),
                  ),
                ),
              )
            ],
          )
        ]);
  }

  static void showLogoutDialog(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    var userController = Get.find<UserController>();
    var productController = Get.find<ProductController>();
    Size size = MediaQuery.of(context).size;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              actionsPadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.all(15),
              backgroundColor: AppColors.whiteTextColor,
              surfaceTintColor: AppColors.whiteTextColor,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              // actionsPadding: EdgeInsets.all(10),
              content: Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      "assets/animation/wrong.json",
                      height: 120,
                    ),
                    const Text(
                      "Are you sure you want to logout?",
                      style: TextStyle(
                          color: AppColors.blackTextColor,
                          fontSize: 18.0),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          width: size.width * 0.25,
                          height: size.height * 0.05,
                          text: "No",
                          textColor: AppColors.primaryColor,
                        ),
                        AppButton(
                          onPressed:
                              () async {
                            userController.clearAllData();
                            productController.clearAllData();
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (_) => const GetStartedScreen()),
                                        (route) => false);

                            await SharedPreferencesService()
                                .remove(KeyConstants.accessToken);
                            await SharedPreferencesService()
                                .remove(KeyConstants.userId);
                            scaffold.showSnackBar(
                              SnackBar(
                                backgroundColor:
                                AppColors.primaryTextColor,
                                elevation: 4,
                                margin: EdgeInsets.all(20),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.white),
                                    borderRadius:
                                    BorderRadius.circular(10)),
                                content: Text("Logout successfully"),
                              ),
                            );
                          },
                          width: size.width * 0.25,
                          height: size.height * 0.05,
                          text: "Yes",
                          textColor: AppColors.whiteTextColor,
                        ),
                      ],
                    )
                  ],
                ),
              ));
        });
  }

}
