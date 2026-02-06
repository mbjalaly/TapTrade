import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Screens/UserDetail/Product/addProductWizard.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/generalService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customText.dart';
import 'package:taptrade/l10n/app_localizations.dart';

class AddInterestScreen extends StatefulWidget {
  const AddInterestScreen({super.key});

  @override
  State<AddInterestScreen> createState() => _AddInterestScreenState();
}

class _AddInterestScreenState extends State<AddInterestScreen> {
  var userController = Get.find<UserController>();
  static const int maxSelectionCount = 5;
  List<String> selectedIndices = [];
  bool isLoading = false;
  bool isLoadingInterests = true;

  @override
  void initState() {
    super.initState();
    _loadInterests();
  }

  Future<void> _loadInterests() async {
    // Check if interests are already loaded
    if (GeneralService.instance.allInterest.value.data != null &&
        GeneralService.instance.allInterest.value.data!.isNotEmpty) {
      setState(() {
        isLoadingInterests = false;
      });
      return;
    }

    // Load interests from API
    setState(() {
      isLoadingInterests = true;
    });

    await GeneralService.instance.getAllInterests(context);

    setState(() {
      isLoadingInterests = false;
    });

    print("[AddInterestScreen] Loaded interests: ${GeneralService.instance.allInterest.value.data?.length ?? 0}");
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print("${GeneralService.instance.allInterest.value.data}");
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                left: Get.width * 0.045, right: Get.width * 0.045),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              SizedBox(
                height: Get.height * 0.02,
              ),
              GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.grey,
                        size: size.width * 0.08,
                      ))),
              Padding(
                padding: EdgeInsets.only(top: Get.height * 0.02),
                child: AppText(
                  text: AppLocalizations.of(context)?.interestsTitle ?? "Interests",
                  fontSize: Get.width * 0.1,
                  textcolor: AppColors.darkBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: Get.height * 0.02),
                child: AppText(
                  text:
                      "Let everyone know what you’re interested in\nby adding it to your profile.",
                  fontSize: Get.width * 0.036,
                  textcolor: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: Get.height * 0.03,
              ),
              if (isLoadingInterests)
                Container(
                  height: Get.height * 0.56,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: AppColors.themeColor,
                  ),
                )
              else if (GeneralService.instance.allInterest.value.data == null ||
                  GeneralService.instance.allInterest.value.data!.isEmpty)
                Container(
                  height: Get.height * 0.56,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      AppText(
                        text: AppLocalizations.of(context)?.failedToLoadInterests ?? "Failed to load interests",
                        fontSize: 16,
                        textcolor: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: _loadInterests,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.themeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        child: AppText(
                            text: AppLocalizations.of(context)?.retry ?? "Retry",
                            textcolor: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  constraints: BoxConstraints(
                    minHeight: Get.height * 0.56,
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: GeneralService.instance.allInterest.value.data!.map((interest) {
                      final name = interest.name ?? '';
                      final isSelected = selectedIndices.contains(name);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedIndices.remove(name);
                            } else {
                              selectedIndices.add(name);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.darkBlue
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.darkBlue
                                  : AppColors.greyText(context).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.darkBlue,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              SizedBox(
                height: Get.height * 0.03,
              ),
              Center(
                child: GestureDetector(
                  onTap: selectedIndices.length >= 5 && !isLoading ? () async{
                    Map<String,dynamic> body = {
                      "interest_names": selectedIndices
                    };
                    String id = userController.userProfile.value.data?.id ?? '';
                    setState(() {
                      isLoading = true;
                    });
                    final result = await ProfileService.instance.addUserInterest(context, body, id);
                    setState(() {
                      isLoading = false;
                    });
                    if(result.status == Status.COMPLETED){
                      ShowMessage.notify(context, "${result.responseData['message']}");
                      ProfileService.instance.getUserInterests(context, id);
                      // Profile is marked as completed in the backend after adding interests
                      Get.to(() =>  AddProductWizardScreen());
                    }else{
                      ShowMessage.notify(context, "${result.message}");
                    }
                  } : null,
                  child: Container(
                      height: Get.height * 0.065,
                      width: Get.width * 0.85,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: selectedIndices.length >= 5
                            ? AppColors.darkBlue
                            : Colors.grey.withOpacity(0.3),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : AppText(
                              text: (AppLocalizations.of(context)?.continueWithCount ?? "Continue ({count}/{max})").toString().replaceAll('{count}', '${selectedIndices.length}').replaceAll('{max}', '$maxSelectionCount'),
                              fontWeight: FontWeight.w700,
                              textcolor: Colors.white,
                              fontSize: Get.width * 0.042,
                            )),
                ),
              )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
