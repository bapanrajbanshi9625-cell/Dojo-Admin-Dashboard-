import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class WalkRequestMapPreview extends StatelessWidget {
  final LatLng location;
  final VoidCallback? onOpenMaps;

  const WalkRequestMapPreview({
    super.key,
    required this.location,
    this.onOpenMaps,
  });

  // ==========================================================
  // OPEN OPENSTREETMAP
  // ==========================================================

  Future<void> _openOpenStreetMap() async {
    final uri = Uri.parse(
      'https://www.openstreetmap.org/?mlat='
      '${location.latitude}'
      '&mlon=${location.longitude}'
      '#map=18/'
      '${location.latitude}/'
      '${location.longitude}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ====================================================
          // OPENSTREETMAP PREVIEW
          // ====================================================

          SizedBox(
            height: 280,
            width: double.infinity,
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(16),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: location,
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'dojo_admin',
                  ),

                  MarkerLayer(
                    markers: [
                      Marker(
                        point: location,
                        width: 55,
                        height: 55,
                        child: const Icon(
                          Icons.location_pin,
                          size: 50,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ====================================================
          // COORDINATES
          // ====================================================

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(12),
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.my_location,
                  size: 18,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    '${location.latitude.toStringAsFixed(6)}, '
                    '${location.longitude.toStringAsFixed(6)}',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ====================================================
          // OPEN OPENSTREETMAP
          // ====================================================

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed:
                  _openOpenStreetMap,
              icon: const Icon(
                Icons.map_outlined,
              ),
              label: const Text(
                'Open in OpenStreetMap',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
