import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Screens/UserDetail/AddInterest/addInterest.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/Auth/auth_scaffold.dart';
import 'package:taptrade/l10n/app_localizations.dart';

/// Screen for entering phone number after email verification
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
  final TextEditingController phoneCon = TextEditingController();
  String countryCode = "+966";
  String countryFlag = "🇸🇦";
  bool isLoading = false;

  String get fullPhoneNumber => '$countryCode${phoneCon.text.trim()}';

  @override
  void dispose() {
    phoneCon.dispose();
    super.dispose();
  }

  Future<void> _completeRegistration() async {
    if (phoneCon.text.trim().isEmpty) {
      ShowMessage.notify(context, "Please enter your phone number");
      return;
    }

    if (phoneCon.text.trim().length < 8) {
      ShowMessage.notify(context, "Please enter a valid phone number");
      return;
    }

    setState(() => isLoading = true);

    try {
      widget.requestModel.contact = fullPhoneNumber;

      final requestData = widget.requestModel.toJson();
      requestData['phone_verified'] = false;
      requestData['email_verified'] = true;

      final result = await AuthService.instance.signUp(context, requestData);

      setState(() => isLoading = false);

      if (result.status == Status.COMPLETED &&
          (result.responseData['success'] ?? false)) {
        String? token = result.responseData['token'] ??
            result.responseData['access_token'] ??
            result.responseData['data']?['token'] ??
            result.responseData['data']?['access_token'];

        if (token != null && token.isNotEmpty) {
          await SharedPreferencesService().setString(
            KeyConstants.accessToken,
            token,
          );
        }

        String? userId = result.responseData['data']?['id']?.toString() ??
            result.responseData['user_profile']?['id']?.toString() ??
            result.responseData['user']?['id']?.toString() ??
            result.responseData['id']?.toString();

        if (userId != null && userId.isNotEmpty) {
          await SharedPreferencesService().setString(
            KeyConstants.userId,
            userId,
          );
        }

        ShowMessage.notify(
          context,
          result.responseData['message'] ?? 'Account created successfully!',
        );

        ProfileService.instance.getProfile(context);
        Get.offAll(() => const AddInterestScreen());
      } else {
        String message =
            result.responseData['message'] ?? 'Registration failed.';
        ShowMessage.inDialog(context, message, true);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('[Auth] Registration error: $e');
      ShowMessage.inDialog(context, 'Registration failed. Please try again.', true);
    }
  }

  void _selectCountry() {
    final l10n = AppLocalizations.of(context)!;
    showCountryPicker(
      exclude: <String>['IL'],
      context: context,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: AppColors.backgroundColor(context),
        bottomSheetHeight: 500,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        inputDecoration: InputDecoration(
          labelText: l10n.search,
          hintText: l10n.startTypingToSearch,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: AppColors.fieldBg(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          countryCode = '+${country.phoneCode}';
          countryFlag = country.flagEmoji;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AuthScaffold(
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          // Title
          Text(
            l10n.almostThere,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText(context),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            l10n.addYourPhoneNumber,
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
                Text(
                  l10n.phoneNumber,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                // Phone input row
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.fieldBg(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      // Country picker
                      GestureDetector(
                        onTap: _selectCountry,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: AppColors.outlineColor(context),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                countryFlag,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                countryCode,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryText(context),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 20,
                                color: AppColors.secondaryText(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Phone number input
                      Expanded(
                        child: TextFormField(
                          controller: phoneCon,
                          keyboardType: TextInputType.phone,
                          cursorColor: AppColors.primaryColor,
                          style: TextStyle(
                            color: AppColors.primaryText(context),
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: '5XXXXXXXX',
                            hintStyle: TextStyle(
                              color: AppColors.hintText(context),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                AuthPrimaryButton(
                  text: l10n.createAccount,
                  isLoading: isLoading,
                  onPressed: _completeRegistration,
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
