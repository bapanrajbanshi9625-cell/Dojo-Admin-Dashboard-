import 'package:flutter/material.dart';

import '../models/walk_request_model.dart';

class WalkRequestCard extends StatelessWidget {
  const WalkRequestCard({
    super.key,
    required this.request,
    required this.onView,
  });

  final WalkRequestModel request;
  final VoidCallback onView;

  Color _statusColor() {
    switch (request.status.toLowerCase()) {
      case 'accepted':
        return Colors.green;

      case 'completed':
        return Colors.blue;

      case 'cancelled':
        return Colors.red;

      case 'searching':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              children: [
                const Icon(
                  Icons.directions_walk_outlined,
                  color: Colors.orange,
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    request.requestId.isEmpty
                        ? request.documentId
                        : request.requestId,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.status.isEmpty
                        ? '-'
                        : request.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ==================================================
            // OWNER
            // ==================================================

            _infoRow(
              Icons.person_outline,
              'Owner',
              request.ownerName.isEmpty
                  ? '-'
                  : request.ownerName,
            ),

            _infoRow(
              Icons.badge_outlined,
              'Owner ID',
              request.ownerId.isEmpty
                  ? '-'
                  : request.ownerId,
            ),

            _infoRow(
              Icons.location_on_outlined,
              'Address',
              request.address.isEmpty
                  ? '-'
                  : request.address,
            ),

            // ==================================================
            // WALKER
            // ==================================================

            _infoRow(
              Icons.directions_walk_outlined,
              'Walker',
              request.walkerName?.isNotEmpty == true
                  ? request.walkerName!
                  : request.walkerId.isEmpty
                      ? 'Not assigned'
                      : request.walkerId,
            ),

            const SizedBox(height: 12),

            // ==================================================
            // FOOTER
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Radius: ${request.searchRadiusKm.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ),

                TextButton.icon(
                  onPressed: onView,
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 17,
                  ),
                  label: const Text('View'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 17,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
