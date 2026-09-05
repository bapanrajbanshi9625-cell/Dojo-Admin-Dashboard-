import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

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
          return _MapPreviewCard(
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return _MapPreviewCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load live walk locations.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
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
                child: _MiniMap(walks: walks),
              ),

              Positioned(
                top: 14,
                left: 14,
                child: _MapStatusBadge(count: walks.length),
              ),

              Positioned(
                right: 14,
                bottom: 14,
                child: FilledButton.icon(
                  onPressed: walks.isEmpty
                      ? null
                      : () {
                          _openFullMap(context, walks);
                        },
                  icon: const Icon(Icons.open_in_full, size: 18),
                  label: const Text('Open Live Map'),
                ),
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1100,
                maxHeight: 800,
              ),
              child: _FullLiveMap(walks: walks),
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
              child: _FullLiveMap(walks: walks),
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
          return GeoPoint(lat, lng);
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
      return GeoPoint(lat, lng);
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

class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 330,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 7),
            color: Colors.black.withValues(alpha: 0.07),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

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
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withValues(alpha: 0.12),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count active ${count == 1 ? 'walk' : 'walks'}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

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
            TextSourceAttribution(
              'OpenStreetMap contributors',
            ),
          ],
        ),
      ],
    );
  }
}

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
            LatLng(lat, lng),
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
        points.add(walk.walkerLatLng!);
      }

      if (walk.ownerLatLng != null) {
        points.add(walk.ownerLatLng!);
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
                            color: Colors.blue,
                          );
                        }).toList(),
                      ),

                    MarkerLayer(
                      markers: _buildMarkers(widget.walks),
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

                Positioned(
                  left: 16,
                  bottom: 16,
                  child: _MapLegend(),
                ),

                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'zoom_in',
                        onPressed: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom + 1,
                          );
                        },
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'zoom_out',
                        onPressed: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom - 1,
                          );
                        },
                        child: const Icon(Icons.remove),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'fit_all',
                        onPressed: _fitAll,
                        child: const Icon(Icons.fit_screen),
                      ),
                    ],
                  ),
                ),

                if (_loadingRoutes)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
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
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Loading routes...',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Walk Map',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Walker locations, pickup points and routes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withValues(alpha: 0.13),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendItem(
            icon: Icons.location_on,
            label: 'Pickup',
            iconColor: Colors.red,
          ),
          SizedBox(width: 14),
          _LegendItem(
            icon: Icons.directions_walk,
            label: 'Walker',
            iconColor: Colors.green,
          ),
          SizedBox(width: 14),
          _LegendItem(
            icon: Icons.route,
            label: 'Route',
            iconColor: Colors.blue,
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
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 17,
          color: iconColor,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

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

LatLng _initialCenter(List<_LiveWalkData> walks) {
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
            backgroundColor: Colors.red,
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
            backgroundColor: Colors.green,
          ),
        ),
      );
    }
  }

  return markers;
}

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
              blurRadius: 8,
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
