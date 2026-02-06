import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Screens/Auth/SsoAccount/verifyOtp.dart';
import 'package:taptrade/Services/IntegrationServices/firebasePhoneAuthService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';
import 'package:taptrade/Widgets/customTextField.dart';
import 'package:taptrade/l10n/app_localizations.dart';

class PhoneSignInScreen extends StatefulWidget {
  PhoneSignInScreen({Key? key, required this.requestModel}) : super(key: key);
  SignUpRequestModel requestModel;
  @override
  State<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  TextEditingController fullNameCon = TextEditingController();
  String countryCode = "+966"; // Default Saudi Arabia
  String countryFlag = "🇸🇦";
  bool isLoading = false;
  final FocusNode fcountry = FocusNode();
  TextEditingController phoneCon = TextEditingController();
  
  /// Get full phone number with country code
  String get fullPhoneNumber => '$countryCode${phoneCon.text.trim()}';
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
        body: SafeArea(
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
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.grey,
                      size: 29,
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065, top: Get.height * 0.03),
                child: AppText(
                  text: l10n.contact,
                  fontSize: Get.width * 0.065,
                  textcolor: AppColors.darkBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065,
                    top: Get.height * 0.0,
                    right: Get.width * 0.065),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showCountryPicker(
                          exclude: <String>[
                            'IL',
                          ],
                          context: context,
                          countryListTheme: CountryListThemeData(
                            flagSize: 25,
                            backgroundColor: AppColors.backgroundColor(context),
                            bottomSheetHeight: 500,
                            // Optional. Country list modal height
                            //Optional. Sets the border radius for the bottomsheet.
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                            //Optional. Styles the search field.
                            inputDecoration: InputDecoration(
                              labelText: l10n.search,
                              hintText: l10n.startTypingToSearch,
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                          onSelect: (Country scountry) {
                            setState(() {
                              countryCode = '+${scountry.phoneCode}';
                              countryFlag = scountry.flagEmoji;
                            });
                            print('Select country: ${scountry.flagEmoji} ${scountry.phoneCode}');
                          },
                        );
                      },
                      child: Center(
                          child: AppText(
                        text: "$countryFlag $countryCode",
                        textcolor: AppColors.textOnBg(context),
                        fontSize: Get.width * 0.035,
                      )),
                    ),
                    Expanded(
                      child: SimpleTextField(
                        keyboardType: TextInputType.number,
                        read: false,
                        textEditingController: phoneCon,
                        hint: '123456789',
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065, right: Get.width * 0.065),
                child: Divider(
                  color: AppColors.outlineColor(context),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065, top: Get.height * 0.015),
                child: AppText(
                  text:
                      "We will send a text with a verification code.\nMessage and data rates may apply.",
                  fontSize: Get.width * 0.032,
                  textcolor: Colors.grey,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Get.width * 0.065, top: Get.height * 0.015),
                child: AppText(
                  text: "Learn what happens when your number changes.",
                  fontSize: Get.width * 0.03,
                  textcolor: AppColors.textOnBg(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: Get.height * 0.07,
              ),
              Center(
                child: AppButton(
                  onPressed: () async {
                    if (phoneCon.text.trim().isEmpty) {
                      ShowMessage.notify(context, l10n.pleaseAddPhoneNumber);
                      return;
                    }
                    
                    // Update request model with phone number
                    widget.requestModel.contact = phoneCon.text.trim();
                    
                    setState(() {
                      isLoading = true;
                    });
                    
                    print("[Firebase Phone Auth] Sending OTP to: $fullPhoneNumber");
                    
                    // Send OTP via Firebase
                    await FirebasePhoneAuthService.instance.sendOtp(
                      phoneNumber: fullPhoneNumber,
                      context: context,
                      onCodeSent: (String verificationId) {
                        setState(() {
                          isLoading = false;
                        });
                        ShowMessage.notify(context, l10n.otpSentTo(fullPhoneNumber));
                        
                        // Navigate to OTP verification screen
                        Get.to(VerifyOtpScreen(
                          requestModel: widget.requestModel,
                          verificationId: verificationId,
                          phoneNumber: fullPhoneNumber,
                        ));
                      },
                      onAutoVerify: (PhoneAuthCredential credential) async {
                        // Auto-verification on Android
                        setState(() {
                          isLoading = false;
                        });
                        ShowMessage.notify(context, l10n.phoneVerifiedAuto);
                        
                        // Navigate to OTP screen (it will handle the auto-verified credential)
                        Get.to(VerifyOtpScreen(
                          requestModel: widget.requestModel,
                          autoVerifiedCredential: credential,
                          phoneNumber: fullPhoneNumber,
                        ));
                      },
                      onError: (String error) {
                        setState(() {
                          isLoading = false;
                        });
                        // Show error in dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.otpError),
                            content: Text(error),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l10n.ok),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  isLoading: isLoading,
                  text: l10n.continueButton,
                  fontSize: Get.width * 0.043,
                  width: Get.width * 0.88,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
