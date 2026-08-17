
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCTb060iJKZ9mQdcMQ04bTFWm5OxkmZPPE',
    appId: '1:113065192457:web:c974aad575259a2c891cd8',
    messagingSenderId: '113065192457',
    projectId: 'enterpriseapp-6aa77',
    authDomain: 'enterpriseapp-6aa77.firebaseapp.com',
    storageBucket: 'enterpriseapp-6aa77.firebasestorage.app',
    measurementId: 'G-S165T2P0DE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCgioQO5qRROFUm49xNw17MDhnxhwQYvmE',
    appId: '1:113065192457:android:4aac596329cb0913891cd8',
    messagingSenderId: '113065192457',
    projectId: 'enterpriseapp-6aa77',
    storageBucket: 'enterpriseapp-6aa77.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB9RRFZXS5oPQiCQh3xFA5NCpRK86RUTJ0',
    appId: '1:113065192457:ios:292385871808c3be891cd8',
    messagingSenderId: '113065192457',
    projectId: 'enterpriseapp-6aa77',
    storageBucket: 'enterpriseapp-6aa77.firebasestorage.app',
    iosClientId: '113065192457-sc5jbsdt2fi7sic6513858on0u953tk9.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApplication',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB9RRFZXS5oPQiCQh3xFA5NCpRK86RUTJ0',
    appId: '1:113065192457:ios:292385871808c3be891cd8',
    messagingSenderId: '113065192457',
    projectId: 'enterpriseapp-6aa77',
    storageBucket: 'enterpriseapp-6aa77.firebasestorage.app',
    iosClientId: '113065192457-sc5jbsdt2fi7sic6513858on0u953tk9.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApplication',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCTb060iJKZ9mQdcMQ04bTFWm5OxkmZPPE',
    appId: '1:113065192457:web:c4b5155ab4d85e51891cd8',
    messagingSenderId: '113065192457',
    projectId: 'enterpriseapp-6aa77',
    authDomain: 'enterpriseapp-6aa77.firebaseapp.com',
    storageBucket: 'enterpriseapp-6aa77.firebasestorage.app',
    measurementId: 'G-Z01JRPC8XR',
  );
}
