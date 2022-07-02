// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCuE8YicktAy95Nk71iBvSOwP2c5SGNa-g',
    appId: '1:56442446408:web:e90ad42bc4c47df4e3ae7d',
    messagingSenderId: '56442446408',
    projectId: 'ani-capstone',
    authDomain: 'ani-capstone.firebaseapp.com',
    storageBucket: 'ani-capstone.appspot.com',
    measurementId: 'G-H0KYE8RJEJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAwLVbO3AP3KnCwjmU0tbfB7anVLUzfYns',
    appId: '1:56442446408:android:c0323e0eb0d7fa37e3ae7d',
    messagingSenderId: '56442446408',
    projectId: 'ani-capstone',
    storageBucket: 'ani-capstone.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDYT5cZempJuvWRJvx7nptqylu0N3hDDM8',
    appId: '1:56442446408:ios:0ac021c915b8d466e3ae7d',
    messagingSenderId: '56442446408',
    projectId: 'ani-capstone',
    storageBucket: 'ani-capstone.appspot.com',
    iosClientId: '56442446408-ek9cshlu9hddvjs1ggvmp3rda7bcbg5a.apps.googleusercontent.com',
    iosBundleId: 'com.example.aniCapstone',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDYT5cZempJuvWRJvx7nptqylu0N3hDDM8',
    appId: '1:56442446408:ios:0ac021c915b8d466e3ae7d',
    messagingSenderId: '56442446408',
    projectId: 'ani-capstone',
    storageBucket: 'ani-capstone.appspot.com',
    iosClientId: '56442446408-ek9cshlu9hddvjs1ggvmp3rda7bcbg5a.apps.googleusercontent.com',
    iosBundleId: 'com.example.aniCapstone',
  );
}
