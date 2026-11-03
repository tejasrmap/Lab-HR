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
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyACz865t21e8fOhLZHrvRiFWCt3WAT7w70',
    appId: '1:593013781266:web:bed12984f926d3089179cb',
    messagingSenderId: '593013781266',
    projectId: 'stock-inventory-lab-f4a7c',
    authDomain: 'stock-inventory-lab-f4a7c.firebaseapp.com',
    storageBucket: 'stock-inventory-lab-f4a7c.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyACz865t21e8fOhLZHrvRiFWCt3WAT7w70',
    appId: '1:593013781266:web:bed12984f926d3089179cb',
    messagingSenderId: '593013781266',
    projectId: 'stock-inventory-lab-f4a7c',
    storageBucket: 'stock-inventory-lab-f4a7c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyACz865t21e8fOhLZHrvRiFWCt3WAT7w70',
    appId: '1:593013781266:web:bed12984f926d3089179cb',
    messagingSenderId: '593013781266',
    projectId: 'stock-inventory-lab-f4a7c',
    storageBucket: 'stock-inventory-lab-f4a7c.firebasestorage.app',
    iosBundleId: 'com.example.stockInventoryApp',
  );
}
