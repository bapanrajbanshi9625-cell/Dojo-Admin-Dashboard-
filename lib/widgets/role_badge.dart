import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBlack = Color(0xFF263238);

class RoleBadge extends StatelessWidget {
  final String role;
  final bool compact;

  const RoleBadge({
    super.key,
    required this.role,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(role);
    final icon = _roleIcon(role);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: compact ? 13 : 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            _displayRole(role),
            style: TextStyle(
              color: color,
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Color _roleColor(String value) {
    switch (value.toLowerCase()) {
      case 'owner':
        return dojoBlue;
      case 'walker':
        return dojoOrange;
      case 'admin':
      case 'super admin':
        return dojoGreen;
      case 'support':
        return dojoGrey;
      default:
        return dojoGrey;
    }
  }

  IconData _roleIcon(String value) {
    switch (value.toLowerCase()) {
      case 'owner':
        return Icons.person_outline;
      case 'walker':
        return Icons.directions_walk_outlined;
      case 'admin':
      case 'super admin':
        return Icons.admin_panel_settings_outlined;
      case 'support':
        return Icons.support_agent_outlined;
      default:
        return Icons.person_outline;
    }
  }

  String _displayRole(String value) {
    if (value.trim().isEmpty) {
      return 'User';
    }

    return value
        .trim()
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
