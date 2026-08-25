import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'walk_request_map_preview.dart';

class WalkRequestDetailsSheet extends StatelessWidget {
  final String requestId;
  final Map<String, dynamic> data;

  final VoidCallback onAssign;
  final VoidCallback onCancel;

  final Future<void> Function(LatLng location) onOpenMaps;

  const WalkRequestDetailsSheet({
    super.key,
    required this.requestId,
    required this.data,
    required this.onAssign,
    required this.onCancel,
    required this.onOpenMaps,
  });

  // ==========================================================
  // VALUE HELPER
  // ==========================================================

  String _value(String key) {
    final value = data[key];

    if (value == null) {
      return '';
    }

    return value.toString();
  }

  // ==========================================================
  // STATUS
  // ==========================================================

  String _status() {
    return _value('status').trim().toLowerCase();
  }

  String _displayStatus() {
    final status = _status();

    if (status.isEmpty) {
      return 'Unknown';
    }

    return status[0].toUpperCase() + status.substring(1);
  }

  // ==========================================================
  // TIMESTAMP
  // ==========================================================

  DateTime? _date(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  String _dateText(dynamic value) {
    final date = _date(value);

    if (date == null) {
      return 'Not available';
    }

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '$hour:$minute';
  }

  // ==========================================================
  // LOCATION
  // ==========================================================

  LatLng? _location() {
    final value = data['ownerLocation'];

    if (value is GeoPoint) {
      return LatLng(
        value.latitude,
        value.longitude,
      );
    }

    return null;
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final status = _status();

    final location = _location();

    final pending =
        status == 'searching' ||
        status == 'pending';

    final canCancel =
        pending ||
        status == 'accepted' ||
        status == 'active';

    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.50,
      maxChildSize: 0.98,
      expand: false,
      builder: (
        context,
        scrollController,
      ) {
        return Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              30,
            ),
            children: [
              // ==================================================
              // HANDLE
              // ==================================================

              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // HEADER
              // ==================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Text(
                      'Walk Request Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _StatusBadge(
                    status: _displayStatus(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ==================================================
              // OWNER DETAILS
              // ==================================================

              _buildSection(
                context,
                title: 'Owner Details',
                icon: Icons.person_outline,
                children: [
                  _buildDetail(
                    'Owner Name',
                    _value('ownerName'),
                  ),
                  _buildDetail(
                    'Owner ID',
                    _value('ownerId'),
                  ),
                  _buildDetail(
                    'Owner Auth UID',
                    _value('ownerAuthUid'),
                  ),
                  _buildDetail(
                    'Sender UID',
                    _value('senderUid'),
                  ),
                  _buildDetail(
                    'Business ID',
                    _value('businessId'),
                  ),
                ],
              ),

              // ==================================================
              // PICKUP LOCATION
              // ==================================================

              _buildSection(
                context,
                title: 'Pickup Location',
                icon: Icons.location_on_outlined,
                children: [
                  _buildDetail(
                    'Address',
                    _value('address'),
                  ),
                  _buildDetail(
                    'Location Type',
                    _value('ownerLocationType'),
                  ),
                  if (location != null)
                    _buildDetail(
                      'Latitude',
                      location.latitude
                          .toStringAsFixed(6),
                    ),
                  if (location != null)
                    _buildDetail(
                      'Longitude',
                      location.longitude
                          .toStringAsFixed(6),
                    ),
                ],
              ),

              // ==================================================
              // OPEN STREET MAP
              // ==================================================

              if (location != null) ...[
                const SizedBox(height: 2),

                WalkRequestMapPreview(
                  location: location,
                  onOpenMaps: () {
                    onOpenMaps(location);
                  },
                ),
              ],

              // ==================================================
              // REQUEST DETAILS
              // ==================================================

              _buildSection(
                context,
                title: 'Request Details',
                icon: Icons.receipt_long_outlined,
                children: [
                  _buildDetail(
                    'Request ID',
                    requestId,
                  ),
                  _buildDetail(
                    'Status',
                    _displayStatus(),
                  ),
                  _buildDetail(
                    'Search Type',
                    _value('searchType'),
                  ),
                  _buildDetail(
                    'Search Radius',
                    _formatRadius(),
                  ),
                  _buildDetail(
                    'Sender Role',
                    _value('senderRole'),
                  ),
                  _buildDetail(
                    'Created At',
                    _dateText(
                      data['createdAt'],
                    ),
                  ),
                  _buildDetail(
                    'Updated At',
                    _dateText(
                      data['updatedAt'],
                    ),
                  ),
                  _buildDetail(
                    'Accepted At',
                    _dateText(
                      data['acceptedAt'],
                    ),
                  ),
                  _buildDetail(
                    'Accepted By',
                    _value('acceptedBy'),
                  ),
                ],
              ),

              // ==================================================
              // WALKER DETAILS
              // ==================================================

              _buildSection(
                context,
                title: 'Walker Details',
                icon: Icons.directions_walk,
                children: [
                  _buildDetail(
                    'Walker Name',
                    _value('walkerName').isEmpty
                        ? 'Not assigned'
                        : _value('walkerName'),
                  ),
                  _buildDetail(
                    'Walker ID',
                    _value('walkerId'),
                  ),
                  _buildDetail(
                    'Walker UID',
                    _value('walkerUid'),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // ==================================================
              // ASSIGN WALKER
              // ==================================================

              if (pending)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onAssign,
                    icon: const Icon(
                      Icons.person_add_alt_1,
                    ),
                    label: const Text(
                      'Assign Walker',
                    ),
                  ),
                ),

              // ==================================================
              // CANCEL REQUEST
              // ==================================================

              if (canCancel) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(
                      Icons.cancel_outlined,
                    ),
                    label: const Text(
                      'Cancel Request',
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // SEARCH RADIUS
  // ==========================================================

  String _formatRadius() {
    final value = data['searchRadiusKm'];

    if (value == null) {
      return 'Not available';
    }

    if (value is num) {
      return '${value.toStringAsFixed(1)} km';
    }

    final parsed = double.tryParse(
      value.toString(),
    );

    if (parsed != null) {
      return '${parsed.toStringAsFixed(1)} km';
    }

    return value.toString();
  }

  // ==========================================================
  // SECTION
  // ==========================================================

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context)
                    .dividerColor,
              ),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DETAIL ROW
  // ==========================================================

  Widget _buildDetail(
    String title,
    String value,
  ) {
    final displayValue =
        value.trim().isEmpty
            ? 'Not available'
            : value;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              displayValue,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STATUS BADGE
// ============================================================

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(30),
        color: colorScheme.primary
            .withValues(alpha: 0.10),
      ),
      child: Text(
        status.isEmpty ? 'Unknown' : status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
