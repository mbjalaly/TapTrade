import 'package:flutter/material.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Utills/appColors.dart';

class AppLoadingPopup {
  static bool _isDialogOpen = false;

  static void show([BuildContext? context]) {
    if (_isDialogOpen) return;

    // Get context from navigatorKey if not provided
    final ctx = context ?? navigatorKey.currentState?.overlay?.context;
    if (ctx == null) return;

    _isDialogOpen = true;

    showDialog(
      context: ctx,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const Center(child: _LoadingBox()),
        );
      },
    );
  }

  static void hide([BuildContext? context]) {
    if (!_isDialogOpen) return;

    final ctx = context ?? navigatorKey.currentState?.overlay?.context;
    if (ctx != null) {
      Navigator.of(ctx, rootNavigator: true).pop();
      _isDialogOpen = false;
    }
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
          strokeWidth: 4.0,
        ),
      ),
    );
  }
}
