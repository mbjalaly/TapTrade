import UIKit
import Flutter
import GoogleMaps
import FirebaseCore
import FirebaseAuth

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyBlORCThQTEVjuRtGK9SzXh-gMMk5MRRo4")
    GeneratedPluginRegistrant.register(with: self)
    
    // Register for remote notifications (required for Phone Auth)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      application.registerForRemoteNotifications()
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle URL for Firebase Auth reCAPTCHA (required for phone auth on iOS)
  override func application(_ app: UIApplication,
                           open url: URL,
                           options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    // Check if Firebase Auth can handle the URL (for reCAPTCHA)
    if Auth.auth().canHandle(url) {
      return true
    }
    // Let Flutter handle other URLs
    return super.application(app, open: url, options: options)
  }
  
  // Handle URL schemes for iOS 8 and below (if needed)
  override func application(_ application: UIApplication,
                           open url: URL,
                           sourceApplication: String?,
                           annotation: Any) -> Bool {
    if Auth.auth().canHandle(url) {
      return true
    }
    return super.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
  }
  
  // Handle remote notification registration for Phone Auth
  override func application(_ application: UIApplication,
                           didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Set APNs token with proper type for phone authentication
    // Firebase Auth automatically detects the token type
    // Use .unknown for automatic detection (works for both debug and release)
    Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  // Handle APNs token registration failures
  override func application(_ application: UIApplication,
                           didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("[AppDelegate] Failed to register for remote notifications: \(error.localizedDescription)")
    // Phone auth will fall back to reCAPTCHA if APNs fails
  }
  
  // Handle remote notification for Phone Auth verification
  override func application(_ application: UIApplication,
                           didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                           fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if Auth.auth().canHandleNotification(userInfo) {
      completionHandler(.noData)
      return
    }
    super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
  }
}
