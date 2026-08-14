import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'dashboard_components.dart';

class DashboardHeader extends StatefulWidget {
  final VoidCallback? onLogout;

  const DashboardHeader({
    super.key,
    this.onLogout,
  });

  @override
  State<DashboardHeader> createState() =>
      _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ============================================================
  // LOAD ADMIN PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _profile = null;
          _loading = false;
        });

        return;
      }

      final doc = await _firestore
          .collection('admins')
          .doc(user.uid)
          .get();

      Map<String, dynamic> profile = {};

      if (doc.exists) {
        profile = doc.data() ?? {};
      }

      // Firebase Auth data fallback
      profile['email'] ??= user.email;
      profile['displayName'] ??= user.displayName;
      profile['photoUrl'] ??= user.photoURL;
      profile['uid'] ??= user.uid;

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Dashboard admin profile error: $e');

      final user = _auth.currentUser;

      if (!mounted) return;

      setState(() {
        _profile = {
          'uid': user?.uid,
          'email': user?.email,
          'displayName': user?.displayName,
          'photoUrl': user?.photoURL,
        };

        _loading = false;
      });
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    Navigator.of(context).pop();

    try {
      await _auth.signOut();

      widget.onLogout?.call();
    } catch (e) {
      debugPrint('Admin logout error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout failed. Please try again.'),
        ),
      );
    }
  }

  // ============================================================
  // PROFILE MENU
  // ============================================================

  void _showProfileMenu() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .25),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _profileAvatar(
                  size: 82,
                ),

                const SizedBox(height: 14),

                Text(
                  _profileName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: dark,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _profileEmail.isEmpty
                      ? 'Admin account'
                      : _profileEmail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: grey,
                  ),
                ),

                const SizedBox(height: 20),

                const Divider(),

                const SizedBox(height: 5),

                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _logout,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: orange.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: orange,
                          size: 21,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: orange,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PROFILE DATA
  // ============================================================

  String get _profileName {
    final name =
        _profile?['name'] ??
        _profile?['displayName'] ??
        'Admin';

    final text = name.toString().trim();

    return text.isEmpty ? 'Admin' : text;
  }

  String get _profileEmail {
    final email = _profile?['email'];

    if (email == null) return '';

    return email.toString().trim();
  }

  String? get _photoUrl {
    final value =
        _profile?['photoUrl'] ??
        _profile?['photoURL'] ??
        _profile?['profileImage'] ??
        _profile?['imageUrl'];

    if (value == null) return null;

    final text = value.toString().trim();

    return text.isEmpty ? null : text;
  }

  // ============================================================
  // PROFILE AVATAR
  // ============================================================

  Widget _profileAvatar({
    required double size,
  }) {
    final photo = _photoUrl;

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: orange.withValues(alpha: .10),
        border: Border.all(
          color: orange.withValues(alpha: .20),
          width: 2,
        ),
      ),
      child: photo != null
          ? Image.network(
              photo,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.person,
                  color: orange,
                  size: 40,
                );
              },
            )
          : const Icon(
              Icons.person,
              color: orange,
              size: 40,
            ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  color: dark,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Complete overview of the DOJO platform',
                style: TextStyle(
                  color: grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: _showProfileMenu,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: _loading
                ? const CircleAvatar(
                    radius: 23,
                    backgroundColor: Color(0xFFEDEFF2),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: orange,
                      ),
                    ),
                  )
                : _profileAvatar(
                    size: 48,
                  ),
          ),
        ),
      ],
    );
  }
}
