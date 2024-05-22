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
    apiKey: 'AIzaSyBDsW1SrH87imJTuI4bAUjrM2vxweSfhyk',
    appId: '1:790731274817:web:d2c04c1b92237e936e64c0',
    messagingSenderId: '790731274817',
    projectId: 'doguber-fcm-test',
    authDomain: 'doguber-fcm-test.firebaseapp.com',
    storageBucket: 'doguber-fcm-test.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCmUKSNiZa_yRRBtkwLIqtgNigZV7AMclc',
    appId: '1:790731274817:android:42c857a0234f2fac6e64c0',
    messagingSenderId: '790731274817',
    projectId: 'doguber-fcm-test',
    storageBucket: 'doguber-fcm-test.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCEdM3dvHcbyfsCwXIfZ3dSNgYVWLVEgHI',
    appId: '1:790731274817:ios:a868b5476c6d2d016e64c0',
    messagingSenderId: '790731274817',
    projectId: 'doguber-fcm-test',
    storageBucket: 'doguber-fcm-test.appspot.com',
    iosBundleId: 'com.example.flutterPushBackV2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCEdM3dvHcbyfsCwXIfZ3dSNgYVWLVEgHI',
    appId: '1:790731274817:ios:a868b5476c6d2d016e64c0',
    messagingSenderId: '790731274817',
    projectId: 'doguber-fcm-test',
    storageBucket: 'doguber-fcm-test.appspot.com',
    iosBundleId: 'com.example.flutterPushBackV2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBDsW1SrH87imJTuI4bAUjrM2vxweSfhyk',
    appId: '1:790731274817:web:f4e86544010a74876e64c0',
    messagingSenderId: '790731274817',
    projectId: 'doguber-fcm-test',
    authDomain: 'doguber-fcm-test.firebaseapp.com',
    storageBucket: 'doguber-fcm-test.appspot.com',
  );

}