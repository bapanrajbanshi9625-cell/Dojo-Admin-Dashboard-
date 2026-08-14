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

        // Not logged in
        if (user == null) {
          return const AdminLogin();
        }

        // Check admin document using Firebase Auth UID
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

            if (adminSnapshot.hasError) {
              return _AccessDeniedScreen(
                message:
                    'Unable to verify your admin account.',
              );
            }

            final adminDocument = adminSnapshot.data;

            if (adminDocument == null ||
                !adminDocument.exists) {
              return const _AccessDeniedScreen(
                message:
                    'No admin account is linked to this Firebase account.',
              );
            }

            final data = adminDocument.data();

            if (data == null) {
              return const _AccessDeniedScreen();
            }

            // IMPORTANT:
            // AdminsScreen stores "status": "Active"
            final status =
                data['status']?.toString() ?? 'Inactive';

            if (status != 'Active') {
              return const _AccessDeniedScreen(
                message:
                    'Your admin account is inactive.',
              );
            }

            return const AdminShell();
          },
        );
      },
    );
  }
}

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

class _AccessDeniedScreen extends StatelessWidget {
  final String message;

  const _AccessDeniedScreen({
    this.message =
        'You are not authorized to access DOJO Admin.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 420,
          ),
          margin: const EdgeInsets.all(24),
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
                  borderRadius:
                      BorderRadius.circular(18),
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
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                style: FilledButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFD35435),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
