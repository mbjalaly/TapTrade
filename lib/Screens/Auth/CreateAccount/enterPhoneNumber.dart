import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
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
import 'package:taptrade/Widgets/customText.dart';
import 'package:taptrade/Widgets/customTextField.dart';

/// Screen for entering phone number after email verification
/// This screen collects the phone number without SMS verification
class EnterPhoneNumberScreen extends StatefulWidget {
  final SignUpRequestModel requestModel;

  const EnterPhoneNumberScreen({
    Key? key,
    required this.requestModel,
  }) : super(key: key);

  @override
  State<EnterPhoneNumberScreen> createState() => _EnterPhoneNumberScreenState();
}

class _EnterPhoneNumberScreenState extends State<EnterPhoneNumberScreen> {
  TextEditingController phoneCon = TextEditingController();
  String countryCode = "+966"; // Default Saudi Arabia
  String countryFlag = "🇸🇦";
  bool isLoading = false;

  String get fullPhoneNumber => '$countryCode${phoneCon.text.trim()}';

  Future<void> _completeRegistration() async {
    if (phoneCon.text.trim().isEmpty) {
      ShowMessage.notify(context, "Please enter your phone number");
      return;
    }

    if (phoneCon.text.trim().length < 8) {
      ShowMessage.notify(context, "Please enter a valid phone number");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Update request model with phone number
      widget.requestModel.contact = fullPhoneNumber;

      // Prepare registration data
      final requestData = widget.requestModel.toJson();
      requestData['phone_verified'] = false; // Phone not verified via SMS
      requestData['email_verified'] = true; // Email was verified via OTP

      // Register user with backend
      final result = await AuthService.instance.signUp(context, requestData);

      setState(() {
        isLoading = false;
      });

      if (result.status == Status.COMPLETED && (result.responseData['success'] ?? false)) {
        print('[Auth] Registration response: ${result.responseData}');

        // Save token
        String? token = result.responseData['token'] 
            ?? result.responseData['access_token']
            ?? result.responseData['data']?['token']
            ?? result.responseData['data']?['access_token'];

        if (token != null && token.isNotEmpty) {
          await SharedPreferencesService().setString(
            KeyConstants.accessToken,
            token,
          );
          print('[Auth] Token saved successfully');
        }

        // Save user ID
        String? userId = result.responseData['data']?['id']?.toString()
            ?? result.responseData['user_profile']?['id']?.toString()
            ?? result.responseData['user']?['id']?.toString()
            ?? result.responseData['id']?.toString();

        if (userId != null && userId.isNotEmpty) {
          await SharedPreferencesService().setString(
            KeyConstants.userId,
            userId,
          );
          print('[Auth] User ID saved: $userId');
        }

        ShowMessage.notify(
          context,
          result.responseData['message'] ?? 'Account created successfully!',
        );

        // Get profile and navigate
        ProfileService.instance.getProfile(context);
        Get.offAll(() => const AddProfileScreen());
      } else {
        String message = result.responseData['message'] ?? 'Registration failed. Please try again.';
        ShowMessage.inDialog(context, message, true);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('[Auth] Registration error: $e');
      ShowMessage.inDialog(context, 'Registration failed. Please try again.', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Get.height * 0.02),
              // Progress bar
              Container(
                height: 4,
                width: Get.width,
                color: Colors.grey.withOpacity(.40),
                child: Row(
                  children: [
                    Container(
                      height: 4,
                      width: Get.width, // Full progress since this is the last step
                      color: AppColors.themeColor,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.grey,
                    size: 29,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: Get.width * 0.065,
                  top: Get.height * 0.03,
                ),
                child: AppText(
                  text: "Phone Number",
                  fontSize: Get.width * 0.065,
                  textcolor: AppColors.darkBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: Get.width * 0.065,
                  right: Get.width * 0.065,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showCountryPicker(
                          exclude: <String>['IL'],
                          context: context,
                          countryListTheme: const CountryListThemeData(
                            flagSize: 25,
                            backgroundColor: Colors.white,
                            bottomSheetHeight: 500,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                            inputDecoration: InputDecoration(
                              labelText: 'Search',
                              hintText: 'Start typing to search',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                          onSelect: (Country country) {
                            setState(() {
                              countryCode = '+${country.phoneCode}';
                              countryFlag = country.flagEmoji;
                            });
                          },
                        );
                      },
                      child: Center(
                        child: AppText(
                          text: "$countryFlag $countryCode",
                          textcolor: Colors.black,
                          fontSize: Get.width * 0.035,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SimpleTextField(
                        keyboardType: TextInputType.phone,
                        read: false,
                        textEditingController: phoneCon,
                        hint: '5XXXXXXXX',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Get.width * 0.065),
                child: const Divider(color: Colors.black),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: Get.width * 0.065,
                  top: Get.height * 0.015,
                ),
                child: AppText(
                  text: "Enter your phone number.\nThis will be used for account recovery and notifications.",
                  fontSize: Get.width * 0.032,
                  textcolor: Colors.grey,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: Get.height * 0.07),
              Center(
                child: AppButton(
                  onPressed: isLoading ? () {} : _completeRegistration,
                  isLoading: isLoading,
                  text: "CREATE ACCOUNT",
                  fontSize: Get.width * 0.043,
                  width: Get.width * 0.88,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
