import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_login.dart';
import '../screens/admin_shell.dart';

class AdminAuthGuard extends StatelessWidget {
  const AdminAuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = snapshot.data;

        // ========================================================
        // NOT LOGGED IN
        // ========================================================

        if (user == null) {
          return const AdminLogin();
        }

        // ========================================================
        // CHECK ADMIN DOCUMENT
        //
        // Firestore:
        // admins/{Firebase Auth UID}
        // ========================================================

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('admins')
              .doc(user.uid)
              .snapshots(),
          builder: (context, adminSnapshot) {
            if (adminSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            // ====================================================
            // FIRESTORE ERROR
            // ====================================================

            if (adminSnapshot.hasError) {
              return _AccessDeniedScreen(
                message:
                    'Unable to verify your admin account.\n\n'
                    'Firestore permission denied or connection error.',
                error: adminSnapshot.error.toString(),
              );
            }

            final adminDocument = adminSnapshot.data;

            // ====================================================
            // ADMIN DOCUMENT NOT FOUND
            // ====================================================

            if (adminDocument == null || !adminDocument.exists) {
              return const _AccessDeniedScreen(
                message:
                    'No admin account is linked to this Firebase account.',
              );
            }

            final data = adminDocument.data();

            // ====================================================
            // EMPTY ADMIN DOCUMENT
            // ====================================================

            if (data == null) {
              return const _AccessDeniedScreen(
                message: 'Admin account data is unavailable.',
              );
            }

            // ====================================================
            // VERIFY ADMIN UID
            // ====================================================

            final adminUid = data['adminUid'];

            if (adminUid != user.uid) {
              return const _AccessDeniedScreen(
                message:
                    'This admin account is not linked to the signed-in Firebase account.',
              );
            }

            // ====================================================
            // ACTIVE CHECK
            //
            // Firestore:
            // active: true
            // ====================================================

            final active = data['active'] == true;

            if (!active) {
              return const _AccessDeniedScreen(
                message: 'Your admin account is inactive.',
              );
            }

            // ====================================================
            // ROLE CHECK
            //
            // Firestore:
            // role: "superAdmin"
            // ====================================================

            final role = data['role'];

            if (role != 'superAdmin') {
              return _AccessDeniedScreen(
                message:
                    'Your account does not have superAdmin access.\n\n'
                    'Current role: ${role ?? 'not set'}',
              );
            }

            // ====================================================
            // ADMIN VERIFIED
            // ====================================================

            return const AdminShell();
          },
        );
      },
    );
  }
}

// ================================================================
// LOADING SCREEN
// ================================================================

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7F8FA),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD35435),
        ),
      ),
    );
  }
}

// ================================================================
// ACCESS DENIED SCREEN
// ================================================================

class _AccessDeniedScreen extends StatelessWidget {
  final String message;
  final String? error;

  const _AccessDeniedScreen({
    this.message = 'You are not authorized to access DOJO Admin.',
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE7E9ED),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEE9),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFFD35435),
                    size: 30,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Access Denied',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),

                if (error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      error!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                FilledButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD35435),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
