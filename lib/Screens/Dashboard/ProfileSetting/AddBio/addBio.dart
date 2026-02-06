import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:taptrade/Models/UserProfile/userProfile.dart';
import 'package:taptrade/Screens/Dashboard/ProfileSetting/verifyProfilePhone.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/deviceResolutionType.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';

// Phone number formatter for 9 digits: XX XXX XXXX
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limit to 9 digits
    final limitedDigits = digitsOnly.substring(0, digitsOnly.length > 9 ? 9 : digitsOnly.length);

    // Format as XX XXX XXXX
    String formatted = '';
    for (int i = 0; i < limitedDigits.length; i++) {
      if (i == 2 || i == 5) {
        formatted += ' ';
      }
      formatted += limitedDigits[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class AddBioScreen extends StatefulWidget {
  AddBioScreen({Key? key, required this.profileData}) : super(key: key);
  UserProfileResponseModel profileData;
  @override
  State<AddBioScreen> createState() => _AddBioScreenState();
}

class _AddBioScreenState extends State<AddBioScreen> {
  var userController = Get.find<UserController>();
  TextEditingController name = TextEditingController();
  TextEditingController userName = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController email = TextEditingController();
  bool isLoading = false;
  String? phoneError;

  // Default to Saudi Arabia
  Country selectedCountry = Country(
    phoneCode: "966",
    countryCode: "SA",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Saudi Arabia",
    example: "55 555 5555",
    displayName: "Saudi Arabia (SA) [+966]",
    displayNameNoCountryCode: "Saudi Arabia (SA)",
    e164Key: "",
  );

  @override
  void initState() {
    super.initState();
    name.text = widget.profileData.data?.fullName ?? '';
    userName.text = widget.profileData.data?.username ?? '';
    gender.text = (widget.profileData.data?.gender ?? '').isEmpty ? 'Male' : widget.profileData.data?.gender ?? '';
    email.text = widget.profileData.data?.email ?? '';

    // Parse contact number - handle both old format (full number) and new format (separate fields)
    String savedCountryCode = widget.profileData.data?.countryCode ?? '';
    String fullContact = widget.profileData.data?.contact ?? '';

    // If we have a separate country code saved, use it
    if (savedCountryCode.isNotEmpty) {
      // New format: country_code and contact are separate
      // Try to find matching country from the saved country code
      // For now, default to Saudi Arabia, user can change it
      selectedCountry = Country(
        phoneCode: savedCountryCode,
        countryCode: savedCountryCode == "966" ? "SA" : "US", // Default mapping
        e164Sc: 0,
        geographic: true,
        level: 1,
        name: savedCountryCode == "966" ? "Saudi Arabia" : (AppLocalizations.of(context)?.unknown ?? "Unknown"),
        example: "55 555 5555",
        displayName: "Country (+$savedCountryCode)",
        displayNameNoCountryCode: "Country",
        e164Key: "",
      );

      // Format contact digits as XX XXX XXXX
      String digitsOnly = fullContact.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.isNotEmpty) {
        String formatted = '';
        for (int i = 0; i < digitsOnly.length && i < 9; i++) {
          if (i == 2 || i == 5) {
            formatted += ' ';
          }
          formatted += digitsOnly[i];
        }
        contact.text = formatted;
      }
    } else if (fullContact.startsWith('+')) {
      // Old format: full phone number with country code in contact field
      // Extract country code and digits
      String digitsOnly = fullContact.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.length >= 9) {
        String phoneDigits = digitsOnly.substring(digitsOnly.length - 9);
        String extractedCountryCode = digitsOnly.substring(0, digitsOnly.length - 9);

        // Update selected country if we extracted a code
        if (extractedCountryCode.isNotEmpty) {
          selectedCountry = Country(
            phoneCode: extractedCountryCode,
            countryCode: extractedCountryCode == "966" ? "SA" : "US",
            e164Sc: 0,
            geographic: true,
            level: 1,
            name: extractedCountryCode == "966" ? "Saudi Arabia" : (AppLocalizations.of(context)?.unknown ?? "Unknown"),
            example: "55 555 5555",
            displayName: "Country (+$extractedCountryCode)",
            displayNameNoCountryCode: "Country",
            e164Key: "",
          );
        }

        // Format as XX XXX XXXX
        String formatted = '';
        for (int i = 0; i < phoneDigits.length; i++) {
          if (i == 2 || i == 5) {
            formatted += ' ';
          }
          formatted += phoneDigits[i];
        }
        contact.text = formatted;
      }
    } else {
      // Fallback: display as-is
      contact.text = fullContact;
    }
  }

  @override
  void dispose() {
    super.dispose();
    name.dispose();
    userName.dispose();
    gender.dispose();
    contact.dispose();
    email.dispose();
  }

  /// Navigate to phone verification screen
  void _navigateToVerifyPhone() async {
    // Validate phone number before sending OTP
    if (contact.text.trim().isEmpty) {
      ShowMessage.notify(context, AppLocalizations.of(context)?.pleaseEnterPhoneFirst ?? 'Please enter your phone number first');
      return;
    }

    if (contact.text.replaceAll(RegExp(r'\D'), '').length != 9) {
      ShowMessage.notify(context, AppLocalizations.of(context)?.phoneMust9Digits ?? 'Phone number must be exactly 9 digits');
      return;
    }

    // Build full phone number
    String phoneDigits = contact.text.replaceAll(RegExp(r'\D'), '');
    String fullPhoneNumber = '+${selectedCountry.phoneCode}$phoneDigits';

    // Navigate to verification screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyProfilePhoneScreen(
          phoneNumber: fullPhoneNumber,
        ),
      ),
    );

    // If verification was successful, refresh the profile data
    if (result == true) {
      // Refresh profile to show updated verification status
      await ProfileService.instance.getProfile(context);

      // Update local widget state with fresh data
      setState(() {
        widget.profileData = userController.userProfile.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isTab = DeviceTypeHelper.isTablet(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: false,
          title: Text(AppLocalizations.of(context)?.profileInformation ?? 'Profile information', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0,top: 20,bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      "assets/images/t.png",
                      height: 30,
                      width: 30,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  Container(
                    width: size.width,
                    height: isTab ? size.height * 0.7 : size.height * 0.68,
                    color: Colors.transparent,
                  ),
                  Center(
                    child: Material(
                      elevation: 0,
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.contentBg(context),
                      child: Container(
                        width: size.width * 0.9,
                        height: isTab ? size.height * 0.67 : size.height * 0.65,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.surfaceColor(context),
                          border: Border.all(color: AppColors.outlineColor(context)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            fieldWidget(AppLocalizations.of(context)?.nameLabel ?? "NAME:", name, false,null),
                            const SizedBox(
                              height: 10,
                            ),
                            fieldWidget(AppLocalizations.of(context)?.userNameLabel ?? "USER NAME:", userName, false,null),
                            const SizedBox(
                              height: 10,
                            ),
                            genderDropdownWidget(AppLocalizations.of(context)?.genderLabel ?? "GENDER:", gender.text.capitalize ?? '', (value){
                              gender.text = value ?? '';
                              setState(() {

                              });
                            }),
                            const SizedBox(
                              height: 10,
                            ),
                            phoneFieldWidget(AppLocalizations.of(context)?.contactLabel ?? "CONTACT#:", contact),
                            // Phone verification status
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: (widget.profileData.data?.phoneVerified ?? false) 
                                  ? null 
                                  : _navigateToVerifyPhone,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: (widget.profileData.data?.phoneVerified ?? false)
                                      ? Colors.green.withOpacity(0.1)
                                      : AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: (widget.profileData.data?.phoneVerified ?? false)
                                        ? Colors.green
                                        : AppColors.primaryColor,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      (widget.profileData.data?.phoneVerified ?? false)
                                          ? Icons.verified
                                          : Icons.verified_user,
                                      color: (widget.profileData.data?.phoneVerified ?? false)
                                          ? Colors.green
                                          : AppColors.primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      (widget.profileData.data?.phoneVerified ?? false)
                                          ? AppLocalizations.of(context)?.alreadyVerified ?? 'Already Verified'
                                          : AppLocalizations.of(context)?.needVerification ?? 'Need Verification',
                                      style: TextStyle(
                                        color: (widget.profileData.data?.phoneVerified ?? false)
                                            ? Colors.green
                                            : AppColors.primaryColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            fieldWidget(AppLocalizations.of(context)?.emailLabel ?? "EMAIL:", email, false, null),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: size.width / 5.0,
                    right: size.width / 5.0,
                    child: AppButton(
                      onPressed: () async {
                        String? message;
                        if (name.text.trim().isEmpty) {
                          message = AppLocalizations.of(context)?.pleaseAddName ?? "Please add Name";
                        } else if (userName.text.trim().isEmpty) {
                          message = AppLocalizations.of(context)?.pleaseAddUsername ?? "Please add userName";
                        } else if (gender.text.trim().isEmpty) {
                          message = AppLocalizations.of(context)?.pleaseSelectGender ?? "Please select gender";
                        } else if (contact.text.trim().isEmpty) {
                          message = AppLocalizations.of(context)?.pleaseAddContact ?? "Please add contact number";
                        } else if (contact.text.replaceAll(RegExp(r'\D'), '').length != 9) {
                          message = AppLocalizations.of(context)?.phoneMust9Digits ?? "Phone number must be exactly 9 digits";
                        } else if (email.text.trim().isEmpty) {
                          message = AppLocalizations.of(context)?.pleaseAddEmail ?? "Please add email";
                        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.text.trim())) {
                          message = AppLocalizations.of(context)?.pleaseEnterValidEmail ?? "Please enter a valid email address";
                        } else {}

                        if (message != null) {
                          ShowMessage.notify(context, message);
                          return;
                        }
                        // Send full phone number format - backend will parse and split it
                        String phoneDigits = contact.text.replaceAll(RegExp(r'\D'), '');
                        String fullPhoneNumber = '+${selectedCountry.phoneCode}$phoneDigits';

                        Map<String, dynamic> body = {
                          'username': userName.text,
                          'gender': gender.text.trim().toLowerCase(),
                          'full_name': name.text.trim(),
                          'contact': fullPhoneNumber, // Full format like +966555555555 - backend will parse it
                          'email': email.text.trim(), // Include email for update
                        };
                        String id = userController.userProfile.value.data?.id ??
                                '';
                        setState(() {
                          isLoading = true;
                          phoneError = null; // Clear previous errors
                        });
                        final result = await ProfileService.instance
                            .updateProfile(context, body, id);

                        setState(() {
                          isLoading = false;
                        });

                        if (result.status == Status.COMPLETED) {
                          // Refresh profile to get updated data
                          await ProfileService.instance.getProfile(context);
                          ShowMessage.notify(context, "${result.responseData['message']}");
                          Navigator.pop(context);
                        }
                        // Error is already shown by ProfileService.updateProfile in a dialog
                      },
                      isLoading: isLoading,
                      width: size.width * 0.5,
                      fontSize: size.width * 0.045,
                      text: AppLocalizations.of(context)?.done ?? "Done",
                      height: size.height * 0.058,
                      buttonColor: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget fieldWidget(
      String fieldName, TextEditingController controller, bool readOnly,void Function()? onTap,{TextInputType? keyboardType}) {
    bool isTab = DeviceTypeHelper.isTablet(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fieldName,
          style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: isTab ? 14 : 16,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 05,
        ),
        Container(
          height: isTab ? 44 : 50,
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            enableInteractiveSelection: !readOnly,
            keyboardType: keyboardType,
            onTap: onTap,
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly ? AppColors.fieldBg(context).withOpacity(0.5) : AppColors.fieldBg(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColors.outlineColor(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColors.outlineColor(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.4),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
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
    bool isTab = DeviceTypeHelper.isTablet(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fieldName,
          style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: isTab ? 14 : 16,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 5,
        ),
        DropdownButtonFormField<String>(
          value: selectedValue,
          items: [
            DropdownMenuItem<String>(value: "Male", child: Text(AppLocalizations.of(context)?.male ?? "Male")),
            DropdownMenuItem<String>(value: "Female", child: Text(AppLocalizations.of(context)?.female ?? "Female")),
            DropdownMenuItem<String>(value: "Other", child: Text(AppLocalizations.of(context)?.other ?? "Other")),
          ],
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.fieldBg(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: AppColors.outlineColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: AppColors.outlineColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.4),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          dropdownColor: AppColors.contentBg(context),
        ),
      ],
    );
  }

  Widget phoneFieldWidget(String fieldName, TextEditingController controller) {
    bool isTab = DeviceTypeHelper.isTablet(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fieldName,
          style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: isTab ? 14 : 16,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Container(
          height: isTab ? 44 : 50,
          decoration: BoxDecoration(
            color: AppColors.fieldBg(context),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: AppColors.outlineColor(context)),
          ),
          child: Row(
            children: [
              // Country code prefix
              InkWell(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: true,
                    countryListTheme: CountryListThemeData(
                      borderRadius: BorderRadius.circular(16),
                      backgroundColor: AppColors.contentBg(context),
                      textStyle: TextStyle(color: AppColors.darkBlue),
                      searchTextStyle: TextStyle(color: AppColors.darkBlue),
                      inputDecoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.search ?? 'Search',
                        hintText: AppLocalizations.of(context)?.searchCountry ?? 'Search country',
                        prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.3)),
                        ),
                      ),
                    ),
                    onSelect: (Country country) {
                      setState(() {
                        selectedCountry = country;
                      });
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Text(
                        '+${selectedCountry.phoneCode}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
                    ],
                  ),
                ),
              ),
              // Vertical divider
              Container(
                width: 1,
                height: 24,
                color: AppColors.outlineColor(context),
              ),
              // Phone number input
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    PhoneNumberFormatter(),
                  ],
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.darkBlue,
                  ),
                  decoration: InputDecoration(
                    hintText: selectedCountry.example,
                    hintStyle: TextStyle(
                      color: AppColors.darkBlue.withOpacity(0.5),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}
