import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'dashboard_components.dart';

class DashboardLiveMap extends StatelessWidget {
  const DashboardLiveMap({
    super.key,
    required this.activeWalksStream,
  });

  final Stream<QuerySnapshot<Map<String, dynamic>>> activeWalksStream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: activeWalksStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _MapPreviewCard(
            child: _MapLoadingState(),
          );
        }

        if (snapshot.hasError) {
          return const _MapPreviewCard(
            child: _MapErrorState(),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        final walks = <_LiveWalkData>[];

        for (final doc in docs) {
          final data = doc.data();

          final walkerLocation = _readGeoPoint(
            data,
            const [
              'walkerLocation',
              'currentLocation',
              'walker_location',
              'current_location',
            ],
          );

          final ownerLocation = _readGeoPoint(
            data,
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

          walks.add(
            _LiveWalkData(
              walkId: doc.id,
              walkerLocation: walkerLocation,
              ownerLocation: ownerLocation,
              walkerName: _readString(
                data,
                const ['walkerName', 'walker_name'],
              ),
              ownerName: _readString(
                data,
                const ['ownerName', 'owner_name'],
              ),
            ),
          );
        }

        return _MapPreviewCard(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: _MiniMap(
                  walks: walks,
                ),
              ),

              /// Top status
              Positioned(
                top: 14,
                left: 14,
                child: _MapStatusBadge(
                  count: walks.length,
                ),
              ),

              /// Map controls / open button
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
                            walks,
                          );
                        },
                ),
              ),

              /// Empty state overlay
              if (walks.isEmpty)
                const Positioned.fill(
                  child: _MapEmptyOverlay(),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openFullMap(
    BuildContext context,
    List<_LiveWalkData> walks,
  ) {
    final width = MediaQuery.sizeOf(context).width;

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
              child: _FullLiveMap(
                walks: walks,
              ),
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
              child: _FullLiveMap(
                walks: walks,
              ),
            ),
          );
        },
      );
    }
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
                    'No active walk locations available',
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
            '$count active ${count == 1 ? 'walk' : 'walks'}',
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
    required this.walks,
  });

  final List<_LiveWalkData> walks;

  @override
  State<_FullLiveMap> createState() => _FullLiveMapState();
}

class _FullLiveMapState extends State<_FullLiveMap> {
  final MapController _mapController = MapController();

  final Map<String, List<LatLng>> _routes = {};

  bool _loadingRoutes = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadRoutes());
  }

  Future<void> _loadRoutes() async {
    final routeTasks = <Future<void>>[];

    for (final walk in widget.walks) {
      final walker = walk.walkerLatLng;
      final owner = walk.ownerLatLng;

      if (walker == null || owner == null) {
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

      final json = jsonDecode(response.body);

      if (json is! Map) {
        return;
      }

      final routes = json['routes'];

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
      // Route failure should not break the live map.
    }
  }

  void _fitAll() {
    final points = <LatLng>[];

    for (final walk in widget.walks) {
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

    final bounds = LatLngBounds.fromPoints(points);

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
                    initialCenter: _initialCenter(widget.walks),
                    initialZoom: 11,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.doojowalker.app',
                    ),

                    if (_routes.isNotEmpty)
                      PolylineLayer(
                        polylines: _routes.entries.map((entry) {
                          return Polyline(
                            points: entry.value,
                            strokeWidth: 5,
                            color: blue,
                          );
                        }).toList(),
                      ),

                    MarkerLayer(
                      markers: _buildMarkers(
                        widget.walks,
                      ),
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

                /// Legend
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: const _MapLegend(),
                ),

                /// Map controls
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
                    onFitAll: _fitAll,
                  ),
                ),

                /// Route loading
                if (_loadingRoutes)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _RouteLoadingBadge(),
                  ),

                /// Active count
                Positioned(
                  top: 16,
                  left: 16,
                  child: _FullMapActiveBadge(
                    count: widget.walks.length,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
/// FULL MAP ACTIVE BADGE
/// ===============================================================

class _FullMapActiveBadge extends StatelessWidget {
  const _FullMapActiveBadge({
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
            '$count active',
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
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFitAll;

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
            tooltip: 'Fit all walks',
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
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              icon,
              color: dark,
              size: 19,
            ),
          ),
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
    final compact = MediaQuery.sizeOf(context).width < 600;

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
