import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taptrade/Services/logService.dart';
import 'package:taptrade/Utills/showMessages.dart';

/// Firebase Phone Authentication Service
/// Handles OTP sending and verification via Firebase
class FirebasePhoneAuthService {
  static final FirebasePhoneAuthService instance = FirebasePhoneAuthService._internal();
  
  factory FirebasePhoneAuthService() => instance;
  
  FirebasePhoneAuthService._internal();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? _verificationId;
  int? _resendToken;
  
  /// Get the verification ID (needed for OTP verification)
  String? get verificationId => _verificationId;
  
  /// Send OTP to phone number
  /// [phoneNumber] should include country code, e.g., "+966123456789"
  Future<bool> sendOtp({
    required String phoneNumber,
    required BuildContext context,
    required Function(String verificationId) onCodeSent,
    required Function(PhoneAuthCredential credential) onAutoVerify,
    Function(String error)? onError,
    int? forceResendingToken,
  }) async {
    try {
      printLog('[Firebase Phone Auth] Sending OTP to: $phoneNumber');
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: forceResendingToken ?? _resendToken,
        
        // Called when code is sent successfully
        codeSent: (String verificationId, int? resendToken) {
          printLog('[Firebase Phone Auth] Code sent! Verification ID: $verificationId');
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        
        // Called on Android devices that support auto-verification
        verificationCompleted: (PhoneAuthCredential credential) async {
          printLog('[Firebase Phone Auth] Auto-verification completed');
          onAutoVerify(credential);
        },
        
        // Called when verification fails
        verificationFailed: (FirebaseAuthException e) {
          printLog('[Firebase Phone Auth] Verification failed:');
          printLog('[Firebase Phone Auth] Code: ${e.code}');
          printLog('[Firebase Phone Auth] Message: ${e.message}');
          printLog('[Firebase Phone Auth] Plugin: ${e.plugin}');
          printLog('[Firebase Phone Auth] Stack: ${e.stackTrace}');
          String errorMessage = _getErrorMessage(e.code);
          if (onError != null) {
            onError(errorMessage);
          } else {
            ShowMessage.inDialog(context, errorMessage, true);
          }
        },
        
        // Called when auto-retrieval timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          printLog('[Firebase Phone Auth] Auto-retrieval timeout');
          _verificationId = verificationId;
        },
      );
      
      return true;
    } catch (e) {
      printLog('[Firebase Phone Auth] Error: $e');
      ShowMessage.inDialog(context, 'Failed to send OTP. Please try again.', true);
      return false;
    }
  }
  
  /// Verify the OTP code entered by user
  /// Returns the UserCredential if successful, null otherwise
  Future<UserCredential?> verifyOtp({
    required String otp,
    required BuildContext context,
    String? verificationId,
  }) async {
    try {
      final verId = verificationId ?? _verificationId;
      
      if (verId == null) {
        ShowMessage.inDialog(context, 'Verification session expired. Please request a new OTP.', true);
        return null;
      }
      
      printLog('[Firebase Phone Auth] Verifying OTP: $otp');
      
      // Create credential from verification ID and OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verId,
        smsCode: otp,
      );
      
      // Sign in with the credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      printLog('[Firebase Phone Auth] Verification successful! User: ${userCredential.user?.uid}');
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      printLog('[Firebase Phone Auth] Verification error: ${e.code} - ${e.message}');
      String errorMessage = _getErrorMessage(e.code);
      ShowMessage.inDialog(context, errorMessage, true);
      return null;
    } catch (e) {
      printLog('[Firebase Phone Auth] Error: $e');
      ShowMessage.inDialog(context, 'Verification failed. Please try again.', true);
      return null;
    }
  }
  
  /// Sign in with credential (used for auto-verification)
  Future<UserCredential?> signInWithCredential(
    PhoneAuthCredential credential,
    BuildContext context,
  ) async {
    try {
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      printLog('[Firebase Phone Auth] Sign-in error: ${e.message}');
      ShowMessage.inDialog(context, _getErrorMessage(e.code), true);
      return null;
    }
  }
  
  /// Resend OTP using the stored resend token
  Future<bool> resendOtp({
    required String phoneNumber,
    required BuildContext context,
    required Function(String verificationId) onCodeSent,
    required Function(PhoneAuthCredential credential) onAutoVerify,
  }) async {
    return sendOtp(
      phoneNumber: phoneNumber,
      context: context,
      onCodeSent: onCodeSent,
      onAutoVerify: onAutoVerify,
      forceResendingToken: _resendToken,
    );
  }
  
  /// Get user-friendly error message
  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Invalid phone number. Please check and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please check and try again.';
      case 'session-expired':
        return 'Verification session expired. Please request a new OTP.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled. Please contact support.';
      case 'internal-error':
        return 'Firebase configuration error. Please check Phone Auth is enabled.';
      case 'app-not-authorized':
        return 'App is not authorized. Please check Firebase configuration.';
      case 'missing-client-identifier':
        return 'Missing APNs token. Please check push notification setup.';
      default:
        return 'Verification failed ($code). Please try again.';
    }
  }
  
  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;
  
  /// Sign out from Firebase
  Future<void> signOut() async {
    await _auth.signOut();
    _verificationId = null;
    _resendToken = null;
  }
  
  /// Clear verification session
  void clearSession() {
    _verificationId = null;
    _resendToken = null;
  }
}

