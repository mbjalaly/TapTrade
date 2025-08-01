import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'addProductStep1.dart';

class AddProductScreen extends StatefulWidget {
  AddProductScreen({Key?key, this.isDirect = false}) : super(key: key);
  bool isDirect;
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  @override
  void initState() {
    super.initState();
    // Redirect to the new step-by-step flow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.off(() => AddProductStep1(isDirect: widget.isDirect));
    });
  }

    @override
  Widget build(BuildContext context) {
    // This screen will automatically redirect to the new step-by-step flow
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}