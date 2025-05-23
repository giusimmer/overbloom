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
    apiKey: 'AIzaSyARjDAZKwi5ho9_mzzKyxn5bJcck8o3gzQ',
    appId: '1:912783622753:web:ab767f20f489b37a2d2020',
    messagingSenderId: '912783622753',
    projectId: 'overbloom-35f23',
    authDomain: 'overbloom-35f23.firebaseapp.com',
    storageBucket: 'overbloom-35f23.firebasestorage.app',
    measurementId: 'G-5PKMV2R4P2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDEDL9D2kBCoRlJqcuZNCvRiU7HH6qsZDI',
    appId: '1:912783622753:android:545806eddcf0157f2d2020',
    messagingSenderId: '912783622753',
    projectId: 'overbloom-35f23',
    storageBucket: 'overbloom-35f23.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAXejDGpBjcPA16EsFxKBa8ZULszP7ZMnw',
    appId: '1:912783622753:ios:d52f156371cb92802d2020',
    messagingSenderId: '912783622753',
    projectId: 'overbloom-35f23',
    storageBucket: 'overbloom-35f23.firebasestorage.app',
    iosBundleId: 'com.example.overbloom',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAXejDGpBjcPA16EsFxKBa8ZULszP7ZMnw',
    appId: '1:912783622753:ios:d52f156371cb92802d2020',
    messagingSenderId: '912783622753',
    projectId: 'overbloom-35f23',
    storageBucket: 'overbloom-35f23.firebasestorage.app',
    iosBundleId: 'com.example.overbloom',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyARjDAZKwi5ho9_mzzKyxn5bJcck8o3gzQ',
    appId: '1:912783622753:web:c7fd3216d15e2fa32d2020',
    messagingSenderId: '912783622753',
    projectId: 'overbloom-35f23',
    authDomain: 'overbloom-35f23.firebaseapp.com',
    storageBucket: 'overbloom-35f23.firebasestorage.app',
    measurementId: 'G-W2JFDJ6328',
  );
}
