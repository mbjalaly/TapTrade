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
      backgroundColor: Colors.white,
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
                  text: "Interests",
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
                        text: "Failed to load interests",
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
                            text: "Retry",
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
                  height: Get.height * 0.56, // Adjust the height as needed
                  child: GridView.builder(
                    padding: EdgeInsets.all(0),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: GeneralService.instance.allInterest.value.data?.length ?? 0,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 2.6),
                    itemBuilder: (context, index) {
                      String name = GeneralService.instance.allInterest.value.data?[index].name ?? '';
                      bool isSelected = selectedIndices.contains(name);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedIndices.contains(name)) {
                              selectedIndices.remove(name);
                            } else {
                                selectedIndices.add(name);
                            }
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.darkYellow.withOpacity(0.1)
                                  : Colors.transparent,
                              border: Border.all(color: isSelected
                                  ? AppColors.darkYellow
                                  : AppColors.greyTextColor,width: isSelected ? 2.0 : 1.0),
                              borderRadius: BorderRadius.circular(
                                30,
                              )),
                          child: AppText(
                            text: name,
                            textAlign: TextAlign.center,
                            textcolor:
                                isSelected ? AppColors.secondaryColor : AppColors.greyTextColor,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(
                height: Get.height * 0.03,
              ),
              Center(
                child: GestureDetector(
                  onTap: () async{
                    if(selectedIndices.length >= 5){
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
                    }else{
                      ShowMessage.notify(context, "Please Select At Least 5 Interest");
                    }


                        },
                  child: Container(
                      height: Get.height * 0.065,
                      width: Get.width * 0.85,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: selectedIndices.length >= 5
                            ? const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFF00E3DF), // Start color
                                  Color(0xFFF2B721), // End color
                                ],
                                stops: [0.0, 1.0], // Gradient stops
                              )
                            : LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.grey.withOpacity(.40), // Start color
                                  Colors.grey.withOpacity(.40), // End color
                                ],
                                stops: [0.0, 1.0], // Gradient stops
                              ),
                      ),
                      child: isLoading ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTextColor,)) : AppText(
                        text: "Continue ${selectedIndices.length}/$maxSelectionCount ",
                        fontWeight: FontWeight.w600,
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
