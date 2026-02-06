import 'package:get/get.dart';
import 'package:taptrade/Controller/languageController.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Controller/settingsController.dart';
import 'package:taptrade/Controller/userController.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LanguageController>(LanguageController());
    Get.put<UserController>(UserController());
    Get.put<ProductController>(ProductController());
    Get.put<SettingsController>(SettingsController());
  }
}