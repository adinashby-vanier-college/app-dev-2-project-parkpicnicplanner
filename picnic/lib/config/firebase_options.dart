import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    //TODO: CONFIGURE WITH APPROPRIATE SETTING INFORMATION
    apiKey: 'AIzaSyDNwQWBfjBkdrqKG8ToUZ8BOIkEdmqE0HQ',
    appId: '1:268015225293:android:93917c99fc1424ca2a5c84',
    messagingSenderId: '268015225293',
    projectId: 'parkpicnicplanner',
    storageBucket: 'parkpicnicplanner.firebasestorage.app',
  );

}
