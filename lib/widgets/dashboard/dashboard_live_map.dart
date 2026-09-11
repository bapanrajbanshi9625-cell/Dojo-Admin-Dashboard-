import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'dashboard_components.dart';

class DashboardLiveMap extends StatelessWidget {
  const DashboardLiveMap({
    super.key,
    required this.liveWalksStream,
    required this.acceptWalksStream,
  });

  final Stream<QuerySnapshot<Map<String, dynamic>>> liveWalksStream;
  final Stream<QuerySnapshot<Map<String, dynamic>>> acceptWalksStream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: acceptWalksStream,
      builder: (context, acceptSnapshot) {
        if (acceptSnapshot.connectionState == ConnectionState.waiting) {
          return const _MapPreviewCard(
            child: _MapLoadingState(),
          );
        }

        if (acceptSnapshot.hasError) {
          return const _MapPreviewCard(
            child: _MapErrorState(),
          );
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: liveWalksStream,
          builder: (context, liveSnapshot) {
            if (liveSnapshot.connectionState == ConnectionState.waiting &&
                !liveSnapshot.hasData) {
              return const _MapPreviewCard(
                child: _MapLoadingState(),
              );
            }

            if (liveSnapshot.hasError) {
              return const _MapPreviewCard(
                child: _MapErrorState(),
              );
            }

            final walks = _buildUnifiedWalks(
              acceptSnapshot.data?.docs ?? const [],
              liveSnapshot.data?.docs ?? const [],
            );

            return _MapPreviewCard(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: _MiniMap(
                      walks: walks,
                    ),
                  ),

                  Positioned(
                    top: 14,
                    left: 14,
                    child: _MapStatusBadge(
                      count: walks.length,
                    ),
                  ),

                  Positioned(
                    right: 14,
                    bottom: 14,
                    child: _OpenMapButton(
                      enabled: walks.isNotEmpty,
                      onTap: walks.isEmpty
                          ? null
                          : () {
                              _openFullMap(
                                context,
                                liveWalksStream,
                                acceptWalksStream,
                              );
                            },
                    ),
                  ),

                  if (walks.isEmpty)
                    const Positioned.fill(
                      child: _MapEmptyOverlay(),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openFullMap(
    BuildContext context,
    Stream<QuerySnapshot<Map<String, dynamic>>> liveStream,
    Stream<QuerySnapshot<Map<String, dynamic>>> acceptStream,
  ) {
    final width = MediaQuery.sizeOf(context).width;

    final map = _FullLiveMap(
      liveWalksStream: liveStream,
      acceptWalksStream: acceptStream,
    );

    if (width >= 700) {
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) {
          return Dialog(
            insetPadding: const EdgeInsets.all(24),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1100,
                maxHeight: 800,
              ),
              child: map,
            ),
          );
        },
      );
    } else {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return FractionallySizedBox(
            heightFactor: 0.94,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: map,
            ),
          );
        },
      );
    }
  }

  static List<_LiveWalkData> _buildUnifiedWalks(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> requestDocs,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> liveDocs,
  ) {
    final requests = <String, _RequestData>{};

    for (final doc in requestDocs) {
      final data = doc.data();

      final requestId = _readString(
        data,
        const ['requestId', 'walkRequestId'],
      ).isNotEmpty
          ? _readString(
              data,
              const ['requestId', 'walkRequestId'],
            )
          : doc.id;

      final status = _normaliseStatus(
        _readString(
          data,
          const ['status'],
        ),
      );

      final reached = data['reached'] == true;

      requests[requestId] = _RequestData(
        id: requestId,
        data: data,
        reached: reached,
        terminal: _isTerminalStatus(status),
      );
    }

    final liveSessions = <String, _LiveSessionData>{};

    for (final doc in liveDocs) {
      final data = doc.data();

      if (_isTerminalLiveSession(data)) {
        continue;
      }

      final requestId = _readString(
        data,
        const ['requestId', 'walkRequestId'],
      );

      final session = _LiveSessionData(
        id: doc.id,
        requestId: requestId,
        data: data,
      );

      final key = requestId.isNotEmpty ? requestId : doc.id;

      final previous = liveSessions[key];

      if (previous == null ||
          _timestampValue(data) >= _timestampValue(previous.data)) {
        liveSessions[key] = session;
      }
    }

    final result = <_LiveWalkData>[];
    final addedLiveIds = <String>{};

    // ------------------------------------------------------------
    // 1. WALK REQUESTS BEFORE REACH
    // ------------------------------------------------------------

    for (final request in requests.values) {
      if (request.terminal) {
        continue;
      }

      // Once walker reaches pickup, request map data must disappear.
      if (request.reached) {
        continue;
      }

      final walkerLocation = _readGeoPoint(
        request.data,
        const [
          'walkerLocation',
          'walker_location',
        ],
      );

      final ownerLocation = _readGeoPoint(
        request.data,
        const [
          'ownerLocation',
          'pickupLocation',
          'location',
          'owner_location',
          'pickup_location',
        ],
      );

      if (walkerLocation == null && ownerLocation == null) {
        continue;
      }

      result.add(
        _LiveWalkData(
          walkId: request.id,
          walkerLocation: walkerLocation,
          ownerLocation: ownerLocation,
          walkerName: _readString(
            request.data,
            const ['walkerName', 'walker_name'],
          ),
          ownerName: _readString(
            request.data,
            const ['ownerName', 'owner_name'],
          ),
        ),
      );
    }

    // ------------------------------------------------------------
    // 2. LIVE SESSIONS
    // ------------------------------------------------------------

    for (final session in liveSessions.values) {
      final requestId = session.requestId;

      final matchingRequest =
          requestId.isNotEmpty ? requests[requestId] : null;

      // If a request exists and walker has NOT reached pickup,
      // the request is already representing this walk.
      if (matchingRequest != null &&
          !matchingRequest.reached &&
          !matchingRequest.terminal) {
        continue;
      }

      // If request is reached, only the live session is shown.
      final walkerLocation = _readLiveWalkerLocation(
        session.data,
      );

      final ownerLocation = _readGeoPoint(
        session.data,
        const [
          'ownerLocation',
          'pickupLocation',
          'location',
          'owner_location',
          'pickup_location',
        ],
      );

      if (walkerLocation == null && ownerLocation == null) {
        continue;
      }

      result.add(
        _LiveWalkData(
          walkId: requestId.isNotEmpty ? requestId : session.id,
          walkerLocation: walkerLocation,
          ownerLocation: ownerLocation,
          walkerName: _readString(
            session.data,
            const [
              'walkerName',
              'walker_name',
            ],
          ),
          ownerName: _readString(
            session.data,
            const [
              'ownerName',
              'owner_name',
            ],
          ),
        ),
      );

      addedLiveIds.add(
        requestId.isNotEmpty ? requestId : session.id,
      );
    }

    return result;
  }

  static bool _isTerminalLiveSession(
    Map<String, dynamic> data,
  ) {
    final status = _normaliseStatus(
      _readString(
        data,
        const ['status'],
      ),
    );

    if (_isTerminalStatus(status)) {
      return true;
    }

    if (data['walkEnded'] == true) {
      return true;
    }

    if (data['trackingEnded'] == true) {
      return true;
    }

    return false;
  }

  static bool _isTerminalStatus(String status) {
    return const {
      'completed',
      'complete',
      'cancelled',
      'canceled',
      'rejected',
      'closed',
      'finished',
      'ended',
    }.contains(status);
  }

  static String _normaliseStatus(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
  }

  static GeoPoint? _readLiveWalkerLocation(
    Map<String, dynamic> data,
  ) {
    final current = _readGeoPoint(
      data,
      const [
        'currentLocation',
        'current_location',
      ],
    );

    if (current != null) {
      return current;
    }

    final currentLat = _number(
      data['currentLat'],
    );

    final currentLng = _number(
      data['currentLng'],
    );

    if (currentLat != null && currentLng != null) {
      return GeoPoint(
        currentLat,
        currentLng,
      );
    }

    return _readGeoPoint(
      data,
      const [
        'walkerLocation',
        'walker_location',
      ],
    );
  }

  static int _timestampValue(
    Map<String, dynamic> data,
  ) {
    final values = [
      data['updatedAt'],
      data['locationUpdatedAt'],
      data['startedAt'],
      data['createdAt'],
    ];

    for (final value in values) {
      if (value is Timestamp) {
        return value.millisecondsSinceEpoch;
      }

      if (value is DateTime) {
        return value.millisecondsSinceEpoch;
      }
    }

    return 0;
  }

  static String _readString(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return '';
  }

  static GeoPoint? _readGeoPoint(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value is GeoPoint) {
        return value;
      }

      if (value is Map) {
        final lat = _number(
          value['latitude'] ??
              value['lat'] ??
              value['currentLatitude'] ??
              value['currentLat'],
        );

        final lng = _number(
          value['longitude'] ??
              value['lng'] ??
              value['lon'] ??
              value['currentLongitude'] ??
              value['currentLng'],
        );

        if (lat != null && lng != null) {
          return GeoPoint(
            lat,
            lng,
          );
        }
      }
    }

    final lat = _number(
      data['latitude'] ??
          data['lat'] ??
          data['currentLatitude'] ??
          data['currentLat'],
    );

    final lng = _number(
      data['longitude'] ??
          data['lng'] ??
          data['lon'] ??
          data['currentLongitude'] ??
          data['currentLng'],
    );

    if (lat != null && lng != null) {
      return GeoPoint(
        lat,
        lng,
      );
    }

    return null;
  }

  static double? _number(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }
}

/// ===============================================================
/// REQUEST DATA
/// ===============================================================

class _RequestData {
  const _RequestData({
    required this.id,
    required this.data,
    required this.reached,
    required this.terminal,
  });

  final String id;
  final Map<String, dynamic> data;
  final bool reached;
  final bool terminal;
}

/// ===============================================================
/// LIVE SESSION DATA
/// ===============================================================

class _LiveSessionData {
  const _LiveSessionData({
    required this.id,
    required this.requestId,
    required this.data,
  });

  final String id;
  final String requestId;
  final Map<String, dynamic> data;
}

/// ===============================================================
/// MAP PREVIEW CARD
/// ===============================================================

class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final height = width < 600
        ? 285.0
        : width < 1000
            ? 310.0
            : 330.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 7),
            color: Colors.black.withValues(alpha: 0.055),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

/// ===============================================================
/// LOADING
/// ===============================================================

class _MapLoadingState extends StatelessWidget {
  const _MapLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: blue,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Loading live walks...',
              style: TextStyle(
                color: grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// ERROR
/// ===============================================================

class _MapErrorState extends StatelessWidget {
  const _MapErrorState();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: danger.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off_outlined,
                  color: danger,
                  size: 23,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Unable to load live walk locations.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: dark,
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

/// ===============================================================
/// EMPTY MAP OVERLAY
/// ===============================================================

class _MapEmptyOverlay extends StatelessWidget {
  const _MapEmptyOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        color: Colors.white.withValues(alpha: 0.76),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: border,
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 18,
                  color: Colors.black.withValues(alpha: 0.08),
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_searching,
                  color: blue,
                  size: 20,
                ),
                SizedBox(width: 9),
                Flexible(
                  child: Text(
                    'No live walk locations available',
                    style: TextStyle(
                      color: dark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ===============================================================
/// STATUS BADGE
/// ===============================================================

class _MapStatusBadge extends StatelessWidget {
  const _MapStatusBadge({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: count > 0 ? green : grey,
              shape: BoxShape.circle,
              boxShadow: count > 0
                  ? [
                      BoxShadow(
                        color: green.withValues(alpha: 0.35),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count Live ${count == 1 ? 'Walk' : 'Walks'}',
            style: const TextStyle(
              color: dark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// OPEN MAP BUTTON
/// ===============================================================

class _OpenMapButton extends StatefulWidget {
  const _OpenMapButton({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback? onTap;

  @override
  State<_OpenMapButton> createState() => _OpenMapButtonState();
}

class _OpenMapButtonState extends State<_OpenMapButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.enabled ? blue : grey;

    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) {
        if (mounted) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() => _hovered = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 4),
              color: Colors.black.withValues(alpha: 0.12),
            ),
          ],
        ),
        child: FilledButton.icon(
          onPressed: widget.onTap,
          style: FilledButton.styleFrom(
            backgroundColor: _hovered && widget.enabled
                ? const Color(0xFF1D4ED8)
                : color,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                Colors.white.withValues(alpha: 0.92),
            disabledForegroundColor: grey,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(
            Icons.open_in_full,
            size: 17,
          ),
          label: const Text(
            'Open Live Map',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// ===============================================================
/// MINI MAP
/// ===============================================================

class _MiniMap extends StatelessWidget {
  const _MiniMap({
    required this.walks,
  });

  final List<_LiveWalkData> walks;

  @override
  Widget build(BuildContext context) {
    final center = _initialCenter(walks);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 11,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.doojowalker.app',
        ),
        MarkerLayer(
          markers: _buildMarkers(walks),
        ),
        RichAttributionWidget(
          attributions: [
            const TextSourceAttribution(
              'OpenStreetMap contributors',
            ),
          ],
        ),
      ],
    );
  }
}

/// ===============================================================
/// FULL LIVE MAP
/// ===============================================================

class _FullLiveMap extends StatefulWidget {
  const _FullLiveMap({
    required this.liveWalksStream,
    required this.acceptWalksStream,
  });

  final Stream<QuerySnapshot<Map<String, dynamic>>> liveWalksStream;
  final Stream<QuerySnapshot<Map<String, dynamic>>> acceptWalksStream;

  @override
  State<_FullLiveMap> createState() => _FullLiveMapState();
}

class _FullLiveMapState extends State<_FullLiveMap> {
  final MapController _mapController = MapController();

  final Map<String, List<LatLng>> _routes = {};

  List<_LiveWalkData> _walks = [];

  bool _loadingRoutes = false;
  bool _nearbyOnly = false;

  LatLng? _myLocation;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _liveSubscription;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _acceptSubscription;

  QuerySnapshot<Map<String, dynamic>>? _liveSnapshot;
  QuerySnapshot<Map<String, dynamic>>? _acceptSnapshot;

  @override
  void initState() {
    super.initState();

    _listenToStreams();
  }

  @override
  void dispose() {
    _liveSubscription?.cancel();
    _acceptSubscription?.cancel();
    super.dispose();
  }

  void _listenToStreams() {
    _acceptSubscription = widget.acceptWalksStream.listen(
      (snapshot) {
        if (!mounted) {
          return;
        }

        _acceptSnapshot = snapshot;
        _rebuildWalks();
      },
      onError: (_) {},
    );

    _liveSubscription = widget.liveWalksStream.listen(
      (snapshot) {
        if (!mounted) {
          return;
        }

        _liveSnapshot = snapshot;
        _rebuildWalks();
      },
      onError: (_) {},
    );
  }

  void _rebuildWalks() {
    final requestDocs = _acceptSnapshot?.docs ?? const [];
    final liveDocs = _liveSnapshot?.docs ?? const [];

    final allWalks = DashboardLiveMap._buildUnifiedWalks(
      requestDocs,
      liveDocs,
    );

    final filteredWalks = _nearbyOnly && _myLocation != null
        ? _filterNearby(
            allWalks,
            _myLocation!,
          )
        : allWalks;

    final changed = _walkListsChanged(
      _walks,
      filteredWalks,
    );

    setState(() {
      _walks = filteredWalks;
    });

    if (changed) {
      unawaited(
        _reloadRoutes(
          filteredWalks,
        ),
      );
    }
  }

  bool _walkListsChanged(
    List<_LiveWalkData> oldWalks,
    List<_LiveWalkData> newWalks,
  ) {
    if (oldWalks.length != newWalks.length) {
      return true;
    }

    for (var i = 0; i < oldWalks.length; i++) {
      final oldWalk = oldWalks[i];
      final newWalk = newWalks[i];

      if (oldWalk.walkId != newWalk.walkId) {
        return true;
      }

      if (!_sameGeoPoint(
        oldWalk.walkerLocation,
        newWalk.walkerLocation,
      )) {
        return true;
      }

      if (!_sameGeoPoint(
        oldWalk.ownerLocation,
        newWalk.ownerLocation,
      )) {
        return true;
      }
    }

    return false;
  }

  bool _sameGeoPoint(
    GeoPoint? a,
    GeoPoint? b,
  ) {
    if (a == null && b == null) {
      return true;
    }

    if (a == null || b == null) {
      return false;
    }

    return a.latitude == b.latitude &&
        a.longitude == b.longitude;
  }

  Future<void> _reloadRoutes(
    List<_LiveWalkData> walks,
  ) async {
    final oldRoutes = Map<String, List<LatLng>>.from(
      _routes,
    );

    _routes.clear();

    if (mounted) {
      setState(() {
        _loadingRoutes = true;
      });
    }

    final routeTasks = <Future<void>>[];

    for (final walk in walks) {
      final walker = walk.walkerLatLng;
      final owner = walk.ownerLatLng;

      if (walker == null || owner == null) {
        continue;
      }

      final oldRoute = oldRoutes[walk.walkId];

      if (oldRoute != null && oldRoute.isNotEmpty) {
        _routes[walk.walkId] = oldRoute;
        continue;
      }

      routeTasks.add(
        _loadRoute(
          walk.walkId,
          walker,
          owner,
        ),
      );
    }

    await Future.wait(routeTasks);

    if (!mounted) {
      return;
    }

    setState(() {
      _loadingRoutes = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _fitAll();
    });
  }

  Future<void> _loadRoute(
    String walkId,
    LatLng walker,
    LatLng owner,
  ) async {
    try {
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${walker.longitude},${walker.latitude};'
        '${owner.longitude},${owner.latitude}'
        '?overview=full&geometries=geojson',
      );

      final response = await http.get(
        uri,
        headers: const {
          'User-Agent': 'DojoAdmin/1.0',
        },
      );

      if (response.statusCode != 200) {
        return;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        return;
      }

      final routes = decoded['routes'];

      if (routes is! List || routes.isEmpty) {
        return;
      }

      final geometry = routes.first['geometry'];

      if (geometry is! Map) {
        return;
      }

      final coordinates = geometry['coordinates'];

      if (coordinates is! List) {
        return;
      }

      final points = <LatLng>[];

      for (final item in coordinates) {
        if (item is List && item.length >= 2) {
          final lng = (item[0] as num).toDouble();
          final lat = (item[1] as num).toDouble();

          points.add(
            LatLng(
              lat,
              lng,
            ),
          );
        }
      }

      if (points.isNotEmpty && mounted) {
        setState(() {
          _routes[walkId] = points;
        });
      }
    } catch (_) {
      // Route failure must never break the live map.
    }
  }

  List<_LiveWalkData> _filterNearby(
    List<_LiveWalkData> walks,
    LatLng center,
  ) {
    const distance = Distance();

    return walks.where((walk) {
      final walker = walk.walkerLatLng;
      final owner = walk.ownerLatLng;

      if (walker != null) {
        final meters = distance.as(
          LengthUnit.Meter,
          center,
          walker,
        );

        if (meters <= 5000) {
          return true;
        }
      }

      if (owner != null) {
        final meters = distance.as(
          LengthUnit.Meter,
          center,
          owner,
        );

        if (meters <= 5000) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  Future<void> _useMyLocation() async {
    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) {
          return;
        }

        _showLocationMessage(
          'Location service is turned off.',
        );
        return;
      }

      var permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) {
          return;
        }

        _showLocationMessage(
          'Location permission is required.',
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) {
          return;
        }

        _showLocationMessage(
          'Location permission is blocked. Enable it in settings.',
        );
        return;
      }

      final position =
          await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) {
        return;
      }

      final location = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _myLocation = location;
        _nearbyOnly = true;
      });

      _rebuildWalks();

      _mapController.move(
        location,
        12.5,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showLocationMessage(
        'Unable to get your current location.',
      );
    }
  }

  void _showLocationMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showAllWalks() {
    if (_nearbyOnly) {
      setState(() {
        _nearbyOnly = false;
      });

      _rebuildWalks();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _fitAll();
    });
  }

  void _handleMapGesture(
    MapCamera camera,
    bool hasGesture,
  ) {
    if (!hasGesture || !_nearbyOnly) {
      return;
    }

    setState(() {
      _nearbyOnly = false;
    });

    _rebuildWalks();
  }

  void _fitAll() {
    final points = <LatLng>[];

    for (final walk in _walks) {
      if (walk.walkerLatLng != null) {
        points.add(
          walk.walkerLatLng!,
        );
      }

      if (walk.ownerLatLng != null) {
        points.add(
          walk.ownerLatLng!,
        );
      }
    }

    if (points.isEmpty) {
      return;
    }

    if (points.length == 1) {
      _mapController.move(
        points.first,
        14,
      );
      return;
    }

    final bounds = LatLngBounds.fromPoints(
      points,
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(70),
        maxZoom: 15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayWalks = _walks;

    return Material(
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialCenter(
                      displayWalks,
                    ),
                    initialZoom: 11,
                    interactionOptions:
                        const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                    onPositionChanged:
                        _handleMapGesture,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.doojowalker.app',
                    ),

                    if (_routes.isNotEmpty)
                      PolylineLayer(
                        polylines:
                            _routes.entries.map((entry) {
                          return Polyline(
                            points: entry.value,
                            strokeWidth: 5,
                            color: blue,
                          );
                        }).toList(),
                      ),

                    MarkerLayer(
                      markers: _buildMarkers(
                        displayWalks,
                      ),
                    ),

                    if (_myLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _myLocation!,
                            width: 34,
                            height: 34,
                            child:
                                const _MyLocationMarker(),
                          ),
                        ],
                      ),

                    RichAttributionWidget(
                      attributions: [
                        const TextSourceAttribution(
                          'OpenStreetMap contributors',
                        ),
                      ],
                    ),
                  ],
                ),

                Positioned(
                  left: 16,
                  bottom: 16,
                  child: const _MapLegend(),
                ),

                Positioned(
                  right: 16,
                  bottom: 16,
                  child: _MapControls(
                    onZoomIn: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      );
                    },
                    onZoomOut: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      );
                    },
                    onFitAll: _showAllWalks,
                    onMyLocation: _useMyLocation,
                    nearbyOnly: _nearbyOnly,
                  ),
                ),

                if (_loadingRoutes)
                  const Positioned(
                    top: 16,
                    right: 16,
                    child: _RouteLoadingBadge(),
                  ),

                Positioned(
                  top: 16,
                  left: 16,
                  child: _FullMapLiveBadge(
                    count: displayWalks.length,
                    nearbyOnly: _nearbyOnly,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
  ) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 600;

    return Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 14 : 20,
        compact ? 13 : 17,
        compact ? 8 : 12,
        compact ? 12 : 15,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: border,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 40 : 44,
            height: compact ? 40 : 44,
            decoration: BoxDecoration(
              color: blue.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.map_outlined,
              color: blue,
              size: 22,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Walk Map',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: dark,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Walker locations, pickup points and routes',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: grey,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: border,
                ),
              ),
              child: const Icon(
                Icons.close,
                size: 18,
                color: dark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// FULL MAP LIVE BADGE
/// ===============================================================

class _FullMapLiveBadge extends StatelessWidget {
  const _FullMapLiveBadge({
    required this.count,
    required this.nearbyOnly,
  });

  final int count;
  final bool nearbyOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withValues(alpha: 0.10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            nearbyOnly
                ? '$count nearby'
                : '$count Live ${count == 1 ? 'Walk' : 'Walks'}',
            style: const TextStyle(
              color: dark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// MAP CONTROLS
/// ===============================================================

class _MapControls extends StatelessWidget {
  const _MapControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFitAll,
    required this.onMyLocation,
    required this.nearbyOnly,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFitAll;
  final VoidCallback onMyLocation;
  final bool nearbyOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withValues(alpha: 0.13),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MapControlButton(
            tooltip: 'My location · nearby walks',
            icon: Icons.my_location,
            onTap: onMyLocation,
            active: nearbyOnly,
          ),
          const SizedBox(height: 4),
          _MapControlButton(
            tooltip: 'Zoom in',
            icon: Icons.add,
            onTap: onZoomIn,
          ),
          const SizedBox(height: 4),
          _MapControlButton(
            tooltip: 'Zoom out',
            icon: Icons.remove,
            onTap: onZoomOut,
          ),
          const SizedBox(height: 4),
          Container(
            height: 1,
            width: 28,
            color: border,
          ),
          const SizedBox(height: 4),
          _MapControlButton(
            tooltip: 'Fit all live walks',
            icon: Icons.fit_screen,
            onTap: onFitAll,
          ),
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active
            ? blue.withValues(alpha: 0.10)
            : background,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              icon,
              color: active ? blue : dark,
              size: 19,
            ),
          ),
        ),
      ),
    );
  }
}

/// ===============================================================
/// MY LOCATION MARKER
/// ===============================================================

class _MyLocationMarker extends StatelessWidget {
  const _MyLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: blue,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: blue.withValues(alpha: 0.35),
            ),
          ],
        ),
        child: const Icon(
          Icons.my_location,
          color: Colors.white,
          size: 12,
        ),
      ),
    );
  }
}

/// ===============================================================
/// ROUTE LOADING BADGE
/// ===============================================================

class _RouteLoadingBadge extends StatelessWidget {
  const _RouteLoadingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withValues(alpha: 0.12),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: blue,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Loading routes...',
            style: TextStyle(
              color: dark,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// LEGEND
/// ===============================================================

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    final compact =
        MediaQuery.sizeOf(context).width < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withValues(alpha: 0.13),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendItem(
            icon: Icons.location_on,
            label: 'Pickup',
            iconColor: danger,
            compact: compact,
          ),
          SizedBox(
            width: compact ? 9 : 14,
          ),
          _LegendItem(
            icon: Icons.directions_walk,
            label: 'Walker',
            iconColor: green,
            compact: compact,
          ),
          SizedBox(
            width: compact ? 9 : 14,
          ),
          _LegendItem(
            icon: Icons.route,
            label: 'Route',
            iconColor: blue,
            compact: compact,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: compact ? 15 : 17,
          color: iconColor,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: dark,
            fontSize: compact ? 10 : 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// ===============================================================
/// LIVE WALK DATA
/// ===============================================================

class _LiveWalkData {
  const _LiveWalkData({
    required this.walkId,
    required this.walkerLocation,
    required this.ownerLocation,
    required this.walkerName,
    required this.ownerName,
  });

  final String walkId;
  final GeoPoint? walkerLocation;
  final GeoPoint? ownerLocation;
  final String walkerName;
  final String ownerName;

  LatLng? get walkerLatLng {
    final location = walkerLocation;

    if (location == null) {
      return null;
    }

    return LatLng(
      location.latitude,
      location.longitude,
    );
  }

  LatLng? get ownerLatLng {
    final location = ownerLocation;

    if (location == null) {
      return null;
    }

    return LatLng(
      location.latitude,
      location.longitude,
    );
  }
}

/// ===============================================================
/// INITIAL CENTER
/// ===============================================================

LatLng _initialCenter(
  List<_LiveWalkData> walks,
) {
  for (final walk in walks) {
    if (walk.walkerLatLng != null) {
      return walk.walkerLatLng!;
    }

    if (walk.ownerLatLng != null) {
      return walk.ownerLatLng!;
    }
  }

  return const LatLng(
    28.6139,
    77.2090,
  );
}

/// ===============================================================
/// MARKERS
/// ===============================================================

List<Marker> _buildMarkers(
  List<_LiveWalkData> walks,
) {
  final markers = <Marker>[];

  for (final walk in walks) {
    if (walk.ownerLatLng != null) {
      markers.add(
        Marker(
          point: walk.ownerLatLng!,
          width: 54,
          height: 54,
          child: const _MapMarker(
            icon: Icons.location_on,
            backgroundColor: danger,
          ),
        ),
      );
    }

    if (walk.walkerLatLng != null) {
      markers.add(
        Marker(
          point: walk.walkerLatLng!,
          width: 54,
          height: 54,
          child: const _MapMarker(
            icon: Icons.directions_walk,
            backgroundColor: green,
          ),
        ),
      );
    }
  }

  return markers;
}

/// ===============================================================
/// MAP MARKER
/// ===============================================================

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.icon,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 9,
              offset: const Offset(0, 3),
              color: Colors.black.withValues(alpha: 0.25),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }
}
