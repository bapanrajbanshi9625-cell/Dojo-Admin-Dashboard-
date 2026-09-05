import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveWalksMap extends StatelessWidget {
  const LiveWalksMap({
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
          return _buildContainer(
            context,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildContainer(
            context,
            child: _EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Unable to load live walks',
              subtitle: snapshot.error.toString(),
            ),
          );
        }

        final walks = <LiveWalkData>[];

        for (final document in snapshot.data?.docs ?? []) {
          final data = document.data();

          final walkerLocation = _readLocation(
            data,
            const [
              'walkerLocation',
              'currentLocation',
              'walker_location',
              'current_location',
            ],
          );

          if (walkerLocation == null) {
            continue;
          }

          final ownerLocation = _readLocation(
            data,
            const [
              'ownerLocation',
              'pickupLocation',
              'owner_location',
              'pickup_location',
              'location',
            ],
          );

          walks.add(
            LiveWalkData(
              id: document.id,
              data: data,
              walkerLocation: walkerLocation,
              ownerLocation: ownerLocation,
            ),
          );
        }

        return _buildContainer(
          context,
          child: _LiveWalksMapCard(
            walks: walks,
          ),
        );
      },
    );
  }

  Widget _buildContainer(
    BuildContext context, {
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      height: 340,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xffe5e7eb),
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            offset: Offset(0, 8),
            color: Color(0x12000000),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  static LatLng? _readLocation(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      final location = _parseLocation(value);

      if (location != null) {
        return location;
      }
    }

    final latitude = _toDouble(
      data['latitude'] ??
          data['lat'] ??
          data['currentLatitude'] ??
          data['currentLat'],
    );

    final longitude = _toDouble(
      data['longitude'] ??
          data['lng'] ??
          data['lon'] ??
          data['currentLongitude'] ??
          data['currentLng'],
    );

    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    }

    return null;
  }

  static LatLng? _parseLocation(dynamic value) {
    if (value is GeoPoint) {
      return LatLng(
        value.latitude,
        value.longitude,
      );
    }

    if (value is Map) {
      final latitude = _toDouble(
        value['latitude'] ??
            value['lat'] ??
            value['currentLatitude'] ??
            value['currentLat'],
      );

      final longitude = _toDouble(
        value['longitude'] ??
            value['lng'] ??
            value['lon'] ??
            value['currentLongitude'] ??
            value['currentLng'],
      );

      if (latitude != null && longitude != null) {
        return LatLng(latitude, longitude);
      }
    }

    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }
}

class LiveWalkData {
  const LiveWalkData({
    required this.id,
    required this.data,
    required this.walkerLocation,
    this.ownerLocation,
  });

  final String id;
  final Map<String, dynamic> data;
  final LatLng walkerLocation;
  final LatLng? ownerLocation;

  String get walkerName {
    return _stringValue(
          data['walkerName'],
        ) ??
        _stringValue(
          data['walker_name'],
        ) ??
        'Walker';
  }

  String get ownerName {
    return _stringValue(
          data['ownerName'],
        ) ??
        _stringValue(
          data['owner_name'],
        ) ??
        'Owner';
  }

  static String? _stringValue(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty) return null;

    return text;
  }
}

class _LiveWalksMapCard extends StatelessWidget {
  const _LiveWalksMapCard({
    required this.walks,
  });

  final List<LiveWalkData> walks;

  @override
  Widget build(BuildContext context) {
    if (walks.isEmpty) {
      return Stack(
        children: [
          const _EmptyState(
            icon: Icons.location_off_rounded,
            title: 'No live walks',
            subtitle: 'Active walks with a valid location will appear here.',
          ),
          Positioned(
            top: 16,
            right: 16,
            child: _MapButton(
              onPressed: () => _openLargeMap(context),
              label: 'Open Map',
            ),
          ),
        ],
      );
    }

    final points = <LatLng>[];

    for (final walk in walks) {
      points.add(walk.walkerLocation);

      if (walk.ownerLocation != null) {
        points.add(walk.ownerLocation!);
      }
    }

    final center = points.first;

    return Stack(
      children: [
        IgnorePointer(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 11.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.dojo.admin',
              ),
              MarkerLayer(
                markers: [
                  for (int i = 0; i < walks.length; i++)
                    Marker(
                      point: walks[i].walkerLocation,
                      width: 42,
                      height: 52,
                      child: _WalkerMarker(
                        number: i + 1,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // Gradient overlay
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 100,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Header
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.map_rounded,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${walks.length} Live Walk${walks.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _MapButton(
                onPressed: () => _openLargeMap(context),
                label: 'Expand',
              ),
            ],
          ),
        ),

        // Bottom legend
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Row(
            children: [
              _LegendItem(
                icon: Icons.directions_walk_rounded,
                label: 'Walker',
              ),
              const SizedBox(width: 8),
              const _LegendItem(
                icon: Icons.location_on_rounded,
                label: 'Pickup',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openLargeMap(BuildContext context) async {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 700) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return DraggableScrollableSheet(
            initialChildSize: 0.90,
            minChildSize: 0.70,
            maxChildSize: 0.98,
            expand: false,
            builder: (context, scrollController) {
              return _LargeLiveWalkMap(
                walks: walks,
              );
            },
          );
        },
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1150,
              maxHeight: 820,
            ),
            child: _LargeLiveWalkMap(
              walks: walks,
            ),
          ),
        );
      },
    );
  }
}

class _LargeLiveWalkMap extends StatefulWidget {
  const _LargeLiveWalkMap({
    required this.walks,
  });

  final List<LiveWalkData> walks;

  @override
  State<_LargeLiveWalkMap> createState() => _LargeLiveWalkMapState();
}

class _LargeLiveWalkMapState extends State<_LargeLiveWalkMap> {
  final MapController _mapController = MapController();

  final Map<String, List<LatLng>> _routes = {};

  bool _loadingRoutes = false;
  bool _didFitMap = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitMap();
      _loadRoutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final points = <LatLng>[];

    for (final walk in widget.walks) {
      points.add(walk.walkerLocation);

      if (walk.ownerLocation != null) {
        points.add(walk.ownerLocation!);
      }

      final route = _routes[walk.id];

      if (route != null) {
        points.addAll(route);
      }
    }

    if (points.isEmpty) {
      points.add(
        const LatLng(
          28.6139,
          77.2090,
        ),
      );
    }

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
                    initialCenter: points.first,
                    initialZoom: 12,
                    onMapReady: _fitMap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.dojo.admin',
                    ),

                    // Routes
                    if (_routes.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          for (final entry in _routes.entries)
                            if (entry.value.length >= 2)
                              Polyline(
                                points: entry.value,
                                strokeWidth: 4,
                                color: Colors.blue.withValues(
                                  alpha: 0.70,
                                ),
                              ),
                        ],
                      ),

                    // Owner pickup markers
                    MarkerLayer(
                      markers: [
                        for (int i = 0; i < widget.walks.length; i++)
                          if (widget.walks[i].ownerLocation != null)
                            Marker(
                              point:
                                  widget.walks[i].ownerLocation!,
                              width: 46,
                              height: 58,
                              child: _OwnerMarker(
                                number: i + 1,
                              ),
                            ),
                      ],
                    ),

                    // Walker markers
                    MarkerLayer(
                      markers: [
                        for (int i = 0; i < widget.walks.length; i++)
                          Marker(
                            point:
                                widget.walks[i].walkerLocation,
                            width: 46,
                            height: 58,
                            child: _WalkerMarker(
                              number: i + 1,
                              large: true,
                            ),
                          ),
                      ],
                    ),

                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () async {
                            final uri = Uri.parse(
                              'https://www.openstreetmap.org/copyright',
                            );

                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                Positioned(
                  right: 16,
                  top: 16,
                  child: Column(
                    children: [
                      _MapControlButton(
                        icon: Icons.add_rounded,
                        onPressed: () {
                          final camera =
                              _mapController.camera;

                          _mapController.move(
                            camera.center,
                            camera.zoom + 1,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _MapControlButton(
                        icon: Icons.remove_rounded,
                        onPressed: () {
                          final camera =
                              _mapController.camera;

                          _mapController.move(
                            camera.center,
                            camera.zoom - 1,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _MapControlButton(
                        icon: Icons.fit_screen_rounded,
                        onPressed: _fitMap,
                      ),
                    ],
                  ),
                ),

                Positioned(
                  left: 16,
                  bottom: 16,
                  child: _MapLegendCard(
                    walkCount: widget.walks.length,
                    loadingRoutes: _loadingRoutes,
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
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xffe5e7eb),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xfffff4ed),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Color(0xfff97316),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Walk Map',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${widget.walks.length} active walk${widget.walks.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff6b7280),
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
            icon: const Icon(
              Icons.close_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadRoutes() async {
    if (_loadingRoutes) return;

    final routeWalks = widget.walks
        .where(
          (walk) => walk.ownerLocation != null,
        )
        .toList();

    if (routeWalks.isEmpty) {
      return;
    }

    setState(() {
      _loadingRoutes = true;
    });

    try {
      for (final walk in routeWalks) {
        if (!mounted) return;

        final owner = walk.ownerLocation!;

        final route = await _getRoute(
          walker: walk.walkerLocation,
          owner: owner,
        );

        if (route != null && route.length >= 2) {
          _routes[walk.id] = route;

          if (mounted) {
            setState(() {});
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingRoutes = false;
        });

        _fitMap();
      }
    }
  }

  Future<List<LatLng>?> _getRoute({
    required LatLng walker,
    required LatLng owner,
  }) async {
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${walker.longitude},${walker.latitude};'
      '${owner.longitude},${owner.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        return null;
      }

      final body = jsonDecode(response.body);

      final routes = body['routes'];

      if (routes is! List || routes.isEmpty) {
        return null;
      }

      final geometry =
          routes.first['geometry'];

      if (geometry is! Map) {
        return null;
      }

      final coordinates =
          geometry['coordinates'];

      if (coordinates is! List) {
        return null;
      }

      final result = <LatLng>[];

      for (final coordinate in coordinates) {
        if (coordinate is! List ||
            coordinate.length < 2) {
          continue;
        }

        final longitude =
            (coordinate[0] as num).toDouble();

        final latitude =
            (coordinate[1] as num).toDouble();

        result.add(
          LatLng(
            latitude,
            longitude,
          ),
        );
      }

      return result;
    } catch (_) {
      return null;
    }
  }

  void _fitMap() {
    if (!mounted) return;

    final points = <LatLng>[];

    for (final walk in widget.walks) {
      points.add(walk.walkerLocation);

      if (walk.ownerLocation != null) {
        points.add(walk.ownerLocation!);
      }

      final route = _routes[walk.id];

      if (route != null) {
        points.addAll(route);
      }
    }

    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController.move(
        points.first,
        14,
      );
      return;
    }

    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(70),
          maxZoom: 15,
        ),
      );

      _didFitMap = true;
    } catch (_) {
      if (!_didFitMap) {
        _mapController.move(
          points.first,
          12,
        );
      }
    }
  }
}

class _WalkerMarker extends StatelessWidget {
  const _WalkerMarker({
    required this.number,
    this.large = false,
  });

  final int number;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 40.0 : 34.0;

    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xff16a34a),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 8,
                offset: Offset(0, 3),
                color: Color(0x45000000),
              ),
            ],
          ),
          child: Icon(
            Icons.directions_walk_rounded,
            color: Colors.white,
            size: large ? 21 : 18,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 1,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x25000000),
              ),
            ],
          ),
          child: Text(
            'W$number',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _OwnerMarker extends StatelessWidget {
  const _OwnerMarker({
    required this.number,
  });

  final int number;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xffdc2626),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 8,
                offset: Offset(0, 3),
                color: Color(0x45000000),
              ),
            ],
          ),
          child: const Icon(
            Icons.location_on_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 1,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x25000000),
              ),
            ],
          ),
          child: Text(
            'P$number',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.onPressed,
    required this.label,
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.open_in_full_rounded,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
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

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  const _LegendItem._({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x25000000),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapLegendCard extends StatelessWidget {
  const _MapLegendCard({
    required this.walkCount,
    required this.loadingRoutes,
  });

  final int walkCount;
  final bool loadingRoutes;

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
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0, 4),
            color: Color(0x30000000),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SmallLegendDot(
            icon: Icons.location_on_rounded,
            label: 'Pickup',
          ),
          const SizedBox(width: 12),
          const _SmallLegendDot(
            icon: Icons.directions_walk_rounded,
            label: 'Walker',
          ),
          if (loadingRoutes) ...[
            const SizedBox(width: 12),
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ],
          const SizedBox(width: 12),
          Text(
            '$walkCount',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallLegendDot extends StatelessWidget {
  const _SmallLegendDot({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 42,
              color: const Color(0xff9ca3af),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xff6b7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
