import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Screens/GetStarted/getStarted.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/AppException/appException.dart';
import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';
import 'package:taptrade/Services/logService.dart';
import 'package:get/get.dart' as getx;
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';

class ApiService {
  static const Duration _defaultTimeout = Duration(seconds: 12);
  static const Duration _fileUploadTimeout = Duration(seconds: 60); // Longer timeout for file uploads
  static const Duration _largeDataTimeout = Duration(seconds: 30); // Longer timeout for endpoints that return large data (e.g., products with images)

  /// Get request with optional token.
  static Future<dynamic> getRequestData(
      String url, BuildContext context, {bool useToken = false, Duration? timeout}) async {
    String apiUrl = url;

    if (kDebugMode) {
      printLog("URL: $apiUrl");
    }

    var responseJson;
    try {
      String? token;

      if (useToken) {
        token = await SharedPreferencesService().getString(KeyConstants.accessToken);
        if (kDebugMode) {
          printLog("Token value: $token");
        }
      }

      // Set up headers
      Map<String, String> headers = {
        'Content-type': 'application/json',
      };

      // Add Authorization header if token is available
      if (useToken && token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Make the HTTP GET request with a timeout to avoid indefinite hangs
      final requestTimeout = timeout ?? _defaultTimeout;
      final response = await http
          .get(Uri.parse(apiUrl), headers: headers)
          .timeout(requestTimeout);

      if (kDebugMode) {
        printLog("Response Status Code: ${response.statusCode}");
      }

      // Process the response
      responseJson = _returnListResponse(response, context);
      return responseJson;

    } on SocketException {
      if (kDebugMode) {
        printLog('Socket Exception');
      }
      throw FetchDataException("No Internet Available");
    } on TimeoutException {
      throw FetchDataException("Request timed out");
    }
  }

  /// Post request with token option.
  static Future<dynamic> postRequestData(
      String url, dynamic body, BuildContext context,
      {bool sendToken = false, String contentType = 'application/json'}) async {
    String apiUrl = url;

    if (kDebugMode) {
      printLog("URL: $apiUrl");
      printLog("BODY: $body");
    }

    var responseJson;
    try {
      String? token;

      if (sendToken) {
        token = await SharedPreferencesService().getString(KeyConstants.accessToken);
      }

      // Use longer timeout for file uploads
      final Duration timeout = contentType == 'multipart/form-data' 
          ? _fileUploadTimeout 
          : _defaultTimeout;

      // Make the HTTP POST request
      var response = await http
          .post(
            Uri.parse(apiUrl),
            body: contentType == 'multipart/form-data' ? body : jsonEncode(body),
            headers: _buildHeaders(sendToken, token, contentType),
          )
          .timeout(timeout);

      responseJson = _returnListResponse(response, context);
      return responseJson;

    } on SocketException {
      throw FetchDataException("No Internet Available");
    } on TimeoutException {
      throw FetchDataException("Request timed out");
    }
  }

  static Future<dynamic> postRequestWithFile(
      String url, dynamic body, BuildContext context,
      {bool sendToken = false, String contentType = 'multipart/form-data'}) async {
    String apiUrl = url;
    if (kDebugMode) {
      print("URL: $apiUrl");
      print("BODY: $body");
    }
    var responseJson;
    try {
      String? token;
      if (sendToken) {
        token = await SharedPreferencesService().getString(KeyConstants.accessToken);
      }
      if (contentType == 'multipart/form-data') {
        Future<http.Response> sendMultipart(String targetUrl, {String method = 'POST'}) async {
          var request = http.MultipartRequest(method, Uri.parse(targetUrl));
          request.followRedirects = false; // prevent 302/303 switching to GET
          request.headers.addAll(_buildHeaders(sendToken, token, contentType));
          if (body is Map<String, dynamic>) {
            // Ensure files are added synchronously with await to avoid race conditions
            for (final entry in body.entries) {
              final key = entry.key;
              final value = entry.value;
              if (value == null) {
                continue; // Skip nulls entirely
              }
              if (value is File) {
                final String lower = value.path.toLowerCase();
                final String subtype = lower.endsWith('.png')
                    ? 'png'
                    : (lower.endsWith('.jpg') || lower.endsWith('.jpeg'))
                        ? 'jpeg'
                        : 'octet-stream';
                final contentType = subtype == 'octet-stream'
                    ? null
                    : http_parser.MediaType('image', subtype);
                request.files.add(
                  await http.MultipartFile.fromPath(
                    key,
                    value.path,
                    contentType: contentType,
                  ),
                );
              } else if (value is Iterable<File>) {
                for (final file in value) {
                  final String lower = file.path.toLowerCase();
                  final String subtype = lower.endsWith('.png')
                      ? 'png'
                      : (lower.endsWith('.jpg') || lower.endsWith('.jpeg'))
                          ? 'jpeg'
                          : 'octet-stream';
                  final contentType = subtype == 'octet-stream'
                      ? null
                      : http_parser.MediaType('image', subtype);
                  request.files.add(
                    await http.MultipartFile.fromPath(
                      key,
                      file.path,
                      contentType: contentType,
                    ),
                  );
                }
              } else {
                request.fields[key] = value.toString();
              }
            }
          }
          var streamedResponse = await request.send().timeout(_fileUploadTimeout);
          return http.Response.fromStream(streamedResponse);
        }

        var response = await sendMultipart(apiUrl);
        if (response.isRedirect ||
            response.statusCode == 301 ||
            response.statusCode == 302 ||
            response.statusCode == 303 ||
            response.statusCode == 307 ||
            response.statusCode == 308) {
          final location = response.headers['location'];
          if (location != null) {
            final resolved = Uri.parse(apiUrl).resolve(location).toString();
            response = await sendMultipart(resolved);
          }
        }
        responseJson = _returnListResponse(response, context);
      } else {
        var response = await http
            .post(
              Uri.parse(apiUrl),
              body: jsonEncode(body),
              headers: _buildHeaders(sendToken, token, 'application/json'),
            )
            .timeout(_defaultTimeout);
        responseJson = _returnListResponse(response, context);
      }
      return responseJson;
    } on SocketException {
      throw FetchDataException("No Internet Available");
    } on TimeoutException {
      throw FetchDataException("Request timed out");
    }
  }

  /// Put request with token option.
  static Future<dynamic> putRequestData(
      String url, dynamic body, BuildContext context, {bool sendToken = false}) async {
    String apiUrl = url;
    var responseJson;

    try {
      String? token;
      if (sendToken) {
        token = await SharedPreferencesService().getString(KeyConstants.accessToken);
      }

      // Make the HTTP PUT request
      var response = await http
          .put(
            Uri.parse(apiUrl),
            body: jsonEncode(body),
            headers: sendToken
                ? {
              'Content-type': 'application/json',
              'x-source': 'impactorMobileApp',
              'Authorization': 'Bearer $token',
            }
                : {
              'Content-type': 'application/json',
              'x-source': 'impactorMobileApp',
            },
          )
          .timeout(_defaultTimeout);

      responseJson = _returnListResponse(response, context);
      return responseJson;

    } on SocketException {
      throw FetchDataException("No Internet Available");
    } on TimeoutException {
      throw FetchDataException("Request timed out");
    }
  }

  /// Delete request with token option.
  static Future<dynamic> deleteRequestData(
      String url, BuildContext context, {bool sendToken = false}) async {
    String apiUrl = url;

    if (kDebugMode) {
      printLog("URL: $apiUrl");
    }

    var responseJson;

    try {
      String? token;
      if (sendToken) {
        token = await SharedPreferencesService().getString(KeyConstants.accessToken);
      }

      // Make the HTTP DELETE request
      var response = await http
          .delete(
            Uri.parse(apiUrl),
            headers: sendToken
                ? {
              'Content-type': 'application/json',
              'x-source': 'impactorMobileApp',
              'Authorization': 'Bearer $token',
            }
                : {
              'Content-type': 'application/json',
              'x-source': 'impactorMobileApp',
            },
          )
          .timeout(_defaultTimeout);

      responseJson = _returnListResponse(response, context);
      return responseJson;

    } on SocketException {
      throw FetchDataException("No Internet Available");
    } on TimeoutException {
      throw FetchDataException("Request timed out");
    }
  }

  /// Patch request with token option.
  static Future<dynamic> patchRequestData(
      String url, dynamic body, BuildContext context,
      {bool sendToken = false, String contentType = 'application/json'}) async {
    String apiUrl = url;

    if (kDebugMode) {
      printLog("URL: $apiUrl");
      printLog("BODY: $body");
    }

    var responseJson;
    try {
      String? token;

      if (sendToken) {
        token = await SharedPreferencesService()
            .getString(KeyConstants.accessToken);
      }

      // Make the HTTP PATCH request
      var response = await http
          .patch(
            Uri.parse(apiUrl),
            body: contentType == 'multipart/form-data' ? body : jsonEncode(body),
            headers: sendToken
                ? {
              'Content-Type': contentType,
              'Authorization': 'Bearer $token',
            }
                : {
              'Content-Type': contentType,
            },
          )
          .timeout(_defaultTimeout);

      responseJson = _returnListResponse(response, context);
      return responseJson;
    } on SocketException {
      throw FetchDataException("No Internet Available");
    } on TimeoutException {
      throw FetchDataException("Request timed out");
    }
  }

  /// Helper function to build headers with optional token.
  static Map<String, String> _buildHeaders(bool sendToken, String? token, String contentType) {
    var headers = <String, String>{
      'x-source': 'impactorMobileApp',
    };
    // Let http.MultipartRequest set its own Content-Type with boundary
    if (contentType != 'multipart/form-data') {
      headers['Content-type'] = contentType;
    }

    if (sendToken && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

}

/// Helper function to handle API responses.
dynamic _returnListResponse(http.Response response, BuildContext context) {
  if (kDebugMode) {
    printLog("Response Code: ${response.statusCode}");
    printLog("Response Body: ${response.body}");
  }

  if (response.statusCode == 200 || response.statusCode == 201) {
    var responseJson = json.decode(response.body.toString());
    return responseJson;
  } else {
    if(response.statusCode == 401){
      var responseJson = json.decode(response.body.toString());
      // Safely check for token validation error
      if(responseJson['errors'] != null && 
         responseJson['errors']['code'] == "token_not_valid"){
        SharedPreferencesService()
            .remove(KeyConstants.accessToken);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const GetStartedScreen()),
                (route) => false);
        getx.Get.snackbar(
          'Expire',
          'Your session has expired. Please log in to proceed.',
          colorText: AppColors.whiteTextColor,
          backgroundColor: AppColors.primaryTextColor,
          icon: const Icon(Icons.add_alert, color: AppColors.whiteTextColor),
        );
      }
    } else {
      // Handle server errors (500, etc.) with proper JSON parsing
      try {
        var responseJson = json.decode(response.body.toString());
        // If the server returns a structured error response, use it
        if (responseJson['message'] != null || responseJson['error'] != null) {
          throw ApiException(response.body.toString(), response.statusCode);
        } else {
          throw ApiException(response.body.toString(), response.statusCode);
        }
      } catch (e) {
        // If JSON parsing fails, throw with raw response
        throw ApiException(response.body.toString(), response.statusCode);
      }
    }
  }
}
