// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Default [FirebaseOptions] for use with your Firebase apps.

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(_unsupportedMsg);
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        //throw UnsupportedError(_unsupportedMsg);
        return macos;
      case TargetPlatform.fuchsia:
        throw UnsupportedError(_unsupportedMsg);
      case TargetPlatform.linux:
        throw UnsupportedError(_unsupportedMsg);
      case TargetPlatform.windows:
        throw UnsupportedError(_unsupportedMsg);
    }
  }

  static const _unsupportedMsg = 'DefaultFirebaseOptions are not supported for this platform.';

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
  );

  static const FirebaseOptions android = FirebaseOptions(
      apiKey: 'AIzaSyBlNJe8TBRihnRhGmnar1lMVZlq6zGFm_s',
      appId: '1:1007682182703:android:e3bfc60d10d3cd4b8270da',
      messagingSenderId: '1007682182703',
      projectId: 'mastermechat',
    );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCHDSuVx4Y2BmNMEhZzrJqoPyIfavlIpm4',
    appId: '1:1007682182703:ios:c4743b97444c8b758270da',
    messagingSenderId: '1007682182703',
    projectId: 'mastermechat',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
  );
}