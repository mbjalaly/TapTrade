import 'package:flutter/foundation.dart';

const kLOG_TAG = "[Tap Trade App]";
const kLOG_ENABLE = true;

printLog(dynamic data) {
  if (kLOG_ENABLE) {
    print("$kLOG_TAG: ${data.toString()}");
  }
}