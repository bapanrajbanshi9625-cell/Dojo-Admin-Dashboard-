// File:
// lib/features/walk_requests/widgets/walk_request_map_preview.dart

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class WalkRequestMapPreview extends StatefulWidget {
  const WalkRequestMapPreview({
    super.key,
    required this.requestId,
    required this.ownerLocation,
    this.walkerLocation,
    this.walkerId,
    this.walkerUid,
    this.walkerName,
    this.onOpenMaps,
  });

  /// Firestore document id:
  /// walk_request/{requestId}
  final String requestId;

  /// Owner pickup location.
  final LatLng ownerLocation;

  /// Initial walker location.
  ///
  /// Live updates are received from:
  /// walk_request/{requestId}.walkerLocation
  final LatLng? walkerLocation;

  final String? walkerId;
  final String? walkerUid;
  final String? walkerName;

  final ValueChanged<LatLng>? onOpenMaps;

  @override
  State<WalkRequestMapPreview> createState() =>
      _WalkRequestMapPreviewState();
}

class _WalkRequestMapPreviewState
    extends State<WalkRequestMapPreview> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  StreamSubscription<
      DocumentSnapshot<Map<String, dynamic>>
  >? _requestSubscription;

  LatLng? _walkerLocation;
  DateTime? _locationUpdatedAt;

  bool _loadingWalker = false;

  @override
  void initState() {
    super.initState();

    _walkerLocation = widget.walkerLocation;

    _startRequestListener();
  }

  @override
  void didUpdateWidget(
    covariant WalkRequestMapPreview oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.requestId != widget.requestId) {
      _requestSubscription?.cancel();

      _walkerLocation = widget.walkerLocation;
      _locationUpdatedAt = null;

      _startRequestListener();
    } else if (oldWidget.walkerLocation !=
        widget.walkerLocation) {
      if (widget.walkerLocation != null) {
        _walkerLocation = widget.walkerLocation;
      }
    }
  }

  @override
  void dispose() {
    _requestSubscription?.cancel();
    super.dispose();
  }

  // ==========================================================
  // LIVE WALK REQUEST LISTENER
  // ==========================================================

  void _startRequestListener() {
    final requestId = widget.requestId.trim();

    if (requestId.isEmpty) {
      if (mounted) {
        setState(() {
          _loadingWalker = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _loadingWalker = true;
      });
    }

    _requestSubscription = _firestore
        .collection('walk_request')
        .doc(requestId)
        .snapshots()
        .listen(
      (snapshot) {
        if (!mounted) {
          return;
        }

        final data = snapshot.data();

        if (data == null) {
          setState(() {
            _loadingWalker = false;
          });
          return;
        }

        final location =
            _extractWalkerLocation(data);

        final updatedAt =
            _extractDateTime(
          data['locationUpdatedAt'],
        );

        setState(() {
          if (location != null) {
            _walkerLocation = location;
          }

          if (updatedAt != null) {
            _locationUpdatedAt = updatedAt;
          }

          _loadingWalker = false;
        });
      },
      onError: (_) {
        if (!mounted) {
          return;
        }

        // Keep the initial/live location if Firestore
        // temporarily fails.
        setState(() {
          _loadingWalker = false;
        });
      },
    );
  }

  // ==========================================================
  // WALKER LOCATION EXTRACTION
  // ==========================================================

  LatLng? _extractWalkerLocation(
    Map<String, dynamic> data,
  ) {
    final candidates = <dynamic>[
      data['walkerLocation'],
      data['walker_location'],
      data['currentWalkerLocation'],
      data['current_walker_location'],
    ];

    for (final value in candidates) {
      final location = _parseLocation(value);

      if (location != null) {
        return location;
      }
    }

    final latitude =
        _toDouble(data['walkerLatitude']);

    final longitude =
        _toDouble(data['walkerLongitude']);

    if (latitude != null && longitude != null) {
      return _safeLatLng(
        latitude,
        longitude,
      );
    }

    final lat =
        _toDouble(data['walkerLat']);

    final lng =
        _toDouble(data['walkerLng']);

    if (lat != null && lng != null) {
      return _safeLatLng(
        lat,
        lng,
      );
    }

    return null;
  }

  LatLng? _parseLocation(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is GeoPoint) {
      return _safeLatLng(
        value.latitude,
        value.longitude,
      );
    }

    if (value is LatLng) {
      return value;
    }

    if (value is Map) {
      final map =
          Map<String, dynamic>.from(value);

      final latitude =
          _toDouble(
        map['latitude'] ??
            map['lat'],
      );

      final longitude =
          _toDouble(
        map['longitude'] ??
            map['lng'] ??
            map['lon'],
      );

      if (latitude != null &&
          longitude != null) {
        return _safeLatLng(
          latitude,
          longitude,
        );
      }
    }

    if (value is List &&
        value.length >= 2) {
      final latitude =
          _toDouble(value[0]);

      final longitude =
          _toDouble(value[1]);

      if (latitude != null &&
          longitude != null) {
        return _safeLatLng(
          latitude,
          longitude,
        );
      }
    }

    return null;
  }

  LatLng? _safeLatLng(
    double latitude,
    double longitude,
  ) {
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      return null;
    }

    return LatLng(
      latitude,
      longitude,
    );
  }

  double? _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString().trim(),
    );
  }

  DateTime? _extractDateTime(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  // ==========================================================
  // OPEN MAP
  // ==========================================================

  Future<void> _openLocationMap() async {
    await _showLocationMap(
      context,
      ownerLocation: widget.ownerLocation,
      walkerLocation: _walkerLocation,
    );
  }

  // ==========================================================
  // LOCATION MAP SHEET
  // ==========================================================

  Future<void> _showLocationMap(
    BuildContext context, {
    required LatLng ownerLocation,
    required LatLng? walkerLocation,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _LocationMapSheet(
          requestId: widget.requestId,
          ownerLocation: ownerLocation,
          walkerLocation: walkerLocation,
          walkerName: widget.walkerName,
          locationUpdatedAt: _locationUpdatedAt,
        );
      },
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final bool hasWalker =
        widget.walkerId?.trim().isNotEmpty == true ||
        widget.walkerUid?.trim().isNotEmpty == true ||
        widget.walkerName?.trim().isNotEmpty == true;

    final bool hasWalkerLocation =
        _walkerLocation != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------
          // HEADER
          // ----------------------------------------------------

          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color:
                      Colors.blue.withValues(alpha: 0.10),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.map_rounded,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location & Route',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasWalker
                          ? 'Owner pickup and walker location'
                          : 'Owner pickup location',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ----------------------------------------------------
          // LOCATION STATUS
          // ----------------------------------------------------

          if (hasWalker)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: hasWalkerLocation
                    ? Colors.green
                        .withValues(alpha: 0.08)
                    : Colors.orange
                        .withValues(alpha: 0.08),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    hasWalkerLocation
                        ? Icons.my_location_rounded
                        : Icons.location_searching_rounded,
                    size: 18,
                    color: hasWalkerLocation
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _loadingWalker
                          ? 'Getting walker location...'
                          : hasWalkerLocation
                              ? _locationUpdatedAt !=
                                      null
                                  ? 'Walker location is live'
                                  : 'Walker location available'
                              : 'Walker current location unavailable',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w600,
                        color: hasWalkerLocation
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ),
                  if (hasWalkerLocation)
                    Container(
                      width: 8,
                      height: 8,
                      decoration:
                          const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 14),

          // ----------------------------------------------------
          // SINGLE LOCATION BUTTON
          // ----------------------------------------------------

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openLocationMap,
              icon: const Icon(
                Icons.location_on_rounded,
              ),
              label: Text(
                hasWalkerLocation
                    ? 'View Walker Route & Pickup'
                    : 'View Pickup Location',
              ),
              style: FilledButton.styleFrom(
                minimumSize:
                    const Size(
                  double.infinity,
                  48,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LOCATION MAP SHEET
// ============================================================================

class _LocationMapSheet extends StatefulWidget {
  const _LocationMapSheet({
    required this.requestId,
    required this.ownerLocation,
    required this.walkerLocation,
    this.walkerName,
    this.locationUpdatedAt,
  });

  final String requestId;
  final LatLng ownerLocation;
  final LatLng? walkerLocation;
  final String? walkerName;
  final DateTime? locationUpdatedAt;

  @override
  State<_LocationMapSheet> createState() =>
      _LocationMapSheetState();
}

class _LocationMapSheetState
    extends State<_LocationMapSheet> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  StreamSubscription<
      DocumentSnapshot<Map<String, dynamic>>
  >? _requestSubscription;

  LatLng? _walkerLocation;
  DateTime? _locationUpdatedAt;

  List<LatLng> _routePoints = [];

  double? _distanceKm;
  double? _durationMinutes;

  bool _routeLoading = false;
  String? _routeError;

  @override
  void initState() {
    super.initState();

    _walkerLocation = widget.walkerLocation;
    _locationUpdatedAt = widget.locationUpdatedAt;

    _startLiveLocationListener();

    if (_walkerLocation != null) {
      _loadRoute();
    }
  }

  @override
  void dispose() {
    _requestSubscription?.cancel();
    super.dispose();
  }

  // ==========================================================
  // LIVE WALKER LOCATION LISTENER
  // ==========================================================

  void _startLiveLocationListener() {
    final requestId = widget.requestId.trim();

    if (requestId.isEmpty) {
      return;
    }

    _requestSubscription = _firestore
        .collection('walk_request')
        .doc(requestId)
        .snapshots()
        .listen(
      (snapshot) {
        if (!mounted) {
          return;
        }

        final data = snapshot.data();

        if (data == null) {
          return;
        }

        final newLocation =
            _extractWalkerLocation(data);

        final newUpdatedAt =
            _extractDateTime(
          data['locationUpdatedAt'],
        );

        if (newLocation == null) {
          if (newUpdatedAt != null) {
            setState(() {
              _locationUpdatedAt = newUpdatedAt;
            });
          }
          return;
        }

        final bool locationChanged =
            _walkerLocation == null ||
            _walkerLocation!.latitude !=
                newLocation.latitude ||
            _walkerLocation!.longitude !=
                newLocation.longitude;

        setState(() {
          _walkerLocation = newLocation;

          if (newUpdatedAt != null) {
            _locationUpdatedAt = newUpdatedAt;
          }
        });

        if (locationChanged) {
          _loadRoute();
        }
      },
      onError: (_) {
        // Keep the last known walker location.
      },
    );
  }

  // ==========================================================
  // WALKER LOCATION EXTRACTION
  // ==========================================================

  LatLng? _extractWalkerLocation(
    Map<String, dynamic> data,
  ) {
    final candidates = <dynamic>[
      data['walkerLocation'],
      data['walker_location'],
      data['currentWalkerLocation'],
      data['current_walker_location'],
    ];

    for (final value in candidates) {
      final location = _parseLocation(value);

      if (location != null) {
        return location;
      }
    }

    final latitude =
        _toDouble(data['walkerLatitude']);

    final longitude =
        _toDouble(data['walkerLongitude']);

    if (latitude != null && longitude != null) {
      return _safeLatLng(
        latitude,
        longitude,
      );
    }

    final lat =
        _toDouble(data['walkerLat']);

    final lng =
        _toDouble(data['walkerLng']);

    if (lat != null && lng != null) {
      return _safeLatLng(
        lat,
        lng,
      );
    }

    return null;
  }

  LatLng? _parseLocation(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is GeoPoint) {
      return _safeLatLng(
        value.latitude,
        value.longitude,
      );
    }

    if (value is LatLng) {
      return value;
    }

    if (value is Map) {
      final map =
          Map<String, dynamic>.from(value);

      final latitude =
          _toDouble(
        map['latitude'] ??
            map['lat'],
      );

      final longitude =
          _toDouble(
        map['longitude'] ??
            map['lng'] ??
            map['lon'],
      );

      if (latitude != null &&
          longitude != null) {
        return _safeLatLng(
          latitude,
          longitude,
        );
      }
    }

    if (value is List &&
        value.length >= 2) {
      final latitude =
          _toDouble(value[0]);

      final longitude =
          _toDouble(value[1]);

      if (latitude != null &&
          longitude != null) {
        return _safeLatLng(
          latitude,
          longitude,
        );
      }
    }

    return null;
  }

  LatLng? _safeLatLng(
    double latitude,
    double longitude,
  ) {
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      return null;
    }

    return LatLng(
      latitude,
      longitude,
    );
  }

  double? _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString().trim(),
    );
  }

  DateTime? _extractDateTime(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  // ==========================================================
  // OSRM ROUTE
  // ==========================================================

  Future<void> _loadRoute() async {
    final walker = _walkerLocation;

    if (walker == null) {
      if (mounted) {
        setState(() {
          _routePoints = [];
          _distanceKm = null;
          _durationMinutes = null;
          _routeLoading = false;
          _routeError = null;
        });
      }
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _routeLoading = true;
      _routeError = null;
    });

    try {
      final String url =
          'https://router.project-osrm.org/'
          'route/v1/driving/'
          '${walker.longitude},'
          '${walker.latitude};'
          '${widget.ownerLocation.longitude},'
          '${widget.ownerLocation.latitude}'
          '?overview=full&geometries=geojson&steps=false';

      final response = await http.get(
        Uri.parse(url),
        headers: const {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Route server returned '
          '${response.statusCode}',
        );
      }

      final Map<String, dynamic> json =
          jsonDecode(response.body);

      final List<dynamic>? routes =
          json['routes'] as List<dynamic>?;

      if (routes == null ||
          routes.isEmpty) {
        throw Exception(
          'No route found',
        );
      }

      final Map<String, dynamic> route =
          Map<String, dynamic>.from(
        routes.first as Map,
      );

      final double? distanceMeters =
          (route['distance'] as num?)
              ?.toDouble();

      final double? durationSeconds =
          (route['duration'] as num?)
              ?.toDouble();

      final geometry =
          route['geometry']
              as Map<String, dynamic>?;

      final coordinates =
          geometry?['coordinates']
              as List<dynamic>?;

      final List<LatLng> points = [];

      if (coordinates != null) {
        for (final item in coordinates) {
          if (item is List &&
              item.length >= 2) {
            final double? lng =
                (item[0] as num?)
                    ?.toDouble();

            final double? lat =
                (item[1] as num?)
                    ?.toDouble();

            if (lat != null &&
                lng != null) {
              points.add(
                LatLng(lat, lng),
              );
            }
          }
        }
      }

      if (points.isEmpty) {
        throw Exception(
          'Route geometry unavailable',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _routePoints = points;

        _distanceKm =
            distanceMeters != null
                ? distanceMeters / 1000
                : null;

        _durationMinutes =
            durationSeconds != null
                ? durationSeconds / 60
                : null;

        _routeLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _routeLoading = false;
        _routeError =
            'Road route could not be loaded.';
      });
    }
  }

  // ==========================================================
  // MAP CENTER
  // ==========================================================

  LatLng _mapCenter() {
    final walker =
        _walkerLocation;

    if (walker == null) {
      return widget.ownerLocation;
    }

    return LatLng(
      (walker.latitude +
              widget.ownerLocation.latitude) /
          2,
      (walker.longitude +
              widget.ownerLocation.longitude) /
          2,
    );
  }

  double _initialZoom() {
    if (_walkerLocation == null) {
      return 15;
    }

    final double distance =
        const Distance().as(
      LengthUnit.Kilometer,
      _walkerLocation!,
      widget.ownerLocation,
    );

    if (distance < 1) {
      return 15;
    }

    if (distance < 3) {
      return 13;
    }

    if (distance < 8) {
      return 11.5;
    }

    if (distance < 20) {
      return 10;
    }

    return 8.5;
  }

  // ==========================================================
  // OPEN OSM
  // ==========================================================

  Future<void> _openOpenStreetMap() async {
    final LatLng location =
        widget.ownerLocation;

    final Uri uri = Uri.parse(
      'https://www.openstreetmap.org/'
      '?mlat=${location.latitude}'
      '&mlon=${location.longitude}'
      '#map=16/'
      '${location.latitude}/'
      '${location.longitude}',
    );

    await launchUrl(
      uri,
      mode:
          LaunchMode.externalApplication,
    );
  }

  // ==========================================================
  // FORMAT DISTANCE
  // ==========================================================

  String _distanceText() {
    if (_distanceKm == null) {
      return '';
    }

    if (_distanceKm! < 1) {
      return '${(_distanceKm! * 1000).round()} m';
    }

    return '${_distanceKm!.toStringAsFixed(1)} km';
  }

  String _durationText() {
    if (_durationMinutes == null) {
      return '';
    }

    final int minutes =
        _durationMinutes!.round();

    if (minutes < 60) {
      return '$minutes min';
    }

    final int hours = minutes ~/ 60;
    final int remaining =
        minutes % 60;

    if (remaining == 0) {
      return '$hours hr';
    }

    return '$hours hr $remaining min';
  }

  String _locationUpdatedText() {
    final updated =
        _locationUpdatedAt;

    if (updated == null) {
      return '';
    }

    final day =
        updated.day
            .toString()
            .padLeft(2, '0');

    final month =
        updated.month
            .toString()
            .padLeft(2, '0');

    final hour =
        updated.hour
            .toString()
            .padLeft(2, '0');

    final minute =
        updated.minute
            .toString()
            .padLeft(2, '0');

    return 'Updated $day/$month/${updated.year} '
        '$hour:$minute';
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final bool hasWalker =
        _walkerLocation != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.55,
      maxChildSize: 0.97,
      expand: false,
      builder: (
        context,
        scrollController,
      ) {
        return Container(
          decoration:
              const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(26),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 9),

              // ------------------------------------------------
              // HANDLE
              // ------------------------------------------------

              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color:
                      Colors.grey.shade300,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 12),

              // ------------------------------------------------
              // HEADER
              // ------------------------------------------------

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration:
                          BoxDecoration(
                        color: Colors.blue
                            .withValues(
                          alpha: 0.10,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.route_rounded,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Text(
                            'Locations',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            hasWalker
                                ? 'Walker → Owner pickup route'
                                : 'Owner pickup location',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.of(
                        context,
                      ).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ------------------------------------------------
              // MAP
              // ------------------------------------------------

              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      22,
                    ),
                    child: Stack(
                      children: [
                        FlutterMap(
                          options:
                              MapOptions(
                            initialCenter:
                                _mapCenter(),
                            initialZoom:
                                _initialZoom(),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/'
                                  '{z}/{x}/{y}.png',
                              userAgentPackageName:
                                  'com.doojowalker.app',
                            ),

                            // ----------------------------------
                            // ROUTE
                            // ----------------------------------

                            if (_routePoints
                                    .length >=
                                2)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points:
                                        _routePoints,
                                    strokeWidth: 9,
                                    color:
                                        Colors.white,
                                  ),
                                  Polyline(
                                    points:
                                        _routePoints,
                                    strokeWidth: 5,
                                    color:
                                        Colors.blue,
                                  ),
                                ],
                              ),

                            // ----------------------------------
                            // MARKERS
                            // ----------------------------------

                            MarkerLayer(
                              markers: [
                                Marker(
                                  point:
                                      widget
                                          .ownerLocation,
                                  width: 74,
                                  height: 88,
                                  child:
                                      const _OwnerMarker(),
                                ),

                                if (_walkerLocation !=
                                    null)
                                  Marker(
                                    point:
                                        _walkerLocation!,
                                    width: 70,
                                    height: 84,
                                    child:
                                        const _WalkerMarker(),
                                  ),
                              ],
                            ),

                            RichAttributionWidget(
                              attributions: [
                                TextSourceAttribution(
                                  'OpenStreetMap contributors',
                                ),
                              ],
                            ),
                          ],
                        ),

                        // --------------------------------------
                        // ROUTE STATUS
                        // --------------------------------------

                        Positioned(
                          top: 12,
                          left: 12,
                          right: 12,
                          child:
                              _RouteInfoCard(
                            hasWalker:
                                hasWalker,
                            loading:
                                _routeLoading,
                            distance:
                                _distanceText(),
                            duration:
                                _durationText(),
                            error:
                                _routeError,
                          ),
                        ),

                        // --------------------------------------
                        // LEGEND
                        // --------------------------------------

                        Positioned(
                          left: 14,
                          bottom: 14,
                          child:
                              _MapLegend(
                            hasWalker:
                                hasWalker,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ------------------------------------------------
              // BOTTOM INFO
              // ------------------------------------------------

              SingleChildScrollView(
                controller:
                    scrollController,
                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  14,
                  18,
                  18,
                ),
                child: Column(
                  children: [
                    _LocationInfoRow(
                      icon:
                          Icons.home_rounded,
                      iconColor:
                          Colors.red,
                      title:
                          'Owner Pickup',
                      subtitle:
                          '${widget.ownerLocation.latitude.toStringAsFixed(5)}, '
                          '${widget.ownerLocation.longitude.toStringAsFixed(5)}',
                      trailing:
                          'Pickup',
                    ),

                    if (hasWalker) ...[
                      const SizedBox(
                        height: 8,
                      ),
                      _LocationInfoRow(
                        icon: Icons
                            .directions_walk_rounded,
                        iconColor:
                            Colors.green,
                        title: widget
                                    .walkerName
                                    ?.trim()
                                    .isNotEmpty ==
                                true
                            ? widget
                                .walkerName!
                                .trim()
                            : 'Walker',
                        subtitle:
                            '${_walkerLocation!.latitude.toStringAsFixed(5)}, '
                            '${_walkerLocation!.longitude.toStringAsFixed(5)}',
                        trailing:
                            'Live',
                      ),
                    ],

                    if (_locationUpdatedText()
                        .isNotEmpty) ...[
                      const SizedBox(
                        height: 8,
                      ),
                      _LocationInfoRow(
                        icon: Icons
                            .update_rounded,
                        iconColor:
                            Colors.green,
                        title:
                            'Location Update',
                        subtitle:
                            _locationUpdatedText(),
                        trailing:
                            'Live',
                      ),
                    ],

                    if (_routePoints.length >=
                        2) ...[
                      const SizedBox(
                        height: 8,
                      ),
                      _LocationInfoRow(
                        icon: Icons
                            .alt_route_rounded,
                        iconColor:
                            Colors.blue,
                        title:
                            'Walker Route',
                        subtitle:
                            '${_distanceText()}'
                            '${_durationText().isNotEmpty ? ' • ${_durationText()}' : ''}',
                        trailing:
                            'Road Route',
                      ),
                    ],

                    const SizedBox(
                      height: 14,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          OutlinedButton.icon(
                        onPressed:
                            _openOpenStreetMap,
                        icon: const Icon(
                          Icons.map_outlined,
                        ),
                        label:
                            const Text(
                          'Open in OpenStreetMap',
                        ),
                        style:
                            OutlinedButton
                                .styleFrom(
                          minimumSize:
                              const Size(
                            double.infinity,
                            48,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// OWNER MARKER
// ============================================================================

class _OwnerMarker
    extends StatelessWidget {
  const _OwnerMarker();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration:
              BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset:
                    const Offset(0, 4),
                color: Colors.black
                    .withValues(
                  alpha: 0.20,
                ),
              ),
            ],
          ),
          child: const Icon(
            Icons.home_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 7,
            vertical: 3,
          ),
          decoration:
              BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: Colors.black
                    .withValues(
                  alpha: 0.12,
                ),
              ),
            ],
          ),
          child: const Text(
            'Pickup',
            style: TextStyle(
              fontSize: 9,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// WALKER MARKER
// ============================================================================

class _WalkerMarker
    extends StatelessWidget {
  const _WalkerMarker();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration:
              BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset:
                    const Offset(0, 4),
                color: Colors.black
                    .withValues(
                  alpha: 0.20,
                ),
              ),
            ],
          ),
          child: const Icon(
            Icons.directions_walk_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 7,
            vertical: 3,
          ),
          decoration:
              BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: Colors.black
                    .withValues(
                  alpha: 0.12,
                ),
              ),
            ],
          ),
          child: const Text(
            'Walker',
            style: TextStyle(
              fontSize: 9,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ROUTE INFO CARD
// ============================================================================

class _RouteInfoCard
    extends StatelessWidget {
  const _RouteInfoCard({
    required this.hasWalker,
    required this.loading,
    required this.distance,
    required this.duration,
    required this.error,
  });

  final bool hasWalker;
  final bool loading;
  final String distance;
  final String duration;
  final String? error;

  @override
  Widget build(
    BuildContext context,
  ) {
    String title;
    String subtitle;

    if (!hasWalker) {
      title = 'Pickup location';
      subtitle =
          'Walker location not available';
    } else if (loading) {
      title = 'Finding road route...';
      subtitle = 'Please wait';
    } else if (error != null) {
      title = 'Route unavailable';
      subtitle = error!;
    } else if (distance.isNotEmpty) {
      title = distance;
      subtitle = duration.isNotEmpty
          ? 'Estimated drive time • $duration'
          : 'Road route to pickup';
    } else {
      title = 'Walker → Pickup';
      subtitle = 'Road route';
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset:
                const Offset(0, 5),
            color: Colors.black
                .withValues(
              alpha: 0.14,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration:
                BoxDecoration(
              color: hasWalker
                  ? Colors.blue
                      .withValues(
                    alpha: 0.10,
                  )
                  : Colors.red
                      .withValues(
                    alpha: 0.10,
                  ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasWalker
                  ? Icons.route_rounded
                  : Icons.location_on_rounded,
              size: 20,
              color: hasWalker
                  ? Colors.blue
                  : Colors.red,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors
                        .grey
                        .shade600,
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

// ============================================================================
// MAP LEGEND
// ============================================================================

class _MapLegend
    extends StatelessWidget {
  const _MapLegend({
    required this.hasWalker,
  });

  final bool hasWalker;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black
                .withValues(
              alpha: 0.12,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const _LegendItem(
            color: Colors.red,
            icon: Icons.home_rounded,
            text: 'Owner Pickup',
          ),
          if (hasWalker) ...[
            const SizedBox(height: 5),
            const _LegendItem(
              color: Colors.green,
              icon: Icons
                  .directions_walk_rounded,
              text: 'Walker',
            ),
            const SizedBox(height: 5),
            const _LegendItem(
              color: Colors.blue,
              icon:
                  Icons.route_rounded,
              text: 'Road Route',
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendItem
    extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.icon,
    required this.text,
  });

  final Color color;
  final IconData icon;
  final String text;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style:
              const TextStyle(
            fontSize: 10,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// LOCATION INFO ROW
// ============================================================================

class _LocationInfoRow
    extends StatelessWidget {
  const _LocationInfoRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(12),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color:
              Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(
              color:
                  iconColor.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors
                        .grey
                        .shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            trailing,
            style: TextStyle(
              fontSize: 10,
              fontWeight:
                  FontWeight.w800,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}
