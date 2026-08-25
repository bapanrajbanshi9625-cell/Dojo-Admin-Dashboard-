import 'package:flutter/material.dart';

class RequestStatusBadge extends StatelessWidget {
  final String status;

  const RequestStatusBadge({
    super.key,
    required this.status,
  });

  String get _normalizedStatus {
    return status.trim().toLowerCase();
  }

  String get _label {
    switch (_normalizedStatus) {
      case 'searching':
        return 'Searching';

      case 'pending':
        return 'Pending';

      case 'accepted':
        return 'Accepted';

      case 'active':
        return 'Active';

      case 'completed':
        return 'Completed';

      case 'cancelled':
        return 'Cancelled';

      case 'canceled':
        return 'Cancelled';

      case 'rejected':
        return 'Rejected';

      case 'expired':
        return 'Expired';

      default:
        if (_normalizedStatus.isEmpty) {
          return 'Unknown';
        }

        return _normalizedStatus
            .split('_')
            .map(
              (word) => word.isEmpty
                  ? ''
                  : '${word[0].toUpperCase()}${word.substring(1)}',
            )
            .join(' ');
    }
  }

  IconData get _icon {
    switch (_normalizedStatus) {
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

      case 'rejected':
        return Icons.block_outlined;

      case 'expired':
        return Icons.timer_off_outlined;

      default:
        return Icons.info_outline;
    }
  }

  Color _foregroundColor(BuildContext context) {
    switch (_normalizedStatus) {
      case 'searching':
      case 'pending':
        return Colors.orange.shade800;

      case 'accepted':
        return Colors.green.shade700;

      case 'active':
        return Colors.blue.shade700;

      case 'completed':
        return Colors.teal.shade700;

      case 'cancelled':
      case 'canceled':
      case 'rejected':
        return Colors.red.shade700;

      case 'expired':
        return Colors.grey.shade700;

      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _backgroundColor(BuildContext context) {
    switch (_normalizedStatus) {
      case 'searching':
      case 'pending':
        return Colors.orange.withValues(alpha: 0.12);

      case 'accepted':
        return Colors.green.withValues(alpha: 0.12);

      case 'active':
        return Colors.blue.withValues(alpha: 0.12);

      case 'completed':
        return Colors.teal.withValues(alpha: 0.12);

      case 'cancelled':
      case 'canceled':
      case 'rejected':
        return Colors.red.withValues(alpha: 0.12);

      case 'expired':
        return Colors.grey.withValues(alpha: 0.12);

      default:
        return Theme.of(context)
            .colorScheme
            .primary
            .withValues(alpha: 0.10);
    }
  }

  @override
  Widget build(BuildContext context) {
    final foreground = _foregroundColor(context);
    final background = _backgroundColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: foreground.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: 15,
            color: foreground,
          ),
          const SizedBox(width: 5),
          Text(
            _label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
