import 'package:flutter/material.dart';

class WalkRequestStatusBadge extends StatelessWidget {
  final String status;

  const WalkRequestStatusBadge({
    super.key,
    required this.status,
  });

  String get _displayStatus {
    final value = status.trim();

    if (value.isEmpty) {
      return 'Unknown';
    }

    return value[0].toUpperCase() +
        value.substring(1);
  }

  Color _statusColor(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    switch (status.trim().toLowerCase()) {
      case 'searching':
      case 'pending':
        return colorScheme.tertiary;

      case 'accepted':
        return Colors.green;

      case 'active':
        return colorScheme.primary;

      case 'completed':
        return Colors.blue;

      case 'cancelled':
      case 'canceled':
        return colorScheme.error;

      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color =
        _statusColor(context);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(30),
        color: color.withValues(
          alpha: 0.10,
        ),
      ),
      child: Text(
        _displayStatus,
        style: TextStyle(
          fontSize: 12,
          fontWeight:
              FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
