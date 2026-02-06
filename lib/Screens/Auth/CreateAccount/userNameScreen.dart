import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Screens/Auth/CreateAccount/createPasswordScreen.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/Auth/auth_scaffold.dart';

class UserNameScreen extends StatefulWidget {
  const UserNameScreen({super.key});

  @override
  State<UserNameScreen> createState() => _UserNameScreenState();
}

class _UserNameScreenState extends State<UserNameScreen> {
  final TextEditingController nameCon = TextEditingController();
  final SignUpRequestModel requestModel = SignUpRequestModel();
  bool isLoading = false;
  String? usernameError;

  @override
  void dispose() {
    nameCon.dispose();
    super.dispose();
  }

  void _clearError() {
    if (usernameError != null) {
      setState(() => usernameError = null);
    }
  }

  String? _validateUsername(String value) {
    if (value.isEmpty) {
      return AppLocalizations.of(context)?.pleaseEnterUsername ?? 'Please enter a username';
    }
    if (value.length < 3) {
      return AppLocalizations.of(context)?.usernameMinLength ?? 'Username must be at least 3 characters';
    }
    if (value.length > 20) {
      return AppLocalizations.of(context)?.usernameMaxLength ?? 'Username must be less than 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return AppLocalizations.of(context)?.usernameInvalidChars ?? 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  Future<void> _checkUsernameAndProceed() async {
    final validation = _validateUsername(nameCon.text.trim());
    if (validation != null) {
      setState(() => usernameError = validation);
      return;
    }

    setState(() {
      isLoading = true;
      usernameError = null;
    });

    try {
      String checkUserName = "username=${nameCon.text.trim()}";
      final result = await AuthService.instance
          .checkUserNameAndEmail(context, checkUserName);

      setState(() => isLoading = false);

      if (result == null) {
        setState(() => usernameError = AppLocalizations.of(context)?.errorCheckingUsername ?? 'Error checking username. Please try again.');
        return;
      }

      if (result['success'] == true) {
        bool exists = result['exists'] ?? false;

        if (!exists) {
          requestModel.username = nameCon.text.trim();
          Get.to(() => PasswordScreen(requestModel: requestModel));
        } else {
          setState(() => usernameError = AppLocalizations.of(context)?.usernameAlreadyTaken ?? 'This username is already taken');
        }
      } else {
        setState(() => usernameError = result['message'] ?? AppLocalizations.of(context)?.errorCheckingUsername ?? 'Error checking username');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        usernameError = AppLocalizations.of(context)?.errorCheckingUsername ?? 'Error checking username. Please try again.';
      });
      debugPrint('Error checking username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      showProgress: true,
      currentStep: 1,
      totalSteps: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          // Title
          Text(
            AppLocalizations.of(context)?.createYourUsername ?? 'Create your username',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText(context),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            AppLocalizations.of(context)?.usernameAppearance ?? "This is how you'll appear in TapTrade. Choose wisely – you can't change it later!",
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondaryText(context),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 40),

          // Username input card
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthTextField(
                  controller: nameCon,
                  label: AppLocalizations.of(context)?.username ?? 'Username',
                  hint: AppLocalizations.of(context)?.enterUsername ?? 'Enter your username',
                  autofocus: true,
                  errorText: usernameError,
                  onChanged: (_) => _clearError(),
                  helperText: AppLocalizations.of(context)?.usernameHelper ?? 'Letters, numbers, and underscores only',
                ),

                const SizedBox(height: 32),

                AuthPrimaryButton(
                  text: AppLocalizations.of(context)?.continue_ ?? 'Continue',
                  isLoading: isLoading,
                  onPressed: _checkUsernameAndProceed,
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
