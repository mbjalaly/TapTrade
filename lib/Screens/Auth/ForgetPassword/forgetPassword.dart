import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:taptrade/Screens/Auth/ForgetPassword/verifyResetOtp.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
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

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController phoneController = TextEditingController();
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
    phoneController.dispose();
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
    final digitsOnly = phoneController.text.replaceAll(RegExp(r'\D'), '');
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

  Future<void> _handleSendOtp() async {
    final validation = _validatePhone(phoneController.text.trim());
    if (validation != null) {
      setState(() => phoneError = validation);
      return;
    }

    setState(() {
      isLoading = true;
      phoneError = null;
    });

    final fullPhoneNumber = _getFullPhoneNumber();
    printLog('[ForgetPassword] Attempting to send OTP to: $fullPhoneNumber');

    try {
      final result = await AuthService.instance.sendPasswordResetOtp(
        context,
        fullPhoneNumber,
      );

      setState(() => isLoading = false);

      if (result.status == Status.COMPLETED && result.responseData['success'] == true) {
        final verificationId = result.responseData['verification_id'];
        printLog('[ForgetPassword] OTP sent successfully, verification_id: $verificationId');

        // Navigate to OTP verification screen
        final resetToken = await Get.to(
          () => VerifyResetOtpScreen(
            phoneNumber: fullPhoneNumber,
            verificationId: verificationId,
          ),
          transition: Transition.rightToLeft,
        );

        // If OTP verified successfully and we got a reset token, the VerifyResetOtpScreen
        // will handle navigation to ResetPasswordScreen. If we return here with success,
        // go back to login.
        if (resetToken == true) {
          // Password was reset successfully
          Get.back(); // Return to login screen
          ShowMessage.notify(context, 'Password reset successfully!');
        }
      } else {
        setState(() {
          phoneError = result.responseData['message'] ?? 'Failed to send verification code';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        phoneError = 'An error occurred. Please try again.';
      });
      printLog('[ForgetPassword] Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AuthScaffold(
      showBackButton: true,
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Lock icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_reset_rounded,
              size: 50,
              color: AppColors.primaryColor,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            l10n.forgotPassword,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText(context),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            l10n.enterPhoneResetPassword,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondaryText(context),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Phone input card
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phone number label
                Text(
                  l10n.phoneNumber,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 12),

                // Country picker and phone input
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Country selector
                    GestureDetector(
                      onTap: _showCountryPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.fieldBg(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: phoneError != null
                                ? AppColors.errorColor
                                : AppColors.outlineColor(context),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedCountry.flagEmoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+${selectedCountry.phoneCode}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryText(context),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.primaryText(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Phone number input
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        autofocus: true,
                        inputFormatters: [PhoneNumberFormatter()],
                        onChanged: (_) => _clearError(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText(context),
                        ),
                        decoration: InputDecoration(
                          hintText: selectedCountry.example,
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: AppColors.hintText(context),
                          ),
                          filled: true,
                          fillColor: AppColors.fieldBg(context),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: phoneError != null
                                  ? AppColors.errorColor
                                  : AppColors.outlineColor(context),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: phoneError != null
                                  ? AppColors.errorColor
                                  : AppColors.outlineColor(context),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: phoneError != null
                                  ? AppColors.errorColor
                                  : AppColors.primaryColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.errorColor,
                              width: 1,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.errorColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Error message
                if (phoneError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    phoneError!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.errorColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                AuthPrimaryButton(
                  text: l10n.sendVerificationCode,
                  isLoading: isLoading,
                  onPressed: _handleSendOtp,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Back to login
          GestureDetector(
            onTap: () => Get.back(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: AppColors.secondaryText(context),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.backToSignIn,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText(context),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
