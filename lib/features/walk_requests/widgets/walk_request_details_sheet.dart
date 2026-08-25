import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'walk_request_map_preview.dart';
import 'walk_request_status_badge.dart';

class WalkRequestDetailsSheet extends StatelessWidget {
  final String requestId;
  final Map<String, dynamic> data;

  final VoidCallback onAssign;
  final VoidCallback onCancel;

  final Future<void> Function(
    LatLng location,
  ) onOpenMaps;

  const WalkRequestDetailsSheet({
    super.key,
    required this.requestId,
    required this.data,
    required this.onAssign,
    required this.onCancel,
    required this.onOpenMaps,
  });

  // ==========================================================
  // VALUE
  // ==========================================================

  String _value(String key) {
    final value = data[key];

    if (value == null) {
      return '';
    }

    return value.toString();
  }

  // ==========================================================
  // DATE
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

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
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
    final status = _value('status')
        .trim()
        .toLowerCase();

    final location = _location();

    final pending =
        status == 'searching' ||
        status == 'pending';

    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.50,
      maxChildSize: 0.98,
      builder: (
        context,
        controller,
      ) {
        return Material(
          borderRadius:
              const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
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
                  WalkRequestStatusBadge(
                    status: status,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ==================================================
              // OWNER DETAILS
              // ==================================================

              _section(
                context,
                'Owner Details',
                [
                  _detail(
                    'Owner Name',
                    _value('ownerName'),
                  ),
                  _detail(
                    'Owner ID',
                    _value('ownerId'),
                  ),
                  _detail(
                    'Owner Auth UID',
                    _value('ownerAuthUid'),
                  ),
                  _detail(
                    'Sender UID',
                    _value('senderUid'),
                  ),
                  _detail(
                    'Business ID',
                    _value('businessId'),
                  ),
                ],
              ),

              // ==================================================
              // PICKUP LOCATION
              // ==================================================

              _section(
                context,
                'Pickup Location',
                [
                  _detail(
                    'Address',
                    _value('address'),
                  ),
                  if (location != null)
                    _detail(
                      'Latitude',
                      location.latitude
                          .toStringAsFixed(6),
                    ),
                  if (location != null)
                    _detail(
                      'Longitude',
                      location.longitude
                          .toStringAsFixed(6),
                    ),
                ],
              ),

              // ==================================================
              // OPEN STREET MAP
              // ==================================================

              if (location != null)
                WalkRequestMapPreview(
                  location: location,
                  onOpenMaps: () {
                    onOpenMaps(location);
                  },
                ),

              // ==================================================
              // REQUEST DETAILS
              // ==================================================

              _section(
                context,
                'Request Details',
                [
                  _detail(
                    'Request ID',
                    requestId,
                  ),
                  _detail(
                    'Search Type',
                    _value('searchType'),
                  ),
                  _detail(
                    'Search Radius',
                    '${_value('searchRadiusKm')} km',
                  ),
                  _detail(
                    'Location Type',
                    _value('ownerLocationType'),
                  ),
                  _detail(
                    'Sender Role',
                    _value('senderRole'),
                  ),
                  _detail(
                    'Created At',
                    _dateText(data['createdAt']),
                  ),
                  _detail(
                    'Updated At',
                    _dateText(data['updatedAt']),
                  ),
                  _detail(
                    'Accepted At',
                    _dateText(data['acceptedAt']),
                  ),
                  _detail(
                    'Accepted By',
                    _value('acceptedBy'),
                  ),
                ],
              ),

              // ==================================================
              // WALKER DETAILS
              // ==================================================

              _section(
                context,
                'Walker Details',
                [
                  _detail(
                    'Walker Name',
                    _value('walkerName').isEmpty
                        ? 'Not assigned'
                        : _value('walkerName'),
                  ),
                  _detail(
                    'Walker ID',
                    _value('walkerId'),
                  ),
                  _detail(
                    'Walker UID',
                    _value('walkerUid'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

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
              // CANCEL
              // ==================================================

              if (pending ||
                  status == 'accepted' ||
                  status == 'active')
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

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // SECTION
  // ==========================================================

  Widget _section(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color:
                    Theme.of(context)
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
  // DETAIL
  // ==========================================================

  Widget _detail(
    String title,
    String value,
  ) {
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
            child: Text(
              value.isEmpty
                  ? 'Not available'
                  : value,
            ),
          ),
        ],
      ),
    );
  }
}
