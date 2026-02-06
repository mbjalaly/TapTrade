import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Screens/Auth/CreateAccount/createPhoneNumber.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/Auth/auth_scaffold.dart';

class CreateEmailScreen extends StatefulWidget {
  final SignUpRequestModel requestModel;

  const CreateEmailScreen({Key? key, required this.requestModel}) : super(key: key);

  @override
  State<CreateEmailScreen> createState() => _CreateEmailScreenState();
}

class _CreateEmailScreenState extends State<CreateEmailScreen> {
  final TextEditingController emailCon = TextEditingController();
  bool isLoading = false;
  String? emailError;

  @override
  void dispose() {
    emailCon.dispose();
    super.dispose();
  }

  void _clearError() {
    if (emailError != null) {
      setState(() => emailError = null);
    }
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Please enter your email';
    }
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    if (!RegExp(pattern).hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> _handleContinue() async {
    final validation = _validateEmail(emailCon.text.trim());
    if (validation != null) {
      setState(() => emailError = validation);
      return;
    }

    setState(() {
      isLoading = true;
      emailError = null;
    });

    // Check if email already exists
    String checkEmail = "email=${emailCon.text.trim()}";
    final result = await AuthService.instance.checkUserNameAndEmail(context, checkEmail);

    setState(() => isLoading = false);

    if (result == null) {
      setState(() => emailError = 'Error checking email. Please try again.');
      return;
    }

    if (result['success'] == true) {
      bool exists = result['exists'] ?? false;

      if (!exists) {
        // Email is available, save it and continue to phone number
        widget.requestModel.email = emailCon.text.trim();
        Get.to(() => CreatePhoneNumberScreen(requestModel: widget.requestModel));
      } else {
        setState(() => emailError = 'This email is already registered');
      }
    } else {
      setState(() => emailError = result['message'] ?? 'Error checking email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      showProgress: true,
      currentStep: 4,
      totalSteps: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          // Title
          Text(
            'Enter your email',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText(context),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'We\'ll use this to keep you updated about your trades.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondaryText(context),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 40),

          // Email input card
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthTextField(
                  controller: emailCon,
                  label: 'Email Address',
                  hint: 'example@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  errorText: emailError,
                  onChanged: (_) => _clearError(),
                ),

                const SizedBox(height: 32),

                AuthPrimaryButton(
                  text: 'Continue',
                  isLoading: isLoading,
                  onPressed: _handleContinue,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Info note
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'No verification needed. We just need your email to contact you about your trades.',
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
