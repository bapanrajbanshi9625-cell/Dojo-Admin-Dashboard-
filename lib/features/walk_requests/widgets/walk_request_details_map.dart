// File:
// lib/features/walk_requests/widgets/walk_request_details_map.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'walk_request_map_preview.dart';

class WalkRequestDetailsMap extends StatelessWidget {
  const WalkRequestDetailsMap({
    super.key,
    required this.requestId,
    required this.ownerLocation,
    this.walkerLocation,
    this.walkerId,
    this.walkerUid,
    this.walkerName,
    this.onOpenMaps,
  });

  /// Firestore document id from walk_request/{requestId}
  final String requestId;

  /// Owner pickup location.
  final LatLng ownerLocation;

  /// Walker's current/live location.
  ///
  /// This is the latest value already available in the
  /// walk_request document. The preview also listens to the
  /// request document for live updates.
  final LatLng? walkerLocation;

  final String? walkerId;
  final String? walkerUid;
  final String? walkerName;

  final ValueChanged<LatLng>? onOpenMaps;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1EC),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.map_outlined,
                    color: Color(0xFFD35435),
                    size: 21,
                  ),
                ),
                const SizedBox(width: 11),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Location',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Owner pickup & walker location',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            WalkRequestMapPreview(
              requestId: requestId,
              ownerLocation: ownerLocation,
              walkerLocation: walkerLocation,
              walkerId: walkerId,
              walkerUid: walkerUid,
              walkerName: walkerName,
              onOpenMaps: onOpenMaps,
            ),
          ],
        ),
      ),
    );
  }
}
