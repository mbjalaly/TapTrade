import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Services/IntegrationServices/chatService.dart';
import 'package:taptrade/Screens/Dashboard/Chat/chatScreen.dart';

import 'package:taptrade/Const/globleKey.dart';

/// Background handler MUST be a top-level or static function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No heavy work here; OS already showed notification if 'notification' exists.
}

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  static const String _matchChannelId = 'high_importance_channel';
  static const String _marketingChannelId = 'marketing_channel';

  static const AndroidNotificationChannel _matchChannel = AndroidNotificationChannel(
    _matchChannelId,
    'High Importance',
    description: 'Important updates like matches',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _marketingChannel = AndroidNotificationChannel(
    _marketingChannelId,
    'Marketing',
    description: 'Occasional promotions and updates',
    importance: Importance.defaultImportance,
  );

  static Future<void> initialize() async {
    // Set background handler before using messaging
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Local notifications init
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: false, 
      requestBadgePermission: false, 
      requestSoundPermission: false
    );
    const InitializationSettings initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final String? payload = response.payload;
        if (payload != null) {
          _handleNavigationFromData(json.decode(payload) as Map<String, dynamic>);
        }
      },
    );

    // Create channels on Android
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_matchChannel);
      await androidPlugin.createNotificationChannel(_marketingChannel);
    }

    // iOS: show banner/sound in foreground
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    // Ask permissions (iOS + Android 13+)
    await requestPermission();

    // Foreground message handling: show local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showForegroundNotification(message);
    });

    // App opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNavigationFromData(message.data);
    });

    // Cold start open
    final RemoteMessage? initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _handleNavigationFromData(initial.data);
    }

    // Get and persist FCM token
    // On iOS simulator, APNs token is unavailable → skip FCM token to avoid crash
    bool canFetchFcmToken = true;
    if (!kIsWeb && Platform.isIOS) {
      final String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      print("🍎 APNs Token: $apnsToken");
      if (apnsToken == null) {
        print("⚠️ APNs Token is NULL - skipping FCM fetch (likely Simulator)");
        canFetchFcmToken = false;
      }
    }

    if (canFetchFcmToken) {
      await fetchAndSaveToken();
    } else {
      print("⏭️ Skipped FCM fetch due to missing APNs token");
    }
  }

  static Future<String?> fetchAndSaveToken() async {
      try {
        final String? token = await FirebaseMessaging.instance.getToken();
        print("🔥 FCM Token fetched: $token");
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(KeyConstants.fcmToken, token);
          print("💾 FCM Token saved to prefs");

          // Trigger listener manually if needed
          return token;
        }

        // Listen for token refreshes
        FirebaseMessaging.instance.onTokenRefresh.listen((String token) async {
          print("🔄 FCM Token refreshed: $token");
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(KeyConstants.fcmToken, token);
          // TODO: Trigger profile update here too if possible
        });
        
        return token;

      } catch (e) {
        print("❌ Error fetching FCM token: $e");
        return null;
      }
  }

  static Future<void> requestPermission() async {
    final NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    // Optionally handle settings.authorizationStatus
  }

  static Future<void> subscribeToMarketing() async {
    await FirebaseMessaging.instance.subscribeToTopic('marketing');
  }

  static Future<void> unsubscribeFromMarketing() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('marketing');
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    final AndroidNotification? android = notification?.android;
    final String type = message.data['type'] ?? 'generic';

    // Check match notification preference (from SettingsController)
    if (type == 'match') {
      final prefs = await SharedPreferences.getInstance();
      final matchNotificationsEnabled = prefs.getBool('PREF_MATCH_NOTIFICATIONS') ?? true;

      if (!matchNotificationsEnabled) {
        print('🔕 Match notification silenced by user preference');
        return; // Silently ignore match notifications if disabled
      }
    }

    // Show in-app snackbar for messages and trades
    if (type == 'message') {
      _showSnackbar(
        title: notification?.title ?? 'New Message',
        message: notification?.body ?? 'You have a new message',
        backgroundColor: const Color(0xFF1976D2), // Blue for messages
      );
    } else if (type == 'trade_completed') {
      _showSnackbar(
        title: notification?.title ?? 'Trade Completed',
        message: notification?.body ?? 'A trade has been completed',
        backgroundColor: const Color(0xFF388E3C), // Green for success
      );
    } else if (type == 'trade_pending') {
      _showSnackbar(
        title: notification?.title ?? 'Confirmation Needed',
        message: notification?.body ?? 'Please confirm trade completion',
        backgroundColor: const Color(0xFFFF6F00), // Orange for pending
      );
    }

    // Determine channel based on type
    String channelId = _marketingChannelId;
    if (type == 'match' || type == 'message' || type == 'trade_completed' || type == 'trade_pending') {
      channelId = _matchChannelId; // Use high-priority channel
    }

    _local.show(
      notification.hashCode,
      notification?.title ?? _titleForType(type),
      notification?.body ?? _bodyForType(type),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId == _matchChannelId ? 'High Importance' : 'Marketing',
          channelDescription: channelId == _matchChannelId ? 'Important updates like matches' : 'Promotions and updates',
          importance: channelId == _matchChannelId ? Importance.high : Importance.defaultImportance,
          priority: channelId == _matchChannelId ? Priority.high : Priority.defaultPriority,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: json.encode(message.data),
    );
  }

  static Future<void> showLocalMatchNotification({
    required int otherProductId,
    required String otherProductTitle,
  }) async {
    final String title = _titleForType('match');
    final String body = 'Match found: $otherProductTitle';
    await _local.show(
      otherProductId, // stable id per product to avoid floods
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _matchChannelId,
          'High Importance',
          channelDescription: 'Important updates like matches',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: json.encode(<String, dynamic>{
        'type': 'match',
        'matchId': otherProductId.toString(),
      }),
    );
  }

  static String _titleForType(String type) {
    switch (type) {
      case 'match':
        return 'It\'s a match!';
      case 'marketing':
        return 'TapTrade';
      default:
        return 'TapTrade';
    }
  }

  static String _bodyForType(String type) {
    switch (type) {
      case 'match':
        return 'Your product has a new match. Tap to view.';
      case 'marketing':
        return 'Check out new deals and offers.';
      default:
        return '';
    }
  }

  static void _handleNavigationFromData(Map<String, dynamic> data) {
    final String? type = data['type'] as String?;
    if (type == null) return;

    if (type == 'match') {
      final String? matchId = data['matchId'] as String?;
      // Replace with your actual route/screen
      navigatorKey.currentState?.pushNamed('/match', arguments: {'matchId': matchId});
    }
    else if (type == 'message') {
      // Navigate to chat screen with specific match
      final String? matchId = data['matchId'] as String?;
      if (matchId != null) {
        _navigateToChat(int.parse(matchId));
      }
    }
    else if (type == 'trade_completed' || type == 'trade_pending') {
      // Navigate to trades/deals screen
      final String? tradeRequestId = data['tradeRequestId'] as String?;
      if (tradeRequestId != null) {
        _navigateToTrade(int.parse(tradeRequestId));
      }
    }
    else if (type == 'marketing') {
      final String? deeplink = data['deeplink'] as String?;
      if (deeplink != null && deeplink.isNotEmpty) {
        navigatorKey.currentState?.pushNamed(deeplink);
      } else {
        navigatorKey.currentState?.pushNamed('/deals');
      }
    }
  }

  /// Navigate to specific chat from notification
  static Future<void> _navigateToChat(int matchId) async {
    try {
      final match = await ChatService.getMatchById(matchId);
      if (match != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(match: match),
          ),
        );
      } else {
        // Match not found, navigate to matches list
        navigatorKey.currentState?.pushNamed('/matches');
      }
    } catch (e) {
      print('Error navigating to chat: $e');
      navigatorKey.currentState?.pushNamed('/matches');
    }
  }

  /// Navigate to specific trade from notification
  static void _navigateToTrade(int tradeRequestId) {
    // Navigate to deals screen with trade request highlighted
    navigatorKey.currentState?.pushNamed(
      '/deals',
      arguments: {'highlightTradeId': tradeRequestId},
    );
  }

  // Existing in-app snack helpers kept for convenience
  static void info({required String title, required String message}) {
    _showSnackbar(title: title, message: message, backgroundColor: Colors.black87);
  }

  static void success({required String title, required String message}) {
    _showSnackbar(title: title, message: message, backgroundColor: const Color(0xFF1B5E20));
  }

  static void error({required String title, required String message}) {
    _showSnackbar(title: title, message: message, backgroundColor: const Color(0xFFB71C1C));
  }

  static void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }
}

