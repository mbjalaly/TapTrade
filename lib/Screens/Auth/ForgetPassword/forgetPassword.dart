import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Screens/Dashboard/Bottombar/bottombarscreen.dart';
import 'package:taptrade/Screens/UserDetail/AddProfile/addProfile.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/deviceResolutionType.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusNode emailFocus = FocusNode();
  final TextEditingController emailController = TextEditingController();
  final FocusNode passwordFocus = FocusNode();
  final TextEditingController passwordController = TextEditingController();
  bool obscureText = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailFocus.dispose();
    emailController.dispose();
    passwordFocus.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    bool isTab = DeviceTypeHelper.isTablet(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body:  SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: size.width,
                height: size.height,
                color: Colors.transparent,
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: size.height * 0.23,
                top: size.height * 0.14,
                child: Material(
                  elevation: 4.5,
                  borderRadius: BorderRadius.circular(60),
                  color: Colors.white,
                  child: Container(
                    width: size.width * 0.9,
                    height: size.height * 0.63,
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 20, bottom: 40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryColor
                              .withOpacity(0.2), // #ecfcff
                          AppColors.secondaryColor
                              .withOpacity(0.2), // #fff5db
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Center(child: Image.asset("assets/images/icon2.png",height: isTab ? size.height / 2.7 : null,)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Email",
                              style: const TextStyle(
                                  color: AppColors.primaryTextColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 05,
                            ),
                            TextFormField(
                              controller: emailController,
                              readOnly: false,
                              focusNode: emailFocus,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                filled: true,
                                hintText: 'example@gmail.com',
                                fillColor: AppColors.secondaryColor
                                    .withOpacity(0.3), // Set the fill color
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      50.0), // Set the border radius
                                  borderSide: BorderSide
                                      .none, // Remove the default border
                                ),
                                // contentPadding: const EdgeInsets.only(
                                //     left: 15.0,
                                //     right:
                                //     15.0), // Padding inside the text field
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: size.height * 0.2,
                left: size.width / 4.5,
                right: size.width / 4.5,
                child: AppButton(
                  onPressed: () async {
                    if (emailController.text.isNotEmpty) {
                      setState(() {
                        isLoading = true;
                      });
          
                      try {
                        // Prepare the request body
                        Map<String, dynamic> body = {
                          "email": emailController.text.trim(),
                        };
          
                        // Perform login request
                        final result = await AuthService.instance.forgetPassword(context, body);
          
                        // Handle response
                        if (result.status == Status.COMPLETED && (result.responseData['success'] ?? false)) {
          
                          // Notify user of success
                          ShowMessage.notify(
                            context,
                            result.responseData['message'],
                          );
                          setState(() {
                            isLoading = false;
                            emailController.clear();
                          });
                        } else {
                          // Handle error response
                          setState(() {
                            isLoading = false;
                          });
                          ShowMessage.notify(
                            context,
                            result.responseData['message'] ?? "An error occurred",
                          );
                        }
                      } catch (e) {
                        // Handle exceptions
                        setState(() {
                          isLoading = false;
                        });
          
                        ShowMessage.notify(
                          context,
                          "An error occurred. Please try again later.",
                        );
          
                        debugPrint("Login Error: $e"); // Log the error for debugging
                      }
                    } else {
                      // Show message for empty fields
                      ShowMessage.notify(
                        context,
                        "Please fill email fields",
                      );
                    }
                  },
          
                  text: 'Continue',
                  isLoading: isLoading,
                  width: double.infinity,
                  height: size.height * 0.065,
                  fontSize: size.width * 0.045,
                  buttonColor: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
