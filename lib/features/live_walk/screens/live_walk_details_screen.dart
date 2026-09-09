import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/live_walk_admin_service.dart';

class LiveWalkDetailsScreen extends StatelessWidget {
  final String sessionId;

  const LiveWalkDetailsScreen({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text(
          'Live Walk Details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('liveWalkSessions')
            .doc(sessionId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _ErrorView(
              message: snapshot.error.toString(),
            );
          }

          final doc = snapshot.data;

          if (doc == null || !doc.exists) {
            return const _ErrorView(
              message: 'Live walk session not found.',
            );
          }

          final data = doc.data() ?? {};

          return _LiveWalkDetailsBody(
            sessionId: doc.id,
            data: data,
          );
        },
      ),
    );
  }
}

class _LiveWalkDetailsBody extends StatelessWidget {
  final String sessionId;
  final Map<String, dynamic> data;

  const _LiveWalkDetailsBody({
    required this.sessionId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocation = _readLocation(
      data['currentLocation'],
    );

    final startLocation = _readLocation(
      data['startLocation'],
    );

    final routePoints = _readRoute(
      data['routeCoordinates'],
    );

    final status = _string(data['status']);

    final requestId = _firstString(
      data,
      [
        'requestId',
        'walkId',
      ],
    );

    final isActive = status.toLowerCase() == 'active';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _Header(
          sessionId: sessionId,
          status: status,
        ),

        const SizedBox(height: 14),

        _AdminControls(
          sessionId: sessionId,
          requestId: requestId,
          status: status,
        ),

        const SizedBox(height: 14),

        _MapCard(
          currentLocation: currentLocation,
          startLocation: startLocation,
          routePoints: routePoints,
        ),

        const SizedBox(height: 14),

        _StatsCard(
          distanceKm: _double(data['distanceKm']),
          distanceMeters: _double(data['distanceMeters']),
          durationSeconds: _int(
            data['durationSeconds'],
          ),
          elapsedSeconds: _int(
            data['elapsedSeconds'],
          ),
          steps: _int(data['steps']),
          peeCount: _int(data['peeCount']),
          poopCount: _int(data['poopCount']),
        ),

        const SizedBox(height: 14),

        _SectionCard(
          title: 'Owner',
          icon: Icons.person_rounded,
          children: [
            _InfoRow(
              label: 'Name',
              value: _firstString(
                data,
                ['ownerName'],
              ),
            ),
            _InfoRow(
              label: 'Owner ID',
              value: _firstString(
                data,
                ['ownerId'],
              ),
            ),
            _InfoRow(
              label: 'UID',
              value: _firstString(
                data,
                ['ownerUid'],
              ),
            ),
            _InfoRow(
              label: 'Phone',
              value: _firstString(
                data,
                ['ownerPhone'],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _SectionCard(
          title: 'Walker',
          icon: Icons.directions_walk_rounded,
          children: [
            _InfoRow(
              label: 'Name',
              value: _firstString(
                data,
                ['walkerName'],
              ),
            ),
            _InfoRow(
              label: 'Walker ID',
              value: _firstString(
                data,
                ['walkerId'],
              ),
            ),
            _InfoRow(
              label: 'UID',
              value: _firstString(
                data,
                ['walkerUid'],
              ),
            ),
            _InfoRow(
              label: 'Phone',
              value: _firstString(
                data,
                ['walkerPhone'],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _SectionCard(
          title: 'Dog',
          icon: Icons.pets_rounded,
          children: [
            _InfoRow(
              label: 'Dog Name',
              value: _firstString(
                data,
                ['dogName'],
              ),
            ),
            _InfoRow(
              label: 'Breed',
              value: _firstString(
                data,
                ['dogBreed'],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _SectionCard(
          title: 'Session',
          icon: Icons.directions_walk_rounded,
          children: [
            _InfoRow(
              label: 'Session ID',
              value: sessionId,
            ),
            _InfoRow(
              label: 'Request ID',
              value: requestId,
            ),
            _InfoRow(
              label: 'Walk ID',
              value: _firstString(
                data,
                ['walkId'],
              ),
            ),
            _InfoRow(
              label: 'Source',
              value: _firstString(
                data,
                ['source'],
              ),
            ),
            _InfoRow(
              label: 'Started From QR',
              value: _boolText(
                data['startedFromQr'],
              ),
            ),
            _InfoRow(
              label: 'Walk Started',
              value: _boolText(
                data['walkStarted'],
              ),
            ),
            _InfoRow(
              label: 'Tracking Started',
              value: _boolText(
                data['trackingStarted'],
              ),
            ),
            _InfoRow(
              label: 'Tracking Ended',
              value: _boolText(
                data['trackingEnded'],
              ),
            ),
            _InfoRow(
              label: 'Walk Ended',
              value: _boolText(
                data['walkEnded'],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _SectionCard(
          title: 'GPS',
          icon: Icons.gps_fixed_rounded,
          children: [
            _InfoRow(
              label: 'Current Latitude',
              value: _numberText(
                data['currentLat'],
              ),
            ),
            _InfoRow(
              label: 'Current Longitude',
              value: _numberText(
                data['currentLng'],
              ),
            ),
            _InfoRow(
              label: 'GPS Accuracy',
              value: _numberText(
                data['gpsAccuracy'],
              ),
            ),
            _InfoRow(
              label: 'GPS Heading',
              value: _numberText(
                data['gpsHeading'],
              ),
            ),
            _InfoRow(
              label: 'GPS Speed',
              value: _numberText(
                data['gpsSpeed'],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _SectionCard(
          title: 'Timeline',
          icon: Icons.schedule_rounded,
          children: [
            _TimestampRow(
              label: 'Created At',
              value: data['createdAt'],
            ),
            _TimestampRow(
              label: 'Started At',
              value: data['startedAt'],
            ),
            _TimestampRow(
              label: 'GPS Updated At',
              value: data['gpsUpdatedAt'],
            ),
            _TimestampRow(
              label: 'Updated At',
              value: data['updatedAt'],
            ),
            _TimestampRow(
              label: 'Ended At',
              value: data['endedAt'],
            ),
            _TimestampRow(
              label: 'Completed At',
              value: data['completedAt'],
            ),
            _TimestampRow(
              label: 'Cancelled At',
              value: data['cancelledAt'],
            ),
          ],
        ),

        const SizedBox(height: 12),

        _RouteCard(
          points: routePoints,
        ),

        const SizedBox(height: 12),

        _EventsCard(
          events: _list(data['events']),
        ),

        const SizedBox(height: 12),

        _RawDataCard(
          data: data,
        ),

        if (!isActive) const SizedBox(height: 4),
      ],
    );
  }
}

class _AdminControls extends StatelessWidget {
  final String sessionId;
  final String requestId;
  final String status;

  const _AdminControls({
    required this.sessionId,
    required this.requestId,
    required this.status,
  });

  bool get _isActive => status.toLowerCase() == 'active';

  @override
  Widget build(BuildContext context) {
    if (!_isActive) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              status.toLowerCase() == 'completed'
                  ? Icons.check_circle_rounded
                  : Icons.info_rounded,
              color: status.toLowerCase() == 'completed'
                  ? Colors.green
                  : Colors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Session status: ${status.isEmpty ? 'Unknown' : status}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFF6B35).withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.admin_panel_settings_rounded,
                color: Color(0xFFFF6B35),
              ),
              SizedBox(width: 8),
              Text(
                'Admin Controls',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Use these controls only when the customer or walker app cannot complete the walk normally.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _confirmComplete(context);
                    },
                    icon: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Complete Walk',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _confirmCancel(context);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Cancel Walk',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.red,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmComplete(
    BuildContext context,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Complete Walk?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'This will mark the live walk as completed and also update the related walk request.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await _runAction(
      context,
      action: () {
        return LiveWalkAdminService().completeWalk(
          sessionId: sessionId,
          requestId: requestId,
        );
      },
      successMessage: 'Walk completed successfully.',
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Cancel Walk?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'This will cancel the live walk and update the related walk request.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel Walk'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await _runAction(
      context,
      action: () {
        return LiveWalkAdminService().cancelWalk(
          sessionId: sessionId,
          requestId: requestId,
        );
      },
      successMessage: 'Walk cancelled successfully.',
    );
  }

  Future<void> _runAction(
    BuildContext context, {
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await action();

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Action failed: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _Header extends StatelessWidget {
  final String sessionId;
  final String status;

  const _Header({
    required this.sessionId,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final isActive = normalized == 'active';
    final isCompleted = normalized == 'completed';

    final statusColor = isActive
        ? Colors.green
        : isCompleted
            ? Colors.blue
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.directions_walk_rounded,
              color: Color(0xFFFF6B35),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Walk Session',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sessionId,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.isEmpty ? 'UNKNOWN' : status.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  final LatLng? currentLocation;
  final LatLng? startLocation;
  final List<LatLng> routePoints;

  const _MapCard({
    required this.currentLocation,
    required this.startLocation,
    required this.routePoints,
  });

  @override
  Widget build(BuildContext context) {
    final center =
        currentLocation ??
        (routePoints.isNotEmpty ? routePoints.last : null) ??
        startLocation;

    if (center == null) {
      return const _NoMap();
    }

    final markers = <Marker>[];

    if (startLocation != null) {
      markers.add(
        Marker(
          point: startLocation!,
          width: 44,
          height: 44,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.flag_rounded,
              color: Colors.orange,
              size: 25,
            ),
          ),
        ),
      );
    }

    if (currentLocation != null) {
      markers.add(
        Marker(
          point: currentLocation!,
          width: 50,
          height: 50,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_walk_rounded,
              color: Colors.green,
              size: 28,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 340,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.dojo.admin',
          ),
          if (routePoints.length >= 2)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routePoints,
                  strokeWidth: 5,
                  color: Colors.blue,
                ),
              ],
            ),
          MarkerLayer(
            markers: markers,
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final double distanceKm;
  final double distanceMeters;
  final int durationSeconds;
  final int elapsedSeconds;
  final int steps;
  final int peeCount;
  final int poopCount;

  const _StatsCard({
    required this.distanceKm,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.elapsedSeconds,
    required this.steps,
    required this.peeCount,
    required this.poopCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Stat(
                  icon: Icons.route_rounded,
                  label: 'Distance',
                  value: '${distanceKm.toStringAsFixed(2)} km',
                ),
              ),
              Expanded(
                child: _Stat(
                  icon: Icons.timer_rounded,
                  label: 'Duration',
                  value: _duration(durationSeconds > 0
                      ? durationSeconds
                      : elapsedSeconds),
                ),
              ),
              Expanded(
                child: _Stat(
                  icon: Icons.directions_walk_rounded,
                  label: 'Steps',
                  value: '$steps',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  icon: Icons.straighten_rounded,
                  label: 'Meters',
                  value: distanceMeters.toStringAsFixed(0),
                ),
              ),
              Expanded(
                child: _Stat(
                  icon: Icons.water_drop_rounded,
                  label: 'Pee',
                  value: '$peeCount',
                ),
              ),
              Expanded(
                child: _Stat(
                  icon: Icons.circle,
                  label: 'Poop',
                  value: '$poopCount',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 22,
          color: const Color(0xFFFF6B35),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFFF6B35),
                size: 21,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimestampRow extends StatelessWidget {
  final String label;
  final dynamic value;

  const _TimestampRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoRow(
      label: label,
      value: _timestamp(value),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final List<LatLng> points;

  const _RouteCard({
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Route',
      icon: Icons.route_rounded,
      children: [
        _InfoRow(
          label: 'Route Points',
          value: '${points.length}',
        ),
      ],
    );
  }
}

class _EventsCard extends StatelessWidget {
  final List<dynamic> events;

  const _EventsCard({
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const _SectionCard(
        title: 'Events',
        icon: Icons.event_note_rounded,
        children: [
          Text(
            'No events recorded.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      );
    }

    return _SectionCard(
      title: 'Events',
      icon: Icons.event_note_rounded,
      children: [
        ...events.asMap().entries.map(
          (entry) {
            final event = entry.value;

            if (event is Map) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatMap(event),
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${entry.key + 1}. ${event.toString()}',
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RawDataCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _RawDataCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList()
      ..sort(
        (a, b) => a.key.compareTo(b.key),
      );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ExpansionTile(
        leading: const Icon(
          Icons.data_object_rounded,
          color: Color(0xFFFF6B35),
        ),
        title: const Text(
          'Complete Session Data',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '${entries.length} fields',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                ...entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 125,
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _formatAny(entry.value),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoMap extends StatelessWidget {
  const _NoMap();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_rounded,
              size: 40,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Location unavailable',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

String _string(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}

String _firstString(
  Map<String, dynamic> data,
  List<String> keys,
) {
  for (final key in keys) {
    final value = data[key];

    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }

  return '';
}

double _double(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

int _int(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

bool _bool(dynamic value) {
  if (value is bool) {
    return value;
  }

  return value?.toString().toLowerCase() == 'true';
}

String _boolText(dynamic value) {
  return _bool(value) ? 'Yes' : 'No';
}

String _numberText(dynamic value) {
  if (value == null) return '—';

  final number = _double(value);

  if (number == 0) {
    return '0';
  }

  return number.toStringAsFixed(6);
}

LatLng? _readLocation(dynamic value) {
  if (value is GeoPoint) {
    return LatLng(
      value.latitude,
      value.longitude,
    );
  }

  if (value is Map) {
    final lat = _double(
      value['lat'] ?? value['latitude'],
    );

    final lng = _double(
      value['lng'] ?? value['longitude'],
    );

    if (lat == 0 && lng == 0) {
      return null;
    }

    return LatLng(lat, lng);
  }

  return null;
}

List<LatLng> _readRoute(dynamic value) {
  if (value is! List) {
    return [];
  }

  final result = <LatLng>[];

  for (final item in value) {
    final point = _readLocation(item);

    if (point != null) {
      result.add(point);
    }
  }

  return result;
}

List<dynamic> _list(dynamic value) {
  if (value is List) {
    return value;
  }

  return [];
}

String _timestamp(dynamic value) {
  if (value == null) {
    return '—';
  }

  if (value is Timestamp) {
    return _formatDate(value.toDate());
  }

  if (value is DateTime) {
    return _formatDate(value);
  }

  return value.toString();
}

String _formatDate(DateTime date) {
  final local = date.toLocal();

  String two(int value) => value.toString().padLeft(2, '0');

  return '${local.day}/${two(local.month)}/${local.year} '
      '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
}

String _duration(int seconds) {
  if (seconds <= 0) {
    return '0m';
  }

  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final secs = seconds % 60;

  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }

  if (minutes > 0) {
    return '${minutes}m ${secs}s';
  }

  return '${secs}s';
}

String _formatAny(dynamic value) {
  if (value == null) {
    return 'null';
  }

  if (value is Timestamp) {
    return _timestamp(value);
  }

  if (value is GeoPoint) {
    return '${value.latitude}, ${value.longitude}';
  }

  if (value is Map) {
    return _formatMap(value);
  }

  if (value is List) {
    return '[${value.map(_formatAny).join(', ')}]';
  }

  return value.toString();
}

String _formatMap(Map value) {
  return value.entries
      .map(
        (entry) =>
            '${entry.key}: ${_formatAny(entry.value)}',
      )
      .join('\n');
}
