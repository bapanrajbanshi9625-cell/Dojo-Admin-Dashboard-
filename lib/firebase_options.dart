import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyBKGx8iof7xv0h666Tdm7I0sddJIZ3ti44',
      authDomain: 'dojo-platform-a5dc8.firebaseapp.com',
      databaseURL:
          'https://dojo-platform-a5dc8-default-rtdb.asia-southeast1.firebasedatabase.app',
      projectId: 'dojo-platform-a5dc8',
      storageBucket: 'dojo-platform-a5dc8.firebasestorage.app',
      messagingSenderId: '719463503810',
      appId: '1:719463503810:web:bd2c9f06df631e8200a85b',
      measurementId: 'G-56Z1BRCL0Q',
    );
  }
}
