// File:
// lib/features/walk_requests/widgets/walk_request_details_location.dart

import 'package:flutter/material.dart';

class WalkRequestDetailsLocation extends StatelessWidget {
  const WalkRequestDetailsLocation({
    super.key,
    required this.address,
    required this.hasLocation,
    required this.onOpenMaps,
  });

  final String address;
  final bool hasLocation;
  final VoidCallback? onOpenMaps;

  static const Color orange = Color(0xFFD35435);
  static const Color blue = Color(0xFF2563EB);
  static const Color dark = Color(0xFF0F172A);
  static const Color background = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);
  static const Color white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Pickup Location',
      icon: Icons.location_on_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: orange,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(
                      color: dark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onOpenMaps != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: hasLocation
                  ? onOpenMaps
                  : null,
              icon: const Icon(
                Icons.map_outlined,
              ),
              label: const Text(
                'Open in Maps',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: blue,
                side: const BorderSide(
                  color: border,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  static const Color blue = Color(0xFF2563EB);
  static const Color dark = Color(0xFF0F172A);
  static const Color white = Colors.white;
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: blue,
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: dark,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
