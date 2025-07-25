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
    apiKey: 'AIzaSyAt2nLKOH4YxY70aTZ1qwxUV2hdwNLWJMo',
    appId: '1:426540662257:web:ca195e65993ed6b4215850',
    messagingSenderId: '426540662257',
    projectId: 'weather-app-8dff8',
    authDomain: 'weather-app-8dff8.firebaseapp.com',
    storageBucket: 'weather-app-8dff8.firebasestorage.app',
    measurementId: 'G-MZNZ4WW2R2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCF8G_UezjQVrCnPRFYwl2vXv43-QdRqNo',
    appId: '1:426540662257:android:393bd23926a63b5b215850',
    messagingSenderId: '426540662257',
    projectId: 'weather-app-8dff8',
    storageBucket: 'weather-app-8dff8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC66nVlZRoDuWLSMIoemzCEKwdkY0YsTfk',
    appId: '1:426540662257:ios:f5236a3b7ef634fa215850',
    messagingSenderId: '426540662257',
    projectId: 'weather-app-8dff8',
    storageBucket: 'weather-app-8dff8.firebasestorage.app',
    iosBundleId: 'com.example.myApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC66nVlZRoDuWLSMIoemzCEKwdkY0YsTfk',
    appId: '1:426540662257:ios:f5236a3b7ef634fa215850',
    messagingSenderId: '426540662257',
    projectId: 'weather-app-8dff8',
    storageBucket: 'weather-app-8dff8.firebasestorage.app',
    iosBundleId: 'com.example.myApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAt2nLKOH4YxY70aTZ1qwxUV2hdwNLWJMo',
    appId: '1:426540662257:web:2cd9fa116c1de5d8215850',
    messagingSenderId: '426540662257',
    projectId: 'weather-app-8dff8',
    authDomain: 'weather-app-8dff8.firebaseapp.com',
    storageBucket: 'weather-app-8dff8.firebasestorage.app',
    measurementId: 'G-R9PTM4788V',
  );
}
