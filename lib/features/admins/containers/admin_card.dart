import 'package:flutter/material.dart';

import '../helpers/admin_colors.dart';
import '../models/admin_data.dart';

class AdminCard extends StatelessWidget {
  final AdminData admin;
  final VoidCallback onView;

  const AdminCard({
    super.key,
    required this.admin,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final active = admin.status == 'Active';
    final statusColor = active ? dojoGreen : dojoRed;
    final role = roleColor(admin.role);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _mobile(
              statusColor,
              role,
            );
          }

          return _desktop(
            statusColor,
            role,
          );
        },
      ),
    );
  }

  Widget _desktop(
    Color statusColor,
    Color role,
  ) {
    return Row(
      children: [
        _avatar(),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: _info(),
        ),
        Expanded(
          child: _roleChip(role),
        ),
        _statusChip(statusColor),
        const SizedBox(width: 14),
        _viewButton(),
      ],
    );
  }

  Widget _mobile(
    Color statusColor,
    Color role,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _avatar(),
            const SizedBox(width: 12),
            Expanded(child: _info()),
          ],
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _roleChip(role),
            _statusChip(statusColor),
            Text(
              'Last active: ${admin.lastActive}',
              style: const TextStyle(
                fontSize: 10,
                color: dojoGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: _viewButton(),
        ),
      ],
    );
  }

  Widget _avatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEE9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.person_outline,
        color: dojoOrange,
        size: 27,
      ),
    );
  }

  Widget _info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          admin.name.isEmpty ? '-' : admin.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          admin.email.isEmpty ? '-' : admin.email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Last active: ${admin.lastActive}',
          style: const TextStyle(
            fontSize: 10,
            color: dojoGrey,
          ),
        ),
      ],
    );
  }

  Widget _roleChip(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        admin.role,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  Widget _statusChip(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 7,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            admin.status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewButton() {
    return OutlinedButton.icon(
      onPressed: onView,
      icon: const Icon(
        Icons.visibility_outlined,
        size: 17,
      ),
      label: const Text('View'),
      style: OutlinedButton.styleFrom(
        foregroundColor: dojoOrange,
        side: const BorderSide(
          color: dojoOrange,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 11,
        ),
      ),
    );
  }
}
