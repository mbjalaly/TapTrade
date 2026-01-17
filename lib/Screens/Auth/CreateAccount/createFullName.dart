import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Models/SignUpRequestModel/signUpRequestModel.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/Auth/auth_scaffold.dart';

import 'createEmail.dart';

class FullNameScreen extends StatefulWidget {
  final SignUpRequestModel requestModel;

  const FullNameScreen({Key? key, required this.requestModel}) : super(key: key);

  @override
  State<FullNameScreen> createState() => _FullNameScreenState();
}

class _FullNameScreenState extends State<FullNameScreen> {
  final TextEditingController fullNameCon = TextEditingController();
  String? nameError;

  @override
  void dispose() {
    fullNameCon.dispose();
    super.dispose();
  }

  void _clearError() {
    if (nameError != null) {
      setState(() => nameError = null);
    }
  }

  String? _validateName(String value) {
    if (value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Name is too long';
    }
    return null;
  }

  void _handleContinue() {
    final validation = _validateName(fullNameCon.text.trim());
    if (validation != null) {
      setState(() => nameError = validation);
      return;
    }

    widget.requestModel.firstName = fullNameCon.text.trim();
    widget.requestModel.lastName = fullNameCon.text.trim();
    widget.requestModel.fullName = fullNameCon.text.trim();
    Get.to(() => CreateEmailScreen(requestModel: widget.requestModel));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      showProgress: true,
      currentStep: 3,
      totalSteps: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          // Title
          Text(
            'What\'s your name?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlue,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Let others know who they\'re trading with.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.darkBlue.withOpacity(0.6),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 40),

          // Full name input card
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthTextField(
                  controller: fullNameCon,
                  label: 'Full Name',
                  hint: 'Enter your first and last name',
                  autofocus: true,
                  errorText: nameError,
                  onChanged: (_) => _clearError(),
                ),

                const SizedBox(height: 32),

                AuthPrimaryButton(
                  text: 'Continue',
                  onPressed: _handleContinue,
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
