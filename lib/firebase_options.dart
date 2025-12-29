// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC8unZymKu-BkvITcsji-2GRBp8v59-QPA',
    appId: '1:269730589276:web:361bc1824f8262c19fd499',
    messagingSenderId: '269730589276',
    projectId: 'eventify-ethiopia',
    authDomain: 'eventify-ethiopia.firebaseapp.com',
    storageBucket: 'eventify-ethiopia.appspot.com',
    measurementId: 'G-XLVDSMYQ67',
    // ✅ CORRECT Database URL:
    databaseURL: 'https://eventify-ethiopia-default-rtdb.europe-west1.firebasedatabase.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC8unZymKu-BkvITcsji-2GRBp8v59-QPA',
    appId: '1:269730589276:android:361bc1824f8262c19fd499',
    messagingSenderId: '269730589276',
    projectId: 'eventify-ethiopia',
    storageBucket: 'eventify-ethiopia.appspot.com',
    // ✅ CORRECT Database URL:
    databaseURL: 'https://eventify-ethiopia-default-rtdb.europe-west1.firebasedatabase.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC8unZymKu-BkvITcsji-2GRBp8v59-QPA',
    appId: '1:269730589276:ios:361bc1824f8262c19fd499',
    messagingSenderId: '269730589276',
    projectId: 'eventify-ethiopia',
    storageBucket: 'eventify-ethiopia.appspot.com',
    // ✅ CORRECT Database URL:
    databaseURL: 'https://eventify-ethiopia-default-rtdb.europe-west1.firebasedatabase.app',
    iosBundleId: 'com.eventify.EventifyEthiopia',
    iosClientId: '', // Leave empty if not using Apple Sign-In
  );

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}