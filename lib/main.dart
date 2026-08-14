import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'auth/admin_auth_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const DojoAdminApp());
}

class DojoAdminApp extends StatelessWidget {
  const DojoAdminApp({super.key});

  static const orange = Color(0xFFD35435);
  static const dark = Color(0xFF263238);
  static const blue = Color(0xFF3F6FA5);
  static const green = Color(0xFF3F8F68);
  static const grey = Color(0xFF6B7280);
  static const background = Color(0xFFF7F8FA);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DOJO Admin',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        fontFamily: 'Roboto',

        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          brightness: Brightness.light,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          foregroundColor: dark,
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
            side: BorderSide(
              color: Color(0xFFE7E9ED),
            ),
          ),
        ),
      ),

      home: const AdminAuthGuard(),
    );
  }
}
