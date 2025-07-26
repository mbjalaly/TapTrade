
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Screens/Dashboard/Bottombar/bottombarscreen.dart';
import 'package:taptrade/Screens/UserDetail/AddProfile/addProfile.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/authService.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Utills/showMessages.dart';

import 'profileService.dart';


class AuthWithGoogle {
  static Future<void> google({required BuildContext context}) async {
    try {
      bool internet = await checkInternet();

      if (!internet) {
        print("No Internet Connection");
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();

        await googleSignIn.signOut();

        final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

        if (googleSignInAccount != null) {
          final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

          print("Google accessToken: ${googleSignInAuthentication.accessToken}");
          print("Google idToken length: ${googleSignInAuthentication.idToken?.length} xxx");
          print("Google idToken: ${googleSignInAuthentication.idToken} xxx");
          print("Google email: ${googleSignInAccount.email}");
          print("Google displayName: ${googleSignInAccount.displayName}");
          print("Google photoUrl: ${googleSignInAccount.photoUrl}");

          final credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );

          print("Firebase idToken length: ${credential.idToken?.length} xxx");
          print("Firebase idToken: ${credential.idToken} xxx");

          if (credential.idToken != null) {
            String idToken = credential.idToken!;
            int midIndex = (idToken.length / 2).round();
            String firstPart = idToken.substring(0, midIndex);
            String secondPart = idToken.substring(midIndex);

            print("First Part of idToken: $firstPart");
            print("Second Part of idToken: $secondPart");
          } else {
            print("Firebase idToken is null");
          }

          print("Firebase rawNonce: ${credential.rawNonce}");
          print("Firebase serverAuthCode: ${credential.serverAuthCode}");
          print("Firebase secret: ${credential.secret}");
          print("Firebase providerId: ${credential.providerId}");
          print("Firebase token: ${credential.token}");
          print("Firebase accessToken: ${credential.accessToken}");
          print("Firebase signInMethod: ${credential.signInMethod}");

          // Sign in to Firebase using the credential
          final authResult = await FirebaseAuth.instance.signInWithCredential(credential);
          final User? user = authResult.user;
          final uId = user?.uid;
          Map<String,dynamic> body = {
            "email": "${user?.email}",
            "full_name": "${user?.displayName}",
            "origin": "google",
            "uid": "${user?.uid}",
            // "image": "${user?.photoURL}",
          };
          final result = await AuthService.instance.googleSignIn(context, body);
          if(result.status == Status.COMPLETED){
            await SharedPreferencesService().setString(
                KeyConstants.accessToken,
                result.responseData['data']['access']);
            await SharedPreferencesService().setString(
                KeyConstants.userId,
                result.responseData['data']['id']);
            ShowMessage.notify(
                context, result.responseData['message']);
            final response = await ProfileService.instance.getProfile(context);
            bool isProfileComplete =  response.responseData['data']['is_profile_completed'] ?? false;
            if(isProfileComplete){
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const BottomNavigationScreen()),
                      (route) => false);
            }else{
              Get.to(const AddProfileScreen());
            }

          }else{
            ShowMessage.notify(context, result.responseData['message'].toString());
          }

          print("Firebase Uid: $uId");
        } else {
          print("Google sign-in was canceled or failed.");
        }
      }
    } catch (e) {
      print("An error occurred during Google Sign-In: $e");
    }
  }
  }





Future<bool> checkInternet() async {
  // return Future.value(true);
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      ////print('connected');
      return true;
    }
  } on SocketException catch (_) {
    ////print('not connected');
    return false;
  }
  return false;
}

