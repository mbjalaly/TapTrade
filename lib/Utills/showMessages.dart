import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:taptrade/Screens/GetStarted/getStarted.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customLoading.dart';
import 'appColors.dart';

class ShowMessage {

  /// Shows a modern snackbar notification
  static void notify(BuildContext context, String text) {
    _showModernSnackbar(context, text, SnackbarType.info);
  }

  /// Shows an error snackbar - use this for errors
  static void error(BuildContext context, String text) {
    _showModernSnackbar(context, text, SnackbarType.error);
  }

  /// Shows a success snackbar
  static void success(BuildContext context, String text) {
    _showModernSnackbar(context, text, SnackbarType.success);
  }

  /// Shows a warning snackbar
  static void warning(BuildContext context, String text) {
    _showModernSnackbar(context, text, SnackbarType.warning);
  }

  /// Replaces the old popup dialog with a snackbar for better UX
  static void inDialog(BuildContext context, String message, bool isError) {
    _showModernSnackbar(
      context, 
      message, 
      isError ? SnackbarType.error : SnackbarType.success,
    );
  }

  static void _showModernSnackbar(BuildContext context, String text, SnackbarType type) {
    final colors = _getSnackbarColors(type, context);
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  colors.icon,
                  color: colors.iconColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: colors.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static _SnackbarColors _getSnackbarColors(SnackbarType type, BuildContext context) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarColors(
          background: const Color(0xFFE8F5E9),
          border: const Color(0xFF81C784),
          iconBackground: const Color(0xFF4CAF50),
          iconColor: Colors.white,
          icon: Icons.check_rounded,
          textColor: const Color(0xFF2E7D32),
          shadow: const Color(0xFF4CAF50).withOpacity(0.15),
        );
      case SnackbarType.error:
        return _SnackbarColors(
          background: const Color(0xFFFFEBEE),
          border: const Color(0xFFE57373),
          iconBackground: const Color(0xFFE53935),
          iconColor: Colors.white,
          icon: Icons.error_outline_rounded,
          textColor: const Color(0xFFC62828),
          shadow: const Color(0xFFE53935).withOpacity(0.15),
        );
      case SnackbarType.warning:
        return _SnackbarColors(
          background: const Color(0xFFFFF3E0),
          border: const Color(0xFFFFB74D),
          iconBackground: const Color(0xFFFF9800),
          iconColor: Colors.white,
          icon: Icons.warning_amber_rounded,
          textColor: const Color(0xFFE65100),
          shadow: const Color(0xFFFF9800).withOpacity(0.15),
        );
      case SnackbarType.info:
      default:
        return _SnackbarColors(
          background: AppColors.contentBg(context),
          border: AppColors.primaryColor.withOpacity(0.3),
          iconBackground: AppColors.primaryColor,
          iconColor: AppColors.isDark(context) ? AppColors.darkPrimaryTextColor : AppColors.darkBlue,
          icon: Icons.info_outline_rounded,
          textColor: AppColors.isDark(context) ? AppColors.darkPrimaryTextColor : AppColors.darkBlue,
          shadow: AppColors.darkBlue.withOpacity(0.1),
        );
    }
  }

  static void inDialogInternet(String message, bool isError) {
    Color color = isError ? Colors.redAccent : Colors.green;
    Get.defaultDialog(
      title: '',
      titleStyle: TextStyle(
          fontFamily: 'Monts',
          fontSize: Get.height * 0.0,
          fontWeight: FontWeight.bold),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: Get.height * 0.032,
            backgroundColor: color,
            child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: Get.height * 0.030,
                child: Icon(
                  isError ? Icons.warning : Icons.done_outline,
                  color: color,
                  size: Get.height * 0.042,
                )),
          ),
          SizedBox(
            height: Get.height * 0.016,
          ),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Monts', fontSize: Get.height * 0.022)),
          SizedBox(height: Get.height * 0.02),
        ],
      ),
      // actions: [
      //   Wrap(
      //     alignment: WrapAlignment.center,
      //     spacing: 8,
      //     runSpacing: 8,
      //     children: [
      //       GestureDetector(
      //         onTap: () => Get.back(),
      //         child: Container(
      //           alignment: Alignment.center,
      //           margin: const EdgeInsets.only(bottom: 16),
      //           width: Get.width * .32,
      //           height: Get.height * .05,
      //           decoration: BoxDecoration(
      //               borderRadius: BorderRadius.circular(10),
      //               color: Resource.colors.appMainColor),
      //           child: Text(
      //             'OK',
      //             style: TextStyle(
      //                 fontFamily: 'Monts',
      //                 color: Colors.white,
      //                 fontWeight: FontWeight.bold,
      //                 fontSize: Get.height * .024),
      //           ),
      //         ),
      //       )
      //     ],
      //   )
      // ]
    );
  }

  static void inDialogUrlCannotLaunch(BuildContext context, String message, bool isError,VoidCallback onTap) {
    Color color = isError ? Colors.redAccent : Colors.green;
    Get.defaultDialog(
        title: '',
        titleStyle: TextStyle(
            fontFamily: 'Monts',
            fontSize: Get.height * 0.0,
            fontWeight: FontWeight.bold),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: Get.height * 0.032,
              backgroundColor: color,
              child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: Get.height * 0.030,
                  child: Icon(
                    isError ? Icons.warning : Icons.done_outline,
                    color: color,
                    size: Get.height * 0.042,
                  )),
            ),
            SizedBox(
              height: Get.height * 0.016,
            ),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Monts', fontSize: Get.height * 0.022)),
            SizedBox(height: Get.height * 0.02),
          ],
        ),
        actions: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              GestureDetector(
                onTap: onTap,
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 16),
                  width: Get.width * .32,
                  height: Get.height * .05,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.primaryColor,),
                  child: Text(
                    'OK',
                    style: TextStyle(
                        fontFamily: 'Monts',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Get.height * .024),
                  ),
                ),
              )
            ],
          )
        ]);
  }

  static void inDialogImageSelection(BuildContext context,String message, bool isError) {
    Color color = isError ? Colors.redAccent : Colors.green;
    Get.defaultDialog(
        title: '',
        titleStyle: TextStyle(
            fontFamily: 'Monts',
            fontSize: Get.height * 0.0,
            fontWeight: FontWeight.bold),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: Get.height * 0.032,
              backgroundColor: color,
              child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: Get.height * 0.030,
                  child: Icon(
                    isError ? Icons.warning : Icons.done_outline,
                    color: color,
                    size: Get.height * 0.042,
                  )),
            ),
            SizedBox(
              height: Get.height * 0.016,
            ),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Monts', fontSize: Get.height * 0.022)),
            SizedBox(height: Get.height * 0.02),
          ],
        ),
        actions: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 16),
                  width: Get.width * .32,
                  height: Get.height * .05,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.primaryColor),
                  child: Text(
                    'OK',
                    style: TextStyle(
                        fontFamily: 'Monts',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Get.height * .024),
                  ),
                ),
              )
            ],
          )
        ]);
  }

  static void showLogoutDialog(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    var userController = Get.find<UserController>();
    var productController = Get.find<ProductController>();
    Size size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              actionsPadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.all(20),
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              surfaceTintColor: isDark ? AppColors.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  side: isDark ? BorderSide(color: Colors.white.withOpacity(0.1)) : BorderSide.none,
              ),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon instead of Lottie for better theme support
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: AppColors.primaryColor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)?.logout ?? "Logout",
                    style: TextStyle(
                        color: isDark ? Colors.white : AppColors.primaryTextColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.confirmLogout ?? "Are you sure you want to logout?",
                    style: TextStyle(
                        color: isDark ? Colors.white : AppColors.blackTextColor,
                        fontSize: 15.0),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: size.height * 0.025),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: AppColors.primaryColor),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.cancel ?? "Cancel",
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            userController.clearAllData();
                            productController.clearAllData();
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const GetStartedScreen()),
                                    (route) => false);

                            await SharedPreferencesService()
                                .remove(KeyConstants.accessToken);
                            await SharedPreferencesService()
                                .remove(KeyConstants.userId);
                            scaffold.showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.primaryColor,
                                elevation: 4,
                                margin: const EdgeInsets.all(20),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                content: Text(AppLocalizations.of(context)?.logoutSuccessful ?? "Logout successful", style: const TextStyle(color: Colors.white)),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.logout ?? "Logout",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ));
        });
  }

  static void showDeleteDialog(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    var userController = Get.find<UserController>();
    var productController = Get.find<ProductController>();
    Size size = MediaQuery.of(context).size;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              actionsPadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.all(15),
              backgroundColor: AppColors.contentBg(context),
              surfaceTintColor: AppColors.contentBg(context),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              // actionsPadding: EdgeInsets.all(10),
              content: Container(
                color: AppColors.contentBg(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_rounded,color: Colors.red,size: 100,),
                    Text(
                        "Are you sure you want to permanently delete your account?",
                      style: TextStyle(
                          color: AppColors.textOnBg(context),
                          fontSize: 18.0),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          width: size.width * 0.25,
                          height: size.height * 0.05,
                          text: "No",
                          textColor: AppColors.primaryColor,
                        ),
                        AppButton(
                          onPressed: () async {
                            String userId = userController.userProfile.value.data?.id ?? "";
                            AppLoadingPopup.show();

                            try {
                              final result = await ProfileService.instance.deleteUser(context, userId);

                              if (result.status == Status.COMPLETED) {
                                AppLoadingPopup.hide();

                                userController.clearAllData();
                                productController.clearAllData();

                                await SharedPreferencesService().remove(KeyConstants.accessToken);
                                await SharedPreferencesService().remove(KeyConstants.userId);

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const GetStartedScreen()),
                                      (route) => false,
                                );

                                scaffold.showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.primaryText(context),
                                    elevation: 4,
                                    margin: const EdgeInsets.all(20),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    content: const Text("Account Deleted successfully"),
                                  ),
                                );
                              } else {
                                AppLoadingPopup.hide();
                                scaffold.showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.primaryText(context),
                                    elevation: 4,
                                    margin: const EdgeInsets.all(20),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    content: Text(
                                      result.responseData['message'] ?? "Something went wrong, please try again later",
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              AppLoadingPopup.hide();
                              scaffold.showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.primaryText(context),
                                  elevation: 4,
                                  margin: const EdgeInsets.all(20),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  content: Text("Error: ${e.toString()}"),
                                ),
                              );
                            }
                          },
                          width: size.width * 0.25,
                          height: size.height * 0.05,
                          text: "Yes",
                          textColor: AppColors.whiteTextColor,
                        ),
                      ],
                    )
                  ],
                ),
              ));
        });
  }

  static void openAppSetting(VoidCallback afterSettingOpen) {
    Get.defaultDialog(
      title: '',
      titleStyle: TextStyle(
        fontFamily: 'Monts',
        fontSize: 0,
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: Get.height * 0.032,
            backgroundColor: Colors.redAccent,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: Get.height * 0.030,
              child: Icon(
                Icons.warning,
                color: Colors.redAccent,
                size: Get.height * 0.042,
              ),
            ),
          ),
          SizedBox(height: Get.height * 0.016),
          Text(
            'Location permission is denied.\nPlease enable it in settings.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Monts',
              fontSize: Get.height * 0.022,
            ),
          ),
          SizedBox(height: Get.height * 0.02),
        ],
      ),
      actions: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 16),
                width: Get.width * .32,
                height: Get.height * .05,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey,
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Monts',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: Get.height * .022,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                Get.back();
                bool isAllow = await Geolocator.openAppSettings();
                if(isAllow){
                  afterSettingOpen;
                }
              },
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 16),
                width: Get.width * .38,
                height: Get.height * .05,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.primaryColor,
                ),
                child: Text(
                  'Open Settings',
                  style: TextStyle(
                    fontFamily: 'Monts',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: Get.height * .022,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

}

/// Enum for snackbar types
enum SnackbarType { success, error, warning, info }

/// Helper class for snackbar colors
class _SnackbarColors {
  final Color background;
  final Color border;
  final Color iconBackground;
  final Color iconColor;
  final IconData icon;
  final Color textColor;
  final Color shadow;

  _SnackbarColors({
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.iconColor,
    required this.icon,
    required this.textColor,
    required this.shadow,
  });
}
