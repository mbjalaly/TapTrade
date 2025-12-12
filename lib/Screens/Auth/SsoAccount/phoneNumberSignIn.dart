import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Screens/Auth/SsoAccount/verifyOtp.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';
import 'package:taptrade/Widgets/customTextField.dart';

class PhoneSignInScreen extends StatefulWidget {
  PhoneSignInScreen({Key? key, required this.requestModel}) : super(key: key);
  SignUpRequestModel requestModel;
  @override
  State<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  TextEditingController fullNameCon = TextEditingController();
  var code = "";
  // var code2 = "";
  var country_valid = "";
  bool isLoading = false;
  final FocusNode fcountry = FocusNode();
  // TextEditingController countryCon = TextEditingController();
  TextEditingController phoneCon = TextEditingController();
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
                  text: "Contact",
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
                          countryListTheme: const CountryListThemeData(
                            flagSize: 25,
                            backgroundColor: Colors.white,
                            bottomSheetHeight: 500,
                            // Optional. Country list modal height
                            //Optional. Sets the border radius for the bottomsheet.
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                            //Optional. Styles the search field.
                            inputDecoration: InputDecoration(
                              labelText: 'Search',
                              hintText: 'Start typing to search',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                          onSelect: (Country scountry) {
                            // countryCon.text = scountry.name;
                            code =
                                scountry.flagEmoji + " + ${scountry.phoneCode}";
                            // code2 = scountry.phoneCode;
                            setState(() {});
                            print('Select country: ${scountry.flagEmoji}');
                          },
                        );
                      },
                      child: Center(
                          child: AppText(
                        text: code == "" ? "🇸🇦 +966" : code,
                        textcolor: Colors.black,
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
                child: const Divider(
                  color: Colors.black,
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
                  textcolor: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: Get.height * 0.07,
              ),
              Center(
                child: AppButton(
                  onPressed: () async{
                    if(phoneCon.text.trim().isNotEmpty){
                      setState(() {
                        widget.requestModel.contact = phoneCon.text.trim();
                      });
                      print("${widget.requestModel.toJson()}");
                      setState(() {
                        isLoading = true;
                      });
                      final result = await AuthService.instance.signUp(context, widget.requestModel.toJson());
                      setState(() {
                        isLoading = false;
                      });
                      print("-=-=-=-=-= ${result.responseData}");
                      if(result.status == Status.COMPLETED){
                        ShowMessage.notify(context, result.responseData['message']);
                        Get.to(VerifyOtpScreen(requestModel: widget.requestModel,));
                      }
                    }else{
                      ShowMessage.notify(context, "Please Add Your Phone Number");
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
    );
  }
}
