import 'package:flutter/material.dart';

class RequestStatusBadge extends StatelessWidget {
  final String status;

  const RequestStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final normalized =
        status.trim().toLowerCase();

    String label;
    IconData icon;

    switch (normalized) {
      case 'searching':
        label = 'Searching';
        icon = Icons.radar;
        break;

      case 'pending':
        label = 'Pending';
        icon = Icons.pending_actions;
        break;

      case 'accepted':
        label = 'Accepted';
        icon = Icons.check_circle_outline;
        break;

      case 'active':
        label = 'Active';
        icon = Icons.directions_walk;
        break;

      case 'completed':
        label = 'Completed';
        icon = Icons.task_alt;
        break;

      case 'cancelled':
      case 'canceled':
        label = 'Cancelled';
        icon = Icons.cancel_outlined;
        break;

      case 'rejected':
        label = 'Rejected';
        icon = Icons.block_outlined;
        break;

      case 'expired':
        label = 'Expired';
        icon = Icons.timer_off_outlined;
        break;

      default:
        label = normalized.isEmpty
            ? 'Unknown'
            : normalized;
        icon = Icons.info_outline;
    }

    final colorScheme =
        Theme.of(context).colorScheme;

    final Color color;

    switch (normalized) {
      case 'searching':
      case 'pending':
        color = colorScheme.tertiary;
        break;

      case 'accepted':
      case 'completed':
        color = colorScheme.primary;
        break;

      case 'active':
        color = colorScheme.secondary;
        break;

      case 'cancelled':
      case 'canceled':
      case 'rejected':
        color = colorScheme.error;
        break;

      default:
        color = colorScheme.outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius:
            BorderRadius.circular(30),
        border: Border.all(
          color: color.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
