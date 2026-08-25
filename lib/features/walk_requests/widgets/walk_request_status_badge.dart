import 'package:flutter/material.dart';

class WalkRequestStatusBadge extends StatelessWidget {
  final String status;

  const WalkRequestStatusBadge({
    super.key,
    required this.status,
  });

  String _displayStatus() {
    final cleanStatus = status.trim();

    if (cleanStatus.isEmpty) {
      return 'Unknown';
    }

    return cleanStatus[0].toUpperCase() +
        cleanStatus.substring(1);
  }

  Color _backgroundColor(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    switch (status.trim().toLowerCase()) {
      case 'searching':
      case 'pending':
        return colorScheme.primary.withValues(
          alpha: 0.10,
        );

      case 'accepted':
        return Colors.green.withValues(
          alpha: 0.12,
        );

      case 'active':
        return Colors.blue.withValues(
          alpha: 0.12,
        );

      case 'completed':
        return Colors.teal.withValues(
          alpha: 0.12,
        );

      case 'cancelled':
      case 'canceled':
        return Colors.red.withValues(
          alpha: 0.12,
        );

      default:
        return colorScheme.onSurface.withValues(
          alpha: 0.08,
        );
    }
  }

  Color _textColor(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    switch (status.trim().toLowerCase()) {
      case 'searching':
      case 'pending':
        return colorScheme.primary;

      case 'accepted':
        return Colors.green.shade700;

      case 'active':
        return Colors.blue.shade700;

      case 'completed':
        return Colors.teal.shade700;

      case 'cancelled':
      case 'canceled':
        return Colors.red.shade700;

      default:
        return colorScheme.onSurface;
    }
  }

  IconData _icon() {
    switch (status.trim().toLowerCase()) {
      case 'searching':
        return Icons.radar;

      case 'pending':
        return Icons.pending_actions;

      case 'accepted':
        return Icons.check_circle_outline;

      case 'active':
        return Icons.directions_walk;

      case 'completed':
        return Icons.task_alt;

      case 'cancelled':
      case 'canceled':
        return Icons.cancel_outlined;

      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        _textColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor(context),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon(),
            size: 14,
            color: textColor,
          ),

          const SizedBox(width: 5),

          Text(
            _displayStatus(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
