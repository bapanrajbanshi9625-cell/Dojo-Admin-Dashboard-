import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFC94A4A);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBlack = Color(0xFF263238);

class StatusBadge extends StatelessWidget {
  final String status;
  final Color? color;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.status,
    this.color,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            status,
            style: TextStyle(
              color: badgeColor,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String value) {
    switch (value.toLowerCase()) {
      case 'active':
      case 'online':
      case 'available':
      case 'completed':
      case 'approved':
      case 'paid':
      case 'success':
        return dojoGreen;

      case 'pending':
      case 'waiting':
      case 'processing':
        return dojoOrange;

      case 'cancelled':
      case 'rejected':
      case 'failed':
      case 'offline':
        return dojoRed;

      case 'scheduled':
      case 'upcoming':
        return dojoBlue;

      default:
        return dojoGrey;
    }
  }
}
