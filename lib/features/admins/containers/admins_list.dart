import 'package:flutter/material.dart';

import '../models/admin_data.dart';
import 'admin_card.dart';

class AdminsList extends StatelessWidget {
  final List<AdminData> admins;
  final ValueChanged<AdminData> onView;

  const AdminsList({
    super.key,
    required this.admins,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    if (admins.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: const Color(0xFFE7E9ED),
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.admin_panel_settings_outlined,
              size: 42,
              color: Color(0xFF9CA3AF),
            ),
            SizedBox(height: 12),
            Text(
              'No admins found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'There are no administrators matching this filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: admins.map((admin) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AdminCard(
            admin: admin,
            onView: () => onView(admin),
          ),
        );
      }).toList(),
    );
  }
}
