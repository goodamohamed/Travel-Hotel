// ═══════════════════════════════════════════════════════════════════
//  firebase_config.dart
//  Replace the placeholder values below with your real Firebase
//  project credentials from the Firebase Console.
//
//  Steps:
//  1. Go to https://console.firebase.google.com
//  2. Create a project (or open existing one)
//  3. Add an Android/iOS app
//  4. Copy the config values into this file
//  5. For Android: place google-services.json in android/app/
//  6. For iOS: place GoogleService-Info.plist in ios/Runner/
// ═══════════════════════════════════════════════════════════════════

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  // ── Replace these with YOUR Firebase project values ──────────────
  static const String apiKey = 'YOUR_API_KEY';
  static const String authDomain = 'YOUR_PROJECT_ID.firebaseapp.com';
  static const String projectId = 'YOUR_PROJECT_ID';
  static const String storageBucket = 'YOUR_PROJECT_ID.appspot.com';
  static const String messagingSenderId = 'YOUR_MESSAGING_SENDER_ID';
  static const String appId = 'YOUR_APP_ID';
  static const String measurementId = 'YOUR_MEASUREMENT_ID'; // optional

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS: return ios;
      default: return web;
    }
  }

  // ── Web ──────────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: apiKey,
    authDomain: authDomain,
    projectId: projectId,
    storageBucket: storageBucket,
    messagingSenderId: messagingSenderId,
    appId: appId,
    measurementId: measurementId,
  );

  // ── Android ───────────────────────────────────────────────────────
  // You can also use google-services.json instead of manual config.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: apiKey,
    projectId: projectId,
    storageBucket: storageBucket,
    messagingSenderId: messagingSenderId,
    appId: appId,
  );

  // ── iOS ───────────────────────────────────────────────────────────
  // You can also use GoogleService-Info.plist instead of manual config.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: apiKey,
    projectId: projectId,
    storageBucket: storageBucket,
    messagingSenderId: messagingSenderId,
    appId: appId,
    iosBundleId: 'com.yourcompany.travelmate',
  );
}
