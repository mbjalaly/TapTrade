import 'package:taptrade/Services/logService.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() {
    return 'ApiException: $message (Status Code: $statusCode)';
  }
}

class ApiResponse<T> {
  Status? status;
  T? responseData;
  String? message;

  ApiResponse.loading(this.message) : status = Status.LOADING;
  ApiResponse.completed(this.responseData) : status = Status.COMPLETED;
  ApiResponse.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    printLog("Status : $status \n Message : $message \n Data : $responseData");
    return "Status : $status \n Message : $message \n Data : $responseData";
  }
}

enum Status { LOADING, COMPLETED, ERROR }
