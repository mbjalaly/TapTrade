import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Screens/Auth/CreateAccount/verifyPhoneOtp.dart';
import 'package:taptrade/Services/IntegrationServices/unoSendSmsService.dart';
import 'package:taptrade/Services/logService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/Auth/auth_scaffold.dart';
import 'package:taptrade/l10n/app_localizations.dart';

// Phone number formatter for Saudi Arabia (9 digits: XX XXX XXXX)
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

class CreatePhoneNumberScreen extends StatefulWidget {
  final SignUpRequestModel requestModel;

  const CreatePhoneNumberScreen({Key? key, required this.requestModel}) : super(key: key);

  @override
  State<CreatePhoneNumberScreen> createState() => _CreatePhoneNumberScreenState();
}

class _CreatePhoneNumberScreenState extends State<CreatePhoneNumberScreen> {
  final TextEditingController phoneCon = TextEditingController();
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
  void dispose() {
    phoneCon.dispose();
    super.dispose();
  }

  void _clearError() {
    if (phoneError != null) {
      setState(() => phoneError = null);
    }
  }

  String? _validatePhone(String value) {
    // Remove spaces to get digit count
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.isEmpty) {
      return 'Please enter your phone number';
    }

    // Must be exactly 9 digits
    if (digitsOnly.length != 9) {
      return 'Phone number must be exactly 9 digits';
    }

    return null;
  }

  String _getFullPhoneNumber() {
    // Remove all spaces before creating full phone number
    final digitsOnly = phoneCon.text.replaceAll(RegExp(r'\D'), '');
    return '+${selectedCountry.phoneCode}$digitsOnly';
  }

  void _showCountryPicker() {
    final l10n = AppLocalizations.of(context)!;
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.circular(16),
        backgroundColor: AppColors.backgroundColor(context),
        textStyle: TextStyle(color: AppColors.primaryText(context)),
        searchTextStyle: TextStyle(color: AppColors.primaryText(context)),
        inputDecoration: InputDecoration(
          labelText: l10n.search,
          hintText: l10n.searchCountry,
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
          _clearError();
        });
      },
    );
  }

  Future<void> _sendPhoneOtp() async {
    final validation = _validatePhone(phoneCon.text.trim());
    if (validation != null) {
      setState(() => phoneError = validation);
      return;
    }

    setState(() {
      isLoading = true;
      phoneError = null;
    });

    final fullPhoneNumber = _getFullPhoneNumber();
    printLog('[CreatePhoneNumber] Attempting to send OTP to: $fullPhoneNumber');

    // Try UnoSend first
    final unoResult = await UnoSendSmsService.instance.sendOtp(
      phoneNumber: fullPhoneNumber,
      context: context,
    );

    if (unoResult['success'] == true) {
      // UnoSend succeeded
      setState(() => isLoading = false);

      ShowMessage.notify(context, 'Verification code sent to $fullPhoneNumber');

      // Navigate to OTP verification screen
      Get.to(() => VerifyPhoneOtpScreen(
            requestModel: widget.requestModel,
            phoneNumber: fullPhoneNumber,
            verificationId: unoResult['verification_id'],
          ));
    } else {
      // Error (validation error, rate limiting, service unavailable, etc.)
      setState(() {
        isLoading = false;
        phoneError = unoResult['message'] ?? 'Failed to send OTP. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AuthScaffold(
      showBackButton: true,
      showProgress: true,
      currentStep: 5,
      totalSteps: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          // Title
          Text(
            l10n.verifyYourPhone,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText(context),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            l10n.sendVerificationCodeMessage,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondaryText(context),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 40),

          // Phone input card
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Country picker button
                Text(
                  l10n.country,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _showCountryPicker,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.contentBg(context),
                    ),
                    child: Row(
                      children: [
                        Text(
                          selectedCountry.flagEmoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedCountry.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryText(context),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '+${selectedCountry.phoneCode}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.secondaryText(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primaryColor,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Phone number input with country code prefix
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.phoneNumber,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: phoneError != null
                            ? AppColors.errorColor.withOpacity(0.05)
                            : AppColors.fieldBg(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: phoneError != null
                              ? AppColors.errorColor
                              : AppColors.outlineColor(context),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Country code prefix
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 8),
                            child: Text(
                              '+${selectedCountry.phoneCode}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryText(context),
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
                              controller: phoneCon,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                PhoneNumberFormatter(),
                              ],
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.primaryText(context),
                              ),
                              decoration: InputDecoration(
                                hintText: selectedCountry.example,
                                hintStyle: TextStyle(
                                  color: AppColors.hintText(context),
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              onChanged: (_) => _clearError(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (phoneError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        phoneError!,
                        style: const TextStyle(
                          color: AppColors.errorColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 32),

                AuthPrimaryButton(
                  text: l10n.sendCode,
                  isLoading: isLoading,
                  onPressed: _sendPhoneOtp,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Privacy note
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              l10n.smsAgreement,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText(context),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
