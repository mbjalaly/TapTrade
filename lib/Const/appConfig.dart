import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central configuration class for all environment variables
/// Loads values from .env file using flutter_dotenv
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  /// Initialize the app configuration by loading .env file
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  // ============================================
  // BACKEND API CONFIGURATION
  // ============================================
  
  /// Base URL for the main API
  static String get apiBaseUrl => 
      dotenv.env['API_BASE_URL'] ?? 'https://taptradebackend.pythonanywhere.com/';

  /// Base URL for images
  static String get imageBaseUrl => 
      dotenv.env['IMAGE_BASE_URL'] ?? 'https://taptradebackend.pythonanywhere.com';

  /// Payment API URL (separate service)
  static String get paymentApiUrl => 
      dotenv.env['PAYMENT_API_URL'] ?? 'https://mbjalaly.pythonanywhere.com/api/payment/';

  // ============================================
  // FIREBASE CONFIGURATION
  // ============================================
  
  static String get firebaseApiKey => 
      dotenv.env['FIREBASE_API_KEY'] ?? '';

  static String get firebaseAuthDomain => 
      dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';

  static String get firebaseProjectId => 
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  static String get firebaseStorageBucket => 
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';

  static String get firebaseMessagingSenderId => 
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';

  static String get firebaseAppId => 
      dotenv.env['FIREBASE_APP_ID'] ?? '';

  static String get firebaseMeasurementId => 
      dotenv.env['FIREBASE_MEASUREMENT_ID'] ?? '';

  // ============================================
  // GOOGLE MAPS API
  // ============================================
  
  static String get googleMapsApiKey => 
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  // ============================================
  // APP CONFIGURATION
  // ============================================
  
  static String get appName => 
      dotenv.env['APP_NAME'] ?? 'TapTrade';

  static String get appVersion => 
      dotenv.env['APP_VERSION'] ?? '1.0.0';

  static String get environment => 
      dotenv.env['ENVIRONMENT'] ?? 'production';

  // ============================================
  // HELPER METHODS
  // ============================================
  
  /// Check if running in development mode
  static bool get isDevelopment => environment == 'development';

  /// Check if running in production mode
  static bool get isProduction => environment == 'production';

  /// Print configuration (for debugging - remove in production)
  static void printConfig() {
    print('=== TapTrade Configuration ===');
    print('Environment: $environment');
    print('API Base URL: $apiBaseUrl');
    print('Image Base URL: $imageBaseUrl');
    print('Firebase Project: $firebaseProjectId');
    print('App Version: $appVersion');
    print('==============================');
  }
}

