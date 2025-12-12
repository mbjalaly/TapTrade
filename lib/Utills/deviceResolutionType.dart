import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DeviceTypeHelper {
  /// Detects if device is a tablet (iPad / Android tablet)
  static bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;

    // Quick Android tablet check: logical shortestSide >= 600
    if (Platform.isAndroid) {
      return shortestSide >= 600;
    }

    // iOS iPad check: use platform detection
    if (Platform.isIOS) {
      // UIKit-based check (iPad reports as tablet)
      final uiKit = defaultTargetPlatform;
      return uiKit == TargetPlatform.iOS || shortestSide >= 600;
    }

    // Web/Desktop fallback

    return shortestSide >= 600;
  }

  /// Detects if device is a phone (iPhone / Android phone)
  static bool isPhone(BuildContext context) {
    return !isTablet(context);
  }

  /// Returns "Phone" or "Tablet" as a string
  static String getDeviceType(BuildContext context) {
    return isTablet(context) ? "Tablet" : "Phone";
  }

}
