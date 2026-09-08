// File:
// lib/features/walk_requests/widgets/walk_request_details_map.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/walk_request_map_preview.dart';

class WalkRequestDetailsMap extends StatelessWidget {
  const WalkRequestDetailsMap({
    super.key,
    required this.ownerLocation,
    this.walkerId,
    this.walkerUid,
    this.walkerName,
    this.onOpenMaps,
  });

  final LatLng? ownerLocation;
  final String? walkerId;
  final String? walkerUid;
  final String? walkerName;
  final VoidCallback? onOpenMaps;

  static const Color blue = Color(0xFF2563EB);
  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);
  static const Color white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Map',
      icon: Icons.map_rounded,
      child: SizedBox(
        height: 360,
        child: ownerLocation != null
            ? WalkRequestMapPreview(
                ownerLocation: ownerLocation!,
                walkerId: walkerId,
                walkerUid: walkerUid,
                walkerName: walkerName,
                onOpenMaps: onOpenMaps,
              )
            : const _NoLocationMap(),
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

class _NoLocationMap extends StatelessWidget {
  const _NoLocationMap();

  static const Color grey = Color(0xFF64748B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: border,
        ),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off_outlined,
                size: 34,
                color: grey,
              ),
              SizedBox(height: 10),
              Text(
                'Location coordinates not available',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
