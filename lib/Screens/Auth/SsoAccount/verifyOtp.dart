import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Screens/UserDetail/AddProfile/addProfile.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customPinCode.dart';
import 'package:taptrade/Widgets/customText.dart';

class VerifyOtpScreen extends StatefulWidget {
  VerifyOtpScreen({Key? key, required this.requestModel}) : super(key: key);
  SignUpRequestModel requestModel;
  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  TextEditingController phoneCon = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: Get.height * 0.02,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.grey,
                        size: 29,
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: Get.width * 0.065, top: Get.height * 0.03),
                  child: AppText(
                    text: "Enter OTP",
                    fontSize: Get.width * 0.065,
                    textcolor: AppColors.darkBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.05,
                ),
                Center(
                  child: CustomPinCodeInput(
                    controller: phoneCon,
                    onDone: (pin) {},
                    onTextChanged: (pin) {},
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.06,
                ),
                Center(
                  child: AppButton(
                    onPressed: () async {
                      if (phoneCon.text.trim().isNotEmpty) {
                        setState(() {
                          isLoading = true;
                        });
                        final result = await AuthService.instance
                            .verifyOtp(context, phoneCon.text);
                        setState(() {
                          isLoading = false;
                        });
                        if (result.status == Status.COMPLETED) {
                          await SharedPreferencesService().setString(
                              KeyConstants.accessToken,
                              result.responseData['token']);
                          await SharedPreferencesService().setString(
                              KeyConstants.userId,
                              result.responseData['user_profile']['id']);
                          ShowMessage.notify(
                              context, result.responseData['message']);
                          ProfileService.instance.getProfile(context);
                          Get.to(const AddProfileScreen());
                        }
                      } else {
                        ShowMessage.notify(context, "Please Insert OTP Code");
                      }
                    },
                    isLoading: isLoading,
                    text: "CONTINUE",
                    fontSize: Get.width * 0.043,
                    width: Get.width * 0.88,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
