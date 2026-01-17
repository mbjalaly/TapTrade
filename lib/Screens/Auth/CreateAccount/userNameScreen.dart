import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      return 'Please enter a username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
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
        setState(() => usernameError = 'Error checking username. Please try again.');
        return;
      }

      if (result['success'] == true) {
        bool exists = result['exists'] ?? false;

        if (!exists) {
          requestModel.username = nameCon.text.trim();
          Get.to(() => PasswordScreen(requestModel: requestModel));
        } else {
          setState(() => usernameError = 'This username is already taken');
        }
      } else {
        setState(() => usernameError = result['message'] ?? 'Error checking username');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        usernameError = 'Error checking username. Please try again.';
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
            'Create your username',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlue,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'This is how you\'ll appear in TapTrade. Choose wisely – you can\'t change it later!',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.darkBlue.withOpacity(0.6),
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
                  label: 'Username',
                  hint: 'Enter your username',
                  autofocus: true,
                  errorText: usernameError,
                  onChanged: (_) => _clearError(),
                  helperText: 'Letters, numbers, and underscores only',
                ),

                const SizedBox(height: 32),

                AuthPrimaryButton(
                  text: 'Continue',
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
