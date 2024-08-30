import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseConf {
  // Android
  static String get androidApiKey =>
      dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '';
  static String get androidAppId => dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '';
  static String get androidMessagingSenderId =>
      dotenv.env['FIREBASE_ANDROID_MESSAGING_SENDER_ID'] ?? '';
  static String get androidProjectId =>
      dotenv.env['FIREBASE_ANDROID_PROJECT_ID'] ?? '';
  static String get androidStorageBucket =>
      dotenv.env['FIREBASE_ANDROID_STORAGE_BUCKET'] ?? '';

  // iOS
  static String get iosApiKey => dotenv.env['FIREBASE_IOS_API_KEY'] ?? '';
  static String get iosAppId => dotenv.env['FIREBASE_IOS_APP_ID'] ?? '';
  static String get iosMessagingSenderId =>
      dotenv.env['FIREBASE_IOS_MESSAGING_SENDER_ID'] ?? '';
  static String get iosProjectId => dotenv.env['FIREBASE_IOS_PROJECT_ID'] ?? '';
  static String get iosStorageBucket =>
      dotenv.env['FIREBASE_IOS_STORAGE_BUCKET'] ?? '';
  static String get iosClientId => dotenv.env['FIREBASE_IOS_CLIENT_ID'] ?? '';
  static String get iosBundleId => dotenv.env['FIREBASE_IOS_BUNDLE_ID'] ?? '';
}
