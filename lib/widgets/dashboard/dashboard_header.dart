import 'package:flutter/material.dart';

import '../../services/admin_profile_service.dart';
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

class _DashboardHeaderState
    extends State<DashboardHeader> {
  final AdminProfileService _profileService =
      AdminProfileService();

  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile =
        await _profileService.getProfile();

    if (!mounted) return;

    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  void _showProfileMenu() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(.25),
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
                  _profileEmail,
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
                  onTap: () async {
                    Navigator.of(context).pop();

                    await _profileService.logout();

                    widget.onLogout?.call();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: orange.withOpacity(.08),
                      borderRadius:
                          BorderRadius.circular(12),
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

  String get _profileName {
    return (_profile?['name'] ??
            _profile?['displayName'] ??
            'Admin')
        .toString();
  }

  String get _profileEmail {
    return (_profile?['email'] ?? '').toString();
  }

  String? get _photoUrl {
    final value = _profile?['photoUrl'];

    if (value == null) return null;

    final text = value.toString().trim();

    return text.isEmpty ? null : text;
  }

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
        color: orange.withOpacity(.10),
        border: Border.all(
          color: orange.withOpacity(.20),
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
                : _profileAvatar(size: 48),
          ),
        ),
      ],
    );
  }
}
