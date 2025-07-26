import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  /// Get request with optional token.
  static Future<dynamic> getRequestData(
      String url, BuildContext context, {bool useToken = false}) async {
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

      // Make the HTTP GET request
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

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

      // Make the HTTP POST request
      var response = await http.post(
        Uri.parse(apiUrl),
        body: contentType == 'multipart/form-data' ? body : jsonEncode(body),
        headers: _buildHeaders(sendToken, token, contentType),
      );

      responseJson = _returnListResponse(response, context);
      return responseJson;

    } on SocketException {
      throw FetchDataException("No Internet Available");
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
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
        request.headers.addAll(_buildHeaders(sendToken, token, contentType));
        if (body is Map<String, dynamic>) {
          body.forEach((key, value) async {
            if (value is File) {
              request.files.add(await http.MultipartFile.fromPath(key, value.path));
            } else {
              request.fields[key] = value.toString();
            }
          });
        }
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        responseJson = _returnListResponse(response, context);
      } else {
        var response = await http.post(
          Uri.parse(apiUrl),
          body: jsonEncode(body),
          headers: _buildHeaders(sendToken, token, 'application/json'),
        );
        responseJson = _returnListResponse(response, context);
      }
      return responseJson;
    } on SocketException {
      throw FetchDataException("No Internet Available");
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
      var response = await http.put(
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
      );

      responseJson = _returnListResponse(response, context);
      return responseJson;

    } on SocketException {
      throw FetchDataException("No Internet Available");
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
      var response = await http.delete(
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
      );

      responseJson = _returnListResponse(response, context);
      return responseJson;

    } on SocketException {
      throw FetchDataException("No Internet Available");
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
      var response = await http.patch(
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
      );

      responseJson = _returnListResponse(response, context);
      return responseJson;
    } on SocketException {
      throw FetchDataException("No Internet Available");
    }
  }

  /// Helper function to build headers with optional token.
  static Map<String, String> _buildHeaders(bool sendToken, String? token, String contentType) {
    var headers = {
      'Content-type': contentType,
      'x-source': 'impactorMobileApp',
    };

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
      if(responseJson['errors']['code'] == "token_not_valid"){
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
    }else{
      throw ApiException(response.body.toString(), response.statusCode);
    }
  }
}
