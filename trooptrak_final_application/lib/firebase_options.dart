// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCaE7uRgNPv_Oix9h_a1OzcqdKI0PdnnLA',
    appId: '1:951642527853:web:a0566449dff11a67be8764',
    messagingSenderId: '951642527853',
    projectId: 'trooptrak-54337',
    authDomain: 'trooptrak-54337.firebaseapp.com',
    storageBucket: 'trooptrak-54337.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDV8KZJveSmHU3D8lWWiguVyaoHfd5OulE',
    appId: '1:951642527853:android:e176495b9f204332be8764',
    messagingSenderId: '951642527853',
    projectId: 'trooptrak-54337',
    storageBucket: 'trooptrak-54337.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyALUTq8vTVds34Y45AQrr8YedeFNaWR56M',
    appId: '1:951642527853:ios:4382b5cdffd0ce30be8764',
    messagingSenderId: '951642527853',
    projectId: 'trooptrak-54337',
    storageBucket: 'trooptrak-54337.appspot.com',
    iosBundleId: 'com.example.trooptrakFinalApplication',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyALUTq8vTVds34Y45AQrr8YedeFNaWR56M',
    appId: '1:951642527853:ios:4382b5cdffd0ce30be8764',
    messagingSenderId: '951642527853',
    projectId: 'trooptrak-54337',
    storageBucket: 'trooptrak-54337.appspot.com',
    iosBundleId: 'com.example.trooptrakFinalApplication',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCaE7uRgNPv_Oix9h_a1OzcqdKI0PdnnLA',
    appId: '1:951642527853:web:3023ea0425aefe61be8764',
    messagingSenderId: '951642527853',
    projectId: 'trooptrak-54337',
    authDomain: 'trooptrak-54337.firebaseapp.com',
    storageBucket: 'trooptrak-54337.appspot.com',
  );
}
