// File:
// lib/features/walk_requests/widgets/walk_request_details_header.dart

import 'package:flutter/material.dart';

class WalkRequestDetailsHeader extends StatelessWidget {
  const WalkRequestDetailsHeader({
    super.key,
    required this.requestId,
    required this.status,
    required this.onCopy,
  });

  final String requestId;
  final String status;
  final VoidCallback onCopy;

  static const Color orange = Color(0xFFD35435);
  static const Color blue = Color(0xFF2563EB);
  static const Color green = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color white = Colors.white;

  Color _statusColor() {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'assigned':
      case 'active':
      case 'started':
      case 'in_progress':
      case 'completed':
        return green;

      case 'cancelled':
      case 'canceled':
      case 'rejected':
        return danger;

      default:
        return blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: border,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _iconBox(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _titleBlock(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusBadge(
                    status: status,
                    color: statusColor,
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              _iconBox(),
              const SizedBox(width: 14),
              Expanded(
                child: _titleBlock(),
              ),
              const SizedBox(width: 10),
              _StatusBadge(
                status: status,
                color: statusColor,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _iconBox() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: orange.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.receipt_long_rounded,
        color: orange,
      ),
    );
  }

  Widget _titleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Walk Request',
          style: TextStyle(
            color: dark,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: onCopy,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    requestId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.copy_rounded,
                  size: 15,
                  color: grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.color,
  });

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
