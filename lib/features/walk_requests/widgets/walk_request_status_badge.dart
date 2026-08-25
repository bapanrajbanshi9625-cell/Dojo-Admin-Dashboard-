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
            .split(RegExp(r'[ _-]+'))
            .map(
              (word) => word.isEmpty
                  ? word
                  : '${word[0].toUpperCase()}'
                      '${word.substring(1)}',
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

  Color _color(BuildContext context) {
    final scheme =
        Theme.of(context).colorScheme;

    switch (_normalizedStatus) {
      case 'searching':
      case 'pending':
        return scheme.tertiary;

      case 'accepted':
      case 'completed':
        return scheme.primary;

      case 'active':
        return scheme.secondary;

      case 'cancelled':
      case 'canceled':
      case 'rejected':
        return scheme.error;

      case 'expired':
        return scheme.outline;

      default:
        return scheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color =
        _color(context);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration:
          BoxDecoration(
        color:
            color.withValues(
          alpha: 0.12,
        ),
        borderRadius:
            BorderRadius.circular(
          30,
        ),
        border:
            Border.all(
          color:
              color.withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: 15,
            color: color,
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            _label,
            style:
                TextStyle(
              color: color,
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
