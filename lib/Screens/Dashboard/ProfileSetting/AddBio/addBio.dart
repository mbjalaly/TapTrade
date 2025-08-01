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

class _AddBioScreenState extends State<AddBioScreen> with TickerProviderStateMixin {
  var userController = Get.find<UserController>();
  String code = "";
  TextEditingController name = TextEditingController();
  TextEditingController userName = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController dob = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController email = TextEditingController();
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();

    name.text = widget.profileData.data?.fullName ?? '';
    userName.text = widget.profileData.data?.username ?? '';
    gender.text = (widget.profileData.data?.gender ?? '').isEmpty ? 'Male' : widget.profileData.data?.gender ?? '';
    dob.text = widget.profileData.data?.dob ?? '';
    contact.text = widget.profileData.data?.contact ?? '';
    email.text = widget.profileData.data?.email ?? '';
  }

  @override
  void dispose() {
    name.dispose();
    userName.dispose();
    gender.dispose();
    dob.dispose();
    contact.dispose();
    email.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.secondaryColor.withOpacity(0.05),
            AppColors.darkBlue.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_outline,
            size: 60,
            color: AppColors.primaryColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Trader Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Update your personal information to help other traders know you better.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isRequired = false,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.darkBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              readOnly: readOnly,
              onTap: onTap,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: readOnly ? const Icon(Icons.arrow_drop_down) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              'Personal Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
          ),
          _buildFormField(
            label: "Full Name",
            hint: "Enter your full name",
            controller: name,
            icon: Icons.person,
            isRequired: true,
          ),
          _buildFormField(
            label: "Username",
            hint: "Choose a unique username",
            controller: userName,
            icon: Icons.alternate_email,
            isRequired: true,
          ),
          _buildFormField(
            label: "Gender",
            hint: "Select your gender",
            controller: gender,
            icon: Icons.person_outline,
            readOnly: true,
            onTap: () => _showGenderDialog(),
          ),
          _buildFormField(
            label: "Date of Birth",
            hint: "Select your date of birth",
            controller: dob,
            icon: Icons.calendar_today,
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
          _buildFormField(
            label: "Contact Number",
            hint: "Enter your phone number",
            controller: contact,
            icon: Icons.phone,
            isRequired: true,
          ),
          _buildFormField(
            label: "Email Address",
            hint: "Enter your email address",
            controller: email,
            icon: Icons.email,
            isRequired: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      margin: const EdgeInsets.all(20),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.secondaryColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : _saveProfile,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.save,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _showGenderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Select Gender',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGenderOption('Male'),
              _buildGenderOption('Female'),
              _buildGenderOption('Other'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenderOption(String genderOption) {
    return ListTile(
      leading: Radio<String>(
        value: genderOption,
        groupValue: gender.text,
        onChanged: (value) {
          setState(() {
            gender.text = value!;
          });
          Navigator.of(context).pop();
        },
        activeColor: AppColors.primaryColor,
      ),
      title: Text(genderOption),
      onTap: () {
        setState(() {
          gender.text = genderOption;
        });
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.darkBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        dob.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (name.text.isEmpty || userName.text.isEmpty || contact.text.isEmpty || email.text.isEmpty) {
      ShowMessage.notify(context, "Please fill in all required fields");
      return;
    }

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> body = {
      'full_name': name.text,
      'username': userName.text,
      'gender': gender.text,
      'dob': dob.text,
      'contact': contact.text,
      'email': email.text,
    };

    String id = userController.userProfile.value.data?.id ?? '';
    final result = await ProfileService.instance.updateProfile(context, body, id);

    setState(() {
      isLoading = false;
    });

    if (result.status == Status.COMPLETED) {
      await ProfileService.instance.getProfile(context);
      ShowMessage.notify(context, "Profile updated successfully!");
      Navigator.of(context).pop();
    } else {
      ShowMessage.notify(context, result.responseData['message'] ?? "Failed to update profile");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Trader Information'),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                _buildFormSection(),
                _buildSaveButton(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
