// File:
// lib/features/live_walk/screens/live_walk_details_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/live_walk_admin_service.dart';
import '../services/live_walk_invoice_service.dart';
import '../widgets/live_walk_invoice_screen.dart';

class LiveWalkDetailsScreen extends StatelessWidget {
  final String sessionId;

  const LiveWalkDetailsScreen({
    super.key,
    required this.sessionId,
  });

  static const _orange = Color(0xFFFF6B13);
  static const _background = Color(0xFFF5F8F7);
  static const _text = Color(0xFF1C3136);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
        titleSpacing: 16,
        title: const Text(
          'Live Walk Details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('liveWalkSessions')
            .doc(sessionId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: _orange,
              ),
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

          return _LiveWalkDetailsBody(
            sessionId: doc.id,
            data: doc.data() ?? {},
          );
        },
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* ERROR VIEW                                                                 */
/* -------------------------------------------------------------------------- */

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
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxWidth: 520,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE0EBE9),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFE45555),
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to Load Live Walk',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C3136),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF667B7D),
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                ),
                label: const Text(
                  'Go Back',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* MAIN BODY                                                                  */
/* -------------------------------------------------------------------------- */

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

    final status = _string(
      data['status'],
    );

    final requestId = _firstString(
      data,
      ['requestId'],
    );

    final walkerUid = _firstString(
      data,
      ['walkerUid'],
    );

    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadWalkerData(walkerUid),
      builder: (context, walkerSnapshot) {
        final walkerData = <String, dynamic>{
          ...data,
          ...?walkerSnapshot.data,
        };

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            12,
            12,
            12,
            28,
          ),
          children: [
            _Header(
              sessionId: sessionId,
              requestId: requestId,
              status: status,
              data: data,
            ),
            const SizedBox(height: 10),
            _MapCard(
              currentLocation: currentLocation,
              startLocation: startLocation,
              routePoints: routePoints,
            ),
            const SizedBox(height: 10),
            _StatsCard(
              distanceKm: _double(
                data['distanceKm'],
              ),
              distanceMeters: _double(
                data['distanceMeters'],
              ),
              durationSeconds: _int(
                data['durationSeconds'],
              ),
              elapsedSeconds: _int(
                data['elapsedSeconds'],
              ),
              steps: _int(
                data['steps'],
              ),
              peeCount: _int(
                data['peeCount'],
              ),
              poopCount: _int(
                data['poopCount'],
              ),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 700;

                final owner = _PersonCard(
                  title: 'Owner',
                  icon: Icons.person_rounded,
                  name: _firstString(
                    data,
                    ['ownerName'],
                  ),
                  idLabel: 'Owner ID',
                  id: _firstString(
                    data,
                    ['ownerId'],
                  ),
                  uid: _firstString(
                    data,
                    ['ownerUid'],
                  ),
                  phone: _firstString(
                    data,
                    ['ownerPhone'],
                  ),
                );

                final walker = _PersonCard(
                  title: 'Walker',
                  icon: Icons.directions_walk_rounded,
                  name: _firstString(
                    walkerData,
                    [
                      'walkerName',
                      'name',
                      'fullName',
                    ],
                  ),
                  idLabel: 'Walker ID',
                  id: _firstString(
                    walkerData,
                    [
                      'walkerId',
                      'id',
                    ],
                  ),
                  uid: _firstString(
                    data,
                    ['walkerUid'],
                  ),
                  phone: _firstString(
                    walkerData,
                    [
                      'walkerPhone',
                      'phone',
                      'phoneNumber',
                      'mobileNumber',
                    ],
                  ),
                );

                if (wide) {
                  return Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: owner,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: walker,
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    owner,
                    const SizedBox(height: 10),
                    walker,
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            _DogCard(
              name: _firstString(
                data,
                ['dogName'],
              ),
              breed: _firstString(
                data,
                ['dogBreed'],
              ),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 700;

                final sessionCard = _CompactExpansionCard(
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
                );

                final gpsCard = _CompactExpansionCard(
                  title: 'GPS',
                  icon: Icons.gps_fixed_rounded,
                  children: [
                    _InfoRow(
                      label: 'Latitude',
                      value: _numberText(
                        data['currentLat'],
                      ),
                    ),
                    _InfoRow(
                      label: 'Longitude',
                      value: _numberText(
                        data['currentLng'],
                      ),
                    ),
                    _InfoRow(
                      label: 'Accuracy',
                      value: _numberText(
                        data['gpsAccuracy'],
                      ),
                    ),
                    _InfoRow(
                      label: 'Heading',
                      value: _numberText(
                        data['gpsHeading'],
                      ),
                    ),
                    _InfoRow(
                      label: 'Speed',
                      value: _numberText(
                        data['gpsSpeed'],
                      ),
                    ),
                  ],
                );

                if (wide) {
                  return Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: sessionCard,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: gpsCard,
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    sessionCard,
                    const SizedBox(height: 10),
                    gpsCard,
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            _TimelineCard(
              data: data,
            ),
            const SizedBox(height: 10),
            _RouteCard(
              points: routePoints,
            ),
            const SizedBox(height: 10),
            _EventsCard(
              events: _list(
                data['events'],
              ),
            ),
          ],
        );
      },
    );
  }
}

/* -------------------------------------------------------------------------- */
/* HEADER                                                                     */
/* -------------------------------------------------------------------------- */

class _Header extends StatelessWidget {
  final String sessionId;
  final String requestId;
  final String status;
  final Map<String, dynamic> data;

  const _Header({
    required this.sessionId,
    required this.requestId,
    required this.status,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final active = normalized == 'active';

    final completed =
        normalized == 'completed' ||
        normalized == 'complete';

    final statusColor = active
        ? Colors.green
        : completed
            ? Colors.blue
            : Colors.red;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        13,
        12,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0EBE9),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;

          final identity = Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_walk_rounded,
                  color: Color(0xFFFF6B13),
                  size: 23,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LIVE WALK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Session • ${_shortId(sessionId)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF667B7D),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(
                status: status,
                color: statusColor,
              ),
            ],
          );

          final actions = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _InvoiceButton(
                sessionId: sessionId,
                requestId: requestId,
                data: data,
              ),
              if (active) ...[
                const SizedBox(width: 6),
                _HeaderActionButton(
                  label: 'Complete',
                  icon: Icons.check_rounded,
                  color: Colors.green,
                  filled: true,
                  onTap: () {
                    _confirmComplete(
                      context,
                      sessionId,
                      requestId,
                    );
                  },
                ),
                const SizedBox(width: 6),
                _HeaderActionButton(
                  label: 'Cancel',
                  icon: Icons.close_rounded,
                  color: Colors.red,
                  filled: false,
                  onTap: () {
                    _confirmCancel(
                      context,
                      sessionId,
                      requestId,
                    );
                  },
                ),
              ],
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                identity,
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: actions,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: identity,
              ),
              const SizedBox(width: 12),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status.isEmpty
                ? 'UNKNOWN'
                : status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* INVOICE BUTTON                                                             */
/* -------------------------------------------------------------------------- */

class _InvoiceButton extends StatelessWidget {
  final String sessionId;
  final String requestId;
  final Map<String, dynamic> data;

  const _InvoiceButton({
    required this.sessionId,
    required this.requestId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Invoice',
      offset: const Offset(0, 42),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (value) async {
        if (value == 'view') {
          _showInvoice(
            context,
            sessionId,
            requestId,
            data,
          );
        } else if (value == 'download') {
          await _downloadInvoice(
            context,
            sessionId,
            requestId,
            data,
          );
        } else if (value == 'share') {
          await _shareInvoice(
            context,
            sessionId,
            requestId,
            data,
          );
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 19,
                color: Color(0xFFFF6B13),
              ),
              SizedBox(width: 10),
              Text('View Invoice'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'download',
          child: Row(
            children: [
              Icon(
                Icons.download_rounded,
                size: 19,
              ),
              SizedBox(width: 10),
              Text('Download PDF'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(
                Icons.share_rounded,
                size: 19,
              ),
              SizedBox(width: 10),
              Text('Share Invoice'),
            ],
          ),
        ),
      ],
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3EA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFFF6B13).withValues(
              alpha: .18,
            ),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 17,
              color: Color(0xFFFF6B13),
            ),
            SizedBox(width: 5),
            Text(
              'Invoice',
              style: TextStyle(
                color: Color(0xFFFF6B13),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Color(0xFFFF6B13),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: filled
          ? ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(
                icon,
                size: 16,
              ),
              label: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(
                icon,
                size: 16,
              ),
              label: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(
                  color: color.withValues(
                    alpha: .45,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* MAP                                                                        */
/* -------------------------------------------------------------------------- */

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
        (routePoints.isNotEmpty
            ? routePoints.last
            : null) ??
        startLocation;

    if (center == null) {
      return const _NoMap();
    }

    final markers = <Marker>[];

    if (startLocation != null) {
      markers.add(
        Marker(
          point: startLocation!,
          width: 38,
          height: 38,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: .16,
                  ),
                  blurRadius: 7,
                ),
              ],
            ),
            child: const Icon(
              Icons.flag_rounded,
              color: Colors.orange,
              size: 21,
            ),
          ),
        ),
      );
    }

    if (currentLocation != null) {
      markers.add(
        Marker(
          point: currentLocation!,
          width: 44,
          height: 44,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: .18,
                  ),
                  blurRadius: 7,
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_walk_rounded,
              color: Colors.green,
              size: 23,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 300,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  strokeWidth: 4.5,
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

/* -------------------------------------------------------------------------- */
/* STATS                                                                      */
/* -------------------------------------------------------------------------- */

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
    final duration = _duration(
      durationSeconds > 0
          ? durationSeconds
          : elapsedSeconds,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final columns = width >= 900
              ? 6
              : width >= 600
                  ? 3
                  : 2;

          return GridView.count(
            crossAxisCount: columns,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            childAspectRatio: width >= 600
                ? 1.8
                : 2.2,
            children: [
              _Stat(
                icon: Icons.route_rounded,
                label: 'Distance',
                value:
                    '${distanceKm.toStringAsFixed(2)} km',
              ),
              _Stat(
                icon: Icons.timer_rounded,
                label: 'Duration',
                value: duration,
              ),
              _Stat(
                icon: Icons.directions_walk_rounded,
                label: 'Steps',
                value: '$steps',
              ),
              _Stat(
                icon: Icons.straighten_rounded,
                label: 'Meters',
                value:
                    distanceMeters.toStringAsFixed(0),
              ),
              _Stat(
                icon: Icons.water_drop_rounded,
                label: 'Pee',
                value: '$peeCount',
              ),
              _Stat(
                icon: Icons.circle,
                label: 'Poop',
                value: '$poopCount',
              ),
            ],
          );
        },
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 19,
          color: const Color(0xFFFF6B13),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF667B7D),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/* -------------------------------------------------------------------------- */
/* PERSON CARDS                                                               */
/* -------------------------------------------------------------------------- */

class _PersonCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String name;
  final String idLabel;
  final String id;
  final String uid;
  final String phone;

  const _PersonCard({
    required this.title,
    required this.icon,
    required this.name,
    required this.idLabel,
    required this.id,
    required this.uid,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _CardTitle(
            icon: icon,
            title: title,
          ),
          const SizedBox(height: 9),
          Text(
            name.isEmpty
                ? 'Not available'
                : name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: _MiniValue(
                  label: idLabel,
                  value: id,
                ),
              ),
              Expanded(
                child: _MiniValue(
                  label: 'Phone',
                  value: phone,
                ),
              ),
            ],
          ),
          if (uid.isNotEmpty) ...[
            const SizedBox(height: 6),
            _MiniValue(
              label: 'UID',
              value: uid,
            ),
          ],
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* DOG                                                                        */
/* -------------------------------------------------------------------------- */

class _DogCard extends StatelessWidget {
  final String name;
  final String breed;

  const _DogCard({
    required this.name,
    required this.breed,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3EA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: Color(0xFFFF6B13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'DOG',
                  style: TextStyle(
                    color: Color(0xFF667B7D),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name.isEmpty
                      ? 'Not available'
                      : name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (breed.isNotEmpty)
            Flexible(
              child: Text(
                breed,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF667B7D),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* EXPANSION CARDS                                                            */
/* -------------------------------------------------------------------------- */

class _CompactExpansionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _CompactExpansionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 1,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          13,
          0,
          13,
          10,
        ),
        leading: Icon(
          icon,
          size: 20,
          color: const Color(0xFFFF6B13),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        children: children,
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TimelineCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return _CompactExpansionCard(
      title: 'Timeline',
      icon: Icons.schedule_rounded,
      children: [
        _TimestampRow(
          label: 'Created',
          value: data['createdAt'],
        ),
        _TimestampRow(
          label: 'Started',
          value: data['startedAt'],
        ),
        _TimestampRow(
          label: 'GPS Updated',
          value: data['gpsUpdatedAt'],
        ),
        _TimestampRow(
          label: 'Updated',
          value: data['updatedAt'],
        ),
        _TimestampRow(
          label: 'Ended',
          value: data['endedAt'],
        ),
        _TimestampRow(
          label: 'Completed',
          value: data['completedAt'],
        ),
        _TimestampRow(
          label: 'Cancelled',
          value: data['cancelledAt'],
        ),
      ],
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
    return _CompactExpansionCard(
      title: 'Route',
      icon: Icons.route_rounded,
      children: [
        _InfoRow(
          label: 'Route Points',
          value: '${points.length}',
        ),
        _InfoRow(
          label: 'Tracking',
          value: points.length >= 2
              ? 'Route available'
              : 'No route recorded',
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
    return _CompactExpansionCard(
      title: 'Events',
      icon: Icons.event_note_rounded,
      children: [
        if (events.isEmpty)
          const Padding(
            padding: EdgeInsets.only(
              top: 4,
              bottom: 6,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'No events recorded.',
                style: TextStyle(
                  color: Color(0xFF667B7D),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ...events.asMap().entries.map(
          (entry) {
            final event = entry.value;

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(
                bottom: 7,
              ),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8F7),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Text(
                event is Map
                    ? _formatMap(event)
                    : '${entry.key + 1}. ${event.toString()}',
                style: const TextStyle(
                  fontSize: 11,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/* -------------------------------------------------------------------------- */
/* BASE UI                                                                    */
/* -------------------------------------------------------------------------- */

class _BaseCard extends StatelessWidget {
  final Widget child;

  const _BaseCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CardTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFFF6B13),
          size: 19,
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _MiniValue extends StatelessWidget {
  final String label;
  final String value;

  const _MiniValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 8,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF91A2A3),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.isEmpty ? '—' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF1C3136),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
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
      padding: const EdgeInsets.only(
        bottom: 7,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF667B7D),
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
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

class _NoMap extends StatelessWidget {
  const _NoMap();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_rounded,
              size: 36,
              color: Color(0xFF91A2A3),
            ),
            SizedBox(height: 7),
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

/* -------------------------------------------------------------------------- */
/* ADMIN ACTIONS                                                              */
/* -------------------------------------------------------------------------- */

Future<void> _confirmComplete(
  BuildContext context,
  String sessionId,
  String requestId,
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
          'This will mark the live walk as completed and update the related walk request.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                false,
              );
            },
            child: const Text('No'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                true,
              );
            },
            icon: const Icon(
              Icons.check_rounded,
              size: 18,
            ),
            label: const Text('Complete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    },
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  await _runAdminAction(
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
  String sessionId,
  String requestId,
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
              Navigator.pop(
                dialogContext,
                false,
              );
            },
            child: const Text('No'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                true,
              );
            },
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
            ),
            label: const Text('Cancel Walk'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    },
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  await _runAdminAction(
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

Future<void> _runAdminAction(
  BuildContext context, {
  required Future<void> Function() action,
  required String successMessage,
}) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF6B13),
        ),
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
        content: Text('Action failed: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* INVOICE ACTIONS                                                            */
/* -------------------------------------------------------------------------- */

void _showInvoice(
  BuildContext context,
  String sessionId,
  String requestId,
  Map<String, dynamic> data,
) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => LiveWalkInvoiceScreen(
        sessionId: sessionId,
        requestId: requestId,
        data: data,
      ),
    ),
  );
}

Future<void> _downloadInvoice(
  BuildContext context,
  String sessionId,
  String requestId,
  Map<String, dynamic> data,
) async {
  try {
    await const LiveWalkInvoiceService().downloadPdf(
      sessionId: sessionId,
      requestId: requestId,
      data: data,
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Invoice PDF is ready.',
        ),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Invoice PDF failed: $e',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<void> _shareInvoice(
  BuildContext context,
  String sessionId,
  String requestId,
  Map<String, dynamic> data,
) async {
  try {
    await const LiveWalkInvoiceService().sharePdf(
      sessionId: sessionId,
      requestId: requestId,
      data: data,
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Invoice shared successfully.',
        ),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Invoice sharing failed: $e',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* WALKER LOOKUP                                                              */
/* -------------------------------------------------------------------------- */

Future<Map<String, dynamic>?> _loadWalkerData(
  String walkerUid,
) async {
  if (walkerUid.trim().isEmpty) {
    return null;
  }

  final firestore = FirebaseFirestore.instance;

  final results = await Future.wait([
    firestore
        .collection('walkers')
        .doc(walkerUid)
        .get(),
    firestore
        .collection('walkerProfiles')
        .doc(walkerUid)
        .get(),
  ]);

  for (final doc in results) {
    if (doc.exists) {
      final value = doc.data();

      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
  }

  return null;
}

/* -------------------------------------------------------------------------- */
/* HELPERS                                                                    */
/* -------------------------------------------------------------------------- */

String _string(dynamic value) {
  if (value == null) {
    return '';
  }

  return value.toString().trim();
}

String _firstString(
  Map<String, dynamic> data,
  List<String> keys,
) {
  for (final key in keys) {
    final value = data[key];

    if (value != null &&
        value.toString().trim().isNotEmpty) {
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
  if (value == null) {
    return '—';
  }

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

    return LatLng(
      lat,
      lng,
    );
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
    return _formatDate(
      value.toDate(),
    );
  }

  if (value is DateTime) {
    return _formatDate(value);
  }

  return value.toString();
}

String _formatDate(DateTime date) {
  final local = date.toLocal();

  String two(int value) {
    return value.toString().padLeft(2, '0');
  }

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

String _shortId(String value) {
  if (value.length <= 24) {
    return value;
  }

  return '${value.substring(0, 12)}…'
      '${value.substring(value.length - 8)}';
}

String _formatMap(Map value) {
  return value.entries
      .map(
        (entry) =>
            '${entry.key}: ${_formatAny(entry.value)}',
      )
      .join('\n');
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
