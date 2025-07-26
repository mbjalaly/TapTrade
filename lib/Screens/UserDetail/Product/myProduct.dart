import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Models/ProductModel/productModel.dart';
import 'package:taptrade/Screens/GetStarted/welcomScreen.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';

class MyProductScreen extends StatefulWidget {
  MyProductScreen({Key? key,required this.productList}) : super(key: key);
  List<ProductModel> productList;
  @override
  State<MyProductScreen> createState() => _MyProductScreenState();
}

class _MyProductScreenState extends State<MyProductScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: AppColors.darkYellow,
      //   foregroundColor: AppColors.darkYellow,
      //   onPressed: () {
      //     Get.to( () => const AddProductScreen());
      //   },
      //   child: const Icon(
      //     Icons.add,
      //     color: Colors.white,
      //   ),
      // ),
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        color: AppColors.secondaryColor.withOpacity(0.1),
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.225),
        child: AppButton(
          onPressed: () async{
            // Map<String,dynamic> body = {
            //   "products": widget.productList.map((e) => e.toJson()).toList()
            // };
            // String id = ProfileService.instance.userProfile.value.data?.id ?? '';
            // setState(() {
            //   isLoading = true;
            // });
            // final result = await ProductService.instance.addUserProducts(context, body, id);
            // setState(() {
            //   isLoading = false;
            // });
            // if(result.status == Status.COMPLETED){
              Get.to( () => const WelcomeScreen());
            // }else{
            //   ShowMessage.notify(context, result.responseData['message'].toString());
            // }
          },
          isLoading: isLoading,
          width: Get.width * 0.55,
          text: "Save",
          textColor: Colors.white,
          fontSize: Get.width * 0.04,
        ),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withOpacity(0.1),
              AppColors.secondaryColor.withOpacity(0.1)
            ], // Define your gradient colors
            begin: Alignment.topLeft, // Starting point of the gradient
            end: Alignment.bottomRight, // Ending point of the gradient
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: Get.height * 0.02,
              ),
              Container(
                height: 4,
                width: Get.width,
                color: Colors.grey.withOpacity(.40),
                child: Row(
                  children: [
                    Container(
                      height: 4,
                      width: Get.width,
                      color: AppColors.themeColor,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: Get.height * 0.02,
              ),
              Center(
                child: AppText(
                  text: "Your Products",
                  fontSize: Get.width * 0.1,
                  textcolor: AppColors.darkBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: Get.height * 0.03),
                child: Container(
                  height: Get.height * 0.62,
                  width: Get.width,
                  child: ListView.builder(
                    itemCount: widget.productList.length,
                    itemBuilder: (context, index) {
                      final item = widget.productList[index];
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const SizedBox(width: 20,),
                              AppText(
                                text: '${index+1}.',
                                fontSize: Get.width * 0.06,
                                textcolor: AppColors.darkYellow,
                                fontWeight: FontWeight.w500,
                              ),
                              Center(
                                child: Container(
                                  height: Get.height * 0.17,
                                  width: Get.width * 0.34,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: NetworkImage("${KeyConstants.imageUrl}${item.image}"),
                                      // FileImage(File(item.image??'')),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              AppText(
                                text: "$index.",
                                fontSize: Get.width * 0.06,
                                textcolor: Colors.transparent,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(width: 20,),
                            ],
                          ),
                          SizedBox(height: Get.height * 0.03),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
