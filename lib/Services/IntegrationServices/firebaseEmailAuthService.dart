import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taptrade/Services/logService.dart';
import 'package:taptrade/Utills/showMessages.dart';

/// Service for handling Firebase Email Link (Passwordless) Authentication
/// This sends a sign-in link to the user's email which they click to verify
class FirebaseEmailAuthService {
  static final FirebaseEmailAuthService instance = FirebaseEmailAuthService._internal();

  factory FirebaseEmailAuthService() {
    return instance;
  }

  FirebaseEmailAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Store the email for verification completion
  String? _pendingEmail;
  
  /// Get the pending email awaiting verification
  String? get pendingEmail => _pendingEmail;

  /// Send sign-in link to email
  /// Returns true if email was sent successfully
  Future<bool> sendSignInLink({
    required String email,
    required BuildContext context,
  }) async {
    try {
      printLog('[Firebase Email Auth] Sending sign-in link to: $email');
      
      // Action code settings for the email link
      final actionCodeSettings = ActionCodeSettings(
        // URL to redirect to after email verification
        // This should be your app's URL scheme or a web URL that can redirect to your app
        url: 'https://taptrade.page.link/verify', // Replace with your actual dynamic link
        handleCodeInApp: true,
        iOSBundleId: 'com.example.taptrade', // Replace with your iOS bundle ID
        androidPackageName: 'com.example.taptrade', // Replace with your Android package name
        androidInstallApp: true,
        androidMinimumVersion: '21',
      );

      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
      
      // Store email for later verification
      _pendingEmail = email;
      
      printLog('[Firebase Email Auth] Sign-in link sent successfully to: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      printLog('[Firebase Email Auth] Error: ${e.code} - ${e.message}');
      String errorMessage = _getErrorMessage(e.code);
      ShowMessage.inDialog(context, errorMessage, true);
      return false;
    } catch (e) {
      printLog('[Firebase Email Auth] Unexpected error: $e');
      ShowMessage.inDialog(context, 'Failed to send verification email. Please try again.', true);
      return false;
    }
  }

  /// Check if the incoming link is a sign-in link
  bool isSignInLink(String emailLink) {
    return _auth.isSignInWithEmailLink(emailLink);
  }

  /// Complete sign-in with email link
  /// Returns the UserCredential if successful, null otherwise
  Future<UserCredential?> signInWithEmailLink({
    required String email,
    required String emailLink,
    required BuildContext context,
  }) async {
    try {
      printLog('[Firebase Email Auth] Completing sign-in for: $email');
      
      final userCredential = await _auth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );
      
      printLog('[Firebase Email Auth] Sign-in successful: ${userCredential.user?.uid}');
      _pendingEmail = null;
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      printLog('[Firebase Email Auth] Sign-in error: ${e.code} - ${e.message}');
      String errorMessage = _getErrorMessage(e.code);
      ShowMessage.inDialog(context, errorMessage, true);
      return null;
    } catch (e) {
      printLog('[Firebase Email Auth] Unexpected error: $e');
      ShowMessage.inDialog(context, 'Failed to verify email. Please try again.', true);
      return null;
    }
  }

  /// Create user with email and password, then send verification email
  /// This is an alternative approach that uses email/password with verification
  Future<UserCredential?> createUserAndSendVerification({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      printLog('[Firebase Email Auth] Creating user with email: $email');
      
      // Create the user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      printLog('[Firebase Email Auth] User created: ${userCredential.user?.uid}');
      
      // Send verification email with custom settings
      try {
        final user = userCredential.user;
        if (user != null) {
          // Set language to ensure email is sent
          await _auth.setLanguageCode('en');
          
          // Send verification email
          await user.sendEmailVerification();
          printLog('[Firebase Email Auth] Verification email sent to: $email');
        } else {
          printLog('[Firebase Email Auth] WARNING: User is null after creation');
        }
      } catch (emailError) {
        printLog('[Firebase Email Auth] Error sending verification email: $emailError');
        // Don't fail the whole process if email sending fails
        // The user can request a resend later
        ShowMessage.notify(context, 'Account created. If you don\'t receive the email, tap Resend.');
      }
      
      _pendingEmail = email;
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      printLog('[Firebase Email Auth] FirebaseAuthException: ${e.code} - ${e.message}');
      
      // If user already exists, try to sign in and resend verification
      if (e.code == 'email-already-in-use') {
        try {
          printLog('[Firebase Email Auth] User exists, trying to sign in and resend verification');
          final existingUser = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          
          if (existingUser.user != null && !existingUser.user!.emailVerified) {
            await existingUser.user!.sendEmailVerification();
            printLog('[Firebase Email Auth] Resent verification to existing user');
            _pendingEmail = email;
            return existingUser;
          } else if (existingUser.user?.emailVerified == true) {
            printLog('[Firebase Email Auth] User already verified');
            _pendingEmail = email;
            return existingUser;
          }
        } catch (signInError) {
          printLog('[Firebase Email Auth] Sign in error: $signInError');
          ShowMessage.inDialog(context, 'Email already registered. Please login or use a different email.', true);
          return null;
        }
      }
      
      String errorMessage = _getErrorMessage(e.code);
      ShowMessage.inDialog(context, errorMessage, true);
      return null;
    } catch (e) {
      printLog('[Firebase Email Auth] Unexpected error: $e');
      ShowMessage.inDialog(context, 'Failed to create account. Please try again.', true);
      return null;
    }
  }

  /// Check if user's email is verified
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Resend verification email to current user
  Future<bool> resendVerificationEmail(BuildContext context) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        printLog('[Firebase Email Auth] No current user to resend verification');
        ShowMessage.inDialog(context, 'No user found. Please try again.', true);
        return false;
      }
      
      printLog('[Firebase Email Auth] Resending verification to: ${user.email}');
      printLog('[Firebase Email Auth] User UID: ${user.uid}');
      printLog('[Firebase Email Auth] Email verified: ${user.emailVerified}');
      
      if (user.emailVerified) {
        printLog('[Firebase Email Auth] Email already verified!');
        ShowMessage.notify(context, 'Your email is already verified!');
        return true;
      }
      
      // Set language before sending
      await _auth.setLanguageCode('en');
      
      await user.sendEmailVerification();
      printLog('[Firebase Email Auth] Verification email resent successfully');
      ShowMessage.notify(context, 'Verification email sent! Check your inbox and spam folder.');
      return true;
    } catch (e) {
      printLog('[Firebase Email Auth] Error resending verification: $e');
      
      String errorMsg = 'Failed to resend verification email.';
      if (e.toString().contains('too-many-requests')) {
        errorMsg = 'Too many requests. Please wait a few minutes before trying again.';
      }
      
      ShowMessage.inDialog(context, errorMsg, true);
      return false;
    }
  }
  
  /// Debug function to check current Firebase Auth state
  void debugAuthState() {
    final user = _auth.currentUser;
    printLog('[Firebase Email Auth] === DEBUG AUTH STATE ===');
    printLog('[Firebase Email Auth] Current user: ${user?.uid ?? 'null'}');
    printLog('[Firebase Email Auth] Email: ${user?.email ?? 'null'}');
    printLog('[Firebase Email Auth] Email verified: ${user?.emailVerified ?? 'null'}');
    printLog('[Firebase Email Auth] Display name: ${user?.displayName ?? 'null'}');
    printLog('[Firebase Email Auth] Provider data: ${user?.providerData.map((p) => p.providerId).toList()}');
    printLog('[Firebase Email Auth] Pending email: $_pendingEmail');
    printLog('[Firebase Email Auth] ========================');
  }

  /// Clear pending email
  void clearPendingEmail() {
    _pendingEmail = null;
  }

  /// Get user-friendly error message
  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'operation-not-allowed':
        return 'Email sign-in is not enabled. Please contact support.';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'invalid-action-code':
        return 'The verification link is invalid or expired. Please request a new one.';
      case 'expired-action-code':
        return 'The verification link has expired. Please request a new one.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
