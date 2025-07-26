import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Models/UserProfile/userProfile.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';

class AddBioScreen extends StatefulWidget {
  AddBioScreen({Key? key, required this.profileData}) : super(key: key);
  UserProfileResponseModel profileData;
  @override
  State<AddBioScreen> createState() => _AddBioScreenState();
}

class _AddBioScreenState extends State<AddBioScreen> {
  var userController = Get.find<UserController>();
  String code = "";
  TextEditingController name = TextEditingController();
  TextEditingController userName = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController dob = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController email = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    name.text = widget.profileData.data?.fullName ?? '';
    userName.text = widget.profileData.data?.username ?? '';
    gender.text = (widget.profileData.data?.gender ?? '').isEmpty ? 'Male' : widget.profileData.data?.gender ?? '';
    dob.text = widget.profileData.data?.dob ?? '';
    contact.text = widget.profileData.data?.contact ?? '';
    email.text = widget.profileData.data?.email ?? '';
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    name.dispose();
    userName.dispose();
    gender.dispose();
    dob.dispose();
    contact.dispose();
    email.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Image.asset(
          "assets/images/t.png",
          height: 30,
          width: 30,
        ),),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: AppText(
                text: "User Information",
                fontSize: size.width * 0.078,
                textcolor: AppColors.darkBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Stack(
              children: [
                Container(
                  width: size.width,
                  height: size.height * 0.77,
                  color: Colors.transparent,
                ),
                Center(
                  child: Material(
                    elevation: 4.5,
                    borderRadius: BorderRadius.circular(60),
                    color: Colors.white,
                    child: Container(
                      width: size.width * 0.9,
                      height: size.height * 0.75,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryColor.withOpacity(0.2), // #ecfcff
                            AppColors.secondaryColor
                                .withOpacity(0.2), // #fff5db
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          fieldWidget("NAME:", name, false,null),
                          const SizedBox(
                            height: 10,
                          ),
                          fieldWidget("USER NAME:", userName, false,null),
                          const SizedBox(
                            height: 10,
                          ),
                          genderDropdownWidget("GENDER:", gender.text.capitalize ?? '', (value){
                            gender.text = value ?? '';
                            setState(() {

                            });
                          }),
                          const SizedBox(
                            height: 10,
                          ),
                          fieldWidget("D.O.B :", dob, true,() async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                // Format the selected date as YYYY-MM-DD
                                dob.text = DateFormat('yyyy-MM-dd').format(picked);
                              });
                            }
                          },),
                          const SizedBox(
                            height: 10,
                          ),
                          fieldWidget("CONTACT#:", contact, false,null,keyboardType: TextInputType.number,prefix: true),
                          const SizedBox(
                            height: 10,
                          ),
                          fieldWidget("EMAIL:", email, true,null),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: size.width / 4.5,
                  right: size.width / 4.5,
                  child: AppButton(
                    onPressed: () async {
                      String? message;
                      if (name.text.trim().isEmpty) {
                        message = "Please add Name";
                      } else if (userName.text.trim().isEmpty) {
                        message = "Please add userName";
                      } else if (gender.text.trim().isEmpty) {
                        message = "Please select gender";
                      } else if (dob.text.trim().isEmpty) {
                        message = "Please add DOB";
                      } else if (contact.text.trim().isEmpty) {
                        message = "Please add contact number";
                      } else if (email.text.trim().isEmpty) {
                        message = "Please add email";
                      } else {}

                      if (message != null) {
                        ShowMessage.notify(context, message);
                        return;
                      }
                      Map<String, dynamic> body = {
                        'username': userName.text,
                        'gender': gender.text.trim().toLowerCase(),
                        'dob': dob.text.trim(),
                        'full_name': name.text.trim(),
                        'contact': contact.text.trim(),
                      };
                      String id = userController.userProfile.value.data?.id ??
                              '';
                      setState(() {
                        isLoading = true;
                      });
                      final result = await ProfileService.instance
                          .updateProfile(context, body, id);
                      await ProfileService.instance.getProfile(context);
                      setState(() {
                        isLoading = false;
                      });
                      if (result.status == Status.COMPLETED) {
                        ShowMessage.notify(context, "${result.responseData['message']}");
                        Navigator.pop(context);
                      } else {
                        ShowMessage.notify(context, "${result.message}");
                      }
                    },
                    isLoading: isLoading,
                    width: size.width * 0.4,
                    fontSize: size.width * 0.045,
                    text: "Done",
                    height: size.height * 0.065,
                    buttonColor: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget fieldWidget(
      String fieldName, TextEditingController controller, bool readOnly,void Function()? onTap,{TextInputType? keyboardType, bool prefix = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$fieldName",
          style: const TextStyle(
              color: AppColors.primaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 05,
        ),
        Container(
          height: 45,
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            onTap: onTap,
            decoration: InputDecoration(
              filled: true, // Enable the fill color
              fillColor: AppColors.secondaryColor
                  .withOpacity(0.3), // Set the fill color
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(50.0), // Set the border radius
                borderSide: BorderSide.none, // Remove the default border
              ),
              contentPadding: const EdgeInsets.only(
                  left: 15.0,right: 15), // Padding inside the text field
              prefix: prefix ? GestureDetector(
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
                      code =
                      "${scountry.flagEmoji} + ${scountry.phoneCode}";
                      setState(() {});
                      print('Select country: ${scountry.flagEmoji}');
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.only(right: 03),
                  margin: EdgeInsets.only(right: 03),
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: AppColors.darkBlue,width: 1))
                  ),
                  child: AppText(
                    text: code == "" ? "🇸🇦 +966" : code,
                    textcolor: Colors.black,
                    fontSize: Get.width * 0.035,
                  ),
                ),
              ) : null,
            ),
          ),
        ),
      ],
    );
  }


  Widget genderDropdownWidget(
      String fieldName,
      String selectedValue,
      void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fieldName,
          style: const TextStyle(
              color: AppColors.primaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            items: ["Male", "Female","Other"].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none, // Remove the dropdown border
            ),
            dropdownColor: AppColors.secondaryColor, // Optional dropdown color
          ),
        ),
      ],
    );
  }

}
