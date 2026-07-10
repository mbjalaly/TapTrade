import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:taptrade/Const/apiEndPoint.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/ApiServices/apiServices.dart';
import 'package:taptrade/Services/logService.dart';
import 'package:taptrade/Utills/showMessages.dart';

/// SMS Service (Firebase-only)
/// UnoSend has been removed. sendOtp() now immediately directs callers to
/// the Firebase phone-auth path via `fallback_needed: true`, reusing the
/// existing fallback branches in each screen. No backend call is made.
class UnoSendSmsService {
  static final UnoSendSmsService instance = UnoSendSmsService._internal();

  factory UnoSendSmsService() {
    return instance;
  }

  UnoSendSmsService._internal();

  // Store verification ID for the verify call
  String? _verificationId;
  String? _phoneNumber;

  String? get verificationId => _verificationId;
  String? get phoneNumber => _phoneNumber;

  /// Send OTP to phone number
  /// Firebase-only: always returns `fallback_needed: true` so the calling
  /// screen proceeds directly with FirebasePhoneAuthService. No UnoSend
  /// attempt, no network round-trip.
  Future<Map<String, dynamic>> sendOtp({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    // Validate phone format (basic E.164 check)
    if (!_isValidE164Phone(phoneNumber)) {
      return {
        'success': false,
        'message': 'Invalid phone number format. Please use international format (e.g., +14155551234)',
      };
    }

    printLog("SmsService: Directing $phoneNumber to Firebase phone verification");

    _phoneNumber = phoneNumber;

    return {
      'success': false,
      'message': 'Using Firebase phone verification',
      'fallback_needed': true,
      'provider': 'firebase',
    };
  }

  /// Verify OTP code (legacy backend verification — unused in the Firebase
  /// flow, where verification happens on-device via FirebasePhoneAuthService.
  /// Kept so existing references keep compiling.)
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String code,
    required BuildContext context,
  }) async {
    try {
      printLog("SmsService: Verifying OTP for $phoneNumber");

      // Validate code format (6 digits)
      if (!_isValidOtpCode(code)) {
        return {
          'success': false,
          'message': 'Invalid OTP code. Please enter a 6-digit code.',
        };
      }

      final requestBody = {
        'phone': phoneNumber,
        'code': code,
        'verification_id': _verificationId,
      };

      final response = await ApiService.postRequestData(
        ApiEndPoint.verifySmsOtp,
        requestBody,
        context,
        sendToken: false,
      );

      printLog("SmsService: Verify OTP response: $response");

      // Handle successful verification
      if (response['success'] == true && response['phone_verified'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Phone verified successfully',
          'phone_verified': true,
          'provider': response['provider'] ?? 'unosend',
        };
      }

      // Handle verification failure
      return {
        'success': false,
        'message': response['message'] ?? 'Invalid OTP code',
        'attempts_remaining': response['attempts_remaining'],
      };

    } catch (e) {
      printLog("SmsService: Error verifying OTP: $e");

      if (e is ApiException) {
        // Parse error message from API
        try {
          Map<String, dynamic> errorJson = json.decode(e.message);
          String errorMessage = errorJson['message'] ?? 'Failed to verify OTP';

          ShowMessage.inDialog(context, errorMessage, true);

          return {
            'success': false,
            'message': errorMessage,
            'attempts_remaining': errorJson['attempts_remaining'],
          };
        } catch (parseError) {
          ShowMessage.inDialog(context, e.message, true);
          return {
            'success': false,
            'message': e.message,
          };
        }
      }

      ShowMessage.inDialog(context, 'Network error. Please try again.', true);
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  /// Clear stored verification data
  void clearVerification() {
    _verificationId = null;
    _phoneNumber = null;
  }

  /// Validate E.164 phone format
  bool _isValidE164Phone(String phone) {
    // Basic E.164 validation: starts with +, followed by 1-15 digits
    final regex = RegExp(r'^\+[1-9]\d{1,14}$');
    return regex.hasMatch(phone);
  }

  /// Validate OTP code format (6 digits)
  bool _isValidOtpCode(String code) {
    final regex = RegExp(r'^\d{6}$');
    return regex.hasMatch(code);
  }
}