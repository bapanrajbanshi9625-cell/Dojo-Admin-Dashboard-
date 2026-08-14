import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFC94A4A);
const Color dojoBlack = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool emailAlerts = true;
  bool liveWalkAlerts = true;
  bool paymentAlerts = true;
  bool maintenanceMode = false;

  String selectedSection = 'General';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 700) {
              return Column(
                children: [
                  _sectionSelector(),
                  const SizedBox(height: 16),
                  _content(),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 210,
                  child: _sectionSelector(),
                ),
                const SizedBox(width: 18),
                Expanded(child: _content()),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoBlack,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Configure your DOJO admin platform',
          style: TextStyle(
            color: dojoGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _sectionSelector() {
    final sections = [
      ('General', Icons.settings_outlined),
      ('Notifications', Icons.notifications_none_outlined),
      ('Security', Icons.security_outlined),
      ('Platform', Icons.tune_outlined),
    ];

    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dojoBorder),
      ),
      child: Column(
        children: sections.map((section) {
          final active = selectedSection == section.$1;

          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(11),
              onTap: () {
                setState(() {
                  selectedSection = section.$1;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFFFEEE9)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  children: [
                    Icon(
                      section.$2,
                      size: 19,
                      color: active ? dojoOrange : dojoGrey,
                    ),
                    const SizedBox(width: 9),
                    Text(
                      section.$1,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: active
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: active ? dojoOrange : dojoBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _content() {
    switch (selectedSection) {
      case 'Notifications':
        return _notificationSettings();
      case 'Security':
        return _securitySettings();
      case 'Platform':
        return _platformSettings();
      default:
        return _generalSettings();
    }
  }

  Widget _generalSettings() {
    return _settingsCard(
      title: 'General Settings',
      icon: Icons.settings_outlined,
      children: [
        _field(
          label: 'Platform Name',
          value: 'DOJO',
          icon: Icons.pets_outlined,
        ),
        const SizedBox(height: 15),
        _field(
          label: 'Support Email',
          value: 'support@dojo.com',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 15),
        _field(
          label: 'Support Phone',
          value: '+91 00000 00000',
          icon: Icons.phone_outlined,
        ),
        const SizedBox(height: 20),
        _saveButton(),
      ],
    );
  }

  Widget _notificationSettings() {
    return _settingsCard(
      title: 'Notification Settings',
      icon: Icons.notifications_none_outlined,
      children: [
        _switchTile(
          title: 'Push Notifications',
          subtitle: 'Receive admin notifications',
          value: notifications,
          onChanged: (value) {
            setState(() {
              notifications = value;
            });
          },
          color: dojoOrange,
          icon: Icons.notifications_none_outlined,
        ),
        _divider(),
        _switchTile(
          title: 'Email Alerts',
          subtitle: 'Receive important alerts by email',
          value: emailAlerts,
          onChanged: (value) {
            setState(() {
              emailAlerts = value;
            });
          },
          color: dojoBlue,
          icon: Icons.email_outlined,
        ),
        _divider(),
        _switchTile(
          title: 'Live Walk Alerts',
          subtitle: 'Notify admins about live walk events',
          value: liveWalkAlerts,
          onChanged: (value) {
            setState(() {
              liveWalkAlerts = value;
            });
          },
          color: dojoGreen,
          icon: Icons.directions_walk_outlined,
        ),
        _divider(),
        _switchTile(
          title: 'Payment Alerts',
          subtitle: 'Notify admins about payment activity',
          value: paymentAlerts,
          onChanged: (value) {
            setState(() {
              paymentAlerts = value;
            });
          },
          color: const Color(0xFF7567A8),
          icon: Icons.payments_outlined,
        ),
      ],
    );
  }

  Widget _securitySettings() {
    return _settingsCard(
      title: 'Security',
      icon: Icons.security_outlined,
      children: [
        _securityTile(
          icon: Icons.lock_outline,
          title: 'Admin Authentication',
          subtitle: 'Firebase Authentication',
          color: dojoBlue,
        ),
        _divider(),
        _securityTile(
          icon: Icons.verified_user_outlined,
          title: 'Two-Step Verification',
          subtitle: 'Recommended for administrator accounts',
          color: dojoGreen,
        ),
        _divider(),
        _securityTile(
          icon: Icons.history,
          title: 'Login Activity',
          subtitle: 'Monitor administrator login activity',
          color: dojoOrange,
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Security settings will connect to Firebase.',
                ),
              ),
            );
          },
          icon: const Icon(Icons.manage_accounts_outlined),
          label: const Text('Manage Security'),
          style: OutlinedButton.styleFrom(
            foregroundColor: dojoOrange,
            side: const BorderSide(color: dojoOrange),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _platformSettings() {
    return _settingsCard(
      title: 'Platform Settings',
      icon: Icons.tune_outlined,
      children: [
        _switchTile(
          title: 'Maintenance Mode',
          subtitle: 'Temporarily restrict user access',
          value: maintenanceMode,
          onChanged: (value) {
            setState(() {
              maintenanceMode = value;
            });
          },
          color: dojoRed,
          icon: Icons.build_outlined,
        ),
        _divider(),
        _securityTile(
          icon: Icons.cloud_outlined,
          title: 'Firebase Backend',
          subtitle: 'Cloud Firestore + Firebase Authentication',
          color: dojoBlue,
        ),
        _divider(),
        _securityTile(
          icon: Icons.location_on_outlined,
          title: 'Live Location',
          subtitle: 'Real-time walker location tracking',
          color: dojoGreen,
        ),
        _divider(),
        _securityTile(
          icon: Icons.payments_outlined,
          title: 'Payments',
          subtitle: 'Payment and payout management',
          color: dojoOrange,
        ),
      ],
    );
  }

  Widget _settingsCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: dojoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEE9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: dojoOrange,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: dojoBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoBorder,
          ),
        ),
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: dojoGrey,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          thumbColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return color;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _securityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: dojoGrey,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right,
          color: dojoGrey,
          size: 20,
        ),
      ],
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 13),
      child: Divider(
        height: 1,
        color: dojoBorder,
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Settings saved successfully.',
              ),
            ),
          );
        },
        icon: const Icon(Icons.save_outlined),
        label: const Text('Save Settings'),
        style: FilledButton.styleFrom(
          backgroundColor: dojoOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 13,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
      ),
    );
  }
}
