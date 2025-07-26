import 'dart:convert';

class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([this._message, this._prefix]);

  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

// class UnauthorisedException extends AppException {
//   UnauthorisedException([message]) : super(message, "Unauthorised: ");
// }

class InvalidInputException extends AppException {
  InvalidInputException([String? message]) : super(message, "Invalid Input: ");
}

class RequestNotFoundException extends AppException {
  RequestNotFoundException([message]) : super(message, "Request Not Found");
}

class UnautorizationException extends AppException {
  UnautorizationException([message]) : super(message, "Un-authorized User");
}

class InternalServerException extends AppException {
  InternalServerException([message]) : super(message, "Internal Server Error");
}

class ServerNotFoundException extends AppException {
  ServerNotFoundException([message]) : super(message, "Server Not Found");
}

class UnauthorisedException implements Exception {
  // String message;
  // bool success;
  // bool isVerified;
  String rawJson; // Store the raw JSON response

  UnauthorisedException({
    // required this.message,
    // required this.success,
    // required this.isVerified,
    required this.rawJson,
  });

  factory UnauthorisedException.fromJson(Map<String, dynamic> json) {
    return UnauthorisedException(
      // message: json['message'],
      // success: json['success'],
      // isVerified: json['isVerified'],
      rawJson: jsonEncode(json), // Store the raw JSON as a string
    );
  }

  @override
  String toString() {
    return 'JSON: $rawJson';
  }
}
