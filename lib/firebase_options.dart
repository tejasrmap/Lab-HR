import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  // Lecturer / Class Project Details (Placeholder for lab configuration)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA-EXAMPLE-CLASSROOM-API-KEY-4207',
    appId: '1:1234567890:web:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'net4207-stock-inventory',
    storageBucket: 'net4207-stock-inventory.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA-EXAMPLE-CLASSROOM-API-KEY-4207',
    appId: '1:1234567890:android:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'net4207-stock-inventory',
    storageBucket: 'net4207-stock-inventory.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA-EXAMPLE-CLASSROOM-API-KEY-4207',
    appId: '1:1234567890:ios:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'net4207-stock-inventory',
    storageBucket: 'net4207-stock-inventory.appspot.com',
    iosBundleId: 'com.example.stockInventoryApp',
  );
}
