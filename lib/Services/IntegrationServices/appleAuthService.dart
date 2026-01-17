import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Screens/Dashboard/Bottombar/bottombarscreen.dart';
import 'package:taptrade/Screens/UserDetail/AddInterest/addInterest.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:taptrade/Widgets/customLoading.dart';

class AppleAuthService {
  static final AppleAuthService instance = AppleAuthService._internal();

  factory AppleAuthService() {
    return instance;
  }

  AppleAuthService._internal();

  static RegExp regExp =
      RegExp(r'^[a-zA-Z0-9._%+-]+@privaterelay\.appleid\.com$');

  static bool isPrivateRelayEmail(String email) {
    return regExp.hasMatch(email);
  }

  // Future<void> apple({required BuildContext context}) async {
  //   try {
  //     // Get Apple credentials
  //     AppLoadingPopup.show();
  //     final appleCredential = await SignInWithApple.getAppleIDCredential(
  //       scopes: [
  //         AppleIDAuthorizationScopes.email,
  //         AppleIDAuthorizationScopes.fullName,
  //       ],
  //     );
  //
  //     final oauthCredential = OAuthProvider("apple.com").credential(
  //       idToken: appleCredential.identityToken,
  //       accessToken: appleCredential.authorizationCode,
  //     );
  //
  //     final FirebaseAuth auth = FirebaseAuth.instance;
  //
  //     UserCredential? userCredential;
  //     try {
  //       // Sign in with credentials
  //       userCredential = await auth.signInWithCredential(oauthCredential);
  //     } catch (authError) {
  //       AppLoadingPopup.hide();
  //       print("Firebase Auth Error: $authError");
  //       ShowMessage.notify(context, "Authentication failed. Please try again.");
  //       return;
  //     }
  //
  //     // Extract user details
  //     String appleName =
  //         "${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}";
  //     if (appleName.trim().isNotEmpty) {
  //       try {
  //         await userCredential.user?.updateDisplayName(appleName);
  //         await userCredential.user?.reload();
  //       } catch (updateError) {
  //         AppLoadingPopup.hide();
  //         print("Error updating display name: $updateError");
  //       }
  //     }
  //
  //     bool isPrivateEmail =
  //         isPrivateRelayEmail(userCredential.user?.email ?? '');
  //     String email = userCredential.user?.email ?? '';
  //     String fullName = appleName.trim().isNotEmpty
  //         ? appleName
  //         : userCredential.user?.displayName ?? '';
  //     String photoUrl = userCredential.user?.photoURL ?? '';
  //     String origin = "ios";
  //     String token = appleCredential.identityToken ?? '';
  //     String uid = userCredential.user?.uid ?? '';
  //
  //     print("--=-=-=-=-=-=- ${userCredential.user?.displayName}");
  //     Map<String, dynamic> body = {
  //       "email": email,
  //       "full_name": fullName,
  //       "username": fullName,
  //       "origin": "apple",
  //       "uid": uid,
  //
  //       // "email": email,
  //       // "photoUrl": photoUrl,
  //       // "fullName": fullName,
  //       // "origin": origin,
  //       // "uid": uid,
  //       // "token": token,
  //     };
  //
  //     try {
  //       // Call backend service for further processing
  //       final result = await AuthService.instance.appleSignIn(context, body);
  //       AppLoadingPopup.hide();
  //       if(result.status == Status.COMPLETED){
  //         await SharedPreferencesService().setString(
  //             KeyConstants.accessToken,
  //             result.responseData['data']['access']);
  //         await SharedPreferencesService().setString(
  //             KeyConstants.userId,
  //             result.responseData['data']['id']);
  //         ShowMessage.notify(
  //             context, result.responseData['message']);
  //         final response = await ProfileService.instance.getProfile(context);
  //         bool isProfileComplete =  response.responseData['data']['is_profile_completed'] ?? false;
  //         if(isProfileComplete){
  //           Navigator.pushAndRemoveUntil(
  //               context,
  //               MaterialPageRoute(builder: (_) => const BottomNavigationScreen()),
  //                   (route) => false);
  //         }else{
  //           Get.to(const AddProfileScreen());
  //         }
  //
  //       }
  //       else{
  //         ShowMessage.notify(context, result.responseData['message'].toString());
  //       }
  //     } catch (backendError) {
  //       AppLoadingPopup.hide();
  //       print("Backend service error: $backendError");
  //       ShowMessage.notify(
  //           context, "Failed to connect to the server. Please try again.");
  //     }
  //
  //     print("Firebase Uid: $uid");
  //     // return appleCredential.userIdentifier;
  //   } on SignInWithAppleAuthorizationException catch (appleError) {
  //     AppLoadingPopup.hide();
  //     print("Apple Sign-In Authorization Error: ${appleError.message}");
  //     ShowMessage.notify(context, "Apple Sign-In failed. Please try again.");
  //   } catch (generalError) {
  //     AppLoadingPopup.hide();
  //     print("Error signing in with Apple: $generalError");
  //     ShowMessage.notify(
  //         context, "An unexpected error occurred. Please try again.");
  //   }
  // }

  Future<void> apple({required BuildContext context}) async {
    try {
      AppLoadingPopup.show();

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final FirebaseAuth auth = FirebaseAuth.instance;

      UserCredential? userCredential;
      try {
        userCredential = await auth.signInWithCredential(oauthCredential);
      } catch (authError) {
        print("Firebase Auth Error: $authError");
        AppLoadingPopup.hide();
        ShowMessage.notify(context, "Authentication failed. Please try again.");
        return;
      }

      // Update display name if available
      String appleName =
      "${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}".trim();

      if (appleName.isNotEmpty) {
        try {
          await userCredential.user?.updateDisplayName(appleName);
          await userCredential.user?.reload();
        } catch (updateError) {
          print("Error updating display name: $updateError");
          AppLoadingPopup.hide();
          return;
        }
      }

      bool isPrivateEmail =
      isPrivateRelayEmail(userCredential.user?.email ?? '');
      String email = userCredential.user?.email ?? '';
      String fullName = appleName.isNotEmpty
          ? appleName
          : userCredential.user?.displayName ?? '';
      String uid = userCredential.user?.uid ?? '';

      Map<String, dynamic> body = {
        "email": email,
        "full_name": fullName,
        "username": fullName,
        "origin": "apple",
        "uid": uid,
      };

      try {
        final result = await AuthService.instance.appleSignIn(context, body);

        if (result.status == Status.COMPLETED) {
          await SharedPreferencesService().setString(
              KeyConstants.accessToken,
              result.responseData['data']['access']);
          await SharedPreferencesService().setString(
              KeyConstants.userId,
              result.responseData['data']['id']);

          ShowMessage.notify(context, result.responseData['message']);

          final response = await ProfileService.instance.getProfile(context);
          bool isProfileComplete =
              response.responseData['data']['is_profile_completed'] ?? false;

          AppLoadingPopup.hide();

          if (isProfileComplete) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const BottomNavigationScreen()),
                    (route) => false);
          } else {
            Get.to(const AddInterestScreen());
          }
        } else {
          AppLoadingPopup.hide();
          ShowMessage.notify(
              context, result.responseData['message'].toString());
        }
      } catch (backendError) {
        print("Backend service error: $backendError");
        AppLoadingPopup.hide();
        ShowMessage.notify(
            context, "Failed to connect to the server. Please try again.");
      }

      print("Firebase Uid: $uid");
    } on SignInWithAppleAuthorizationException catch (appleError) {
      print("Apple Sign-In Authorization Error: ${appleError.message}");
      AppLoadingPopup.hide();
      ShowMessage.notify(context, "Apple Sign-In failed. Please try again.");
    } catch (generalError) {
      print("Error signing in with Apple: $generalError");
      AppLoadingPopup.hide();
      ShowMessage.notify(
          context, "An unexpected error occurred. Please try again.");
    }
  }

}

//
// flutter: [My Impact Meter]: gvjhblschchjnasjkcksa
// flutter: [My Impact Meter]: userIdentifier 001653.33b15e4b123f490abbe7ed95dc84f6d3.0648
// flutter: [My Impact Meter]: email ydkmbdhnh6@privaterelay.appleid.com
// flutter: [My Impact Meter]: givenName muhammad
// flutter: [My Impact Meter]: familyName obaidullah
// flutter: [My Impact Meter]: authorizationCode ca8d9e0276f1948dd800b783f596c13ce.0.srwvt.HHzq8G2frqfNGa7hIOV-zw
// flutter: [My Impact Meter]: identityToken eyJraWQiOiJGZnRPTlR4b0VnIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLmltcGFjdC5tZXRlciIsImV4cCI6MTcyMjY2NzcxNSwiaWF0IjoxNzIyNTgxMzE1LCJzdWIiOiIwMDE2NTMuMzNiMTVlNGIxMjNmNDkwYWJiZTdlZDk1ZGM4NGY2ZDMuMDY0OCIsImNfaGFzaCI6IlhxcEpCZzVfV0lWTzhSRjhqNUU5Z1EiLCJlbWFpbCI6Inlka21iZGhuaDZAcHJpdmF0ZXJlbGF5LmFwcGxlaWQuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF1dGhfdGltZSI6MTcyMjU4MTMxNSwibm9uY2Vfc3VwcG9ydGVkIjp0cnVlLCJyZWFsX3VzZXJfc3RhdHVzIjoxfQ.ANTngicw8Ynze10brquzTpkdhxUZA3YskSDKoBhJb5u-uXZoj1sB8RoD5FsbCysBHfhZ-k3jKbPnFkpEev-fStCbvaihvHkPSKRcY4AqYyEnahf9a4TT91Vsg7I-GgtLtS-qlfmoP1qfyW-4gopCvd9ZNKTgChgJDH5UPdnQvwFBJR_8_MJC4YWwoUMQBe2uYMLZ9bwVEsG5kaDgx0524fTh7eTQjbD5fGqu5tGbg9n5GEESFb67bktxbguBQm9tT_WHezX8jBC48fBraTwva-gIo-pfI8VTkpNs_34pDIPogZVbF-1sDAGyUP3GAwwn-OBSPx5fZ8Nl_wX-1xWqAw
// flutter: [My Impact Meter]: state null
// flutter: [My Impact Meter]: userIdentifier ydkmbdhnh6@privaterelay.appleid.com
// flutter: [My Impact Meter]: email null
// flutter: [My Impact Meter]: givenName null
// flutter: [My Impact Meter]: familyName null
// flutter: [My Impact Meter]: authorizationCode K5J48uYZB6TKbtL9WfIAP3rzOJ33
// flutter: [My Impact Meter]: identityToken AMf-vBzWJTx06BelBCrVhSAEoq45duKrAMFBLzfDTYfJvXn8KQa2q4CCQTThB_pw4ZfLslMAAUlnHTMt1SAgzFTuXJ5AE9yJF02b5rBWRY-e3TBxgzKHFme599zzvRJDCGTitvXfda78YyUVWEXovhY_Zn-g7FoOAibRiNXR_PGUCHQPzgpJutWeGa2IFZWkbmmsYf4MqvmeSBGM2RDWXonhiQBY9Z1WYMv6mAdkY5FMYFXYKWkidEhbtsSvfCl3WN3nvtnBH590LIuflTFYlA9UK0N2DT7aGBckCNPnTdTTwRswDlT8ZiERpj-aVv1hJVODLzj5UU6k
// flutter: [My Impact Meter]: state null
// flutter: [My Impact Meter]: state apple.com
