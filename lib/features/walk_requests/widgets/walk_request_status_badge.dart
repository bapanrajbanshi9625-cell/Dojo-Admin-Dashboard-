import 'package:flutter/material.dart';

class RequestStatusBadge extends StatelessWidget {
  final String status;

  const RequestStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final cleanStatus = status.trim().toLowerCase();

    String text;
    IconData icon;
    Color color;

    switch (cleanStatus) {
      case 'searching':
      case 'pending':
        text = 'Pending';
        icon = Icons.pending_actions;
        color = Colors.orange;
        break;

      case 'accepted':
        text = 'Accepted';
        icon = Icons.check_circle_outline;
        color = Colors.blue;
        break;

      case 'active':
        text = 'Active';
        icon = Icons.directions_walk;
        color = Colors.green;
        break;

      case 'completed':
        text = 'Completed';
        icon = Icons.task_alt;
        color = Colors.teal;
        break;

      case 'cancelled':
      case 'canceled':
        text = 'Cancelled';
        icon = Icons.cancel_outlined;
        color = Colors.red;
        break;

      default:
        text = cleanStatus.isEmpty
            ? 'Unknown'
            : cleanStatus[0].toUpperCase() +
                cleanStatus.substring(1);
        icon = Icons.help_outline;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
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
            text,
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
