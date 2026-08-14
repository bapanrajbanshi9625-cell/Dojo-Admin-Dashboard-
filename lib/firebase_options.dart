import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase configuration has not been generated yet. '
      'Run FlutterFire CLI to generate firebase_options.dart.',
    );
  }
}
