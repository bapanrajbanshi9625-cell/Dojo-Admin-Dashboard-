// File:
// lib/features/walk_requests/widgets/walk_request_details_actions.dart

import 'package:flutter/material.dart';

class WalkRequestDetailsActions extends StatelessWidget {
  const WalkRequestDetailsActions({
    super.key,
    required this.isPending,
    required this.hasWalker,
    this.onAssign,
    this.onCancel,
  });

  final bool isPending;
  final bool hasWalker;
  final VoidCallback? onAssign;
  final VoidCallback? onCancel;

  static const Color blue = Color(0xFF2563EB);
  static const Color danger = Color(0xFFDC2626);
  static const Color dark = Color(0xFF0F172A);
  static const Color white = Colors.white;
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    if (onAssign == null && onCancel == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Actions',
            style: TextStyle(
              color: dark,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),

          if (onAssign != null)
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: onAssign,
                icon: Icon(
                  hasWalker
                      ? Icons.swap_horiz_rounded
                      : Icons.person_add_alt_1_rounded,
                ),
                label: Text(
                  hasWalker
                      ? 'Change Walker'
                      : 'Assign Walker',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  foregroundColor: white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          if (onAssign != null &&
              onCancel != null &&
              isPending)
            const SizedBox(height: 10),

          if (onCancel != null && isPending)
            SizedBox(
              height: 46,
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(
                  Icons.cancel_outlined,
                ),
                label: const Text(
                  'Cancel Request',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: danger,
                  side: const BorderSide(
                    color: danger,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
