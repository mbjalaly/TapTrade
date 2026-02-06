import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:taptrade/Const/apiEndPoint.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/ApiServices/apiServices.dart';
import 'package:taptrade/Services/logService.dart';
import 'package:taptrade/Utills/showMessages.dart';

/// UnoSend SMS Service
/// Handles phone OTP verification using the backend UnoSend API
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
  /// Returns a map with success status and verification details
  Future<Map<String, dynamic>> sendOtp({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    try {
      printLog("UnoSendSmsService: Sending OTP to $phoneNumber");

      // Validate phone format (basic E.164 check)
      if (!_isValidE164Phone(phoneNumber)) {
        return {
          'success': false,
          'message': 'Invalid phone number format. Please use international format (e.g., +14155551234)',
        };
      }

      final requestBody = {
        'phone': phoneNumber,
      };

      final response = await ApiService.postRequestData(
        ApiEndPoint.sendSmsOtp,
        requestBody,
        context,
        sendToken: false,
      );

      printLog("UnoSendSmsService: Send OTP response: $response");

      // Handle successful response
      if (response['success'] == true) {
        _verificationId = response['verification_id'];
        _phoneNumber = phoneNumber;

        return {
          'success': true,
          'message': response['message'] ?? 'OTP sent successfully',
          'verification_id': _verificationId,
          'expires_at': response['expires_at'],
          'provider': response['provider'] ?? 'unosend',
        };
      }

      // Handle fallback needed
      if (response['fallback_needed'] == true) {
        printLog("UnoSendSmsService: Fallback needed");
        return {
          'success': false,
          'message': response['message'] ?? 'Primary SMS service unavailable',
          'fallback_needed': true,
          'provider': response['provider'] ?? 'unosend',
        };
      }

      // Handle other errors
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to send OTP',
        'fallback_needed': false,
      };

    } catch (e) {
      printLog("UnoSendSmsService: Error sending OTP: $e");

      if (e is ApiException) {
        // Parse error message from API
        try {
          Map<String, dynamic> errorJson = json.decode(e.message);
          String errorMessage = errorJson['message'] ?? 'Failed to send OTP';
          bool fallbackNeeded = errorJson['fallback_needed'] ?? false;

          // Show error to user only if not fallback scenario
          if (!fallbackNeeded) {
            ShowMessage.inDialog(context, errorMessage, true);
          }

          return {
            'success': false,
            'message': errorMessage,
            'fallback_needed': fallbackNeeded,
          };
        } catch (parseError) {
          return {
            'success': false,
            'message': e.message,
            'fallback_needed': true,
          };
        }
      }

      // Network or unknown errors should trigger fallback
      return {
        'success': false,
        'message': 'Network error. Please try again.',
        'fallback_needed': true,
      };
    }
  }

  /// Verify OTP code
  /// Returns a map with success status and verification result
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String code,
    required BuildContext context,
  }) async {
    try {
      printLog("UnoSendSmsService: Verifying OTP for $phoneNumber");

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

      printLog("UnoSendSmsService: Verify OTP response: $response");

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
      printLog("UnoSendSmsService: Error verifying OTP: $e");

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
